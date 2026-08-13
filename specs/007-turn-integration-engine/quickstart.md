# Quickstart: ターン統合エンジン検証ガイド

## 前提

```bash
docker compose up -d   # Neo4j（任意）
npx tsc --noEmit       # 型チェック 0 エラー確認
```

## シナリオ A: デイリーカードがアクティブ効果に追加される

```typescript
import { processTurn } from "./src/game/turn.js";

const state = makeBaseState(); // activeEffects: []
const result = processTurn(state, ["デイリー"]);

// activeEffectsAdded に task_event_prob_reduced が含まれる
assert(result.activeEffectsAdded.some(e => e.effectType === "task_event_prob_reduced"));
// activeEffectsAfterTick にも引き継がれる（remainingTurns=null は tick で除去されない）
assert(result.activeEffectsAfterTick.some(e => e.effectType === "task_event_prob_reduced"));
```

## シナリオ B: レビューカードで手戻り確率が半減する

cards=["レビュー"] のターンでは `rework_prob_reduced` 効果が currentEffects に追加され、
手戻りイベント判定に使われる確率が `EVENT_PROB.REWORK * 0.5 = 0.04` になる。
決定論的テストでは `Math.random` をモックして確率補正の分岐を検証する。

```typescript
const result = processTurn(state, ["レビュー"]);
assert(result.activeEffectsAdded.some(e => e.effectType === "rework_prob_reduced"));
```

## シナリオ C: 個別面談カードでメンバー morale が即時回復する

```typescript
const result = processTurn(state, ["個別面談"]);
const cardUpdate = result.memberUpdates.find(u => u.memberId === "m1");
assert(cardUpdate !== undefined);
assert(cardUpdate.moraleDelta > 0); // PARAM_DELTA.ONE_ON_ONE_MORALE(15) - decay 分
```

## シナリオ D: applyEffectTick で期限付き効果が除去される

```typescript
import { applyEffectTick } from "./src/game/effect.js";

const effects = [
  { cardName: "デイリー", targetId: "project",
    effectType: "task_event_prob_reduced", remainingTurns: 1 },
  { cardName: "レビュー", targetId: "project",
    effectType: "rework_prob_reduced", remainingTurns: null },
];
const after = applyEffectTick(effects);
// remainingTurns=1 の効果は除去される
assert(after.length === 1);
assert(after[0].effectType === "rework_prob_reduced");
```

## シナリオ E: calcEventProbModifier の確率補正

```typescript
import { calcEventProbModifier } from "./src/game/effect.js";

const effects = [
  { cardName: "レビュー", targetId: "project",
    effectType: "rework_prob_reduced", remainingTurns: null },
];
const prob = calcEventProbModifier(effects, 0.08, "rework_prob_reduced");
assert(prob === 0.04); // 0.08 * 0.5

const probNoEffect = calcEventProbModifier([], 0.08, "rework_prob_reduced");
assert(probNoEffect === 0.08); // そのまま
```

## 検証コマンド

```bash
npx tsc --noEmit
npx vitest run tests/unit/effect.test.ts
npx vitest run tests/unit/turn.test.ts
npx vitest run --coverage
grep -r "phaser\|document\|window" src/game/effect.ts  # 0件
```
