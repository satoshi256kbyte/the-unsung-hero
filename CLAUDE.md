# The Unsung Hero

プロジェクトマネジメント×SRPGのシミュレーションゲーム。

## コミットメッセージ

Conventional Commits 形式＋日本語で記述する。

```
<type>: <日本語の要約>

<本文（任意、日本語）>
```

type の例: feat, fix, docs, refactor, chore, test, style

## ナレッジグラフ

設計・コードの内容を確認する際は、まずMCP経由でNeo4jグラフDBを参照すること。
グラフDBにはプロジェクトのドキュメントやコードから抽出したナレッジが格納されている。

### 使い方

1. Neo4jコンテナが停止中の場合は `docker compose up -d` で起動する
2. `read_neo4j_cypher` でグラフを検索し、コンテキストを得る
3. ファイルを直接読む前にグラフDBで全体像を把握する

### データ更新

docs/ やソースコードを変更した場合、ターン終了時に自動でグラフDBが更新される。
手動で更新する場合は `/sync-graphdb` を実行する。
