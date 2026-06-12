#!/bin/bash
set -e

echo "Starting Dramatiq worker..."
uv run dramatiq --processes 2 --threads 2 run_agent_background &

echo "Starting FastAPI on port 7860..."
exec uv run uvicorn api:app --host 0.0.0.0 --port 7860
