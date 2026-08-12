# Data Model: Core Types and Constants

## エンティティ定義

### Member

ゲームメンバー1人を表す。

| フィールド | 型 | 範囲 | 説明 |
|-----------|-----|------|------|
| id | string | — | ユニーク識別子 |
| name | string | — | 表示名 |
| skill | number | 0〜99（整数） | 技レベル。進捗ダイスの安定性に影響 |
| exp | number | 0以上（整数） | 経験値。次レベルアップまでの累積値 |
| morale | number | 0〜150（整数） | 心。低/高でネガティブイベント発生 |
| health | number | 0〜100（整数） | 体。低いと進捗下振れ・体調不良確率上昇 |

---

### Card

PMが使用できるカードを表す。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| name | CardName（union型） | カード識別子 |
| cost | number | コスト（1/2/3/4/6のいずれか） |
| applicationMode | 'immediate' \| 'set-auto' \| 'set-manual' | 適用方式 |
| targetType | 'pm' \| 'member' \| 'task' \| 'project' | 対象種別 |

**CardName union型（全カード）**:
`デイリー` `デイリー中止` `レビュー` `モニタリング` `サマライズ` `臨時MTG` `臨時モニタリング`
`臨時サマライズ` `教育` `ペアプログラミング` `雑談` `停滞対応` `個別面談` `表彰` `計画休`
`残業許可` `アサイン` `入れ替え` `巻取り` `進捗ブースト` `強制締め` `リスケ`
`メンバー追加` `休出` `納期交渉` `スコープ交渉`

---

### CardEffect

カード使用によってセットされた持続状態を表す。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| cardName | CardName | 発生源カード |
| targetId | string | 対象（メンバーIDまたは 'project'） |
| effectType | EffectType | 効果の種別 |
| remainingTurns | number \| null | 残存ターン数（null = 手動解除まで継続） |

---

### GanttTask

ガントチャート上の1タスクを表す。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | string | タスク識別子 |
| name | string | タスク名 |
| phase | string | 所属工程（'設計' \| '実装' \| 'テスト' 等） |
| startTurn | number | 開始ターン（1-indexed） |
| duration | number | 計画期間（ターン数） |
| assignedMemberId | string | 担当メンバーID |
| progress | number | 現在進捗（0.0〜100.0） |
| status | 'active' \| 'stalled' \| 'done' | タスク状態 |
| dependencies | string[] | 先行タスクID一覧 |

---

### GanttChart

ガントチャート全体を表す。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| tasks | GanttTask[] | タスク一覧 |
| variantId | string \| null | 適用中バリアントID（null = デフォルト） |

---

### GameState

ある時点のゲーム全体の状態スナップショット。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| turn | number | 現在ターン（1-indexed） |
| members | Member[] | メンバー一覧 |
| gantt | GanttChart | ガントチャート |
| totalCost | number | 総消費コスト |
| budget | number | 予算 |
| deadline | number | 納期ターン |
| hand | CardName[] | 手持ちカード |
| activeEffects | CardEffect[] | 有効エフェクト一覧 |
| transparency | number | 透明性（0〜150） |
| tension | number | 緊張感（0〜150） |
| isGameOver | boolean | ゲームオーバーフラグ |
| gameOverReason | string \| null | ゲームオーバー理由 |

---

### TurnResult

1ターン実行後の差分情報。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| events | GameEvent[] | 発生したイベント一覧 |
| progressUpdates | ProgressUpdate[] | タスクごとの進捗変化 |
| memberUpdates | MemberUpdate[] | メンバーパラメータ変化 |
| costDelta | number | このターンの追加コスト |
| isGameOver | boolean | ゲームオーバー判定 |
| gameOverReason | string \| null | ゲームオーバー理由 |

---

### StageData

ステージの静的定義データ（ランタイム状態ではなく初期設定）。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | string | ステージID（例: 'poc'） |
| name | string | ステージ名 |
| budget | number | 予算 |
| deadline | number | 納期ターン数 |
| initialMembers | Member[] | 初期メンバー構成 |
| initialGantt | GanttChart | 初期ガントチャート |
| ganttVariants | Record\<string, GanttChart\> | バリアント一覧（キー = バリアントID） |
| conditionalEvents | ConditionalEvent[] | 条件付きイベント定義 |
| initialCards | CardName[] | 初期配布カード |

---

### ConditionalEvent

条件付きイベントの定義（ステージデータの一部）。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | string | イベントID |
| turn | number | 条件評価ターン |
| condition | string | 条件式（評価は別モジュールが担当） |
| eventType | EventType | 発生するイベント種別 |
| params | Record\<string, unknown\> | イベントパラメータ |

---

### GameEvent

発生したイベントの記録。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | string | イベントID |
| type | EventType | イベント種別 |
| category | EventCategory | イベントカテゴリ |
| targetId | string \| null | 対象タスク/メンバーID |
| params | Record\<string, unknown\> | 付随パラメータ |

---

## 定数・型の依存関係

```
types.ts
  └── CardName, EventType, EventCategory, EffectType（union/enum型）
  └── Member, Card, CardEffect, GanttTask, GanttChart
  └── GameState, TurnResult, StageData, ConditionalEvent, GameEvent
  └── ProgressUpdate, MemberUpdate（補助型）

constants.ts（types.ts に依存）
  └── BALANCE: バランス数値定数オブジェクト
  └── CARD_COSTS: Record<CardName, number>
  └── LEVEL_UP_EXP: レベルアップ必要経験値テーブル

balance.ts（constants.ts, types.ts に依存）
  └── getSkillFactorRange(skill: number): [number, number]
  └── getHealthFactor(health: number): [number, number]
```
