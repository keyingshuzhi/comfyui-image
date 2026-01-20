#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-18188}"
NAME="${2:-comfyui_smoke}"

echo "[healthcheck] starting container on port ${PORT} ..."
docker rm -f "${NAME}" >/dev/null 2>&1 || true

docker run -d --rm \
  --name "${NAME}" \
  -p "${PORT}:8188" \
  "${IMAGE_UNDER_TEST:?IMAGE_UNDER_TEST env var required}" >/dev/null

# wait a bit for startup
for i in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${PORT}/" >/dev/null 2>&1; then
    echo "[healthcheck] OK: UI endpoint reachable"
    docker rm -f "${NAME}" >/dev/null 2>&1 || true
    exit 0
  fi
  sleep 1
done

echo "[healthcheck] FAILED: endpoint not reachable"
echo "--- container logs (last 200 lines) ---"
docker logs --tail 200 "${NAME}" || true
docker rm -f "${NAME}" >/dev/null 2>&1 || true
exit 1