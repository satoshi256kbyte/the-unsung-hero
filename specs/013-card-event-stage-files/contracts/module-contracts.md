# Module Contracts: カード・イベント・ステージのファイル構造再編

本Specは外部API（HTTP等）を持たないため、`src/game/` 内の各サブモジュールが
互いに対して守るべきインターフェース契約を記載する。

## `src/game/cards/index.ts` が公開する契約

```typescript
export interface CardDefinition {
  readonly cost: number;
  applyEffect(state: GameState): {
    effectsToAdd: CardEffect[];
    memberUpdates: MemberUpdate[];
  };
}

export const CARD_REGISTRY: Record<CardName, CardDefinition>;

export function applyCards(state: GameState, cards: CardName[]): CardApplicationResult;
```

`applyCards` のシグネチャ・戻り値の型（`CardApplicationResult`）は
既存の `card.ts` と完全に同一で、呼び出し側（`turn.ts` 等）の変更を要求しない。

## `src/game/events/index.ts` が公開する契約

```typescript
export interface EventDefinition {
  roll(state: GameState, activeEffects: CardEffect[]): GameEvent | null;
}

export const EVENT_REGISTRY: Record<string, EventDefinition>;

export function rollRandomEvents(state: GameState, activeEffects: CardEffect[]): GameEvent[];
export function applyEventToProgress(event: GameEvent, progressMap: Map<string, number>): Map<string, number>;
export function applyEventToMember(event: GameEvent, member: Member): Member;
```

`rollRandomEvents` `applyEventToProgress` `applyEventToMember` のシグネチャは
既存の `event.ts` と完全に同一で、呼び出し側の変更を要求しない。

## `src/game/stages/index.ts` が公開する契約

```typescript
export const STAGE_REGISTRY: Record<string, StageData>;
```

`poc-01.ts` の `export const stage: StageData` を `STAGE_REGISTRY["poc-01"]` として
参照できる。既存の `MainScene.ts` からの参照は
`import { pocStage } from "../game/stages/pocStage.js"` から
`import { STAGE_REGISTRY } from "../game/stages/index.js"`
（または `poc-01.ts` を直接import）に変更する。

## 互換性契約

- `card.ts` `event.ts` の廃止に伴い、これらから外部にexportされていた関数
  （`applyCards` `rollRandomEvents` `applyEventToProgress` `applyEventToMember`）は
  すべて同名・同シグネチャで新モジュールから再exportされる
- `constants.ts` から `CARD_COSTS` `EVENT_PROB` を除去した後、これらを参照していた
  `src/ui/MainGameUI.ts` は `CARD_REGISTRY[name].cost` を参照するように変更する
