# comfyui-image

Build reproducible Docker images for **ComfyUI** from upstream tags/commits, with smoke tests and a `stable` release channel. Default publish target is **GHCR**, but the workflow can be pointed at any registry.

## What this repo does
- Builds ComfyUI from an upstream git ref (`COMFYUI_REF`)
- Produces a runtime image (CPU baseline)
- Runs a smoke test (UI endpoint reachable)
- Publishes to `${REGISTRY}/${IMAGE_PREFIX}/${IMAGE_REPO}:<tag>` and optionally `:stable`

## Why
For delivery and team usage, we need:
- pinned upstream version (tag/commit)
- reproducible builds
- a stable channel that only advances when tests pass

## Quick start (local)
```bash
make smoke COMFYUI_REF=v0.9.2 IMAGE=comfyui-local
docker run --rm -p 8188:8188 comfyui-local
# open http://localhost:8188
```

## Upstream source
- Default repo: `https://github.com/comfyanonymous/ComfyUI.git`
- Override with `COMFYUI_REPO` (Makefile) or the `comfyui_repo` workflow input

## Base image (mirror support)
If Docker Hub is not reachable, override the base image to your mirror:
```bash
make build BASE_IMAGE=registry.example.com/library/python:3.12-slim
```
CI: set repo variable `BASE_IMAGE` or use the `base_image` workflow input.

## Third-party registry (CI publish)
This repo supports publishing to a custom registry (Harbor, Aliyun, etc.).
- Repo variables: `REGISTRY`, `IMAGE_PREFIX`, `IMAGE_REPO`
- Secrets for custom registry login: `REGISTRY_USERNAME`, `REGISTRY_PASSWORD`
- Optional `workflow_dispatch` overrides: `registry`, `image_prefix`, `image_repo`

## Runtime data (volumes)
`compose/docker-compose.yml.example` keeps `models`, `input`, and `output` on the host. Updating image tags will not overwrite those bind-mounted directories. Configure the image with:
```bash
COMFYUI_IMAGE=ghcr.io/keyingshuzhi/comfyui:stable
```
