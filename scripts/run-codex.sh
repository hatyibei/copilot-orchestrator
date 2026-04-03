#!/bin/bash
# Codex CLI をプログラマティックに実行し結果を stdout に返す
# Usage: run-codex.sh "prompt" [working_dir]
set -euo pipefail

PROMPT="${1:?Usage: run-codex.sh \"prompt\" [working_dir]}"
WORKDIR="${2:-.}"

if ! command -v codex &>/dev/null; then
  echo "Error: codex is not installed or not in PATH" >&2
  exit 1
fi

cd "$WORKDIR"
codex exec "$PROMPT" --full-auto 2>/dev/null
