#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/../.."; pwd)

set -e

echo "=== switch-uncrustify: linux ==="
bash "${REPO_ROOT}/a-rtegen/bin/bin/switch-uncrustify.sh" linux

echo "=== download AUTOSAR Schema ==="
cd "${REPO_ROOT}/a-rtegen/bin/schema"
if [ -f "AUTOSAR_MMOD_XMLSchema.zip" ]; then
	echo "AUTOSAR_MMOD_XMLSchema.zip exists. Skipping download."
else
	bash download.sh
fi
