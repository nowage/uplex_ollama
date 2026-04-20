#!/bin/bash
set -e

/bin/ollama serve &
OLLAMA_PID=$!

until ollama list >/dev/null 2>&1; do
  echo "[entrypoint] waiting for ollama..."
  sleep 2
done
echo "[entrypoint] ollama is up"

if [ -n "$OLLAMA_MODEL" ]; then
  ollama pull "$OLLAMA_MODEL" || echo "[entrypoint] WARNING: model pull failed: $OLLAMA_MODEL"
fi

mkdir -p /root/.claude
cat > /root/.claude/settings.json <<JSON
{
  "model": "${OLLAMA_MODEL:-}",
  "env": {
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:11434",
    "ANTHROPIC_AUTH_TOKEN": "ollama"
  }
}
JSON

exec "$@"
