# copilot-orchestrator

Copilot CLI をハブとして Claude Code / Codex CLI を束ねる異種モデルワークフロー。

Copilot の Agent Skills + Custom Agent として実装。
ユーザーは Copilot とだけ対話すれば、裏で Claude Code と Codex CLI が動く。

## 必要なもの

- [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (optional)
- [Codex CLI](https://github.com/openai/codex) (optional)

Claude Code / Codex CLI が未インストールでも動作する。
その場合、Copilot 自身が `/model` 切替で代替する。

## 使い方

### オーケストレーターエージェント (対話モード)

```bash
copilot --agent orchestrator
```

初回は環境チェックが走り、利用可能な CLI を表示する。

### 個別スキル

Copilot CLI セッション内で:

```
/cross-review    # 異種モデルクロスレビュー
/bench           # 同一タスクベンチマーク
/route           # タスクルーター
/sync-skills     # スキル同期 (Claude/Codex にも配布)
```

または自然言語で:

```
> この PR を Claude と Codex でクロスレビューして
> FizzBuzz を3つの CLI でベンチマークして
> このバグ修正を最適な CLI にルーティングして
```

## アーキテクチャ

```
User
  |
  v
Copilot CLI (orchestrator)
  |
  +---> scripts/run-claude.sh ---> Claude Code (claude -p)
  |
  +---> scripts/run-codex.sh  ---> Codex CLI (codex exec)
  |
  +---> (self)                ---> Copilot internal models
```

Copilot が shell ツール経由で外部 CLI を子プロセスとして呼び出す。

## ディレクトリ構成

```
.github/
  skills/
    cross-review/SKILL.md   # 異種モデルクロスレビュー
    bench/SKILL.md           # ベンチマーク
    route/SKILL.md           # タスクルーター
    sync-skills/SKILL.md     # スキル同期
  agents/
    orchestrator.agent.md    # 統合オーケストレーター
scripts/
  detect-clis.sh             # CLI 検出
  run-claude.sh              # Claude Code ラッパー
  run-codex.sh               # Codex CLI ラッパー
  collect-results.sh         # 結果収集
results/                     # 実行結果 (gitignored)
```

## Agent Skills のクロスプラットフォーム互換

`/sync-skills` を実行すると `.github/skills/` のスキルが
`.claude/skills/` と `.codex/skills/` にシンボリックリンクされる。

3つの CLI 全てが [Agent Skills 標準 (agentskills.io)](https://agentskills.io) に準拠しているため、
同一の SKILL.md がそのまま動作する。

## セキュリティ

外部 CLI の実行には `--dangerously-skip-permissions` / `--full-auto` フラグを使用する。
これらは信頼できるタスクのみで使用すること。

Copilot セッション内では shell ツールの承認が求められる。
セッション中に一括承認する場合: `Yes, and approve shell for the rest of the session`

## License

MIT
