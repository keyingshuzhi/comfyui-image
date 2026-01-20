# comfyui-image: CPU baseline image
# - Builds ComfyUI from an upstream tag/commit (COMFYUI_REF)
# - Keeps runtime minimal; models/nodes/workflows are mounted at runtime via volumes

ARG BASE_IMAGE=python:3.12-slim
FROM ${BASE_IMAGE}

ARG COMFYUI_REF=v0.9.2
ARG COMFYUI_REPO=https://github.com/Comfy-Org/ComfyUI.git

LABEL org.opencontainers.image.source="https://github.com/keyingshuzhi/comfyui-image"

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Create non-root user and workspace
RUN useradd -m -u 1000 app \
  && mkdir -p /opt \
  && chown -R app:app /opt

USER app
WORKDIR /opt

# Fetch upstream source (robust for tags like v0.9.2)
# 1) Try shallow clone by tag/branch (fast, stable for release tags)
# 2) Fallback to full clone + checkout for commit hashes or unusual refs
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

# Install python deps (CPU baseline)
RUN pip install --no-cache-dir -r requirements.txt

# Runtime directories (bind mounts recommended)
RUN mkdir -p /opt/ComfyUI/models /opt/ComfyUI/input /opt/ComfyUI/output \
  /opt/ComfyUI/custom_nodes /opt/ComfyUI/workflows

EXPOSE 8188

CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
