# Data Model: カード・イベント・ステージのファイル構造再編

既存の `src/game/types.ts` のエンティティ（`GameState` `CardEffect` `MemberUpdate`
`GameEvent` `StageData` 等）は変更しない。本Specで新規に導入・変更するのは
以下のモジュール内インターフェースと `StageData.id` の命名規則のみ。

## CardDefinition（新規）

カード1件分の定義。`src/game/cards/<カード名>.ts` が1件ずつexportする。

| フィールド | 型 | 説明 |
| ---------- | ---- | ---- |
| `cost` | `number` | カードのコスト（旧 `CARD_COSTS[cardName]` 相当） |
| `applyEffect` | `(state: GameState) => { effectsToAdd: CardEffect[]; memberUpdates: MemberUpdate[] }` | カード使用時の効果。未実装カードは常に空配列を返す |

`cards/index.ts` は `CARD_REGISTRY: Record<CardName, CardDefinition>` を
`satisfies` で網羅性検証しつつ保持する。

## EventDefinition（新規）

ランダムイベント1種の定義。`src/game/events/<イベント名>.ts` が1件ずつexportする。

| フィールド | 型 | 説明 |
| ---------- | ---- | ---- |
| `roll` | `(state: GameState, activeEffects: CardEffect[]) => GameEvent \| null` | 確率判定を行い、発生すれば `GameEvent` を、しなければ `null` を返す。未実装イベントは常に `null` を返す |

`events/index.ts` は `EVENT_REGISTRY: Record<string, EventDefinition>`
（キーは既存の `EVENT_PROB` のキー名を踏襲）を保持し、
`rollRandomEvents` はこれを走査して発生イベントを集約する。

## StageData（既存、変更点のみ）

| フィールド | 変更内容 |
| ---------- | -------- |
| `id` | 命名規則を「タイプ-連番」形式に統一（例: `"poc-01"`）。既存の `"poc"` から変更 |

その他のフィールド（`name` `budget` `deadline` `initialMembers` `initialGantt`
`ganttVariants` `conditionalEvents` `initialCards`）は変更しない。

`stages/index.ts` は `STAGE_REGISTRY: Record<string, StageData>`
（キーは `StageData.id`）を保持する。

## 状態遷移

本Specは状態遷移を持つエンティティを追加しない（純粋なデータ・ロジックの再配置）。
