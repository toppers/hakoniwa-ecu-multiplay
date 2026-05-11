#!/bin/bash

set -e

. "$(dirname "$0")/common.bash"

# Parse options
DRY_RUN=false
PUSH_TARGET="both"

while [[ $# -gt 0 ]]; do
	case $1 in
		--dry-run|-n)
			DRY_RUN=true
			shift
			;;
		base|asset|both)
			PUSH_TARGET="$1"
			shift
			;;
		-h|--help)
			cat <<EOF
Usage: $0 [OPTIONS] [base|asset|both]

OPTIONS:
  --dry-run, -n    Show what would be pushed without actually pushing
  -h, --help       Show this help message

TARGETS (default: both):
  base             Push base image only
  asset            Push asset image only
  both             Push both base and asset images

EXAMPLES:
  bash docker/push-image.bash               # Push both (default)
  bash docker/push-image.bash --dry-run     # Simulate push
  bash docker/push-image.bash -n base       # Simulate base push
  bash docker/push-image.bash asset         # Push asset only
EOF
			exit 0
			;;
		*)
			echo "Error: Unknown option: $1"
			exit 1
			;;
	esac
done

# Check registry connectivity
check_registry() {
	echo "=== Registry Connection Check ==="
	if docker info 2>&1 | grep -q "Registry:"; then
		echo "✓ Docker connected"
	fi

	# Try to authenticate with registry
	if docker login --dry-run ghcr.io >/dev/null 2>&1 || [ -f ~/.docker/config.json ]; then
		echo "✓ GHCR authentication available"
	else
		echo "⚠ GHCR authentication not configured"
		echo "  Run: docker login ghcr.io"
	fi
}

# Verify image exists locally
verify_image() {
	local image=$1
	if docker image inspect "$image" >/dev/null 2>&1; then
		local size=$(docker image inspect "$image" --format='{{.Size}}' | numfmt --to=iec-i --suffix=B 2>/dev/null || echo "unknown")
		echo "✓ Image found: $image (Size: $size)"
		return 0
	else
		echo "✗ Image not found: $image"
		return 1
	fi
}

check_remote_image() {
	local image=$1
	docker manifest inspect "$image" >/dev/null 2>&1
	return $?
}

push_base() {
	load_image_metadata

	if [ "$DRY_RUN" = true ]; then
		echo ""
		echo "=== DRY-RUN: Base Image ==="
		echo "Target: ${BASE_DOCKER_TAG}"
		verify_image ${BASE_DOCKER_TAG} || return 1

		if check_remote_image ${BASE_DOCKER_TAG}; then
			echo "⚠ Image already exists on remote (would skip push)"
		else
			echo "✓ Image would be pushed"
			echo "Would execute: docker push ${BASE_DOCKER_TAG}"
		fi
	else
		# Check if image already exists on remote
		if check_remote_image ${BASE_DOCKER_TAG}; then
			echo "✗ Image already exists on remote: ${BASE_DOCKER_TAG}"
			echo "  To overwrite, remove the image first and try again"
			return 1
		fi

		echo "Pushing base image: ${BASE_DOCKER_TAG}"
		docker push ${BASE_DOCKER_TAG}
		echo "✓ Successfully pushed ${BASE_DOCKER_TAG}"
	fi
}

push_asset() {
	load_image_metadata

	if [ "$DRY_RUN" = true ]; then
		echo ""
		echo "=== DRY-RUN: Asset Image ==="
		echo "Target: ${ASSET_DOCKER_TAG}"
		verify_image ${ASSET_DOCKER_TAG} || return 1

		if check_remote_image ${ASSET_DOCKER_TAG}; then
			echo "⚠ Image already exists on remote (would skip push)"
		else
			echo "✓ Image would be pushed"
			echo "Would execute: docker push ${ASSET_DOCKER_TAG}"
		fi
	else
		# Check if image already exists on remote
		if check_remote_image ${ASSET_DOCKER_TAG}; then
			echo "✗ Image already exists on remote: ${ASSET_DOCKER_TAG}"
			echo "  To overwrite, remove the image first and try again"
			return 1
		fi

		echo "Pushing asset image: ${ASSET_DOCKER_TAG}"
		docker push ${ASSET_DOCKER_TAG}
		echo "✓ Successfully pushed ${ASSET_DOCKER_TAG}"
	fi
}

if [ "$DRY_RUN" = true ]; then
	check_registry
fi

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
		echo "Usage: $0 [OPTIONS] [base|asset|both]"
		echo "  base   - Push base image only"
		echo "  asset  - Push asset image only"
		echo "  both   - Push both base and asset images (default)"
		echo ""
		echo "OPTIONS:"
		echo "  --dry-run, -n    Show what would be pushed"
		exit 1
		;;
esac

if [ "$DRY_RUN" = true ]; then
	echo ""
	echo "=== Dry-run completed ==="
	echo "To actually push, run without --dry-run flag"
fi