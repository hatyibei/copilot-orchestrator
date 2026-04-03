# 三種混合AIコーディングCLI比較＆異種モデルワークフロー

## メタ情報

- **記事タイトル案**: 「AI コーディング CLI 三国志 2026 ── Claude Code x Codex CLI x Copilot CLI 徹底比較と異種モデルワークフロー」
- **Zenn コンテスト**: GitHub Copilot 活用選手権
- **狙い**: 最優秀賞
- **切り口**: Copilot CLI を他の CLI エージェントと組み合わせることで真価を発揮させる
- **締切**: 2026/04/30
- **最終リサーチ日**: 2026/04/03

---

## なぜ3つ巴か

- 2026年現在、ターミナルAIコーディングエージェントは三国時代
  - **Claude Code** (Anthropic) -- 深い推論と自律エージェント
  - **Codex CLI** (OpenAI) -- Rust製OSS、サンドボックスセキュリティ
  - **Copilot CLI** (GitHub/MS) -- マルチモデルハブ、GitHub統合
- 「どれが最強か」ではなく「どう組み合わせるか」が実務の問い
- 3つのCLIが **Agent Skills標準 (agentskills.io)** と **MCP** という共通レイヤーで繋がっている
- Copilot活用選手権の文脈で「Copilotは他のツールとどう共存するか」を語る

---

## 1. 3つのCLIの現状比較 (2026年4月時点)

### 1.1 基本スペック

| 項目 | Claude Code | Codex CLI | Copilot CLI |
|------|------------|-----------|-------------|
| 開発元 | Anthropic | OpenAI | GitHub (Microsoft) |
| 実装言語 | TypeScript (Node.js) | Rust | TypeScript (Node.js) |
| OSS | No | Yes (github.com/openai/codex) | No |
| デフォルトモデル | Claude Sonnet 4 | gpt-5.4 | Claude Sonnet 4.5 |
| 上位モデル | Claude Opus 4.6 | gpt-5.3-codex-spark (o3派生) | GPT-5.1, Claude Opus 4.5, Gemini 3 Pro |
| モデル切り替え | `/model` | `/model` | `/model` |
| **モデルプロバイダ** | **Anthropicのみ** | **OpenAIのみ (+ Ollama/Azure等カスタム)** | **マルチ: Anthropic + OpenAI + Google** |
| 料金体系 | Max $200/Pro $20 | Pro $20/Plus含む | Pro $10~/Pro+ $39 |

### 1.2 エージェントアーキテクチャ

