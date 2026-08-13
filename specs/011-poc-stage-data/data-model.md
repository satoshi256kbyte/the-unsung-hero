# Data Model: PoCステージデータ

Phase 1 output for Spec-11

## pocStage（StageData 定数）

`StageData` 型（`src/game/types.ts`）に準拠した定数オブジェクト。

### トップレベルフィールド

| フィールド | 値 | 備考 |
|---|---|---|
| `id` | `"poc"` | ステージ識別子 |
| `name` | `"PoCステージ"` | 表示名 |
| `budget` | `5_000_000` | 500万円 |
| `deadline` | `22` | 22ターン |
| `ganttVariants` | `{}` | バリアントなし（FR-010） |

### initialMembers（3名）

| id | name | skill | exp | morale | health |
|---|---|---|---|---|---|
| `"alice"` | `"アリス"` | 12 | 0 | 100 | 100 |
| `"bob"` | `"ボブ"` | 8 | 0 | 100 | 100 |
| `"carol"` | `"キャロル"` | 6 | 0 | 100 | 100 |

### initialGantt.tasks（9タスク）

PoC工程を要件定義→設計→実装→テスト→リリース準備の5フェーズに分割する。

| id | name | phase | startTurn | duration | assignedMemberId | dependencies |
|---|---|---|---|---|---|---|
| `"t01"` | `"要件定義"` | `"要件定義"` | 1 | 3 | `"alice"` | `[]` |
| `"t02"` | `"UI設計"` | `"設計"` | 4 | 3 | `"alice"` | `["t01"]` |
| `"t03"` | `"DB設計"` | `"設計"` | 4 | 2 | `"bob"` | `["t01"]` |
| `"t04"` | `"API実装"` | `"実装"` | 7 | 5 | `"alice"` | `["t02","t03"]` |
| `"t05"` | `"フロント実装"` | `"実装"` | 7 | 5 | `"carol"` | `["t02"]` |
| `"t06"` | `"バックエンド実装"` | `"実装"` | 7 | 4 | `"bob"` | `["t03"]` |
| `"t07"` | `"単体テスト"` | `"テスト"` | 12 | 4 | `"bob"` | `["t04","t06"]` |
| `"t08"` | `"結合テスト"` | `"テスト"` | 14 | 4 | `"carol"` | `["t05","t07"]` |
| `"t09"` | `"リリース準備"` | `"リリース準備"` | 18 | 4 | `"alice"` | `["t08"]` |

全タスク `progress: 0`、`status: "active"`、`variantId: null`。

タスク終了確認:

- 最終タスク t09: `startTurn(18) + duration(4) = 22 <= deadline(22)` ✓
- 依存関係に循環なし ✓
- 全 `assignedMemberId` が `initialMembers` に存在する ✓

### conditionalEvents（5件）

| id | turn | condition | eventType | category | 説明 |
|---|---|---|---|---|---|
| `"ce01"` | 5 | `turn >= 5` | `"ネガティブ"` | `"進捗ダウン"` | 中間チェック・進捗遅延警告 |
| `"ce02"` | 10 | `completion_rate < 0.4` | `"ネガティブ"` | `"デバフ系"` | 前半終了時の進捗不足 |
| `"ce03"` | 12 | `any_member_morale < 60` | `"ネガティブ"` | `"メンバー稼働系"` | メンバー士気低下 |
| `"ce04"` | 16 | `budget_remaining <= 1500000` | `"ネガティブ"` | `"スコープ変化系"` | 予算逼迫アラート |
| `"ce05"` | 18 | `completion_rate >= 0.8` | `"ポジティブ"` | `"バフ系"` | 終盤の高進捗ボーナス |

各イベントの `params` は `{ message: string, category: string }` を持つ。

### initialCards（3枚）

`["デイリー", "レビュー", "モニタリング"]`

PM実践の基本セットとしてPoCステージ標準装備カードを選択。

## 依存関係グラフ（DAG確認）

```text
t01 → t02 → t04 → t07 → t08 → t09
t01 → t03 → t04
t01 → t03 → t06 → t07
t02 → t05 → t08
```

循環なし ✓
