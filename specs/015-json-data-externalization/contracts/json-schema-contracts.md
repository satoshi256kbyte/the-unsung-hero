# Contracts: JSONスキーマとレジストリ構築関数

本Specは外部API（HTTP等）を持たないため、JSONファイルの形状（zodスキーマ）と
`src/game/`が公開する構築関数のインターフェース契約を記載する。

## `src/game/schemas/`が公開する契約

```typescript
// cardData.ts
export const cardDataSchema = z.object({ cost: z.number().int().nonnegative() });
export type CardData = z.infer<typeof cardDataSchema>;

// eventData.ts
export const eventDataSchema = z.object({ baseProb: z.number().min(0).max(1) }).catchall(z.number());
export type EventData = z.infer<typeof eventDataSchema>;

// stageData.ts
export const stageDataSchema: z.ZodType<StageData>; // 既存StageDataと同型

// balanceConstants.ts
export const balanceConstantsSchema = z.object({
  MEMBER_PARAMS: z.object({ /* ... */ }),
  PROGRESS_DICE: z.object({ /* ... */ }),
  EXP: z.object({ /* ... */ }),
  LEVEL_UP_EXP: z.array(z.tuple([z.number(), z.number()])),
  PARAM_DELTA: z.object({ /* ... */ }),
  THRESHOLDS: z.object({ /* ... */ }),
  STALL: z.object({ /* ... */ }),
  CHECKPOINT_PROB: z.object({ /* ... */ }),
  SKILL_FACTOR_TABLE: z.array(z.tuple([z.number(), z.tuple([z.number(), z.number()])])),
  HEALTH_FACTOR_TABLE: z.array(z.tuple([z.number(), z.tuple([z.number(), z.number()])])),
  GLOBAL_RULES: z.object({
    BUFFER_RATIO: z.number(),
    TARGET_PROFIT_RATE: z.number(),
    DAILY_COST_CAP: z.number(),
    OVERTIME_COST_CAP: z.number(),
  }),
});
export type BalanceConstants = z.infer<typeof balanceConstantsSchema>;
```

不正なJSONに対して`.parse()`は`ZodError`を投げる。`PreloadScene`はこれを
キャッチせず、ゲームを起動失敗させる（US2のFR-005に対応）。

## `src/game/config.ts`が公開する契約

```typescript
export interface GameConfig {
  balance: BalanceConstants;
}

export function initGameConfig(data: GameConfig): void;
export function getConfig(): GameConfig; // 未初期化時に呼ぶと例外
```

## `src/game/{cards,events,stages}/index.ts`が公開する契約（変更点）

```typescript
// cards/index.ts
export function buildCardRegistry(costData: Record<CardName, CardData>): Record<CardName, CardDefinition>;
export function applyCards(state: GameState, cards: CardName[]): CardApplicationResult; // シグネチャ不変

// events/index.ts
export function buildEventRegistry(probData: Record<string, EventData>): Record<string, EventDefinition>;
export function rollRandomEvents(state: GameState, activeEffects: CardEffect[]): GameEvent[]; // シグネチャ不変

// stages/index.ts
export function buildStageRegistry(stageDataList: StageData[]): Record<string, StageData>;
```

`applyCards` / `rollRandomEvents` / `applyEventToProgress` / `applyEventToMember`の
シグネチャは変更しない。`buildXxxRegistry`系関数のみが新規追加され、
`PreloadScene`から一度だけ呼ばれる。

## 互換性契約

- `src/game/`内の既存関数（`getSkillFactorRange` `getHealthFactor` `applyTurnDecay`
  `rollProgress`等）のシグネチャは変更しない。内部で`constants.ts`の静的importから
  `getConfig().balance.X`への参照に変わるのみ
- `PreloadScene`より前（`BootScene`）でこれらの関数を呼び出すコードは存在しない
  ことをE2Eで確認する（`getConfig()`未初期化時の例外が発生しないこと）
