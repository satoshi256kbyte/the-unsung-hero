# Data Model: バランスデータのJSON外部化

既存の`src/game/types.ts`のエンティティ（`GameState` `CardEffect` `MemberUpdate`
`GameEvent` `StageData`等）は変更しない。本Specで新規に導入するのは
JSONファイルの形状（zodスキーマ）と、それを保持する設定シングルトンのみ。

## CardData（新規、JSON形状）

`public/data/cards/<name>.json`。

| フィールド | 型 | 説明 |
| ---------- | ---- | ---- |
| `cost` | `number`（整数・0以上） | カードのコスト |

## EventData（新規、JSON形状）

`public/data/events/<name>.json`。

| フィールド | 型 | 説明 |
| ---------- | ---- | ---- |
| `baseProb` | `number`（0〜1） | 基本発生確率 |
| `withDailyReviewProb`等 | `number`（0〜1、任意） | カード使用時の派生確率（対象イベントのみ） |

## StageData（JSON形状）

既存の`StageData`インターフェース（`id` `name` `budget` `deadline`
`initialMembers` `initialGantt` `ganttVariants` `conditionalEvents`
`initialCards` `description`）と同型。`public/data/stages/poc-01.json`。

## BalanceConstants（新規、JSON形状）

`public/data/balance/constants.json`。既存`constants.ts`の各テーブルと同型。

| グループ | 内容 |
| -------- | ---- |
| `MEMBER_PARAMS` | 技・経験値・心・体・透明性・緊張感の範囲と初期値 |
| `PROGRESS_DICE` | 進捗ダイスの基本範囲 |
| `EXP` | 経験値・レベルアップ係数 |
| `LEVEL_UP_EXP` | レベルアップ必要経験値テーブル |
| `PARAM_DELTA` | パラメータ変動量一覧 |
| `THRESHOLDS` | ネガティブイベント発生閾値 |
| `STALL` | 停滞持続ターン数分布 |
| `CHECKPOINT_PROB` | 固定イベント確率 |
| `SKILL_FACTOR_TABLE` | 技レベル別skill_factorテーブル |
| `HEALTH_FACTOR_TABLE` | 体レベル別health_factorテーブル |
| `GLOBAL_RULES` | ステージ非依存のグローバルルール（旧`POC_STAGE`の非重複分） |

## GameConfig（新規、実行時シングルトン）

`src/game/config.ts`が保持する。

```typescript
export interface GameConfig {
  balance: BalanceConstants; // zodスキーマから導出
}

export function initGameConfig(data: GameConfig): void; // PreloadSceneから1回だけ呼ぶ
export function getConfig(): GameConfig; // 未初期化時は例外
```

カード・イベント・ステージのレジストリ（`CARD_REGISTRY`等）は`GameConfig`とは
別に、各`buildXxxRegistry(jsonData)`関数の戻り値として構築され、`PreloadScene`が
Phaserの`this.registry`に載せて後続Sceneへ渡す。

## 状態遷移

本Specは状態遷移を持つエンティティを追加しない。`GameConfig`は「未初期化→
初期化済み」の一方向の状態のみを持つ（`initGameConfig`は起動シーケンス中に
1回だけ呼ばれる想定）。
