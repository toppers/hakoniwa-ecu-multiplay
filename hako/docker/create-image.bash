#!/bin/bash

set -e

. "$(dirname "$0")/common.bash"

# Default: build both base and asset
BUILD_TARGET="${1:-both}"

DOCKER_FILE_BASE=docker/Dockerfile.base
DOCKER_FILE_ASSET=docker/Dockerfile

# Enable BuildKit for faster, more efficient builds
export DOCKER_BUILDKIT=1

# Use provided TARGETPLATFORM or default to linux/amd64
TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

# Additional docker build arguments (e.g., cache configuration from CI/CD)
# Can be set via environment variable: DOCKER_BUILD_ARGS
DOCKER_BUILD_ARGS=${DOCKER_BUILD_ARGS:-}

build_base() {
	load_image_metadata
	echo "Building base image: ${BASE_DOCKER_TAG} (${TARGETPLATFORM})"
	docker buildx build \
	  -t ${BASE_DOCKER_TAG} \
	  -f ${DOCKER_FILE_BASE} \
	  --build-arg TARGETPLATFORM=${TARGETPLATFORM} \
	  ${DOCKER_BUILD_ARGS} \
	  .
	echo "✓ Successfully built ${BASE_DOCKER_TAG}"
}

build_asset() {
	load_image_metadata
	echo "Building asset image: ${ASSET_DOCKER_TAG} (${TARGETPLATFORM})"
	docker buildx build \
	  -t ${ASSET_DOCKER_TAG} \
	  -f ${DOCKER_FILE_ASSET} \
	  --build-arg IMAGE_NAME=${BASE_IMAGE_NAME} \
	  --build-arg IMAGE_TAG=${BASE_TAG} \
	  --build-arg TARGETPLATFORM=${TARGETPLATFORM} \
	  ${DOCKER_BUILD_ARGS} \
	  .
	echo "✓ Successfully built ${ASSET_DOCKER_TAG}"
}

case "${BUILD_TARGET}" in
	base)
		build_base
		;;
	both)
		build_base
		build_asset
		;;
	*)
		echo "Usage: $0 [base|both]"
		echo "  base  - Build base image only"
		echo "  both  - Build both base and asset images (default)"
		exit 1
		;;
esac
