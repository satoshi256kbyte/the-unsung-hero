# Implementation Plan: GameEngine（フルターンループ）

**Branch**: `010-game-engine` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Summary

`src/game/engine.ts` を新規作成し、GameState を内部管理する `GameEngine` クラスを実装する。
`processTurn(cards)` でターン処理を実行し、progressUpdates・memberUpdates・costDelta・
isGameOver を GameState に反映する。ゲームオーバー後の操作は例外でガードする。

## Technical Context

**Language/Version**: TypeScript 5 (strict mode)

**Primary Dependencies**: Vitest + fast-check（テスト）

**Storage**: N/A（pure in-memory）

**Testing**: Vitest + fast-check

**Target Platform**: Node.js（Vitest 環境）、ブラウザ（Vite バンドル後）

**Project Type**: ゲームロジック ライブラリ（Phaser/DOM 非依存）

**Performance Goals**: 単体ターン処理 < 1ms

**Constraints**: Phaser/DOM インポート禁止（アーキテクチャ境界）

**Scale/Scope**: engine.ts 〜120行、engine.test.ts 〜200行

## Constitution Check

| 原則 | 状態 | 備考 |
|------|------|------|
| Architecture Boundaries | PASS | src/game/ 内に実装、Phaser/DOM 非依存 |
| Test Coverage Gates | PASS | lines/functions ≥ 80% 維持必須 |
| Game Balance Invariant | N/A | エンジン層はロジックを呼び出すだけ |
| Design Knowledge in Graph DB | PASS | after_specify フック済み（ADR-013 追加済み） |
| Dependency Hygiene | PASS | 新規依存なし |

## Key Decisions

### KD-1: GameEngine クラス設計

```typescript
export class GameEngine {
  private state: GameState;
  private readonly conditionalEvents: ConditionalEvent[];

  constructor(stageData: StageData)
  processTurn(cards: CardName[]): TurnResult
  getState(): GameState       // shallow copy を返す
  isGameOver(): boolean
}
```

`conditionalEvents` は `stageData.conditionalEvents` をコンストラクタで受け取り内部保持する。
GameState には含めない（ADR-013）。

### KD-2: 初期 GameState の構築

```typescript
this.state = {
  turn: 1,
  members: [...stageData.initialMembers],
  gantt: { ...stageData.initialGantt },
  totalCost: 0,
  budget: stageData.budget,
  deadline: stageData.deadline,
  hand: [...stageData.initialCards],
  activeEffects: [],
  transparency: MEMBER_PARAMS.TRANSPARENCY.INITIAL,
  tension: MEMBER_PARAMS.TENSION.INITIAL,
  isGameOver: false,
  gameOverReason: null,
};
```

### KD-3: progressUpdates の適用方式

`updateTaskProgress` は progress===100 で status を `done` に変更する（gantt.ts:8-15）。
stall イベント検出は `result.events` から id プレフィックスで判定し `setTaskStatus` で `stalled`
に設定する。

```typescript
const updatedTasks = state.gantt.tasks.map((task) => {
  const pu = result.progressUpdates.find((p) => p.taskId === task.id);
  const updated = pu ? updateTaskProgress(task, pu.delta) : task;
  const isStalled = result.events.some(
    (e) => e.id.startsWith("stall") && e.targetId === task.id
  );
  return isStalled ? setTaskStatus(updated, "stalled") : updated;
});
```

### KD-4: memberUpdates の集計と適用

同一メンバーへの複数エントリを合算してからクランプ適用する:

```typescript
const updatedMembers = state.members.map((member) => {
  const updates = result.memberUpdates.filter((u) => u.memberId === member.id);
  const moraleDelta = updates.reduce((acc, u) => acc + u.moraleDelta, 0);
  const healthDelta = updates.reduce((acc, u) => acc + u.healthDelta, 0);
  const skillDelta  = updates.reduce((acc, u) => acc + (u.skillDelta  ?? 0), 0);
  const expDelta    = updates.reduce((acc, u) => acc + (u.expDelta    ?? 0), 0);
  return {
    ...member,
    morale: clamp(member.morale + moraleDelta, MEMBER_PARAMS.MORALE.MIN, MEMBER_PARAMS.MORALE.MAX),
    health: clamp(member.health + healthDelta, MEMBER_PARAMS.HEALTH.MIN, MEMBER_PARAMS.HEALTH.MAX),
    skill:  clamp(member.skill + skillDelta,   MEMBER_PARAMS.SKILL.MIN,  MEMBER_PARAMS.SKILL.MAX),
    exp:    Math.max(member.exp + expDelta, MEMBER_PARAMS.EXP.MIN),
  };
});
```

### KD-5: ゲーム終了ガード

ゲームオーバー後の `processTurn` 呼び出しは即座に例外をスローする:

```typescript
if (this.state.isGameOver) {
  throw new Error("Game is already over");
}
```

ターン処理後は `state.turn += 1` して TurnResult を返す。

### KD-6: getState() の戻り値

外部からの直接変更を防ぐため shallow copy を返す:

```typescript
getState(): GameState {
  return { ...this.state };
}
```

## Project Structure

### Documentation (this feature)

```text
specs/010-game-engine/
├── plan.md              # This file
├── data-model.md        # クラス設計・更新フロー
├── quickstart.md        # 検証シナリオ
└── tasks.md             # /speckit-tasks コマンド出力
```

### Source Code

```text
src/game/
└── engine.ts            # NEW: GameEngine クラス

tests/unit/
└── engine.test.ts       # NEW: 単体テスト + fast-check
```
