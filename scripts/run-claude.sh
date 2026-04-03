#!/bin/bash
# Claude Code をプログラマティックに実行し結果を stdout に返す
# Usage: run-claude.sh "prompt" [working_dir]
set -euo pipefail

PROMPT="${1:?Usage: run-claude.sh \"prompt\" [working_dir]}"
WORKDIR="${2:-.}"

if ! command -v claude &>/dev/null; then
  echo "Error: claude is not installed or not in PATH" >&2
  exit 1
fi

cd "$WORKDIR"
claude -p "$PROMPT" --dangerously-skip-permissions 2>/dev/null
