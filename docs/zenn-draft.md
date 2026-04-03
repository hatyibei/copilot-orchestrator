---
title: "Copilot CLI で Claude Code と Codex CLI を束ねる ── 異種モデルクロスレビューで指摘の57%を救出した話"
emoji: "🔀"
type: "tech"
topics: ["githubcopilot", "claudecode", "codexcli", "ai", "cli"]
published: false
---

# はじめに：ターミナルAIエージェント三国時代

2026年、ターミナルで動くAIコーディングエージェントが3つ揃った。

- **Claude Code** (Anthropic) — Claude Opus 4.6 / Sonnet 4
- **Codex CLI** (OpenAI) — gpt-5.4、Rust製OSS
- **GitHub Copilot CLI** (GitHub/MS) — Claude Sonnet 4.5 / GPT-5.1 / Gemini 3 Pro

「どれが最強か」を議論する記事は山ほどある。この記事では逆のことをする。

**Copilot CLI をハブにして、3つ全部使う。**

作ったものは [copilot-orchestrator](https://github.com/hatyibei/copilot-orchestrator)。Copilot CLI の Agent Skills と Custom Agent として実装したオーケストレーターで、Copilot のセッション内から Claude Code と Codex CLI を呼び出し、異種モデルクロスレビュー・ベンチマーク・タスクルーティングを実行する。

# なぜ Copilot がオーケストレーターなのか

3つの理由がある。

## 1. マルチモデルハブ

Copilot CLI は `/model` コマンドで以下のモデルを切り替えられる：

- Claude Sonnet 4.5（デフォルト）
- Claude Opus 4.5
- Claude Haiku 4.5
- GPT-5.1
- Gemini 3 Pro

**3社のモデルに1つの CLI からアクセスできる唯一のツール。** Claude Code は Anthropic のモデルだけ、Codex CLI は OpenAI のモデルだけ。Copilot だけが全方位。

さらに shell ツール経由で `claude -p` や `codex exec` も呼べるので、Copilot から到達できるモデルの数は最多になる。

## 2. GitHub ネイティブ統合

Copilot CLI には GitHub MCP サーバーが組み込みで入っている。Issue の読み取り、PR へのコメント、ラベル操作などがプロンプトから直接できる。レビュー結果を PR に投稿する、Issue から要件を読み取ってタスクを振る、といった連携が自然にできる。

## 3. SKILL.md を置くだけで拡張できる

`.github/skills/` にマークダウンファイルを置くだけで、Copilot に新しい能力を追加できる。npm install もバイナリダウンロードも不要。ユーザーは git clone するだけで使える。

# 3つのCLIを並べてみる

## 基本スペック

| 項目 | Claude Code | Codex CLI | Copilot CLI |
|------|------------|-----------|-------------|
| 開発元 | Anthropic | OpenAI | GitHub (Microsoft) |
| 実装言語 | TypeScript | Rust | TypeScript |
| OSS | No | Yes | No |
| デフォルトモデル | Claude Sonnet 4 | gpt-5.4 | Claude Sonnet 4.5 |
| 上位モデル | Opus 4.6 | GPT-5-Codex | GPT-5.1, Opus 4.5, Gemini 3 Pro |
| プログラマティック実行 | `claude -p` | `codex exec` | `copilot -p` |
| 自動実行フラグ | `--dangerously-skip-permissions` | `--full-auto` | `--allow-all-tools --no-ask-user` |

## 共通の相互運用レイヤー

驚くべきことに、3つの CLI は共通の拡張基盤を持っている。

| 機能 | Claude Code | Codex CLI | Copilot CLI |
|------|------------|-----------|-------------|
| Agent Skills (SKILL.md) | `.claude/skills/` | `.codex/skills/` | `.github/skills/` |
| MCP | `.mcp.json` | `config.toml` | `mcp-config.json` |
| Hooks | `.claude/hooks/` | `.codex/hooks.json` | `.github/hooks/` |
| カスタムエージェント | `.claude/agents/` | `AGENTS.md` | `.agent.md` |

**3つとも [Agent Skills 標準](https://agentskills.io) に準拠している。** つまり同じ `SKILL.md` ファイルが、ディレクトリを変えるだけで3つの CLI 全てで動く。後述する `sync-skills` でこれを実証する。

# copilot-orchestrator：作ったもの

## アーキテクチャ

```
ユーザー
  |
  v
Copilot CLI（オーケストレーター）
  |
  +---> scripts/run-claude.sh ---> Claude Code (claude -p)
  |
  +---> scripts/run-codex.sh  ---> Codex CLI (codex exec)
  |
  +---> (self)                ---> Copilot 内部モデル
```

Copilot が shell ツール経由で外部 CLI を子プロセスとして呼び出す。ユーザーは Copilot とだけ対話すればいい。

## 提供するスキル

| スキル | 機能 |
|--------|------|
| `/cross-review` | 異種モデルクロスレビュー |
| `/bench` | 同一タスクベンチマーク |
| `/route` | タスクルーター |
| `/sync-skills` | スキルを3つの CLI に同期 |

対話的に使う場合は `copilot --agent orchestrator` で統合エージェントが起動する。

# 実測：ベンチマーク

## タスク

> Write a Python function that plays FizzBuzz from 1 to 100. Include type hints, docstring, and unit tests using pytest. Output only the code, no explanation.

3つの CLI に全く同じプロンプトを投げた。

## 結果

| CLI | 時間 | 動作の特徴 |
|-----|------|-----------|
| Claude Code | 35.2s | ファイル作成 + テスト実行 → 要約1行だけ返す |
| Codex CLI | 42.3s | コードをインライン返却（ファイル作成なし） |
| Copilot CLI | 35.8s | ファイル作成 + テスト実行 + テスト修正 + 再実行 + 全コード表示 |

## 哲学の違い

ここで分かったのは、3つの CLI が根本的に異なる「仕事の流儀」を持っていること。

- **Claude Code**: 「**やって、結果だけ伝える**」。ファイルを作り、テストを走らせ、「全14テスト合格」とだけ返す。出力は65文字。プロにタスクを頼んだ感覚。
- **Codex CLI**: 「**コードを見せる**」。ファイルは作らず、きれいに整形されたコードをインラインで返す。コピペですぐ使える。テキスト生成として最も優秀。
- **Copilot CLI**: 「**作業過程を全部見せる**」。ファイル作成 → テスト実行 → 失敗発見 → 修正 → 再実行、というエージェントループを回し、その過程と最終コードの両方を返す。最も丁寧。

:::message
**注意**: Copilot CLI は `--allow-all-tools --no-ask-user` の両方が必要。`--no-ask-user` だけだと shell ツールが permission denied になり、まともに動かない。
:::

# 実測：異種モデルクロスレビュー

## セットアップ

Claude Code がベンチマークで生成した `fizzbuzz.py` + `test_fizzbuzz.py`（79行）をフィーチャーブランチにコミットし、3つの CLI にレビューさせた。

## 各レビュアーの結果

| レビュアー | 指摘数 | MEDIUM | LOW | 特徴 |
|-----------|--------|--------|-----|------|
| Claude Code | 4 | 2 | 2 | 実用的な修正案、テストカバレッジ重視 |
| Codex CLI | 3 | 2 | 1 | 技術的に深い（bool subclass, DoS リスク） |
| Copilot CLI | 3 | 1 | 2 | **唯一テスト実行してからレビュー**、最も簡潔 |

## 指摘の重なりと独自発見

ここが記事の核心。

### 全員が指摘した問題
- `play_fizzbuzz(start > end)` が空リストを黙って返す（バリデーション不足）

### 2人が指摘した問題
- 大きな範囲でのメモリ効率（Codex + Copilot）
- Python 3.9+ の型ヒント互換性（Codex + Copilot）

### 1人だけが発見した問題

| 発見者 | 指摘内容 |
|--------|---------|
| Claude のみ | 境界値テスト不足（`fizzbuzz(45)`, 非3非5の偶数） |
| Claude のみ | 単一要素テスト `play_fizzbuzz(5, 5)` の欠如 |
| Codex のみ | `bool` は `int` のサブクラス → `fizzbuzz(True)` が "1" を返す |
| Codex のみ | `start/end` がユーザー制御下だと DoS リスク（セキュリティ視点） |

## 結論：単一モデルでは57%を見逃す

全7件の指摘のうち、**4件はクロスレビューでなければ発見されなかった**。

```
単一モデルが発見できる指摘: 最大 3/7 件（43%）
クロスレビューで発見された指摘: 7/7 件（100%）
→ クロスレビューによる上乗せ: +57%
```

これは「異なるモデルアーキテクチャは異なるバイアスを持つ」ことの実証だ。Claude は テスト品質に敏感、Codex は型システムとセキュリティに鋭い、Copilot は実行してから判断する。この多様性が死角を埋める。

## Copilot の特筆すべき動作

Copilot CLI は **レビュー前にテストを実行した**。他の2つは diff だけを見てレビューしたが、Copilot は `python3 -m pytest -v` を走らせてテストが通ることを確認した上でレビューしている。

これは Copilot がエージェント的に「まず事実確認」する設計思想を持っていることを示している。レビューの信頼性という点では、実行確認済みのレビューは静的レビューより一段上だ。

# タスクルーター：適材適所の自動振り分け

`/route` スキルはタスクの特性を分析して最適な CLI を選ぶ。

| タスクの種類 | 選択されるCLI | 理由 |
|-------------|-------------|------|
| レビュー・バグ修正 | Codex CLI | built-in review agent |
| 設計・リファクタ | Claude Code | Opus 4.6 の深い推論 |
| GitHub 操作 | Copilot CLI | ネイティブ GitHub MCP |
| 短い質問 | Copilot CLI | quota 消費が最小 |

単純にキーワードベースのヒューリスティックだが、実用上はこれで十分機能する。ユーザーが上書きすることも可能。

# スキルの相互運用：Agent Skills 標準の威力

`/sync-skills` を実行すると、`.github/skills/` のスキルが `.claude/skills/` と `.codex/skills/` にシンボリックリンクで同期される。

```bash
$ copilot --agent orchestrator
> スキルを同期して

Skill Sync Complete:

| Skill        | .github/ | .claude/ | .codex/ |
|--------------|----------|----------|---------|
| cross-review | source   | symlink  | symlink |
| bench        | source   | symlink  | symlink |
| route        | source   | symlink  | symlink |
| sync-skills  | source   | symlink  | symlink |
```

これにより、チームメンバーが Claude Code を使っていても Codex CLI を使っていても、同じスキルセットが利用できる。**CLI 選択の宗教戦争を回避できる**のは実務上大きい。

# Copilot CLI の独自の強み

この記事を通じて浮かび上がった Copilot CLI の強みをまとめる。

## マルチモデルハブ

`/model` で Claude / GPT / Gemini を切り替えられる唯一の CLI。さらに shell 経由で外部 CLI も呼べるため、到達可能なモデル数が最多。

## /fleet：並列オーケストレーション

```
/fleet "Refactor the authentication module"
```

タスクを分解 → 並列可能なものを特定 → サブエージェントに分配 → 完了待ち → 統合、という5ステップを自動で回す。

## /delegate：非同期クラウド委譲

```
& complete the API integration tests
```

`&` プレフィックスで Coding Agent に非同期委譲。クラウドでブランチ作成 → 実装 → セルフレビュー → セキュリティスキャン → Draft PR 作成まで全自動。

## レビュー時の実行確認

前述の通り、Copilot CLI はレビュー前にテストを実行する。静的レビューではなく「実行確認済みレビュー」を提供するのは、3つの中で Copilot だけ。

# まとめ：1つに絞る必要はない

この記事で実証したこと：

1. **異種モデルクロスレビューで指摘の57%を追加発見できる**。単一モデルのバイアスは、別のモデルで補完できる。

2. **Agent Skills 標準 (SKILL.md) が3つの CLI を繋ぐ**。同じスキルファイルが Claude Code / Codex CLI / Copilot CLI の全てで動く。ツール選択がチームの分断を生まない。

3. **Copilot CLI はオーケストレーターに最適**。マルチモデルハブ + GitHub 統合 + SKILL.md 拡張 + shell 経由の外部 CLI 呼び出し。すべてが「束ねる」ための機能。

Copilot の真価は「最強のコード生成」ではない。**「つなぐ力」**だ。

---

リポジトリ：[hatyibei/copilot-orchestrator](https://github.com/hatyibei/copilot-orchestrator)

実測データ（ベンチマーク・クロスレビュー結果の全文）はリポジトリの `docs/results/` に置いてある。
