#!/bin/bash

set -e

IMAGE_NAME=`cat docker/image_name.txt`
IMAGE_TAG=`cat appendix/latest_version.txt`
DOCKER_IMAGE=${IMAGE_NAME}:${IMAGE_TAG}
DOCKER_FILE=docker/Dockerfile

# Enable BuildKit for faster, more efficient builds
export DOCKER_BUILDKIT=1

# Use provided TARGETPLATFORM or default to linux/amd64
TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

# Additional docker build arguments (e.g., cache configuration from CI/CD)
# Can be set via environment variable: DOCKER_BUILD_ARGS
DOCKER_BUILD_ARGS=${DOCKER_BUILD_ARGS:-}

docker build \
  -t ${DOCKER_IMAGE} \
  -f ${DOCKER_FILE} \
  --build-arg HAKONIWA_VERSION=${IMAGE_TAG} \
  --build-arg TARGETPLATFORM=${TARGETPLATFORM} \
  ${DOCKER_BUILD_ARGS} \
  .

