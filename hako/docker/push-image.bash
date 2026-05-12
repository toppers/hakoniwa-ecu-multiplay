#!/bin/bash

set -e

. "$(dirname "$0")/common.bash"

PUSH_TARGET="${1:-both}"

check_remote_image() {
	local image=$1
	docker manifest inspect "$image" >/dev/null 2>&1
	return $?
}

push_base() {
	load_image_metadata
	if check_remote_image ${BASE_DOCKER_TAG}; then
		echo "⚠ Image already exists on remote, overwriting: ${BASE_DOCKER_TAG}"
	fi
	echo "Pushing base image: ${BASE_DOCKER_TAG}"
	docker push ${BASE_DOCKER_TAG}
	echo "✓ Successfully pushed ${BASE_DOCKER_TAG}"
}

push_asset() {
	load_image_metadata
	if check_remote_image ${ASSET_DOCKER_TAG}; then
		echo "⚠ Image already exists on remote, overwriting: ${ASSET_DOCKER_TAG}"
	fi
	echo "Pushing asset image: ${ASSET_DOCKER_TAG}"
	docker push ${ASSET_DOCKER_TAG}
	echo "✓ Successfully pushed ${ASSET_DOCKER_TAG}"
}

case "${PUSH_TARGET}" in
	base)
		push_base
		;;
	asset)
		push_asset
		;;
	both)
		push_base
		push_asset
		;;
	*)
		echo "Usage: $0 [base|asset|both]"
		echo "  base   - Push base image only"
		echo "  asset  - Push asset image only"
		echo "  both   - Push both base and asset images (default)"
		exit 1
		;;
esac
