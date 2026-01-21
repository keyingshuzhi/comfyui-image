#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-18188}"
NAME="${2:-comfyui_smoke}"

if [ -z "${IMAGE_UNDER_TEST:-}" ]; then
  echo "ERROR: IMAGE_UNDER_TEST env var required"
  exit 2
fi

GPU_ARGS=()
if [ "${HEALTHCHECK_GPU:-}" = "1" ]; then
  GPU_ARGS+=(--gpus all)
fi

ENV_ARGS=()
if [ -n "${COMFYUI_FORCE_CPU:-}" ]; then
  ENV_ARGS+=(-e "COMFYUI_FORCE_CPU=${COMFYUI_FORCE_CPU}")
fi

echo "[healthcheck] starting container ${NAME} on port ${PORT} using image ${IMAGE_UNDER_TEST} ..."

# Cleanup any previous container with same name
docker rm -f "${NAME}" >/dev/null 2>&1 || true

# IMPORTANT: do NOT use --rm, so we can fetch logs if it crashes
if ! docker run -d \
  --name "${NAME}" \
  -p "127.0.0.1:${PORT}:8188" \
  "${GPU_ARGS[@]}" \
  "${ENV_ARGS[@]}" \
  "${IMAGE_UNDER_TEST}" >/dev/null; then
  echo "[healthcheck] FAILED: docker run failed"
  exit 1
fi

# Wait until endpoint is reachable OR container stops
for i in $(seq 1 45); do
  # If container exited, show logs and fail fast
  if ! docker ps -q -f "name=^/${NAME}$" | grep -q .; then
    echo "[healthcheck] FAILED: container exited before becoming ready"
    echo "--- container logs (last 200 lines) ---"
    docker logs --tail 200 "${NAME}" || true
    docker rm -f "${NAME}" >/dev/null 2>&1 || true
    exit 1
  fi

  # If endpoint reachable, success
  if curl -fsS "http://127.0.0.1:${PORT}/" >/dev/null 2>&1; then
    echo "[healthcheck] OK: endpoint reachable"
    docker rm -f "${NAME}" >/dev/null 2>&1 || true
    exit 0
  fi

  sleep 1
done

echo "[healthcheck] FAILED: endpoint not reachable within timeout"
echo "--- container logs (last 200 lines) ---"
docker logs --tail 200 "${NAME}" || true
docker rm -f "${NAME}" >/dev/null 2>&1 || true
exit 1
