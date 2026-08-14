# The Unsung Hero

プロジェクトマネジメント × SRPG のシミュレーションゲーム。
PMとなってウォーターフォール型プロジェクトを完遂し、目標利益の達成を目指す。

## ドキュメント構成

設計ドキュメントは `docs/` 配下に格納されている。

| ディレクトリ | 内容 |
| ------------ | ------ |
| `docs/01-要件定義/` | ゲーム概要、ステージ構成、勝利/失敗条件 |
| `docs/02-基本設計/` | ターン制、カード、メンバー、経済モデル、画面構成 |
| `docs/03-詳細設計/` | イベント、ターン処理フロー、カード効果、進捗ダイス |
| `docs/superpowers/specs/` | 個別機能の設計スペック |

## 開発環境

### 前提

- Node.js / npm
- Docker / Docker Compose（ナレッジグラフ用）

### アプリの起動

```bash
npm install
npm run dev
```

起動後、コンソールに表示されるURL（デフォルトは
<http://localhost:5173>）をブラウザで開く。

### ナレッジグラフ（Neo4j）

設計ドキュメントとコードから抽出したナレッジをグラフDBで管理している。

```bash
docker compose up -d
```

起動後、 <http://localhost:7474> でブラウザからアクセス可能（neo4j / password）。

### DBデータの永続化と復元

| 層 | パス | Git管理 | 説明 |
|----|------|---------|------|
| シードファイル | `db/neo4j-seed.cypher` | 対象 | 再現可能なDB再構築の基点 |
| DBデータ | `data/neo4j/` | 対象外 | コンテナのbind mount（バイナリデータ） |

DBが壊れた・消えた場合はシードファイルからワンコマンドで復元できる。

```bash
docker compose up -d
docker compose exec neo4j cypher-shell \
  -u neo4j -p password \
  --file /var/lib/neo4j/import/neo4j-seed.cypher
```

シードファイルの更新（docs/ 変更後）は `/sync-graphdb` スキルを使う。

## ライセンス

Private
