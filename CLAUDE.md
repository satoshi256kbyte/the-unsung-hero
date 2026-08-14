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

**グラフDBが「正」の状態。** 設計内容・経緯（ADR）はすべてグラフDBに格納されている。

### 参照方法

1. Neo4jコンテナが停止中の場合は `docker compose up -d` で起動する
2. ファイルを直接読む前に `read_neo4j_cypher` でグラフDBを参照して全体像を把握する
3. ADRも格納されているため、「なぜそう決まったか」もグラフDBで確認できる

```cypher
// 設計概要の確認
MATCH (n) RETURN labels(n) AS label, count(n) AS cnt ORDER BY cnt DESC

// 特定の決定経緯を確認
MATCH (adr:ADR)-[:AFFECTS]->(n {name: '調べたいノード名'})
RETURN adr.title, adr.decision, adr.rationale
```

### 進捗確認

**Specの実装進捗は基本的にグラフDBで確認する。** `docs/sdd-tasks.md` はチェックリストの体裁だが、
各Documentノードの `status` プロパティ（`completed` / `implemented` / `all-pass` 等）が正の情報源。

```cypher
// 全Specの進捗確認
MATCH (d:Document) WHERE d.name STARTS WITH 'Spec-'
RETURN d.name AS name, d.type AS type, d.status AS status
ORDER BY name
```

### docs/ の役割

設計内容・経緯は例外なくすべてグラフDBに格納する。AIはグラフDBだけを見れば全体像が分かる状態を維持する。

docs/ はその一部を、人間が読みやすい形式で**二重管理として**置いているファイル群。
グラフDBの代わりではなく、グラフDBの内容のうち下記に該当するものをMarkdown等の形でも
併存させているだけなので、docs/ に書いてよい内容を制限する意図はない。

| docs/ に置く形式 | 例 |
| --------- | ----- |
| 数値・計算式・係数 | バランスパラメータ.md |
| イベント・カード一覧 | イベント.md / カード.md |
| ステージデータ | 条件付きイベントJSON、ガントチャート定義 |
| 画面構成図 | Mermaidダイアグラム |

### 設計フロー

設計会話で決まった内容は以下の手順で管理する。

1. 設計決定事項と経緯（ADR）を `docs/design-session/YYYY-MM-DD-<topic>.md` に書き留める
2. セッション終了時に `/sync-graphdb` を実行してグラフDBへ反映（Fix）
3. 一時ファイルは sync-graphdb スキルが自動削除する

一時ファイルのフォーマット:

```markdown
## 設計決定事項
（変更するノード・プロパティ・リレーションシップ）

## ADR
- **タイトル**: 決定の短いタイトル
- **背景**: 何が問題だったか
- **決定**: 何をどう決めたか
- **理由**: なぜその選択か・却下した代替案
- **影響**: トレードオフ・今後への影響
```

`docs/design-session/` は `.gitignore` に登録済み（Git管理外）。
DB復元手順は `README.md` の「DBデータの永続化と復元」を参照。
