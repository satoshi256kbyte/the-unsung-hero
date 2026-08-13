# Data Model: ランダムイベントエンジン

## 関数シグネチャ

### rollRandomEvents

```typescript
function rollRandomEvents(
  state: GameState,
  activeEffects: CardEffect[],
): GameEvent[]
```

- `state.gantt.tasks` からアクティブタスクを抽出してタスク系イベント判定
- `state.members` からメンバー系イベント判定
- `activeEffects` は calcEventProbModifier に渡して確率補正

### applyEventToProgress

```typescript
function applyEventToProgress(
  event: GameEvent,
  progressMap: Map<string, number>,
): Map<string, number>
```

- rework イベント: `progressMap.get(event.targetId) + event.params.reworkDelta` で更新
- stall イベント: `progressMap.set(event.targetId, 0)` でそのターンの進捗をリセット
- それ以外（メンバーイベント等）: progressMap をそのままコピーして返す
- 引数の Map は変更しない（`new Map(progressMap)` でコピー）

### applyEventToMember

```typescript
function applyEventToMember(
  event: GameEvent,
  member: Member,
): Member
```

- sick: morale - PARAM_DELTA.EVENT_SICK_MORALE, health - PARAM_DELTA.EVENT_SICK_HEALTH
- low_motivation: morale - （別途定義, -10）
- fatigue: health - （別途定義, -8）
- それ以外: member をそのまま返す
- 結果を MEMBER_PARAMS.MORALE.MIN/MAX, HEALTH.MIN/MAX でクランプ

## GameEvent の params 仕様

| イベント種別 | category | params フィールド |
|------------|----------|-----------------|
| stall | 進捗ダウン | `{ stallTurns: 1 \| 2 }` |
| rework | 進捗ダウン | `{ reworkDelta: number }` （負値） |
| sick | デバフ系 | `{ moraleDelta: -8, healthDelta: -10 }` |
| low_motivation | デバフ系 | `{ moraleDelta: -10 }` |
| fatigue | デバフ系 | `{ healthDelta: -8 }` |

## GameEvent id の命名規則

```
<eventType>-<turn>-<targetId>
```

例: `stall-3-t1`, `rework-3-t2`, `sick-3-m1`

## 処理フロー（turn.ts Step 5）

```
rollRandomEvents(state, currentEffects)
  ├─ アクティブタスク取得: state.gantt.tasks.filter(t => t.status === 'active')
  ├─ stall 判定:
  │    prob = calcEventProbModifier(activeEffects, EVENT_PROB.STALL, 'task_event_prob_reduced')
  │    if Math.random() < prob && activeTasks.length > 0
  │      target = activeTasks[random index]
  │      stallTurns = Math.random() < STALL.ONE_TURN_PROB ? 1 : 2
  │      emit GameEvent { id: `stall-${turn}-${target.id}`, type: 'ネガティブ', ... }
  ├─ rework 判定:
  │    prob = calcEventProbModifier(activeEffects, EVENT_PROB.REWORK, 'rework_prob_reduced')
  │    if Math.random() < prob && activeTasks.length > 0
  │      target = activeTasks[random index]
  │      skill = member.skill (assignedMemberId から取得)
  │      reworkedTask = applyRework(target, skill)
  │      reworkDelta = reworkedTask.progress - target.progress  // 負値
  │      emit GameEvent { id: `rework-${turn}-${target.id}`, type: 'ネガティブ', ... }
  ├─ sick 判定:
  │    if Math.random() < EVENT_PROB.SICK && members.length > 0
  │      target = members[random index]
  │      emit GameEvent { id: `sick-${turn}-${target.id}`, type: 'ネガティブ', ... }
  ├─ low_motivation 判定:
  │    if Math.random() < EVENT_PROB.LOW_MOTIVATION && members.length > 0
  │      target = members[random index]
  │      emit GameEvent { id: `low_motivation-${turn}-${target.id}`, type: 'ネガティブ', ... }
  └─ fatigue 判定:
       if Math.random() < EVENT_PROB.FATIGUE && members.length > 0
         target = members[random index]
         emit GameEvent { id: `fatigue-${turn}-${target.id}`, type: 'ネガティブ', ... }
```

## 依存関係グラフ

```
event.ts
  ├── types.ts        (GameEvent / GameState / Member / CardEffect)
  ├── constants.ts    (EVENT_PROB / STALL / PARAM_DELTA / MEMBER_PARAMS)
  ├── effect.ts       (calcEventProbModifier)
  └── gantt.ts        (applyRework)

turn.ts (Step 5 更新)
  └── event.ts        (rollRandomEvents / applyEventToProgress / applyEventToMember)
```
