---
name: sync-skills
description: >-
  Sync Agent Skills across Claude Code, Codex CLI, and Copilot CLI.
  Creates symlinks from .github/skills/ to .claude/skills/ and .codex/skills/.
  Use when: sync skills, スキル同期, share skills, スキル共有,
  agent skills portability, ポータビリティ
user-invocable: true
allowed-tools:
  - shell
  - read
---

# Skill Sync

.github/skills/ に定義されたスキルを .claude/skills/ と .codex/skills/ に
シンボリックリンクで同期します。これにより同一の SKILL.md が 3 つの CLI 全てで利用可能になります。

## Step 1: 現在のスキルを一覧

プロジェクトルートの `.github/skills/` 配下のスキルをリストアップ:

```bash
ls -1 .github/skills/
```

## Step 2: 同期先ディレクトリの作成

```bash
mkdir -p .claude/skills .codex/skills
```

## Step 3: シンボリックリンクの作成

各スキルについて:

```bash
for skill in .github/skills/*/; do
  skill_name=$(basename "$skill")
  # Claude Code 用
  ln -sfn "../../.github/skills/$skill_name" ".claude/skills/$skill_name"
  # Codex CLI 用
  ln -sfn "../../.github/skills/$skill_name" ".codex/skills/$skill_name"
  echo "Synced: $skill_name -> .claude/skills/, .codex/skills/"
done
```

## Step 4: 結果報告

以下の形式で報告:

```
Skill Sync Complete:

| Skill        | .github/ | .claude/ | .codex/ |
|--------------|----------|----------|---------|
| cross-review | source   | symlink  | symlink |
| bench        | source   | symlink  | symlink |
| route        | source   | symlink  | symlink |
| sync-skills  | source   | symlink  | symlink |
```

## Step 5: .gitignore の確認

`.claude/` と `.codex/` が `.gitignore` に含まれていることを確認:

```bash
grep -q "^\.claude/" .gitignore && echo ".claude/ is gitignored" || echo "WARNING: add .claude/ to .gitignore"
grep -q "^\.codex/" .gitignore && echo ".codex/ is gitignored" || echo "WARNING: add .codex/ to .gitignore"
```

## 注意事項

- シンボリックリンクは相対パスで作成（リポジトリの移動に対応）
- .claude/ と .codex/ は .gitignore に含めること（ユーザー固有の設定）
- 既存のリンクがある場合は上書き（-f フラグ）
