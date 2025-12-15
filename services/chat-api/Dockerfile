# Stage 1: Builder
FROM python:3.11-slim as builder

WORKDIR /app

# Install build dependencies (if any needed for python packages)
RUN apt-get update && apt-get install -y --no-install-recommends gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
# Install dependencies to a local user directory
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

WORKDIR /app

# Create a non-root user for security
RUN useradd -m appuser
USER appuser

# Copy installed packages from builder stage
COPY --from=builder /root/.local /home/appuser/.local
# Update PATH to include user installed packages
ENV PATH=/home/appuser/.local/bin:$PATH

COPY . .

EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app", "--workers", "2"]
