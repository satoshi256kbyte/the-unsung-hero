# Quickstart Validation Guide: カード効果エンジン

## 前提条件

- Node.js 20+
- `npm install` 済み
- Spec-01（types.ts / constants.ts）実装済み

## 実装後の検証手順

### 1. 型チェック

```bash
npx tsc --noEmit
```

期待結果: エラー 0 件

### 2. ユニットテスト実行

```bash
npx vitest run tests/unit/card.test.ts
```

期待結果: 全テスト PASS

### 3. DOM/Phaser 依存がないことを確認

```bash
grep -r "phaser\|document\|window" src/game/card.ts
```

期待結果: マッチ 0 件

### 4. 全テストスイート + カバレッジ

```bash
npx vitest run --coverage
```

期待結果: lines / functions ≥ 80%

## 検証シナリオ

### シナリオ A: 確率低減カード3種（グループA）

```typescript
import { applyCards } from "../src/game/card.js";
import type { GameState } from "../src/game/types.js";

const state: GameState = {
  turn: 1, deadline: 22,
  members: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 }],
  gantt: { tasks: [], variantId: null },
  totalCost: 0, budget: 200,
  hand: [], activeEffects: [],
  transparency: 100, tension: 100,
  isGameOver: false, gameOverReason: null,
};

const result = applyCards(state, ["デイリー", "レビュー", "モニタリング"]);

console.assert(result.effectsToAdd.some(e => e.effectType === "task_event_prob_reduced"));
console.assert(result.effectsToAdd.some(e => e.effectType === "rework_prob_reduced"));
console.assert(result.effectsToAdd.some(e => e.effectType === "overreport_prob_reduced"));
console.assert(result.effectsToAdd.every(e => e.targetId === "project"));
console.assert(result.effectsToAdd.every(e => e.remainingTurns === null));
console.assert(result.memberUpdates.length === 0);
```

### シナリオ B: 即時メンバー系（グループB）

```typescript
const resultB = applyCards(state, ["個別面談"]);
console.assert(resultB.memberUpdates[0]?.moraleDelta === 15);
console.assert(resultB.memberUpdates[0]?.healthDelta === 0);
console.assert(resultB.effectsToAdd.length === 0);

const resultC = applyCards(state, ["計画休"]);
console.assert(resultC.memberUpdates[0]?.moraleDelta === 20);
console.assert(resultC.memberUpdates[0]?.healthDelta === 25);
```

### シナリオ C: メンバー 0 人のとき panic しない

```typescript
const emptyState = { ...state, members: [] };
const resultD = applyCards(emptyState, ["個別面談", "表彰", "計画休"]);
console.assert(resultD.memberUpdates.length === 0); // panic しない
```

### シナリオ D: 空配列・スコープ外カード

```typescript
const resultE = applyCards(state, []);
console.assert(resultE.effectsToAdd.length === 0);
console.assert(resultE.memberUpdates.length === 0);

const resultF = applyCards(state, ["納期交渉", "スコープ交渉"]);
console.assert(resultF.effectsToAdd.length === 0);
console.assert(resultF.memberUpdates.length === 0);
```

### シナリオ E: イミュータブル確認

```typescript
const membersBefore = JSON.stringify(state.members);
applyCards(state, ["個別面談", "デイリー"]);
console.assert(JSON.stringify(state.members) === membersBefore);
```

## fast-check プロパティテストのポイント

任意の合法 GameState と CardName[] を入力しても panic しないことを確認。

| 不変条件 | 確認方法 |
|---------|---------|
| 例外なし | 任意の GameState・cards で applyCards を呼ぶ |
| effectsToAdd の effectType が有効な EffectType | 各エントリで型チェック |
| memberUpdates の moraleDelta / healthDelta が有限数 | Number.isFinite で確認 |
| GameState が変化しない | 呼び出し前後で state を比較 |
