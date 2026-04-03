#!/bin/bash
# Copilot が呼び出して環境確認に使う
# 3つのCLIの存在・バージョン・認証状態を JSON で返す
set -euo pipefail

check_cli() {
  local name="$1" cmd="$2"
  local version="null" status="not_found" path="null"

  if command -v "$cmd" &>/dev/null; then
    path="$(command -v "$cmd")"
    version=$("$cmd" --version 2>/dev/null | head -1 || echo "unknown")
    status="ok"
  fi

  printf '{"name":"%s","status":"%s","version":"%s","path":"%s"}' \
    "$name" "$status" "$version" "$path"
}

echo "["
check_cli "claude" "claude"
echo ","
check_cli "codex" "codex"
echo ","
check_cli "copilot" "copilot"
echo "]"
