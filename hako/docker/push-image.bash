#!/bin/bash

set -e

. "$(dirname "$0")/common.bash"

# Default: push both base and asset
PUSH_TARGET="${1:-both}"

push_base() {
	load_image_metadata
	echo "Pushing base image: ${BASE_DOCKER_TAG}"
	docker push ${BASE_DOCKER_TAG}
	echo "✓ Successfully pushed ${BASE_DOCKER_TAG}"
}

push_asset() {
	load_image_metadata
	echo "Pushing asset image: ${ASSET_DOCKER_TAG}"
	docker push ${ASSET_DOCKER_TAG}
	echo "✓ Successfully pushed ${ASSET_DOCKER_TAG}"
}

case "${PUSH_TARGET}" in
	base)
		push_base
		;;
	both)
		push_base
		push_asset
		;;
	*)
		echo "Usage: $0 [base|both]"
		echo "  base  - Push base image only"
		echo "  both  - Push both base and asset images (default)"
		exit 1
		;;
esac