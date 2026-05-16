#!/usr/bin/env bash
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

cp "$SCRIPT_DIR/proxy_config.json" \
    "$REPO_ROOT/a-comstack/can/target/hsbrh850f1k_gcc/sample/"

cp "$SCRIPT_DIR/proxy_config_rte_ecu1.json" \
    "$REPO_ROOT/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu1/"

cp "$SCRIPT_DIR/proxy_config_rte_ecu2.json" \
    "$REPO_ROOT/a-rtegen/sample/sc1/HelloAutosarWithCom/hsbrh850f1k_gcc/ecu2/"

echo "Done: proxy configs copied."