| 機能 | Claude Code | Codex CLI | Copilot CLI |
|------|------------|-----------|-------------|
| サブエージェント/並列 | Agent tool, .claude/agents/, Agent Teams (実験的), /batch | /agent, spawn_agents_on_csv, max_threads設定可 | /fleet (5ステップオーケストレーション) |
| カスタムエージェント | CLAUDE.md + .claude/agents/*.md | AGENTS.md + .codex/agents/*.toml | .github/agents/*.agent.md |
| Agent Skills | .claude/skills/ (SKILL.md) | .agents/skills/ or .codex/skills/ (SKILL.md) | .github/skills/ (SKILL.md) |
| Hooks | .claude/hooks/ (25+イベント) | .codex/hooks.json (要feature flag) | .github/hooks/hooks.json (6イベント) |
| MCP対応 | ネイティブ (.mcp.json) | config.toml + **MCPサーバーとして動作可** | mcp-config.json + 組み込みGitHub MCP |
| プラグイン | /plugin, マーケットプレイス | /plugins | /plugin, マーケットプレイス |
| プログラマティック実行 | `claude -p "PROMPT"` | `codex exec "PROMPT"` | `copilot -p "PROMPT"` |
| 自動実行フラグ | `--allowedTools "Bash,Read,Edit"` | `--full-auto` | `--allow-all-tools --no-ask-user` |

### 1.3 クラウド・リモート実行

| 機能 | Claude Code | Codex CLI | Copilot CLI |
|------|------------|-----------|-------------|
| クラウド実行 | /schedule (クラウドタスク), --remote (Web) | codex cloud exec, @codex (Issue/PR) | /delegate -> Coding Agent |
| コードレビュー | /security-review, code-reviewerエージェント | /review (プリセット付き) | /review (エージェント型) |
| セッション再開 | --resume, /resume | codex resume, codex fork | /resume |
| Web検索 | WebSearch/WebFetchツール | --search (ライブ/キャッシュ) | 組み込み |
| リモート操作 | Remote Control, Teleport, Desktop/Web/Chrome/iOS | Desktop (macOS) | GitHub連携 |

### 1.4 セキュリティモデル

| 項目 | Claude Code | Codex CLI | Copilot CLI |
|------|------------|-----------|-------------|
| サンドボックス | OSレベル (コンテナ型) | macOS: Seatbelt, Linux: Bubblewrap+seccomp | GitHub Runner (クラウド) |
| 権限モード | default/acceptEdits/plan/auto/dontAsk/bypass | read-only/workspace-write/danger-full-access | 標準/--allow-all/--yolo |
| 保護パス | 設定ベース | .git, .agents/, .codex/ (常にread-only) | 設定ベース |
| 監査 | セッション履歴 | OpenTelemetry対応 | GitHub Audit Log |

### 1.5 ユニーク機能

| 機能 | Claude Code | Codex CLI | Copilot CLI |
|------|------------|-----------|-------------|
| 音声入力 | /voice (push-to-talk) | -- | -- |
| 画像入力 | 画像ファイル読み取り | -i flag (PNG/JPEG) | -- |
| チェックポイント | /rewind | -- | -- |
| セッション分析 | /insights | -- | /chronicle (実験的) |
| LSP連携 | -- | -- | /lsp |
| コンテキスト可視化 | /context | /status | /context |
| セッション共有 | /export | -- | /share (file/gist) |
| マルチアカウント | -- | -- | /user (切替) |
| Agent SDK | Python/TypeScript SDK | -- | -- |
| Channels | Telegram/Discord/iMessage連携 | -- | -- |
| プランモード | /plan, Shift+Tab | /plan | /plan, Shift+Tab |

### 1.6 得意領域の体感 (★実測で検証予定)

| タスク | Claude Code | Codex CLI | Copilot CLI |
|--------|------------|-----------|-------------|
| 新規実装 (ゼロから) | ◎ (Opus 4.6の推論力) | ◎ (gpt-5.4) | ○ |
| リファクタリング | ◎ | ○ | ○ |
| バグ修正 | ○ | ◎ | ○ |
| コードレビュー | ○ (/security-review) | ◎ (/review プリセット) | ◎ (/review エージェント型) |
| テスト生成 | ◎ | ○ | ○ |
| ドキュメント生成 | ◎ | ○ | ○ |
| GitHub連携 (PR/Issue) | △ (gh CLI経由) | ○ (Codex Cloud) | ◎ (ネイティブGitHub MCP) |
| 長時間自律実行 | ◎ | ◎ (full-auto) | ◎ (autopilot) |
| 並列タスク | ○ (/batch, Agent Teams) | ○ (spawn_agents_on_csv) | ◎ (/fleet 5ステップ) |

---

## 2. 相互運用レイヤー (3ツール共通の基盤)

### 2.1 Agent Skills 標準 (agentskills.io)

3つのCLI全てが同じ **SKILL.md** フォーマットに準拠。これは記事の最大の発見の一つ。

**ディレクトリ配置の違い**:
```
# Claude Code
.claude/skills/<skill-name>/SKILL.md
~/.claude/skills/<skill-name>/SKILL.md

# Codex CLI
.agents/skills/<skill-name>/SKILL.md
.codex/skills/<skill-name>/SKILL.md
~/.codex/skills/<skill-name>/SKILL.md

# Copilot CLI
.github/skills/<skill-name>/SKILL.md
~/.copilot/skills/<skill-name>/SKILL.md

# 共通 (一部ツールが認識)
.agents/skills/<skill-name>/SKILL.md
```

**ポータビリティの意味**:
- 1つのSKILL.mdを書けば、シンボリックリンクで3ツール全てに配布可能
- チームで「どのCLIを使うか」の宗教戦争を回避できる
- スキルのエコシステムがツール横断で育つ

### 2.2 MCP ユニバーサル対応

3つ全てがModel Context Protocolに対応。さらに:

- **Codex CLI固有**: `codex mcp-server` で自身をMCPサーバーとして公開可能
  - → Claude CodeやCopilot CLIからCodexの機能を消費できる
  - → ツール間のブリッジとして機能

**設定ファイルの違い**:
```
# Claude Code
.mcp.json (プロジェクト) / ~/.claude/settings.json (ユーザー)

# Codex CLI  
~/.codex/config.toml の [mcp_servers] セクション

# Copilot CLI
~/.copilot/mcp-config.json
```

### 2.3 Hooks 3ツール対応

| イベント | Claude Code | Codex CLI | Copilot CLI |
|---------|------------|-----------|-------------|
| セッション開始/終了 | SessionStart/End | SessionStart | sessionStart/End |
| ツール実行前/後 | PreToolUse/PostToolUse | PreToolUse/PostToolUse | preToolUse/postToolUse |
| プロンプト送信 | UserPromptSubmit | UserPromptSubmit | userPromptSubmitted |
| 停止時 | Stop | Stop | -- |
| エラー | StopFailure, PostToolUseFailure | -- | errorOccurred |
| ファイル変更 | FileChanged | -- | -- |
| サブエージェント | SubagentStart/Stop | -- | -- |
| コンテキスト | PreCompact/PostCompact | -- | -- |

### 2.4 カスタム指示ファイルの互換性

| ファイル | Claude Code | Codex CLI | Copilot CLI |
|---------|------------|-----------|-------------|
| CLAUDE.md | ✓ (ネイティブ) | -- | -- |
| AGENTS.md | import可能 | ✓ (ネイティブ) | ✓ (読み込み対応) |
| .agent.md | -- | -- | ✓ (ネイティブ) |
| copilot-instructions.md | -- | -- | ✓ (ネイティブ) |

---

## 3. 異種モデルワークフロー設計

### パターン1: Write-Review (異種モデルレビュー)

```
[Claude Code (Opus 4.6)] ---(実装)--→ git commit
                                        |
                                        v
[Copilot CLI (Sonnet 4.5)] ---(レビュー)--→ /review でフィードバック
                                        |
                                        v
[Claude Code] ---(修正)--→ git commit
                                        |
                                        v
[Codex CLI (gpt-5.4)] ---(最終レビュー)--→ /review
```

**なぜ異種モデルか**: 同じモデルが書いたコードを同じモデルがレビューすると盲点が生まれる。
異なるモデルアーキテクチャ (Claude/GPT) でクロスレビューすることで死角を減らせる。

### パターン2: Quota Arbitrage (コスト最適化)

```
タスク分類:
  - 単純なコード生成/質問 → Copilot CLI (Pro $10/月に含まれる、最安)
  - 複雑な実装/リファクタ → Claude Code (Opus 4.6、最深推論)
  - 並列バッチ処理 → Codex CLI (codex exec --full-auto、Rust高速)
  - GitHub連携 (PR/Issue) → Copilot CLI (ネイティブGitHub MCP)
```

### パターン3: Parallel Implementation (競争的実装)

```
同じタスクを3つに投げて比較:

$ claude -p "implement auth middleware" --allowedTools "Bash,Read,Write,Edit" &
$ codex exec "implement auth middleware" --full-auto &
$ copilot -p "implement auth middleware" --allow-all-tools --no-ask-user &

→ 3つの実装を比較して最良のものを採用
→ または3つの実装のいいとこ取りでマージ
```

### パターン4: Sequential Pipeline (リレー型)

```
1. [Copilot CLI] Issue解析 → 要件整理
   - GitHub MCPでIssue読み取り (ネイティブ統合)
   - /plan で実装計画作成

2. [Claude Code] 設計 → 実装
   - Opus 4.6の深い推論で複雑なロジック実装
   - Agent Teamsで並列設計 (実験的)

3. [Codex CLI] テスト生成 → レビュー
   - /review でプリセット型レビュー
   - codex exec でCIパイプライン統合

4. [Copilot CLI] PR作成 → クラウド委譲
   - /delegate でCoding Agentに非同期委譲
   - Coding Agentが自動レビュー + セキュリティスキャン
```

### パターン5: MCP Bridge (NEW)

Codex CLIをMCPサーバーとして起動し、他のCLIから消費する。

```
# ターミナル1: Codex CLIをMCPサーバーとして起動
$ codex mcp-server

# ターミナル2: Claude Codeから消費
# .mcp.json に設定:
{
  "mcpServers": {
    "codex-bridge": {
      "command": "codex",
      "args": ["mcp-server"]
    }
  }
}
$ claude  # Codexの機能をMCP経由で利用可能

# ターミナル3: Copilot CLIから消費
# ~/.copilot/mcp-config.json に設定:
{
  "mcpServers": {
    "codex-bridge": {
      "type": "local",
      "command": "codex",
      "args": ["mcp-server"],
      "tools": ["*"]
    }
  }
}
$ copilot  # Codexの機能をMCP経由で利用可能
```

**ユースケース**:
- Codex のRust高速ファイル操作を Claude Code の推論と組み合わせ
- Codex の独自ツール (sandbox実行等) を Copilot CLI から利用
- 将来的にはClaude CodeもMCPサーバー化の可能性 (Agent SDK経由)

### パターン6: Agent Skills Portability (NEW)

同一のSKILL.mdを3ツール全てに配布するワークフロー。

```bash
# スキルを1箇所で管理し、シンボリックリンクで配布
SKILL_DIR="$HOME/.shared-skills"
mkdir -p "$SKILL_DIR/my-skill"

# SKILL.md を作成
cat > "$SKILL_DIR/my-skill/SKILL.md" << 'EOF'
---
name: my-custom-reviewer
description: Custom code review skill for team standards
---

Review the code changes against our team coding standards:
1. Check naming conventions (camelCase for JS/TS, snake_case for Python)
2. Verify error handling patterns
3. Ensure test coverage for new functions
EOF

# 3ツール全てにシンボリックリンク
mkdir -p ~/.claude/skills ~/.codex/skills ~/.copilot/skills
ln -sf "$SKILL_DIR/my-skill" ~/.claude/skills/my-skill
ln -sf "$SKILL_DIR/my-skill" ~/.codex/skills/my-skill
ln -sf "$SKILL_DIR/my-skill" ~/.copilot/skills/my-skill

# どのCLIからでも同じスキルが使える
$ claude        # /my-custom-reviewer で起動
$ codex         # $my-custom-reviewer で起動
$ copilot       # /my-custom-reviewer で起動
```

---

## 4. 実装スクリプト

### 4.1 cross-review.sh (異種モデルクロスレビュー)

```bash
#!/bin/bash
# 異種モデルクロスレビュー
# Usage: bash cross-review.sh [branch]

set -euo pipefail

BRANCH="${1:-$(git branch --show-current)}"
BASE_BRANCH="${2:-main}"
DIFF=$(git diff "$BASE_BRANCH"..."$BRANCH")
TMPDIR=$(mktemp -d)

if [ -z "$DIFF" ]; then
  echo "No diff found between $BASE_BRANCH and $BRANCH"
  exit 1
fi

echo "=== Phase 1: Copilot CLI Review (Claude Sonnet 4.5) ==="
copilot -p "Review this diff for bugs, security issues, and code quality. Be specific about line numbers and severity.

$DIFF" --no-ask-user 2>&1 | tee "$TMPDIR/review-copilot.md"

echo ""
echo "=== Phase 2: Codex CLI Review (gpt-5.4) ==="
codex exec "Review this diff for bugs, security issues, and style. Focus on logic errors and edge cases.

$DIFF" --full-auto 2>&1 | tee "$TMPDIR/review-codex.md"

echo ""
echo "=== Phase 3: Claude Code Synthesis (Opus 4.6) ==="
claude -p "Here are two code reviews of the same diff from different AI models.
Synthesize them into a unified, prioritized review:
- Resolve contradictions between the two reviews
- Prioritize by severity (CRITICAL > HIGH > MEDIUM > LOW)
- Add any issues both reviewers missed
- Format as actionable items

Review 1 (Copilot CLI / Claude Sonnet 4.5):
$(cat "$TMPDIR/review-copilot.md")

Review 2 (Codex CLI / gpt-5.4):
$(cat "$TMPDIR/review-codex.md")

Original diff:
$DIFF" --output-format text 2>&1 | tee "$TMPDIR/review-final.md"

echo ""
echo "=== Results ==="
echo "Individual reviews: $TMPDIR/review-copilot.md, $TMPDIR/review-codex.md"
echo "Synthesized review: $TMPDIR/review-final.md"
```

### 4.2 quota-router.sh (タスクルーター)

```bash
#!/bin/bash
# タスクの特性に応じてCLIを自動選択
# Usage: bash quota-router.sh "task description"

set -euo pipefail

TASK="$1"

# タスク特性を判定
is_github_task() {
  echo "$TASK" | grep -qiE "issue|pull.?request|pr|merge|branch|github|label|milestone"
}

is_review_task() {
  echo "$TASK" | grep -qiE "review|audit|check|inspect|security"
}

is_complex_task() {
  # 50語以上、または複雑キーワードを含む
  local word_count=$(echo "$TASK" | wc -w)
  [ "$word_count" -gt 50 ] || echo "$TASK" | grep -qiE "refactor|architect|design|migrate|implement.*(system|service|module)"
}

is_parallel_task() {
  echo "$TASK" | grep -qiE "batch|parallel|multiple|each|every|all files"
}

# ルーティング
if is_github_task; then
  echo "[Router] GitHub task -> Copilot CLI (native GitHub MCP)"
  copilot -p "$TASK" --no-ask-user
elif is_parallel_task; then
  echo "[Router] Parallel task -> Codex CLI (spawn_agents_on_csv capable)"
  codex exec "$TASK" --full-auto
elif is_complex_task; then
  echo "[Router] Complex task -> Claude Code (Opus 4.6 deep reasoning)"
  claude -p "$TASK" --output-format text
elif is_review_task; then
  echo "[Router] Review task -> Codex CLI (built-in /review presets)"
  codex exec "$TASK" --full-auto
else
  echo "[Router] Standard task -> Copilot CLI (quota-friendly, $10/mo)"
  copilot -p "$TASK" --no-ask-user
fi
```

### 4.3 sync-skills.sh (Agent Skills ポータビリティ)

```bash
#!/bin/bash
# Agent Skills を3つのCLIに同期
# Usage: bash sync-skills.sh [source-dir]

set -euo pipefail

SOURCE_DIR="${1:-$HOME/.shared-skills}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory not found: $SOURCE_DIR"
  echo "Create skills in $SOURCE_DIR/<skill-name>/SKILL.md first"
  exit 1
fi

# 各CLIのスキルディレクトリ
CLAUDE_SKILLS="$HOME/.claude/skills"
CODEX_SKILLS="$HOME/.codex/skills"
COPILOT_SKILLS="$HOME/.copilot/skills"

mkdir -p "$CLAUDE_SKILLS" "$CODEX_SKILLS" "$COPILOT_SKILLS"

synced=0
for skill_dir in "$SOURCE_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "[SKIP] $skill_name: no SKILL.md found"
    continue
  fi

  for target in "$CLAUDE_SKILLS" "$CODEX_SKILLS" "$COPILOT_SKILLS"; do
    if [ -L "$target/$skill_name" ]; then
      # 既存のシンボリックリンクを更新
      rm "$target/$skill_name"
    fi
    ln -sf "$skill_dir" "$target/$skill_name"
  done
  
  echo "[SYNCED] $skill_name -> claude, codex, copilot"
  synced=$((synced + 1))
done

echo ""
echo "Synced $synced skill(s) to all 3 CLIs"
```

### 4.4 mcp-bridge.sh (MCP ブリッジ起動)

```bash
#!/bin/bash
# Codex CLI を MCP サーバーとして起動し、他のCLIから消費可能にする
# Usage: bash mcp-bridge.sh [setup|start]

set -euo pipefail

ACTION="${1:-start}"

setup_claude_code() {
  local mcp_file=".mcp.json"
  if [ -f "$mcp_file" ]; then
    echo "[INFO] $mcp_file already exists, checking for codex-bridge..."
    if grep -q "codex-bridge" "$mcp_file"; then
      echo "[OK] codex-bridge already configured in $mcp_file"
      return
    fi
  fi
  
  cat > "$mcp_file" << 'EOF'
{
  "mcpServers": {
    "codex-bridge": {
      "command": "codex",
      "args": ["mcp-server"]
    }
  }
}
EOF
  echo "[OK] Created $mcp_file with codex-bridge server"
}

setup_copilot_cli() {
  local mcp_file="$HOME/.copilot/mcp-config.json"
  mkdir -p "$(dirname "$mcp_file")"
  
  if [ -f "$mcp_file" ]; then
    echo "[INFO] $mcp_file already exists, manual edit may be needed"
    return
  fi
  
  cat > "$mcp_file" << 'EOF'
{
  "mcpServers": {
    "codex-bridge": {
      "type": "local",
      "command": "codex",
      "args": ["mcp-server"],
      "tools": ["*"]
    }
  }
}
EOF
  echo "[OK] Created $mcp_file with codex-bridge server"
}

case "$ACTION" in
  setup)
    echo "=== Setting up MCP Bridge ==="
    setup_claude_code
    setup_copilot_cli
    echo ""
    echo "Setup complete. Run 'bash mcp-bridge.sh start' to verify."
    ;;
  start)
    echo "=== Starting Codex MCP Server ==="
    echo "Other CLIs can now connect to Codex via MCP."
    echo "Press Ctrl+C to stop."
    echo ""
    codex mcp-server
    ;;
  *)
    echo "Usage: bash mcp-bridge.sh [setup|start]"
    exit 1
    ;;
esac
```

---

## 5. 検証計画

### 5.1 同一タスクベンチマーク

以下のタスクを3つのCLIで実行し、結果を比較:

1. **新規実装**: 小規模なWebAPIエンドポイント追加
2. **バグ修正**: 意図的に仕込んだバグの修正
3. **リファクタリング**: 既存スクリプトのリファクタ
4. **コードレビュー**: 同じPRを3つにレビューさせる
5. **テスト生成**: 同じコードのテストを3つに書かせる
6. **並列タスク**: 複数ファイルの同時修正 (/fleet vs /batch vs spawn_agents)

### 5.2 計測項目

- 実行時間
- トークン消費量 (概算)
- 出力品質 (主観評価 + 相互レビュー)
- quota/コスト
- 成功率 (タスク完了できたか)

### 5.3 新規検証項目

- **MCP Bridge**: Codex MCPサーバー経由でClaude Codeからタスク実行
- **Skills Portability**: 同一SKILL.mdが3ツールで正しく読み込まれるか
- **Cross-Review**: 異種モデルレビューvs同一モデルレビューの品質差

---

## 6. 記事構成案

```
タイトル: 「AI コーディング CLI 三国志 2026
          ── Claude Code x Codex CLI x Copilot CLI 徹底比較と異種モデルワークフロー」

1. はじめに: ターミナルAIエージェント三国時代
   - 2026年のCLI landscape
   - 3つのCLIが成熟しエージェントプラットフォーム化
   - 「どれが最強か」ではなく「どう組み合わせるか」

2. 3つのCLIを並べてみる
   - 基本スペック比較表 (Section 1.1)
   - インストール・認証の違い
   - 同じタスクを3つに投げた結果 (ベンチマーク)

3. エージェントアーキテクチャ比較
   - サブエージェント: Agent Teams vs spawn_agents vs /fleet
   - カスタムエージェント: CLAUDE.md vs AGENTS.md vs .agent.md
   - 各ツールのエージェント哲学の違い

4. 相互運用レイヤー: 3ツールを繋ぐ共通基盤
   - Agent Skills標準 (agentskills.io) -- 最大の発見
   - MCP ユニバーサル対応
   - Hooks の共通パターン
   - sync-skills.sh で実証

5. 異種モデルワークフロー設計
   - Write-Review パターン (cross-review.sh)
   - Quota Arbitrage パターン (quota-router.sh)
   - Parallel Implementation パターン
   - Sequential Pipeline パターン
   - MCP Bridge パターン (mcp-bridge.sh) -- 新
   - Agent Skills Portability パターン (sync-skills.sh) -- 新

6. 実測: クロスレビューの効果
   - 同一モデルレビュー vs 異種モデルレビューの品質差
   - cross-review.sh の実行結果
   - 発見されたバグの種類と数の比較

7. Copilot CLI の独自の強み
   - マルチモデルハブ (Claude + GPT + Gemini を1CLIで)
   - /fleet: 5ステップ並列オーケストレーション
   - /delegate: & でCoding Agentに非同期委譲
   - /chronicle: セッション分析 (実験的)
   - Plugin Marketplace
   - /plan → /fleet → /delegate のワンストップフロー

8. Claude Code の独自の強み
   - Opus 4.6 の推論深度
   - Agent Teams (実験的だが将来性)
   - Remote Control / Teleport / 音声入力
   - Agent SDK (Python/TypeScript)
   - Channels (Telegram/Discord連携)

9. Codex CLI の独自の強み
   - 唯一のOSS (Rust実装)
   - MCPサーバー化 (ブリッジの要)
   - Seatbelt/Bubblewrap サンドボックス
   - OpenTelemetry監査
   - Codex Cloud + @codex タグ

10. 使い分けガイド: 適材適所マトリクス
    - ユースケース別おすすめCLI
    - チーム規模別の推奨構成
    - コスト最適化のポイント

11. まとめ: 異種モデル時代の開発ワークフロー
    - 1つに絞る必要はない
    - Agent Skills標準がツール間の壁を溶かす
    - Copilot は「ハブ」になりうる (マルチモデル + GitHub統合)
    - しかし各ツールに固有の強みがあり、組み合わせが最適解
```

---

## 7. Copilot CLI の独自の強み (記事セクション7用の素材)

### 7.1 マルチモデルハブ

Copilot CLIは **唯一、3つのAIプロバイダのモデルを切り替えて使える**:
- Claude Sonnet 4.5 (デフォルト)
- Claude Opus 4.5
- Claude Haiku 4.5
- GPT-5.1 バリアント
- Gemini 3 Pro

これはClaude Code (Anthropicのみ) やCodex CLI (OpenAIのみ) にはない特性。
チームで「Claude派」と「GPT派」が混在していても、Copilot CLI 1本で対応できる。

### 7.2 /fleet 5ステップオーケストレーション

```
/fleet "Refactor the authentication module"

Step 1: Decompose → 認証ロジック、ミドルウェア、テスト、ドキュメントに分解
Step 2: Identify → ミドルウェアとテストは並列可、ロジック先行
Step 3: Dispatch → 並列可能なタスクをサブエージェントに分配
Step 4: Poll → 完了を待ち、次のウェーブを開始
Step 5: Verify → 出力を検証し、最終成果物を統合
```

**制約**: 同一ファイルへの並列書き込みは最後の勝ち (自動マージなし)
**ベストプラクティス**: ファイル単位でタスクを分割する

### 7.3 /delegate と Coding Agent

```
# プレフィックス & で非同期委譲
& complete the API integration tests and fix failing edge cases

# 内部動作:
1. 未コミット変更をチェックポイントとしてコミット
2. Coding Agent がクラウドでブランチ作成
3. バックグラウンドで実装
4. 自動セルフレビュー (Copilot Code Review)
5. セキュリティスキャン (CodeQL, Secret Scanning, Dependency Check)
6. Draft PR を開く
7. レビューを要求
```

### 7.4 /chronicle (実験的)

```
/experimental on
/chronicle standup    # 直近24時間のアクティビティサマリー
/chronicle tips       # 使用パターンに基づくパーソナライズ提案
/chronicle improve    # .github/copilot-instructions.md の改善提案
```

### 7.5 Plugin Marketplace

```
copilot plugin marketplace browse    # マーケットプレイス一覧
copilot plugin install PLUGIN@MARKETPLACE
copilot plugin install owner/repo    # GitHubリポジトリから
copilot plugin install ./local-path  # ローカルから
```

### 7.6 ワンストップフロー

```
/plan "Add user authentication with OAuth"   # 計画
  → プランを確認・承認
/fleet implement the plan                     # 並列実装
  → /tasks で進捗確認
/review                                       # レビュー
  → フィードバック確認・修正
& create PR with full test coverage           # Coding Agentに委譲
  → PR自動作成、セキュリティスキャン付き
```

---

## 8. 差別化ポイント (記事としてのユニーク性)

### 既存記事にない切り口

1. **3つのCLIを実際に同じタスクで比較した記事はほぼない**
   - 2つの比較 (Claude Code vs Copilot CLI 等) は散見
   - 3つ巴の実測比較は希少

2. **Agent Skills標準の発見と実証**
   - SKILL.mdが3ツール共通であることを実証した記事はない
   - sync-skills.sh による実用的なポータビリティ

3. **MCP Bridgeパターンの提案**
   - Codex CLIのMCPサーバー機能を活用した異種ツール連携
   - 完全に新しいワークフローパターン

4. **「組み合わせる」視点がユニーク**
   - 大抵の比較記事は「どれを使うべきか」で結論
   - 本記事は「全部使え、しかも共通基盤がある」がメッセージ

5. **Copilot活用選手権の文脈で最高の切り口**
   - Copilotを「他を排除する唯一のツール」ではなく「エコシステムのハブ」として位置づける
   - マルチモデル対応の事実が「ハブ」論を裏付ける
   - 審査員 (GitHub/MS) にとっても新鮮な視点

---

## 9. 参考リンク

### Claude Code
- https://docs.anthropic.com/en/docs/claude-code
- Skills: https://docs.anthropic.com/en/docs/claude-code/skills
- Agents: https://docs.anthropic.com/en/docs/claude-code/sub-agents
- MCP: https://docs.anthropic.com/en/docs/claude-code/mcp
- Hooks: https://docs.anthropic.com/en/docs/claude-code/hooks
- Agent SDK: https://docs.anthropic.com/en/docs/claude-code/sdk

### Codex CLI
- https://developers.openai.com/codex/cli
- https://github.com/openai/codex
- Features: https://developers.openai.com/codex/cli/features
- Reference: https://developers.openai.com/codex/cli/reference
- Agent Loop: https://openai.com/index/unrolling-the-codex-agent-loop/

### Copilot CLI
- https://docs.github.com/en/copilot/how-tos/copilot-cli
- Slash Commands: https://github.blog/ai-and-ml/github-copilot/a-cheat-sheet-to-slash-commands-in-github-copilot-cli/
- /fleet: https://github.blog/ai-and-ml/github-copilot/run-multiple-agents-at-once-with-fleet-in-copilot-cli/
- Skills: (公式ドキュメント内)
- Custom Agents: (公式ドキュメント内)
- Agentic Workflows: https://github.blog/ai-and-ml/github-copilot/power-agentic-workflows-in-your-terminal-with-github-copilot-cli/
- Idea to PR: https://github.blog/ai-and-ml/github-copilot/from-idea-to-pull-request-a-practical-guide-to-building-with-github-copilot-cli/
- Coding Agent: https://github.blog/ai-and-ml/github-copilot/whats-new-with-github-copilot-coding-agent/
- Squad: https://github.blog/ai-and-ml/github-copilot/how-squad-runs-coordinated-ai-agents-inside-your-repository/
- Memory System: https://github.blog/ai-and-ml/github-copilot/building-an-agentic-memory-system-for-github-copilot/

### Agent Skills Standard
- https://agentskills.io (★要確認)

---

## 10. 注意点

- ベンチマーク結果は実行時点のモデルバージョンに依存 (記事内で日付を明記)
- 主観評価が入る部分は明示する
- 特定のCLIを貶める論調にしない (「適材適所」のトーン)
- Copilot活用選手権なので、Copilotの立ち位置をポジティブに語る
  - ただし提灯記事にはしない。正直な比較の中でCopilotの強みを浮かび上がらせる
- Claude Code の Max plan 値上げ ($100→$200) など最新の料金情報を確認
- agentskills.io の正式名称・URLを記事公開前に再確認
- 全スクリプトは記事公開前に実機テスト必須
