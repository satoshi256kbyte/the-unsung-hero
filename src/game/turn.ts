import { applyCards } from "./cards/index.js";
import { rollConditionalEvents } from "./conditional.js";
import { POC_STAGE } from "./constants.js";
import { rollProgress } from "./dice.js";
import { applyEffectTick } from "./effect.js";
import { applyEventToMember, applyEventToProgress, rollRandomEvents } from "./events/index.js";
import { getCompletionRate, updateTaskProgress } from "./gantt.js";
import { applyTurnDecay, applyWeekendRecovery } from "./member.js";
import type {
  CardEffect,
  CardName,
  ConditionalEvent,
  GameEvent,
  GameState,
  MemberUpdate,
  ProgressUpdate,
  TurnResult,
} from "./types.js";

export function processTurn(
  state: GameState,
  cards: CardName[],
  conditionalEvents?: ConditionalEvent[],
): TurnResult {
  const events: GameEvent[] = [];
  const progressMap = new Map<string, number>();

  // Step 1: applyCards → effectsToAdd + cardMemberUpdates
  const { effectsToAdd, memberUpdates: cardMemberUpdates } = applyCards(state, cards);

  // Step 2: currentEffects = 前ターン継続 + 今ターン追加
  const currentEffects: CardEffect[] = [...state.activeEffects, ...effectsToAdd];

  // Step 3: Progress dice per member's active tasks
  for (const member of state.members) {
    const activeTasks = state.gantt.tasks.filter(
      (t) => t.assignedMemberId === member.id && t.status === "active",
    );
    for (const task of activeTasks) {
      const delta = rollProgress(member);
      progressMap.set(task.id, (progressMap.get(task.id) ?? 0) + delta);
    }
  }

  // Step 4: Parameter decay + weekend recovery
  const decayMemberUpdates: MemberUpdate[] = [];
  for (const member of state.members) {
    const decayed = applyTurnDecay(member);
    const final = state.turn % 5 === 0 ? applyWeekendRecovery(decayed) : decayed;
    decayMemberUpdates.push({
      memberId: member.id,
      moraleDelta: final.morale - member.morale,
      healthDelta: final.health - member.health,
    });
  }

  // Step 5: rollRandomEvents → progressMap 更新 + メンバーイベントデルタ収集
  const randomEvents = rollRandomEvents(state, currentEffects);
  events.push(...randomEvents);

  let updatedProgressMap = progressMap;
  for (const event of randomEvents) {
    updatedProgressMap = applyEventToProgress(event, updatedProgressMap);
  }

  const eventMemberUpdates: MemberUpdate[] = [];
  for (const member of state.members) {
    const memberEvents = randomEvents.filter((e) => e.targetId === member.id);
    if (memberEvents.length > 0) {
      let updated = member;
      for (const event of memberEvents) {
        updated = applyEventToMember(event, updated);
      }
      eventMemberUpdates.push({
        memberId: member.id,
        moraleDelta: updated.morale - member.morale,
        healthDelta: updated.health - member.health,
      });
    }
  }

  const progressUpdates: ProgressUpdate[] = Array.from(updatedProgressMap.entries()).map(
    ([taskId, delta]) => ({ taskId, delta }),
  );

  // Step 5.5: rollConditionalEvents → events 統合
  const conditionalEventsResult = rollConditionalEvents(state, conditionalEvents ?? []);
  events.push(...conditionalEventsResult);

  // Step 6: applyEffectTick
  const activeEffectsAfterTick = applyEffectTick(currentEffects);

  // Game-over detection on virtual gantt
  const virtualTasks = state.gantt.tasks.map((task) => {
    const delta = updatedProgressMap.get(task.id);
    return delta !== undefined ? updateTaskProgress(task, delta) : task;
  });
  const virtualGantt = { ...state.gantt, tasks: virtualTasks };

  const allDone = state.gantt.tasks.length > 0 && getCompletionRate(virtualGantt) >= 1.0;
  const deadlineExceeded = state.turn > state.deadline;
  const isGameOver = allDone || deadlineExceeded;
  const gameOverReason = allDone ? "全タスク完了" : deadlineExceeded ? "納期超過" : null;

  const costDelta = POC_STAGE.DAILY_COST_CAP * state.members.length;

  // Step 7: memberUpdates = カード由来 + decay 由来 + イベント由来を統合
  const memberUpdates: MemberUpdate[] = [
    ...cardMemberUpdates,
    ...decayMemberUpdates,
    ...eventMemberUpdates,
  ];

  return {
    events,
    progressUpdates,
    memberUpdates,
    costDelta,
    isGameOver,
    gameOverReason,
    activeEffectsAdded: effectsToAdd,
    activeEffectsAfterTick,
  };
}
