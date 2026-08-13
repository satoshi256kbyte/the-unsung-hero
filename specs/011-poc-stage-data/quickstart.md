# Quickstart Validation Guide: PoCステージデータ

Phase 1 output for Spec-11

## Prerequisites

- Node.js 20+ インストール済み
- `npm install` 完了済み

## セットアップコマンド

```sh
npm install
```

## テスト実行

```sh
# ユニットテストのみ実行
npx vitest run tests/unit/stages/pocStage.test.ts

# 全ユニットテスト + カバレッジ確認
npx vitest run --coverage

# 型チェック
npx tsc --noEmit
```

## 検証シナリオ

### シナリオ 1: GameEngine 初期化（SC-001）

```ts
import { GameEngine } from "../../src/game/engine.js";
import { pocStage } from "../../src/game/stages/pocStage.js";

const engine = new GameEngine(pocStage);
const state = engine.getState();

assert(state.turn === 1);
assert(state.members.length === 3);
assert(state.budget === 5_000_000);
assert(state.deadline === 22);
assert(state.hand.length === 3);
```

### シナリオ 2: ガントタスク整合性（SC-002・SC-003）

```ts
const state = new GameEngine(pocStage).getState();

// 全タスクが deadline 以内
state.gantt.tasks.forEach(t => {
  assert(t.startTurn + t.duration <= 22);
});

// 依存循環なし（トポロジカルソート）
const taskIds = new Set(state.gantt.tasks.map(t => t.id));
state.gantt.tasks.forEach(t => {
  t.dependencies.forEach(dep => assert(taskIds.has(dep)));
});
```

### シナリオ 3: 条件付きイベント検証（SC-004）

```ts
const validPatterns = [
  /^turn\s*(>=|<=|==)\s*\d+$/,
  /^completion_rate\s*(>=|<)\s*[\d.]+$/,
  /^budget_remaining\s*<=\s*\d+$/,
  /^any_member_morale\s*<\s*\d+$/,
  /^any_member_health\s*<\s*\d+$/,
  /^all_members_morale\s*<\s*\d+$/,
];

pocStage.conditionalEvents.forEach(ce => {
  const matched = validPatterns.some(p => p.test(ce.condition));
  assert(matched, `条件式 "${ce.condition}" が無効パターン`);
});
```

### シナリオ 4: 22ターン進行テスト（SC-005）

```ts
const engine = new GameEngine(pocStage);
for (let i = 0; i < 22; i++) {
  if (engine.isGameOver()) break;
  engine.processTurn([]);
}
// 例外が出ないことを確認
```

## 期待する結果

| テスト | 期待値 |
|---|---|
| `npx vitest run` | 全テスト PASS |
| `npx tsc --noEmit` | エラー 0 |
| カバレッジ（src/game/\*\*） | lines ≥ 80%, functions ≥ 80%, branches ≥ 75% |
