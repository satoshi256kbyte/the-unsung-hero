---
name: sync-graphdb
description: >
  プロジェクトのdocs/およびソースコードを読み取り、Neo4jにナレッジグラフとして反映する。
  「graphdb更新」「ナレッジ同期」「グラフDB反映」「Neo4jに入れて」「graphdb sync」
  などのキーワードで発動する。
---

# sync-graphdb: ナレッジグラフ同期

## ストレージ構成

Neo4jのデータは2段階で永続化される。

| 層 | パス | Git管理 | 用途 |
|----|------|---------|------|
| シードファイル | `db/neo4j-seed.cypher` | 対象 | 再現可能なDB再構築の基点 |
| DBデータ | `data/neo4j/` | 対象外 | Dockerコンテナのbind mount |

`docker-compose.yml` のvolumes設定:

```yaml
volumes:
  - ./data/neo4j:/data                    # DBデータ永続化
  - ./db:/var/lib/neo4j/import            # シードファイルのimportディレクトリ
```

## Phase 1: シードファイル生成

`docs/` の変更をシードファイルに反映する。

### 1-1. Neo4jコンテナの起動確認

`docker compose ps` でNeo4jコンテナの状態を確認する。

- 起動中（running）: そのまま次へ
- 停止中: `docker compose up -d` で起動し、
  `docker compose exec neo4j cypher-shell -u neo4j -p password "RETURN 1"` が成功するまで最大30秒待機する

### 1-2. 現在のグラフ状態を確認（差分更新の判断用）

`read_neo4j_cypher` で以下を確認する:

```cypher
MATCH (n) RETURN count(n) AS nodeCount
```

ノード数が0の場合、またはシードファイルがない場合は全リビルドを行う。

### 1-3. docs/ の読み取り

`docs/` 配下の全Markdownファイルとソースコードを読み取り、
変更内容をリストアップする。

### 1-4. 更新戦略の決定

| 戦略 | 選択基準 |
|------|---------|
| 全リビルド | 初回、構造の大幅変更、ノード設計の見直しが必要な場合 |
| 差分更新 | 既存ノードの内容修正、小規模な追加・削除のみの場合 |

迷ったら全リビルドを選ぶ。

### 1-5. `db/neo4j-seed.cypher` の生成・更新

`db/neo4j-seed.cypher` をWriteまたはEditで更新する。

**全リビルドの場合**、ファイル先頭で全削除してから全ノード・リレーションシップをMERGEで記述する:

```cypher
// 既存データを全削除
MATCH (n) DETACH DELETE n;

// ノード
MERGE (:Label {name: '...', prop: '...'});

// リレーションシップ（MATCHでノードを取得してからMERGE）
MATCH (a:Label {name: '...'}), (b:Label {name: '...'})
MERGE (a)-[:REL_TYPE]->(b);
```

**差分更新の場合**、既存のMERGEに対応するノードを追加・変更・削除する。
削除は `MATCH ... DELETE` を使い、変更はプロパティを更新するMERGEを使う。

設計指針:

- AIエージェントが設計・コード理解のコンテキストとして使うことを意識する
- 概念間の関係（依存、参照、構成）が辿れるようにする
- 各ノードには出典（ファイルパス、セクション名）を含めること
- CREATEではなくMERGEを使い、冪等性を保つ

## Phase 2: DBへのロード

シードファイルをNeo4jにロードする。

```bash
docker compose exec neo4j cypher-shell \
  -u neo4j -p password \
  --file /var/lib/neo4j/import/neo4j-seed.cypher
```

実行後、ノード数・リレーションシップ数を確認する:

```cypher
MATCH (n) RETURN count(n) AS nodeCount
```

```cypher
MATCH ()-[r]->() RETURN count(r) AS relCount
```

## 破損・消失時のリストア手順

```bash
# コンテナとストレージが両方壊れた場合
docker compose down        # コンテナ停止
rm -rf data/neo4j          # 壊れたデータを削除
docker compose up -d       # 空のbind mountでコンテナ起動
# Phase 2のコマンドでシードファイルをロード
docker compose exec neo4j cypher-shell \
  -u neo4j -p password \
  --file /var/lib/neo4j/import/neo4j-seed.cypher
```

シードファイル自体が古い場合は、Phase 1から実行してファイルを再生成してからPhase 2を実行する。

## 完了報告

更新内容を簡潔に報告する:

- 全リビルド or 差分更新のどちらを実行したか
- ノード数・リレーションシップ数
- 主な変更点
