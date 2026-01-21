#!/usr/bin/env bash
set -euo pipefail

cd /opt/ComfyUI

args=(--listen --port 8188)

use_cpu=0
if [ "${COMFYUI_FORCE_CPU:-}" = "1" ]; then
  use_cpu=1
elif [ "${NVIDIA_VISIBLE_DEVICES:-}" = "void" ] || [ "${NVIDIA_VISIBLE_DEVICES:-}" = "none" ]; then
  use_cpu=1
elif [ ! -e /dev/nvidiactl ] && [ ! -e /dev/nvidia0 ]; then
  use_cpu=1
fi

if [ "${use_cpu}" -eq 1 ]; then
  args+=(--cpu)
fi

exec python3 main.py "${args[@]}" "$@"
