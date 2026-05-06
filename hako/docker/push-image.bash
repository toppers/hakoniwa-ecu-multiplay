#!/bin/bash

IMAGE_NAME=`cat docker/image_name.txt`
IMAGE_TAG=`cat appendix/latest_version.txt`
DOCKER_IMAGE=${IMAGE_NAME}:${IMAGE_TAG}

# Ensure logged in to GHCR
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker daemon is not accessible"
  exit 1
fi

# For manual execution, ensure user is logged in
if ! grep -q "ghcr.io" ~/.docker/config.json 2>/dev/null; then
  echo "Not logged in to ghcr.io. Please run: docker login ghcr.io"
  exit 1
fi

docker push ${DOCKER_IMAGE}