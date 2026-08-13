# Data Model: GameEngine（フルターンループ）

## クラス設計

```typescript
import { MEMBER_PARAMS } from "./constants.js";
import { setTaskStatus, updateTaskProgress } from "./gantt.js";
import { processTurn as processTurnCore } from "./turn.js";
import type {
  CardName, ConditionalEvent, GameState, StageData, TurnResult
} from "./types.js";

export class GameEngine {
  private state: GameState;
  private readonly conditionalEvents: ConditionalEvent[];

  constructor(stageData: StageData): void
  processTurn(cards: CardName[]): TurnResult   // throws if isGameOver
  getState(): GameState                         // returns shallow copy
  isGameOver(): boolean
}
```

## 初期化フロー

```
new GameEngine(stageData)
  │
  ├── this.conditionalEvents = stageData.conditionalEvents
  └── this.state = {
        turn: 1,
        members: [...stageData.initialMembers],
        gantt: { ...stageData.initialGantt },
        totalCost: 0,
        budget: stageData.budget,
        deadline: stageData.deadline,
        hand: [...stageData.initialCards],
        activeEffects: [],
        transparency: 100,
        tension: 100,
        isGameOver: false,
        gameOverReason: null,
      }
```

## processTurn フロー

```
processTurn(cards)
  │
  ├── guard: if isGameOver → throw Error
  ├── result = processTurnCore(state, cards, conditionalEvents)
  ├── updatedTasks = applyProgressUpdates(state.gantt.tasks, result)
  ├── updatedMembers = applyMemberUpdates(state.members, result.memberUpdates)
  ├── state = {
  │     ...state,
  │     gantt: { ...state.gantt, tasks: updatedTasks },
  │     members: updatedMembers,
  │     totalCost: state.totalCost + result.costDelta,
  │     turn: state.turn + 1,
  │     isGameOver: result.isGameOver,
  │     gameOverReason: result.gameOverReason,
  │     activeEffects: result.activeEffectsAfterTick,
  │   }
  └── return result
```

## progressUpdates 適用

```
for each task in gantt.tasks:
  pu = progressUpdates.find(p => p.taskId === task.id)
  updated = pu ? updateTaskProgress(task, pu.delta) : task
  isStalled = events.some(e => e.id.startsWith("stall") && e.targetId === task.id)
  finalTask = isStalled ? setTaskStatus(updated, "stalled") : updated
```

`updateTaskProgress` は progress===100 で status を `done` に変更する（Spec-02）。

## memberUpdates 集計・適用

```
for each member in members:
  updates = memberUpdates.filter(u => u.memberId === member.id)
  totalMorale = sum(updates.moraleDelta)
  totalHealth = sum(updates.healthDelta)
  totalSkill  = sum(updates.skillDelta ?? 0)
  totalExp    = sum(updates.expDelta ?? 0)

  newMember = {
    ...member,
    morale: clamp(morale + totalMorale, 0, 150),
    health: clamp(health + totalHealth, 0, 100),
    skill:  clamp(skill  + totalSkill,  0, 99),
    exp:    max(exp + totalExp, 0),
  }
```

## 型依存関係

```
engine.ts
  └── imports: turn.ts (processTurn)
  └── imports: gantt.ts (updateTaskProgress, setTaskStatus)
  └── imports: constants.ts (MEMBER_PARAMS)
  └── imports: types.ts (GameState, StageData, TurnResult, CardName, ConditionalEvent)
```
