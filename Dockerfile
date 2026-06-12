FROM ghcr.io/astral-sh/uv:python3.11-alpine

ENV ENV_MODE production
ENV SUPABASE_URL="https://nsdeksbfidghdjnuwmke.supabase.co"
ENV SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zZGVrc2JmaWRnaGRqbnV3bWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyODExNTksImV4cCI6MjA5Njg1NzE1OX0.7HSHkTCDj6Wsasf8cq7uGfe2heI7VLkfQdIuEWuZulA"
ENV SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zZGVrc2JmaWRnaGRqbnV3bWtlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTI4MTE1OSwiZXhwIjoyMDk2ODU3MTU5fQ.g8L3cWSgfpFAVduRLAF60Sqkoddy9W0biUR7zZoDeI8"
ENV REDIS_HOST="redis"
ENV REDIS_PORT="6379"
ENV REDIS_PASSWORD=""
ENV REDIS_SSL="false"
ENV RABBITMQ_HOST="rabbitmq"
ENV RABBITMQ_PORT="5672"
ENV ANTHROPIC_API_KEY="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"
ENV OPENAI_API_KEY="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"
ENV MODEL_TO_USE="openai/gpt-4o-mini"
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_REGION_NAME=""
ENV GROQ_API_KEY="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"
ENV OPENROUTER_API_KEY="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"
ENV RAPID_API_KEY=""
ENV TAVILY_API_KEY="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"
ENV FIRECRAWL_API_KEY="fc-386d4705528f41379f22108b4276ad7a"
ENV FIRECRAWL_URL="https://api.firecrawl.dev"
ENV DAYTONA_API_KEY="dtn_8080170f5ff1eeae898c84087c27c12e47ba5b4708cdea7fcd401d525cc7e930"
ENV DAYTONA_SERVER_URL="https://app.daytona.io/api"
ENV DAYTONA_TARGET="us"
ENV LANGFUSE_PUBLIC_KEY="pk-REDACTED"
ENV LANGFUSE_SECRET_KEY="sk-REDACTED"
ENV LANGFUSE_HOST="https://cloud.langfuse.com"
ENV SMITHERY_API_KEY="93e4602c-dff1-4e91-84b8-815ec04b2785"
ENV MCP_CREDENTIAL_ENCRYPTION_KEY="S6QUrKNOeKt__SSxYVtAO1dLrVfFLKOV7d4-PKh1aNo="
ENV QSTASH_CURRENT_SIGNING_KEY="sig_58ByUgN5aCy27VGiY4vW2EZosHh9"
ENV QSTASH_NEXT_SIGNING_KEY="sig_5TK5CMUZW313ecc1GRUo22ahuLPr"
ENV QSTASH_TOKEN="eyJVc2VySUQiOiI2MDc3MTliZS02ZjFlLTQyMGUtYjBmNi0yMTliMjA2NTIyOTAiLCJQYXNzd29yZCI6IjIxZjA1ZWI2ODYxMDQzYTdiNjViODhmNDQ2MTAwZGVhIn0="
ENV QSTASH_URL="https://qstash.upstash.io"

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
