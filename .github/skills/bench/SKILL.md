---
name: bench
description: >-
  Benchmark the same task across multiple AI coding CLIs.
  Sends identical prompts to Claude Code, Codex CLI, and Copilot (self),
  compares execution time and output quality.
  Use when: benchmark, bench, compare, 比較, 速度比較, ベンチマーク,
  which CLI is better, どのCLIがいい, performance comparison
user-invocable: true
allowed-tools:
  - shell
  - read
  - write
---

# Multi-CLI Benchmark

同一タスクを Claude Code、Codex CLI、Copilot（自分自身）で実行し、結果を比較します。

## Step 1: タスクの確認

ユーザーのタスク（プロンプト）を確認してください。
タスクが不明確な場合は聞き返してください。

## Step 2: 結果ディレクトリの作成

```bash
RESULT_DIR=$(bash !`echo "$(git rev-parse --show-toplevel)/scripts/collect-results.sh"` bench)
```

タスク内容を保存:

```bash
echo "<TASK>" > "$RESULT_DIR/task.txt"
```

## Step 3: Claude Code で実行

```bash
START=$(date +%s%N)
bash !`echo "$(git rev-parse --show-toplevel)/scripts/run-claude.sh"` "<TASK>" > "$RESULT_DIR/claude-output.md"
END=$(date +%s%N)
echo $(( (END - START) / 1000000 )) > "$RESULT_DIR/claude-time-ms.txt"
```

Claude Code が利用不可の場合はスキップし、その旨を記録。

## Step 4: Codex CLI で実行

```bash
START=$(date +%s%N)
bash !`echo "$(git rev-parse --show-toplevel)/scripts/run-codex.sh"` "<TASK>" > "$RESULT_DIR/codex-output.md"
END=$(date +%s%N)
echo $(( (END - START) / 1000000 )) > "$RESULT_DIR/codex-time-ms.txt"
```

Codex CLI が利用不可の場合はスキップし、その旨を記録。

## Step 5: Copilot（自分自身）で実行

あなた自身が同じタスクを実行してください。
結果を `$RESULT_DIR/copilot-output.md` に保存。
実行時間は概算で記録。

## Step 6: 比較テーブル生成

各出力ファイルを読み取り、以下の形式でテーブルを生成:

```
## Benchmark Results

Task: <TASK>
Date: <TIMESTAMP>

| CLI     | Time     | Output (chars) | Output (lines) |
|---------|----------|----------------|----------------|
| Claude  | X,XXXms  | X,XXX          | XX             |
| Codex   | X,XXXms  | X,XXX          | XX             |
| Copilot | X,XXXms  | X,XXX          | XX             |
```

テーブルを `$RESULT_DIR/summary.md` に保存。

## Step 7: 品質コメント

各出力を読み比べて、以下の観点で簡潔にコメントしてください:

- **正確性**: タスクの要件を正しく満たしているか
- **完全性**: 必要な要素がすべて含まれているか
- **コード品質**: 読みやすさ、エラーハンドリング等

```
Results saved to: $RESULT_DIR/
```

## 注意事項

- Step 3 と Step 4 は独立しているので順序は問わない
- 各外部CLIの実行にはユーザーの shell tool 承認が必要
- 実行時間はネットワーク状況やモデル負荷に依存するため参考値
