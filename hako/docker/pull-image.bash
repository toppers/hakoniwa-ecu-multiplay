#!/bin/bash

set -e

. "$(dirname "$0")/common.bash"

# Default: pull both base and asset
PULL_TARGET="${1:-both}"

pull_base() {
	load_image_metadata
	echo "Pulling base image: ${BASE_DOCKER_TAG}"
	docker pull ${BASE_DOCKER_TAG}
	echo "✓ Successfully pulled ${BASE_DOCKER_TAG}"
}

pull_asset() {
	load_image_metadata
	echo "Pulling asset image: ${ASSET_DOCKER_TAG}"
	docker pull ${ASSET_DOCKER_TAG}
	echo "✓ Successfully pulled ${ASSET_DOCKER_TAG}"
}

case "${PULL_TARGET}" in
	base)
		pull_base
		;;
	both)
		pull_base
		pull_asset
		;;
	*)
		echo "Usage: $0 [base|both]"
		echo "  base  - Pull base image only"
		echo "  both  - Pull both base and asset images (default)"
		exit 1
		;;
esac
