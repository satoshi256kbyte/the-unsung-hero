# Data Model: 条件付きイベントエンジン

## 関数シグネチャ

### evaluateCondition

```typescript
import { getCompletionRate } from "./gantt.js";
import type { GameState } from "./types.js";

export function evaluateCondition(state: GameState, condition: string): boolean
```

**入力**:

- `state`: GameState（ターン、メンバー、ガントチャート、予算情報を含む）
- `condition`: 条件式文字列（例: `"turn >= 5"`, `"completion_rate >= 0.9"`）

**出力**: `boolean`（条件成立なら `true`、不成立または未知条件なら `false`）

**副作用**: なし（純粋関数）

### rollConditionalEvents

```typescript
import type { ConditionalEvent, GameEvent, GameState } from "./types.js";

export function rollConditionalEvents(
  state: GameState,
  conditionalEvents: ConditionalEvent[]
): GameEvent[]
```

**入力**:

- `state`: GameState
- `conditionalEvents`: ConditionalEvent[] （ステージデータから渡される）

**出力**: `GameEvent[]`（条件成立したイベントのみ）

**副作用**: なし（純粋関数）

## 条件式パターン

`evaluateCondition` は以下の正規表現でパターンマッチングを行う:

| パターン | 正規表現 | 評価式 |
|---------|---------|-------|
| completion_rate 比較 | `/^completion_rate\s*(>=|<)\s*([\d.]+)$/` | `getCompletionRate(state.gantt) op N` |
| turn 比較 | `/^turn\s*(>=|<=|==)\s*(\d+)$/` | `state.turn op N` |
| budget_remaining | `/^budget_remaining\s*<=\s*(\d+)$/` | `(state.budget - state.totalCost) <= N` |
| any_member_morale | `/^any_member_morale\s*<\s*(\d+)$/` | `state.members.some(m => m.morale < N)` |
| any_member_health | `/^any_member_health\s*<\s*(\d+)$/` | `state.members.some(m => m.health < N)` |
| all_members_morale | `/^all_members_morale\s*<\s*(\d+)$/` | `state.members.every(m => m.morale < N)` |

未マッチは `false` を返す（例外なし）。

## GameEvent 生成スキーマ

`rollConditionalEvents` が生成する GameEvent:

```typescript
{
  id:       `conditional-${state.turn}-${conditionalEvent.id}`,
  type:     conditionalEvent.eventType,
  category: (conditionalEvent.params.category as EventCategory | undefined) ?? null,
  targetId: (conditionalEvent.params.targetId as string | undefined) ?? null,
  params:   conditionalEvent.params,
}
```

## 処理フロー（processTurn への統合後）

```
processTurn(state, cards, conditionalEvents?)
  │
  ├── Step 1: applyCards → effectsToAdd + cardMemberUpdates
  ├── Step 2: currentEffects = activeEffects + effectsToAdd
  ├── Step 3: rollProgress per member's active tasks → progressMap
  ├── Step 4: applyTurnDecay + weekendRecovery → decayMemberUpdates
  ├── Step 5: rollRandomEvents → events.push(...), updatedProgressMap, eventMemberUpdates
  ├── Step 5.5: rollConditionalEvents(state, conditionalEvents ?? []) → events.push(...)
  ├── Step 6: applyEffectTick → activeEffectsAfterTick
  ├── Step 7: memberUpdates = cardMemberUpdates + decayMemberUpdates + eventMemberUpdates
  └── Return: TurnResult
```

## 型依存関係

```
conditional.ts
  └── imports: types.ts (GameState, ConditionalEvent, GameEvent, EventCategory)
  └── imports: gantt.ts (getCompletionRate)

turn.ts
  └── imports: conditional.ts (rollConditionalEvents) [NEW]
  └── imports: types.ts (ConditionalEvent) [NEW]
```
