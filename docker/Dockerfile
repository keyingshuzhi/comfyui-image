# comfyui-image: CPU baseline image
# - Builds ComfyUI from an upstream tag/commit (COMFYUI_REF)
# - Keeps runtime minimal; models/nodes/workflows are mounted at runtime via volumes

ARG BASE_IMAGE=python:3.12-slim
FROM ${BASE_IMAGE}

ARG COMFYUI_REF=v0.9.2
ARG COMFYUI_REPO=https://github.com/comfyanonymous/ComfyUI.git

# OCI label so GHCR package links back to this repository
LABEL org.opencontainers.image.source="https://github.com/keyingshuzhi/comfyui-image"

# Basic runtime deps commonly needed by comfyui + image libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Create non-root user and prepare workspace
RUN useradd -m -u 1000 app \
  && mkdir -p /opt/ComfyUI \
  && chown -R app:app /opt/ComfyUI

WORKDIR /opt/ComfyUI

# Fetch only the requested ref to keep the image small
RUN set -eux; \
  git init .; \
  git remote add origin "${COMFYUI_REPO}"; \
  git fetch --depth 1 origin "${COMFYUI_REF}"; \
  git checkout --detach FETCH_HEAD; \
  rm -rf .git

# Optional: keep pip tooling updated (safe, small)
RUN pip install --no-cache-dir -U pip setuptools wheel

# Install python deps (CPU baseline)
RUN pip install --no-cache-dir -r requirements.txt

# Ensure runtime directories exist and remain external via bind mounts
RUN mkdir -p /opt/ComfyUI/models /opt/ComfyUI/input /opt/ComfyUI/output \
  /opt/ComfyUI/custom_nodes /opt/ComfyUI/workflows \
  && chown -R app:app /opt/ComfyUI

USER app

EXPOSE 8188

# Notes:
# - By default we listen on 0.0.0.0 inside container. Control exposure via compose port binding.
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
