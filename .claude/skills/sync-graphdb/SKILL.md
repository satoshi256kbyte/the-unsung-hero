---
name: sync-graphdb
description: >
  プロジェクトのdocs/およびソースコードを読み取り、Neo4jにナレッジグラフとして反映する。
  「graphdb更新」「ナレッジ同期」「グラフDB反映」「Neo4jに入れて」「graphdb sync」
  などのキーワードで発動する。ターン終了時のStop hookからも自動呼び出しされる。
---

# sync-graphdb: ナレッジグラフ同期

## 処理手順

### ステップ1: Neo4jコンテナの起動確認

プロジェクトルートで `docker compose ps` を実行し、Neo4jコンテナの状態を確認する。

- 起動中（running）: そのまま次へ
- 停止中またはコンテナなし: `docker compose up -d` で起動し、
  `docker compose exec neo4j cypher-shell -u neo4j -p password "RETURN 1"` が成功するまで最大30秒待機する

### ステップ2: 現在のグラフ状態を確認

`read_neo4j_cypher` で以下を取得する:

```cypher
CALL db.labels() YIELD label RETURN collect(label) AS labels
```

```cypher
MATCH (n) RETURN count(n) AS nodeCount
```

```cypher
CALL db.relationshipTypes() YIELD relationshipType RETURN collect(relationshipType) AS types
```

ノード数が0の場合は初回実行として全リビルドを行う。

### ステップ3: プロジェクトコンテンツの読み取り

以下を読み取る:

- `docs/` 配下の全Markdownファイル
- ソースコード（存在する場合）

### ステップ4: 更新戦略の決定

現在のグラフ状態とプロジェクトコンテンツを比較し、以下のいずれかを選択する:

| 戦略 | 選択基準 |
|------|---------|
| 全リビルド | 初回、構造の大幅変更、ノード設計の見直しが必要な場合 |
| 差分更新 | 既存ノードの内容修正、小規模な追加・削除のみの場合 |

判断はあなた自身が行う。迷ったら全リビルドを選ぶこと（作り直し前提の運用のため）。

### ステップ5: グラフの更新

全リビルドの場合、まず全データを削除する:

```cypher
MATCH (n) DETACH DELETE n
```

その後、コンテンツに基づいてノードとリレーションシップを作成する。
`write_neo4j_cypher` を使ってCypherクエリを投入する。

データモデル（ノードラベル、プロパティ、リレーションシップタイプ）は
コンテンツの内容に応じてあなた自身が設計する。固定スキーマはない。

設計の指針:

- AIエージェントが設計・コード理解のコンテキストとして使うことを意識する
- 概念間の関係（依存、参照、構成）が辿れるようにする
- 各ノードには出典（ファイルパス、セクション名）を含めること

### ステップ6: 完了報告

更新内容を簡潔に報告する:

- 全リビルド or 差分更新のどちらを実行したか
- ノード数・リレーションシップ数
- 主な変更点
