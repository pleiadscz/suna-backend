FROM ghcr.io/astral-sh/uv:python3.11-alpine

ENV ENV_MODE production
WORKDIR /app

ARG RAILWAY_SERVICE_ID
ENV SERVICE_ID=$RAILWAY_SERVICE_ID

RUN echo ${SERVICE_ID}

# Install Python dependencies
COPY pyproject.toml uv.lock ./
ENV UV_LINK_MODE=copy

# RUN --mount=type=cache,id=s/b1d29d5f-69d0-40cc-bb64-bfabdb5063a0-/root/.cache/uv,target=/root/.cache/uv uv sync --locked --quiet

# Copy application code
COPY . .

# Calculate optimal worker count based on 16 vCPUs
# Using (2*CPU)+1 formula for CPU-bound applications
ENV WORKERS=33
ENV THREADS=2
ENV WORKER_CONNECTIONS=2000

ENV PYTHONPATH=/app
EXPOSE 8080

# Gunicorn configuration
CMD ["sh", "-c", "uv run gunicorn api:app \
  --workers $WORKERS \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8080 \
  --timeout 1800 \
  --graceful-timeout 600 \
  --keep-alive 1800 \
  --max-requests 0 \
  --max-requests-jitter 0 \
  --forwarded-allow-ips '*' \
  --worker-connections $WORKER_CONNECTIONS \
  --worker-tmp-dir /dev/shm \
  --preload \
  --log-level info \
  --access-logfile - \
  --error-logfile - \
  --capture-output \
  --enable-stdio-inheritance \
  --threads $THREADS"]
