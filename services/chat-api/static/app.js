let currentRoom = "global";
let nickname = "";

const joinBox = document.getElementById("joinBox");
const chatBox = document.getElementById("chatBox");
const joinStatus = document.getElementById("joinStatus");
const whoami = document.getElementById("whoami");
const messagesDiv = document.getElementById("messages");

function setHidden(el, hidden) {
  el.classList.toggle("hidden", hidden);
}

async function join() {
  nickname = document.getElementById("nickname").value.trim();
  currentRoom = (document.getElementById("room").value.trim() || "global");

  if (!nickname) {
    joinStatus.textContent = "Nickname is required.";
    return;
  }

  const res = await fetch("/join", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({ nickname, room: currentRoom })
  });

  const data = await res.json();
  if (!res.ok) {
    joinStatus.textContent = data.error || "Join failed";
    return;
  }

  joinStatus.textContent = "";
  whoami.textContent = `You are ${data.nickname} in room "${data.room}"`;
  setHidden(joinBox, true);
  setHidden(chatBox, false);

  await loadMessages();
}

async function sendMessage() {
  const textEl = document.getElementById("text");
  const text = textEl.value.trim();
  if (!text) return;

  const res = await fetch("/messages", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({ room: currentRoom, text })
  });

  if (res.ok) {
    textEl.value = "";
    await loadMessages();
  } else {
    const err = await res.text();
    alert("Send failed: " + err);
  }
}

function renderMessages(list) {
  messagesDiv.innerHTML = "";
  for (const m of list) {
    const div = document.createElement("div");
    div.className = "msg";
    div.innerHTML = `<b>${escapeHtml(m.nickname)}</b>: ${escapeHtml(m.text)}
      <span class="time">${new Date(m.created_at).toLocaleString()}</span>`;
    messagesDiv.appendChild(div);
  }
  messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

async function loadMessages() {
  const res = await fetch(`/messages?room=${encodeURIComponent(currentRoom)}&limit=50`);
  const data = await res.json();
  renderMessages(data);
}

function escapeHtml(s) {
  return (s || "").replace(/[&<>"']/g, c => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[c]));
}

document.getElementById("joinBtn").addEventListener("click", join);
document.getElementById("sendBtn").addEventListener("click", sendMessage);
document.getElementById("text").addEventListener("keydown", (e) => {
  if (e.key === "Enter") sendMessage();
});

setInterval(() => {
  if (!chatBox.classList.contains("hidden")) loadMessages();
}, 2000);
