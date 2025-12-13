import os
import json
from datetime import datetime, timezone

from flask import Flask, request, jsonify, render_template, session
from pymongo import MongoClient, ASCENDING, DESCENDING
import redis

from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Session secret (override in .env / Kubernetes Secret)
app.secret_key = os.getenv("FLASK_SECRET", "dev-secret-change-me")

MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongo:27017/chatdb")
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
CACHE_LIMIT = int(os.getenv("CACHE_LIMIT", "50"))

mongo_client = MongoClient(MONGO_URI)
# Explicit DB name (safe)
db = mongo_client["chatdb"]
messages_col = db["messages"]

# index for fast room queries
messages_col.create_index([("room", ASCENDING), ("created_at", DESCENDING)])

r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

REQ_COUNT = Counter("http_requests_total", "Total HTTP requests", ["method", "path", "status"])
REQ_LAT = Histogram("http_request_latency_seconds", "Request latency", ["path"])


def cache_key(room: str) -> str:
    return f"messages:{room}"


@app.get("/")
def home():
    return render_template("index.html")


@app.post("/join")
def join():
    data = request.get_json(force=True)
    nickname = (data.get("nickname") or "").strip()
    room = (data.get("room") or "global").strip() or "global"

    if not nickname:
        return jsonify({"error": "nickname required"}), 400

    session["nickname"] = nickname
    session["room"] = room

    return jsonify({"ok": True, "nickname": nickname, "room": room}), 200


@app.get("/health")
def health():
    try:
        mongo_client.admin.command("ping")
        r.ping()
        return jsonify({"status": "ok"}), 200
    except Exception as e:
        return jsonify({"status": "error", "detail": str(e)}), 500


@app.get("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


@app.get("/messages")
def get_messages():
    with REQ_LAT.labels(path="/messages").time():
        room = (request.args.get("room") or session.get("room") or "global").strip()
        limit = int(request.args.get("limit", CACHE_LIMIT))

        key = cache_key(room)

        # try cache first
        cached = r.lrange(key, 0, limit - 1)
        if cached:
            resp = [json.loads(x) for x in cached]
            REQ_COUNT.labels(method="GET", path="/messages", status="200").inc()
            return jsonify(resp), 200

        # fallback to mongo
        docs = list(
            messages_col.find({"room": room}, {"_id": 0})
            .sort("created_at", DESCENDING)
            .limit(limit)
        )
        docs.reverse()  # oldest -> newest

        # populate cache (newest at head)
        pipe = r.pipeline()
        pipe.delete(key)
        for msg in reversed(docs):
            pipe.lpush(key, json.dumps(msg))
        pipe.ltrim(key, 0, CACHE_LIMIT - 1)
        pipe.execute()

        REQ_COUNT.labels(method="GET", path="/messages", status="200").inc()
        return jsonify(docs), 200


@app.post("/messages")
def post_message():
    with REQ_LAT.labels(path="/messages").time():
        data = request.get_json(force=True)

        room = (data.get("room") or session.get("room") or "global").strip()
        nickname = (data.get("nickname") or session.get("nickname") or "").strip()
        text = (data.get("text") or "").strip()

        if not nickname or not text:
            REQ_COUNT.labels(method="POST", path="/messages", status="400").inc()
            return jsonify({"error": "nickname and text are required"}), 400

        msg = {
            "room": room,
            "nickname": nickname,
            "text": text,
            "created_at": datetime.now(timezone.utc).isoformat()
        }

        # Insert into Mongo, capture inserted_id safely
        result = messages_col.insert_one(msg)
        msg["_id"] = str(result.inserted_id)

        # Decide what we store/return (keep it simple: do not expose _id)
        msg_for_client = dict(msg)
        msg_for_client.pop("_id", None)

        # update cache: keep newest at head
        key = cache_key(room)
        pipe = r.pipeline()
        pipe.lpush(key, json.dumps(msg_for_client))
        pipe.ltrim(key, 0, CACHE_LIMIT - 1)
        pipe.execute()

        # publish event (good for scaling later)
        r.publish(f"room:{room}", json.dumps(msg_for_client))

        REQ_COUNT.labels(method="POST", path="/messages", status="201").inc()
        return jsonify(msg_for_client), 201
