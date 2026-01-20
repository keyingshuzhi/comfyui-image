# comfyui-image: CPU baseline (mac/docker friendly)
# - Builds ComfyUI from an upstream tag/commit (COMFYUI_REF)
# - Keeps runtime minimal; models/nodes/workflows are mounted via volumes

ARG BASE_IMAGE=python:3.11-slim
FROM ${BASE_IMAGE}

ARG COMFYUI_REF=v0.9.2
ARG COMFYUI_REPO=https://github.com/Comfy-Org/ComfyUI.git

LABEL org.opencontainers.image.source="https://github.com/keyingshuzhi/comfyui-image"

# System deps (minimal but practical)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Non-root user
RUN useradd -m -u 1000 app \
  && mkdir -p /opt \
  && chown -R app:app /opt

USER app
WORKDIR /opt

# Fetch upstream source (robust for release tags like v0.9.2)
RUN set -eux; \
  rm -rf /opt/ComfyUI; \
  if git clone --depth 1 --branch "${COMFYUI_REF}" "${COMFYUI_REPO}" /opt/ComfyUI; then \
    echo "cloned by branch/tag: ${COMFYUI_REF}"; \
  else \
    echo "shallow clone failed, fallback to full clone"; \
    rm -rf /opt/ComfyUI; \
    git clone "${COMFYUI_REPO}" /opt/ComfyUI; \
    cd /opt/ComfyUI; \
    git fetch --all --tags; \
    git checkout --detach "${COMFYUI_REF}"; \
  fi; \
  rm -rf /opt/ComfyUI/.git

WORKDIR /opt/ComfyUI

# Keep pip tooling updated
RUN pip install --no-cache-dir -U pip setuptools wheel

# IMPORTANT: Install CPU-only PyTorch first (prevents pulling CUDA/nvidia wheels)
RUN pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu \
    torch torchvision torchaudio

# Install ComfyUI deps (should reuse the already-installed CPU torch)
RUN pip install --no-cache-dir -r requirements.txt

# Runtime directories (bind mounts recommended)
RUN mkdir -p /opt/ComfyUI/models /opt/ComfyUI/input /opt/ComfyUI/output \
  /opt/ComfyUI/custom_nodes /opt/ComfyUI/workflows

EXPOSE 8188

CMD ["python", "main.py", "--cpu", "--listen", "--port", "8188"]
