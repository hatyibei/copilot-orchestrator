---
name: route
description: >-
  Route a task to the optimal AI coding CLI based on task characteristics.
  Considers cost, speed, and task type to select Claude Code, Codex CLI, or Copilot.
  Use when: route, routing, which CLI, どのCLI, 使い分け, ルーティング,
  quota, コスト最適化, 適材適所, best tool for
user-invocable: true
allowed-tools:
  - shell
---

# Task Router

タスクの特性に応じて最適な CLI を選択し、実行します。

## Step 1: タスクの分析

ユーザーのタスクを以下の観点で分析してください:

- タスクの種類（レビュー、実装、質問、GitHub操作、etc.）
- 複雑さ（単純な質問か、複雑な設計か）
- キーワード

## Step 2: CLI の選択

以下のルールで最適な CLI を選択:

### レビュー・テスト系タスク
**キーワード**: review, test, bug, fix, lint, check, レビュー, テスト, バグ, 修正
**選択**: Codex CLI (built-in review agent が強い)
**実行**: `bash scripts/run-codex.sh "<TASK>"`

### 複雑な設計・実装タスク
**キーワード**: implement, design, architect, refactor, migrate, 実装, 設計, リファクタ, アーキテクチャ
**選択**: Claude Code (Opus 4.6 の深い推論)
**実行**: `bash scripts/run-claude.sh "<TASK>"`

### GitHub 連携タスク
**キーワード**: PR, issue, merge, deploy, workflow, release, label, milestone
**選択**: Copilot CLI (自分自身、GitHub MCP がネイティブ)
**実行**: 自分で直接実行

### 単純な質問・短いタスク
上記に該当しない、短いタスク
**選択**: Copilot CLI (自分自身、quota 消費が最小)
**実行**: 自分で直接実行

## Step 3: 選択結果の表示

実行前に以下を表示してユーザーに確認:

```
Route: <TASK の要約>
  -> Selected: <CLI名>
  -> Reason: <選択理由>
  -> Command: <実行コマンド>

Proceed? (y/n)
```

ユーザーが別の CLI を指定した場合はそちらを使用。

## Step 4: 実行

ユーザーが承認したら選択した CLI で実行。
結果をそのまま表示。

## 注意事項

- ルーティングはヒューリスティック。ユーザーの判断が常に優先
- Claude / Codex が利用不可の場合は Copilot 自身で代替実行
- dry-run を求められた場合は Step 3 で停止
