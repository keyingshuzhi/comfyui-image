# comfyui-image

Reproducible Docker images for **ComfyUI**, built from upstream tags/commits with smoke tests and a `stable` release channel. Images are published to **GitHub Container Registry (GHCR)** by default.

## Image on GitHub (GHCR)
- Image: `ghcr.io/keyingshuzhi/comfyui`
- Tags: `stable`, `<COMFYUI_REF>` (safe tag), `sha-<short>`
```bash
docker pull ghcr.io/keyingshuzhi/comfyui:stable
docker run --rm --gpus all -p 8188:8188 ghcr.io/keyingshuzhi/comfyui:stable
# open http://localhost:8188
```

## Quick start (local build)
```bash
make build COMFYUI_REF=v0.9.2 IMAGE=comfyui-local
docker run --rm --gpus all -p 8188:8188 comfyui-local
# No GPU runtime? add: -e COMFYUI_FORCE_CPU=1
```

## What this repo does
- Builds ComfyUI from an upstream git ref (`COMFYUI_REF`)
- Produces a runtime image (GPU baseline, CUDA 12.x)
- Runs a smoke test (UI endpoint reachable)
- Publishes to `${REGISTRY}/${IMAGE_PREFIX}/${IMAGE_REPO}:<tag>` and optionally `:stable`

## Why
For delivery and team usage, we need:
- pinned upstream version (tag/commit)
- reproducible builds
- a stable channel that only advances when tests pass

## GPU requirements
- NVIDIA driver >= 530 and `nvidia-container-toolkit` (CUDA 12.1, RTX 40xx/4080+)
- Start containers with `--gpus all` or compose device requests
- Set `COMFYUI_FORCE_CPU=1` to force CPU mode

## Runtime data (compose)
`compose/docker-compose.yml.example` keeps `models`, `input`, and `output` on the host and requests GPU access. Updating image tags will not overwrite those bind-mounted directories. Configure the image with:
```bash
COMFYUI_IMAGE=ghcr.io/keyingshuzhi/comfyui:stable
```

## Upstream source
- Default repo: `https://github.com/Comfy-Org/ComfyUI.git`
- Override with `COMFYUI_REPO` (Makefile) or the `comfyui_repo` workflow input

## Build configuration
Base image (mirror support):
```bash
make build BASE_IMAGE=registry.example.com/nvidia/cuda:12.1.1-runtime-ubuntu22.04
```
PyTorch CUDA wheel index:
```bash
make build TORCH_INDEX_URL=https://download.pytorch.org/whl/cu124
```

## Third-party registry (CI publish)
This repo supports publishing to a custom registry (Harbor, Aliyun, etc.).
- Repo variables: `REGISTRY`, `IMAGE_PREFIX`, `IMAGE_REPO`
- Secrets for custom registry login: `REGISTRY_USERNAME`, `REGISTRY_PASSWORD`
- Optional `workflow_dispatch` overrides: `registry`, `image_prefix`, `image_repo`
