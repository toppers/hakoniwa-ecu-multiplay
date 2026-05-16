#!/bin/bash

set -e

. "$(dirname "$0")/common.bash"

# Default: remove both base and asset
REMOVE_TARGET="${1:-both}"

remove_base() {
	load_image_metadata
	echo "Removing base image: ${BASE_DOCKER_TAG}"
	docker rmi ${BASE_DOCKER_TAG} || echo "⚠ Base image not found or already removed"
	echo "✓ Successfully removed ${BASE_DOCKER_TAG}"
}

remove_asset() {
	load_image_metadata
	echo "Removing asset image: ${ASSET_DOCKER_TAG}"
	docker rmi ${ASSET_DOCKER_TAG} || echo "⚠ Asset image not found or already removed"
	echo "✓ Successfully removed ${ASSET_DOCKER_TAG}"
}

case "${REMOVE_TARGET}" in
	base)
		remove_base
		;;
	both)
		remove_asset
		remove_base
		;;
	*)
		echo "Usage: $0 [base|both]"
		echo "  base  - Remove base image only"
		echo "  both  - Remove both base and asset images (default)"
		exit 1
		;;
esac
