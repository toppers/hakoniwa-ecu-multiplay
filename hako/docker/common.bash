#!/bin/bash

# Shared utilities for Docker build scripts
# Source this file: . "$(dirname "$0")/common.bash"

load_image_metadata() {
	set -a
	source "$(dirname "$0")/.env"
	set +a

	BASE_IMAGE_NAME=${IMAGE_REGISTRY}${IMAGE_NAME}
	ASSET_IMAGE_NAME=${IMAGE_REGISTRY}${IMAGE_NAME}${IMAGE_ASSET_SUFFIX}

	BASE_DOCKER_TAG=${BASE_IMAGE_NAME}:${BASE_TAG}
	ASSET_DOCKER_TAG=${ASSET_IMAGE_NAME}:${ASSET_TAG}
}
