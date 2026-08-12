---
name: sync-graphdb
description: >
  設計会話で決まった内容をNeo4jグラフDBに反映してFixする。
  「graphdb更新」「ナレッジ同期」「グラフDB反映」「Neo4jに入れて」「Fix」「sync」
  などのキーワードで発動する。セッション終了時に必ず実行する。
---

# sync-graphdb: ナレッジグラフ同期

## 設計フロー上の位置づけ

```
設計会話 → 一時ファイル（docs/design-session/）に決定事項を書き留め
         → /sync-graphdb でグラフDBへ反映（Fix）
         → 一時ファイルを削除
```

グラフDBが「正」の状態。docs/ は数値・一覧・ステージデータのみ保持する。

## ストレージ構成

| 層 | パス | Git管理 | 用途 |
|----|------|---------|------|
| シードファイル | `db/neo4j-seed.cypher` | 対象 | 再現可能なDB再構築の基点 |
| DBデータ | `data/neo4j/` | 対象外 | Dockerコンテナのbind mount |
| 一時ファイル | `docs/design-session/` | 対象外（.gitignore） | セッション中の設計メモ |

## Phase 0: 一時ファイルの確認

`docs/design-session/` に未反映の設計決定事項があれば読み取る。
なければ現在のグラフDBの状態を確認して差分を把握する。

```cypher
MATCH (n) RETURN labels(n) AS label, count(n) AS cnt ORDER BY cnt DESC
```

## Phase 1: シードファイル生成

グラフDBの現状と今回の決定事項を統合して `db/neo4j-seed.cypher` を更新する。

### 1-1. Neo4jコンテナの起動確認

`docker compose ps` でNeo4jコンテナの状態を確認する。

- 起動中（running）: そのまま次へ
- 停止中: `docker compose up -d` で起動し、
  `docker compose exec neo4j cypher-shell -u neo4j -p password "RETURN 1"` が成功するまで最大30秒待機する

### 1-2. 更新戦略の決定

| 戦略 | 選択基準 |
|------|---------|
| 全リビルド | 初回、ノード構造の大幅変更、今回の変更量が大きい場合 |
| 差分更新 | 既存ノードのプロパティ修正、小規模な追加のみの場合 |

迷ったら全リビルドを選ぶ。

### 1-3. `db/neo4j-seed.cypher` の生成・更新

`db/neo4j-seed.cypher` をWriteまたはEditで更新する。

**全リビルドの場合**（先頭で全削除してから全ノード・全リレーションをMERGEで記述）:

```cypher
MATCH (n) DETACH DELETE n;

MERGE (:Label {name: '...', prop: '...'});

MATCH (a:Label {name: '...'}), (b:Label {name: '...'})
MERGE (a)-[:REL_TYPE]->(b);
```

**差分更新の場合**（追加はMERGE、削除はMATCH+DELETE、変更はSETで記述）:

```cypher
MERGE (:Label {name: '新ノード'}) SET n.prop = '値';

MATCH (n:Label {name: '削除するノード'}) DETACH DELETE n;
```

設計指針:

- AIエージェントが設計・コード理解のコンテキストとして使うことを意識する
- 概念間の関係（依存、参照、構成）が辿れるようにする
- CREATEではなくMERGEを使い、冪等性を保つ
- 数値・計算式・係数はプロパティとして保持する

## Phase 2: DBへのロード

```bash
docker compose exec neo4j cypher-shell \
  -u neo4j -p password \
  --file /var/lib/neo4j/import/neo4j-seed.cypher
```

実行後に確認:

```cypher
MATCH (n) RETURN count(n) AS nodeCount
```

```cypher
MATCH ()-[r]->() RETURN count(r) AS relCount
```

## Phase 3: 一時ファイルの削除

```bash
rm -rf docs/design-session/
```

## 破損・消失時のリストア

```bash
docker compose down
rm -rf data/neo4j
docker compose up -d
docker compose exec neo4j cypher-shell \
  -u neo4j -p password \
  --file /var/lib/neo4j/import/neo4j-seed.cypher
```

## 完了報告

- 全リビルド or 差分更新のどちらを実行したか
- ノード数・リレーションシップ数
- 主な変更点
