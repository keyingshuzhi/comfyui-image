# comfyui-image: CPU baseline image
# - Builds ComfyUI from an upstream git ref (tag/commit/branch)
# - Does NOT bundle model weights or custom nodes/workflows
# - Mount models/nodes/workflows via volumes at runtime

FROM python:3.11-slim

ARG COMFYUI_REF=master
ARG COMFYUI_REPO=https://github.com/Comfy-Org/ComfyUI.git

# OCI label so GHCR package links back to this repository
LABEL org.opencontainers.image.source="https://github.com/REPLACE_OWNER/comfyui-image"

# Runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Non-root user
RUN useradd -m -u 1000 app
USER app

WORKDIR /opt

# Fetch upstream source
RUN git clone ${COMFYUI_REPO} /opt/ComfyUI
WORKDIR /opt/ComfyUI
RUN git fetch --all --tags && git checkout ${COMFYUI_REF}

# Install deps (CPU baseline)
RUN pip install --no-cache-dir -U pip setuptools wheel \
 && pip install --no-cache-dir -r requirements.txt

EXPOSE 8188

# Listen on 0.0.0.0 inside container; control exposure via docker/compose port binding
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]