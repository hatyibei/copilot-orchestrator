#!/bin/bash
# 結果ディレクトリの作成とメタデータ記録
# Usage: collect-results.sh <command> [label]
# Returns: 作成されたディレクトリパス
set -euo pipefail

COMMAND="${1:?Usage: collect-results.sh <command> [label]}"
LABEL="${2:-}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$PROJECT_ROOT/results"

if [ -n "$LABEL" ]; then
  DIR_NAME="${COMMAND}-${LABEL}-${TIMESTAMP}"
else
  DIR_NAME="${COMMAND}-${TIMESTAMP}"
fi

RESULT_DIR="$RESULTS_DIR/$DIR_NAME"
mkdir -p "$RESULT_DIR"

# メタデータ記録
cat > "$RESULT_DIR/meta.json" << EOF
{
  "command": "$COMMAND",
  "label": "$LABEL",
  "timestamp": "$(date -Iseconds)",
  "cwd": "$(pwd)"
}
EOF

echo "$RESULT_DIR"
