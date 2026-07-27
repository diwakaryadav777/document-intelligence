#!/bin/bash
# Start the LedgerLens FastAPI backend
cd "$(dirname "$0")"
export PYTHONPATH="$(pwd)"
uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
