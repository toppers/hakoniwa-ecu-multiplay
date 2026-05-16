#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/../.."; pwd)

set -e

echo "=== setup-atk2: cfg symlink ==="
if [ -d "${REPO_ROOT}/atk2-sc1/cfg" ]; then
	echo "${REPO_ROOT}/atk2-sc1/cfg exists. Skipping setup."
else
	mkdir -p "${REPO_ROOT}/atk2-sc1/cfg/"
	ln -s /home/hako/schema "${REPO_ROOT}/atk2-sc1/cfg/cfg"
	echo "Created ${REPO_ROOT}/atk2-sc1/cfg and symlink cfg -> /home/hako/schema"
fi
