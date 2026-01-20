IMAGE ?= comfyui-local
COMFYUI_REF ?= v0.9.2
BASE_IMAGE ?= python:3.12-slim
COMFYUI_REPO ?= https://github.com/comfyanonymous/ComfyUI.git

build:
	docker build -f docker/Dockerfile --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg COMFYUI_REF=$(COMFYUI_REF) --build-arg COMFYUI_REPO=$(COMFYUI_REPO) -t $(IMAGE) .

smoke: build
	IMAGE_UNDER_TEST=$(IMAGE) bash scripts/healthcheck.sh 18188 comfyui_smoke

run:
	docker run --rm -it -p 8188:8188 $(IMAGE)

.PHONY: build smoke run
