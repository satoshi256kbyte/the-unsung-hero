# Data Model: ターン処理エンジン

## 入出力エンティティ

### GameState（既存: src/game/types.ts）

processTurn の入力。引数として渡され、変更されない。

| フィールド | 型 | 用途 |
|-----------|-----|------|
| turn | number | 現在ターン（1-indexed）。週末判定・ゲームオーバー判定に使用 |
| members | Member[] | 全メンバー。進捗ダイス・パラメータ変動の対象 |
| gantt | GanttChart | タスク一覧。進捗更新・手戻りの対象 |
| deadline | number | 納期ターン。ゲームオーバー判定に使用 |
| activeEffects | CardEffect[] | 現在有効なカード効果 |
| hand | CardName[] | 手札（今回は cards 引数で渡す） |
| totalCost | number | 累計コスト（costDelta と合算して更新） |
| budget | number | 予算（ゲームオーバー判定には使用しない） |

### TurnResult（既存: src/game/types.ts）

processTurn の戻り値。呼び出し側が GameState の更新に使う。

| フィールド | 型 | 内容 |
|-----------|-----|------|
| events | GameEvent[] | 発生したイベント（手戻り等） |
| progressUpdates | ProgressUpdate[] | タスクごとの進捗変化量（taskId + delta） |
| memberUpdates | MemberUpdate[] | メンバーごとのパラメータ変化量 |
| costDelta | number | このターンのコスト消費量 |
| isGameOver | boolean | ゲームオーバー判定結果 |
| gameOverReason | string \| null | ゲームオーバー理由（null = 継続中） |

### ProgressUpdate（既存: src/game/types.ts）

```typescript
interface ProgressUpdate {
  taskId: string;
  delta: number; // 進捗変化量（%単位、正負両方あり）
}
```

### MemberUpdate（既存: src/game/types.ts）

```typescript
interface MemberUpdate {
  memberId: string;
  moraleDelta: number;
  healthDelta: number;
  skillDelta?: number;
  expDelta?: number;
}
```

## 関数シグネチャ（src/game/turn.ts）

```typescript
export function processTurn(state: GameState, cards: CardName[]): TurnResult
```

## 処理フロー

```
processTurn(state, cards):
  1. カード効果: cards を activeEffects に追加（CardEffect として記録）
  2. 進捗ダイス:
     for each member:
       activeTasks = state.gantt.tasks.filter(t => t.assignedMemberId === member.id && t.status === 'active')
       for each task in activeTasks:
         delta = rollProgress(member)
         progressUpdates.push({ taskId: task.id, delta })
  3. パラメータ変動:
     for each member:
       decayed = applyTurnDecay(member)
       final = turn % 5 === 0 ? applyWeekendRecovery(decayed) : decayed
       memberUpdates.push({ memberId: member.id, moraleDelta: final.morale - member.morale, ... })
  4. 手戻りイベント（確率 EVENT_PROB.REWORK）:
     if Math.random() < EVENT_PROB.REWORK:
       activeTasks = state.gantt.tasks.filter(t => t.status === 'active')
       if activeTasks.length > 0:
         target = activeTasks[Math.floor(Math.random() * activeTasks.length)]
         avgSkill = members.reduce(skill) / members.length
         reworkedTask = applyRework(target, avgSkill)
         progressUpdates に手戻り delta を追加（または既存エントリを上書き）
         events.push({ type: 'ネガティブ', ... })
  5. ゲームオーバー判定:
     updatedGantt = progressUpdates を適用した仮想ガントチャート
     isGameOver = getCompletionRate(updatedGantt) >= 1.0 || state.turn > state.deadline
     costDelta = POC_STAGE.DAILY_COST_CAP * state.members.length
  return TurnResult { events, progressUpdates, memberUpdates, costDelta, isGameOver, gameOverReason }
```

## 依存関係

| モジュール | 使用する関数 |
|-----------|------------|
| gantt.ts | updateTaskProgress, applyRework, getCompletionRate |
| dice.ts | rollProgress |
| member.ts | applyTurnDecay, applyWeekendRecovery |
| constants.ts | EVENT_PROB.REWORK, POC_STAGE.DAILY_COST_CAP |
