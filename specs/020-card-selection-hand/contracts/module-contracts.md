# Contracts: カード選択・手札への組み込み機能

**Spec**: [spec.md](../spec.md) | **Data Model**: [../data-model.md](../data-model.md) | **Date**: 2026-08-30

本フィーチャーが公開・変更するモジュール契約（型・関数シグネチャ）。外部 API は持たず、
ゲームロジック層（`src/game/`）の内部契約が中心。

## 型契約（`src/game/types.ts`）

```typescript
export interface CardPoolEntry {
  readonly name: CardName;
  readonly weight: number; // 出やすさ（相対重み、> 0）
  readonly maxDraws?: number; // ステージ中の配布回数上限（省略時は無制限）
}

export interface StageData {
  // 既存フィールドに加えて:
  cardPool: CardPoolEntry[];
  handLimit: number;
}

export interface GameState {
  // 既存フィールドに加えて:
  drawCounts: Record<string, number>; // カード名 → 累計配布回数
}
```

## 配布ロジック契約（`src/game/deck.ts`、新規・純関数）

```typescript
/** maxDraws 未到達で配布可能なプールエントリを返す */
export function eligibleEntries(
  pool: CardPoolEntry[],
  drawCounts: Record<string, number>,
): CardPoolEntry[];

/**
 * 手札を handLimit まで補充する。純関数。
 * rng は [0,1) を返す関数（デフォルト Math.random）。テストで決定論的に注入可能。
 * 配布可能カードが尽きたら不足のまま打ち切る（エラーにしない）。
 */
export function drawCards(
  pool: CardPoolEntry[],
  drawCounts: Record<string, number>,
  hand: CardName[],
  handLimit: number,
  rng?: () => number,
): { hand: CardName[]; drawCounts: Record<string, number> };
```

- `src/game/` に置き、Phaser/DOM を import しない（Constitution 原則 I）。
- `drawCards` は入力を変更せず新しい `hand`/`drawCounts` を返す（純関数）。

## engine 契約（`src/game/engine.ts`、挙動追加）

```typescript
// buildInitialState: drawCounts を initialCards から初期化
// processTurn: 既存処理の後、次ターン開始時点の手札を drawCards で handLimit まで補充する
processTurn(cards: { name: CardName; targetId?: string }[]): TurnResult; // シグネチャ不変
```

## スキーマ契約（`src/game/schemas/stageData.ts`）

- `cardPool`: `z.array(z.object({ name, weight: z.number().positive(),
  maxDraws: z.number().int().positive().optional() }))`、既定 `[]`
- `handLimit`: `z.number().int().positive()`、既定は initialCards 長

## 互換性契約

- `turn.ts` の `processTurn(state, cards, conditionalEvents?)` シグネチャは変更しない。
  補充は engine 側で行う。
- `applyCards` / カードレジストリ（`cards/index.ts`）のシグネチャは変更しない。
- 既存の `initialCards` は初期配布として存続。既存ステージ JSON は cardPool/handLimit を
  省略してもロードできる（既定値補完）。ただし poc-01 は本フィーチャーで cardPool を定義する。
- UI（MainGameUI）の手札表示（`state.hand` を描画）は変更不要。手札の構成方法のみが変わる。
