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

### 設計フロー

グラフDBが「正」の状態。設計会話で決まった内容は以下の手順で管理する。

1. 設計決定事項を `docs/design-session/YYYY-MM-DD-<topic>.md` に書き留める
2. セッション終了時に `/sync-graphdb` を実行してグラフDBへ反映（Fix）
3. 一時ファイルは sync-graphdb スキルが自動削除する

`docs/design-session/` は `.gitignore` に登録済み（一時ファイルのためGit管理外）。
詳細な手順は `README.md` の「DBデータの永続化と復元」を参照。
