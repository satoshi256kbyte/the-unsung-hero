# Neo4j ローカル環境セットアップ

## 目的

開発用ナレッジの格納先としてNeo4jをローカルに立てる。
優先度順に以下のユースケースを想定する。

1. AIエージェント向けコンテキスト（RAG的な知識ベース）
2. ゲーム設計ドキュメント間の概念関係のグラフ管理
3. 開発プロセスのナレッジ（技術的知見・決定事項）

データモデルは未確定。作り直しを何度も行う前提で、
破棄と再構築が容易な構成にする。

## 構成

### Docker Compose

プロジェクトルートに `docker-compose.yml` を配置。

| サービス | イメージ | ポート |
|---------|---------|--------|
| neo4j | `neo4j:5-community` | 7474（UI）, 7687（Bolt） |

- 認証あり（`NEO4J_AUTH=neo4j/password`）
- APOCプラグイン有効化（MCPサーバーのスキーマ取得に必要）
- データは named volume `neo4j_data` に保存

### MCPサーバー

Neo4j公式の `neo4j_mcp_server` を使用。

| 項目 | 値 |
| ------ | ----- |
| パッケージ | `neo4j-mcp-server` |
| 実行方法 | `uvx neo4j-mcp-server`（uv経由） |
| トランスポート | stdio |
| 接続先 | `bolt://localhost:7687` |

主要な環境変数:

| 変数 | 値 | 備考 |
| ------ | ----- | ------ |
| `NEO4J_URI` | `bolt://localhost:7687` | Bolt接続先 |
| `NEO4J_USERNAME` | `neo4j` | ユーザー名 |
| `NEO4J_PASSWORD` | `password` | パスワード |
| `NEO4J_DATABASE` | `neo4j` | デフォルトDB |
| `NEO4J_READ_ONLY` | `false` | スキルから書き込みを行うため |

設定はプロジェクトルートの `.mcp.json` に記述し、Git管理対象とする。

## ファイル構成（変更分）

| ファイル | 操作 |
| --------- | ------ |
| `docker-compose.yml` | 新規作成 |
| `.mcp.json` | 新規作成（MCPサーバー設定） |

## 運用コマンド

| 操作 | コマンド |
| ------ | --------- |
| 起動 | `docker compose up -d` |
| 停止 | `docker compose down` |
| データリセット | `docker compose down -v` |
| ブラウザUI | <http://localhost:7474> |

## 前提条件

- Docker / Docker Compose がインストール済み
- uv がインストール済み（MCPサーバー実行用）

## スコープ外

- データモデルの定義（ナレッジ書き込みスキルの責務）
- Phaser 4用コンテナの追加（将来のタスク）
- Neo4jのバックアップ・リストア手順（作り直し前提のため不要）
