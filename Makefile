IMAGE ?= comfyui-local
COMFYUI_REF ?= v0.9.2
BASE_IMAGE ?= nvidia/cuda:12.1.1-runtime-ubuntu22.04
TORCH_INDEX_URL ?= https://download.pytorch.org/whl/cu121
COMFYUI_REPO ?= https://github.com/Comfy-Org/ComfyUI.git
GPU ?= 1

ifeq ($(GPU),1)
GPU_ARGS = --gpus all
endif

build:
	docker build -f docker/Dockerfile --build-arg BASE_IMAGE=$(BASE_IMAGE) --build-arg COMFYUI_REF=$(COMFYUI_REF) --build-arg COMFYUI_REPO=$(COMFYUI_REPO) --build-arg TORCH_INDEX_URL=$(TORCH_INDEX_URL) -t $(IMAGE) .

smoke: build
	IMAGE_UNDER_TEST=$(IMAGE) bash scripts/healthcheck.sh 18188 comfyui_smoke

run:
	docker run --rm -it -p 8188:8188 $(GPU_ARGS) $(IMAGE)

.PHONY: build smoke run
