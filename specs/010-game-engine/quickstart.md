# Quickstart: GameEngine（フルターンループ）

## 前提条件

```bash
npm install
npm run typecheck
```

## シナリオ A: 初期化

```typescript
import { GameEngine } from "./src/game/engine.js";

const engine = new GameEngine(stageData);
const state = engine.getState();

console.log(state.turn);         // → 1
console.log(state.isGameOver);   // → false
console.log(engine.isGameOver()); // → false
```

**期待結果**: turn=1、isGameOver=false

## シナリオ B: 1ターン実行

```typescript
const result = engine.processTurn([]);
const stateAfter = engine.getState();

console.log(stateAfter.turn);       // → 2
console.log(stateAfter.totalCost);  // → (初期値 + costDelta)
console.log(result.events);         // → GameEvent[]
```

**期待結果**: ターン後に turn が 2 になり totalCost が増加する

## シナリオ C: 複数ターン実行

```typescript
let turn = 1;
while (!engine.isGameOver() && turn <= 30) {
  const result = engine.processTurn([]);
  console.log(`Turn ${turn}: isGameOver=${result.isGameOver}`);
  turn++;
}
console.log("Final state:", engine.getState().gameOverReason);
```

**期待結果**: 全タスク完了または納期超過でループが終了し、gameOverReason が設定される

## シナリオ D: ゲームオーバー後の操作ガード

```typescript
// ゲームオーバーになるまで進める
while (!engine.isGameOver()) {
  engine.processTurn([]);
}

// ゲームオーバー後の呼び出し → 例外
try {
  engine.processTurn([]);
} catch (e) {
  console.log("Expected error:", e.message); // → "Game is already over"
}
```

**期待結果**: ゲームオーバー後の呼び出しが例外をスローする

## シナリオ E: memberUpdates クランプ確認

```typescript
// 士気が 10 のメンバーに複数のネガティブイベントが重なったとき
// morale が 0 未満にならないことを確認
const state = engine.getState();
for (const member of state.members) {
  console.log(`${member.name}: morale=${member.morale}, health=${member.health}`);
  // morale は 0〜150、health は 0〜100 の範囲内
}
```

## 検証コマンド

```bash
# テスト実行
npm test

# カバレッジ確認
npm run test:coverage

# アーキテクチャ境界チェック
grep -r "phaser\|document\.\|window\." src/game/engine.ts && echo "VIOLATION" || echo "OK"

# 型チェック
npm run typecheck
```
