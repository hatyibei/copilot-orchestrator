---
name: cross-review
description: >-
  Cross-model code review using multiple AI coding agents.
  Copilot orchestrates Claude Code and Codex CLI to review the same diff,
  then synthesizes a unified review.
  Use when: cross-review, cross review, multi-model review, compare reviews,
  異種レビュー, クロスレビュー, 複数AIでレビュー, 異なるモデルでレビュー
user-invocable: true
allowed-tools:
  - shell
  - read
  - write
---

# Cross-Model Code Review

あなたは異種モデルクロスレビューのオーケストレーターです。
Claude Code と Codex CLI に同じコード差分をレビューさせ、結果を統合します。

## Step 1: 差分の取得

ユーザーが指定したブランチ（または現在のブランチ）と base（デフォルト: main）の差分を取得してください:

```bash
git diff main...HEAD
```

差分がない場合は未コミットの変更を対象にします:

```bash
git diff
```

差分が空の場合はユーザーに報告して終了してください。

## Step 2: 結果ディレクトリの作成

```bash
RESULT_DIR=$(bash !`echo "$(git rev-parse --show-toplevel)/scripts/collect-results.sh"` cross-review)
```

差分を保存:

```bash
git diff main...HEAD > "$RESULT_DIR/diff.patch"
```

## Step 3: Claude Code にレビュー依頼

以下のコマンドで Claude Code にレビューを依頼してください:

```bash
bash !`echo "$(git rev-parse --show-toplevel)/scripts/run-claude.sh"` "以下のコード差分をレビューしてください。
バグ、セキュリティ問題、パフォーマンス、可読性の観点で指摘してください。
行番号を引用し、具体的な修正案を提示してください。
重要度を HIGH / MEDIUM / LOW で分類してください。

diff:
$(git diff main...HEAD)" > "$RESULT_DIR/review-claude.md"
```

**Claude Code が利用不可の場合**: Copilot 自身が `/model` を Claude Opus 4.5 に切り替えてレビューしてください。

## Step 4: Codex CLI にレビュー依頼

```bash
bash !`echo "$(git rev-parse --show-toplevel)/scripts/run-codex.sh"` "Review the following code diff.
Focus on bugs, security vulnerabilities, performance issues, and maintainability.
Cite line numbers and suggest specific fixes.
Classify severity as HIGH / MEDIUM / LOW.

diff:
$(git diff main...HEAD)" > "$RESULT_DIR/review-codex.md"
```

**Codex CLI が利用不可の場合**: Copilot 自身が `/model` を GPT-5.1 に切り替えてレビューしてください。

## Step 5: 統合レビューの生成

**あなた自身（Copilot）が** 2つのレビュー結果を読み取り、統合してください:

1. `$RESULT_DIR/review-claude.md` を読む
2. `$RESULT_DIR/review-codex.md` を読む
3. 以下のルールで統合:
   - 重複する指摘はマージ
   - 矛盾する指摘は両方の視点を記載し、あなたの判断を添える
   - 両方が見落としている問題があれば追加
   - 重要度 HIGH → MEDIUM → LOW の順に並べる

統合結果を `$RESULT_DIR/review-synthesis.md` に保存。

## Step 6: サマリー表示

以下の形式でサマリーを表示してください:

```
## Cross-Review Summary

| Reviewer | Issues | HIGH | MEDIUM | LOW |
|----------|--------|------|--------|-----|
| Claude   | N      | N    | N      | N   |
| Codex    | N      | N    | N      | N   |
| Combined | N      | N    | N      | N   |

Results saved to: $RESULT_DIR/
```

## 注意事項

- Step 3 と Step 4 は独立しているので順序は問わない
- 差分が5000行を超える場合はユーザーにファイル単位で分割するか確認
- 各外部CLIの実行にはユーザーの shell tool 承認が必要
