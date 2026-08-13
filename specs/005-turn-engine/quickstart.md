# Quickstart Validation Guide: ターン処理エンジン

## 前提条件

- Node.js 20+
- `npm install` 済み
- Spec-01〜04（types.ts / constants.ts / gantt.ts / dice.ts / member.ts）実装済み

## 実装後の検証手順

### 1. 型チェック

```bash
npx tsc --noEmit
```

期待結果: エラー 0 件

### 2. ユニットテスト実行

```bash
npx vitest run tests/unit/turn.test.ts
```

期待結果: 全テスト PASS

### 3. DOM/Phaser 依存がないことを確認

```bash
grep -r "phaser\|document\|window" src/game/turn.ts
```

期待結果: マッチ 0 件

### 4. 全テストスイート + カバレッジ

```bash
npx vitest run --coverage
```

期待結果: lines / functions ≥ 80%

## 検証シナリオ

### シナリオ A: 基本ターン処理

```typescript
import { processTurn } from "../src/game/turn.js";

const state: GameState = {
  turn: 1, deadline: 22,
  members: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 }],
  gantt: { tasks: [{ id: "t1", name: "設計", phase: "設計", startTurn: 1, duration: 5,
    assignedMemberId: "m1", progress: 0, status: "active", dependencies: [] }], variantId: null },
  totalCost: 0, budget: 100, hand: [], activeEffects: [], transparency: 100, tension: 100,
  isGameOver: false, gameOverReason: null,
};
const result = processTurn(state, []);

// progressUpdates に t1 の進捗変化が含まれる
console.assert(result.progressUpdates.some(u => u.taskId === "t1"));
// memberUpdates に m1 のパラメータ変化が含まれる
console.assert(result.memberUpdates.some(u => u.memberId === "m1"));
// ゲームオーバーでない
console.assert(!result.isGameOver);
// 引数の state が変化していない
console.assert(state.turn === 1);
```

### シナリオ B: 週末回復（turn=5）

```typescript
const state5 = { ...state, turn: 5 };
const result5 = processTurn(state5, []);
// healthDelta が通常より大きい（週末回復 +12 が加算されている）
const update = result5.memberUpdates.find(u => u.memberId === "m1")!;
console.assert(update.healthDelta > -3); // 通常最小 -3 より大きい
```

### シナリオ C: ゲームオーバー（全タスク完了）

```typescript
const doneState = {
  ...state,
  gantt: { tasks: [{ ...state.gantt.tasks[0], status: "done" as const }], variantId: null },
};
const result = processTurn(doneState, []);
console.assert(result.isGameOver === true);
```

### シナリオ D: ゲームオーバー（納期超過）

```typescript
const overdueState = { ...state, turn: 23, deadline: 22 };
const result = processTurn(overdueState, []);
console.assert(result.isGameOver === true);
```

## fast-check プロパティテストのポイント

任意の合法 GameState を入力しても panic しないことを確認。

| 不変条件 | 確認方法 |
|---------|---------|
| TurnResult が返る（例外なし） | 任意の GameState で processTurn を呼ぶ |
| progressUpdates の delta が有限数 | 全 update で Number.isFinite(delta) |
| isGameOver が boolean | typeof result.isGameOver === 'boolean' |
| GameState が変化しない | state のフィールドを呼び出し前後で比較 |
