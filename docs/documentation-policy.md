# Documentation Policy

> Audience: Both

## 目的

この文書はドキュメントを誰向けに、どの粒度で書くかを決める正本です。

本プロジェクトのドキュメントは、人間が理解・判断するためのものと、AI Agent が開発作業で迷わず使うためのものを分けて管理します。
個別ドキュメントの内容そのものではなく、ドキュメントを追加・更新するときの責務、書き方を定義します。

## 読者分類

| 分類 | 主な読者 | 最適化すること | 避けること |
| :--- | :--- | :--- | :--- |
| Human-main | 人間の開発者、運用者、利用者 | 全体像、背景、判断材料、作業手順の理解しやすさ | ファイルパスや制約の羅列だけで終わること。冗長な補足、過去の経緯や背景説明。本筋から外れた詳細の不要に長い説明。 |
| AI-main | AI Agent | 変更前に読むべき正本、境界、禁止事項、確認コマンドの明確さ | 長い背景説明、曖昧な推奨、作業に不要な物語 |
| Both | 人間と AI Agent | 意思決定、公開 contract、変更理由、影響範囲の追跡しやすさ | 人間向け説明と AI 向け指示が混ざって責務不明になること |

## 共通方針

- ドキュメントは「今の状態」を説明することに集中すべきです。過去の経緯や変更履歴は不可欠な場合を除いて一切記述しません。
- 冒頭で「この文書で分かること」と「対象読者」を明示する。

## Human-main 方針

Human-main ドキュメントは、読む人が短時間で構造を把握し判断・作業できることを優先します。

### 書き方

- 全体像の把握、フローの理解のしやすさ、ステップごとの作業の意味の理解のしやすさに最適化する。
- ドキュメントは「今の状態」を説明することに集中すべき。過去からの変更履歴に関する言及は一切行わない。
- 歴史的な背景、冗長な補足、不必要な副詞、ほぼ同じ内容を言い方を変えて二重に説明する行為を避けること。
- 文章だけで説明し続けず、 Mermaid diagram、表、箇条書きを積極的につかい、構造・関係・流れを視覚化する。
- コードブロックを積極的に利用すること。コメントとして記述可能な説明はコードブロック内のコメントとして記述すること。
- 重要概念は最初に定義し、以降は同じ用語を使う。

### 推奨構成

#### 設計書
```markdown
# Title

## 目的
## 対象読者
## 全体像
## 主要概念
## フロー
## 詳細
```

#### 手順書

```markdown
# Title

## 目的
## 前提
## 手順
## 確認方法
```

### Mermaid の使い分け

| 用途 | Mermaid |
| :--- | :--- |
| コンポーネント間の関係 | flowchart |
| API、deploy、認証などの時系列 | sequenceDiagram |
| 状態遷移 | stateDiagram-v2 |
| データモデルの概念説明 | erDiagram |

Mermaid は設計理解の補助に使います。正確な実装詳細をすべて詰め込まず、詳細は表や本文へ逃がします。

## AI-main 方針

AI-main ドキュメントは、AI Agent が変更前に必要な制約を短時間で読み取り、既存設計に沿って作業できることを優先します。  

### 書き方

- 長い背景説明よりも、読む順番、変更分類、境界、禁止事項、確認コマンドを優先する。
- 「必ず」「通常」「必要に応じて」を使い分け、強制力の違いを明確にする。
- ファイルパス、正本、影響先、テストコマンドを具体的に書く。
- AI Agent が勝手に推測しやすい箇所には、明示的な禁止事項を書く。
- 仕様の背景や全体像は Human-main docs にリンクし、AI-main では要約に留める。

### 推奨構成

```markdown
# Area Agent Guide

## Read First
## Product Context
## Directory Map
## Architecture Rules
## Contract Rules
## Common Change Recipes
## Verification
## Avoid
```

### 必ず含める情報

| 情報 | 理由 |
| :--- | :--- |
| 最初に読む文書 | 参照漏れを減らす |
| Directory Map | 変更対象を素早く特定する |
| Layer / Contract Rules | 既存設計から外れる変更を防ぐ |
| Common Change Recipes | 典型作業の影響範囲を固定する |
| Verification | 実装後の確認を迷わせない |
| Avoid | 高リスクな誤操作を明示する |

### 追加先

| 追加するもの | 置き場所 | 理由 |
| :--- | :--- | :--- |
| リポジトリ全体の作業規約 | CLAUDE.md | AI Agent が最初に読む入口にする |
| 領域別の短縮作業ガイド | docs/agent-guides/<area>.md | AI-main を集約し、Human-main docs と責務を分ける |
| AI Agent も読む設計判断 | docs/adr/ | 判断履歴として Both にする |
| ドキュメントの追加・更新方針 | docs/documentation-policy.md | ドキュメント責務設計の正本にする |

## Both 方針

Both ドキュメントは、人間と AI Agent の両方が参照します。ただし、1 つの文書内で責務を混ぜすぎないようにします。

### ADR (Architecture Decision Record)

ADR は意思決定の履歴であり、通常の読みやすさ改善で設計判断の意味を変えません。

ADR は次を守ります。

- Status、Date、Supersedes、Superseded-By を維持する。
- Context は人間が判断背景を理解できる粒度で書く。
- Decision は AI Agent が現在の制約として読めるように箇条書きで明確にする。
- Consequences は影響範囲、更新が必要なファイル、運用上の注意を含める。
- Alternatives Considered は、なぜ採用しなかったかを短く残す。

ADR を大きく変更したい場合は、既存 ADR を上書きして歴史を変えるのではなく、新しい ADR で supersede します。

### 編集原則

| 原則 | 内容 |
| :--- | :--- |
| 上から人間、下で AI 補助 | 冒頭は背景と判断を説明し、後半に contract / checklist を置く |
| 判断と指示を分ける | なぜそうするかと、何を守るかを別セクションにする |
| 正本を明示する | schema、API、Terraform output などは source of truth を具体的に書く |
| 破壊的変更を明示する | contract、state、permission、routing の変更は影響範囲を表にする |

## ドキュメント間の責務分離

同じ内容を複数箇所に詳述しません。重複が必要な場合は、入口文書には短い要約だけを書き、詳細文書へリンクします。

| 情報 | 正本 | 分類 |
| :--- | :--- | :--- |
| リポジトリ全体の入口 | README.md | Both |
| プロジェクトの概要・全体設計 | docs/overview.md | Both |
| AI Agent 全体規約 | CLAUDE.md | AI-main |
| ドキュメント責務設計 | docs/documentation-policy.md | Both |
| 設計・仕様書 | docs/design-specs/ | Human-main |
| AI向けの作業ルール | docs/agent-guides/ | AI-main |
| 手順書 | docs/guides/ | Human-main |
| インフラ・IaC関連の作業ルール | docs/agent-guides/infra.md | design spec は背景と詳細設計 |

- 関連 design spec へのリンク補強。

## レビュー観点

ドキュメント改善 PR では、次を確認します。

| 観点 | 確認内容 |
| :--- | :--- |
| Audience | Human-main / AI-main / Both の分類に沿った書き方か |
| Duplication | 同じ詳細を複数箇所で管理していないか |
| Source of truth | 正本が明示され、リンクされているか |
| Navigability | 初見の人間が読む順番を理解できるか |
| Agent usability | AI Agent が変更前に読むべき制約と確認コマンドを特定できるか |
| Visual structure | Human-main docs に必要な図、表、箇条書きがあるか |
| Contract safety | API、schema、Terraform、permission の破壊的変更が明示されているか |