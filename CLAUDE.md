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

docs/ やソースコードを変更した場合は `/sync-graphdb` を実行する。
詳細な手順（2フェーズ構成・復元手順）は `README.md` の「DBデータの永続化と復元」を参照。
