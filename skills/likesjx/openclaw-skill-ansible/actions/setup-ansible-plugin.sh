#!/usr/bin/env bash
set -euo pipefail

TASK_JSON="$1"
TASK_ID=$(echo "$TASK_JSON" | jq -r .task_id)
ARTROOT=${OPENCLAW_ARTIFACT_ROOT:-/var/lib/openclaw/artifacts}
mkdir -p "$ARTROOT"

SOURCE=$(echo "$TASK_JSON" | jq -r .params.source