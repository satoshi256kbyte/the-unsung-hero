import { applyCards } from "./card.js";
import { EVENT_PROB, POC_STAGE } from "./constants.js";
import { rollProgress } from "./dice.js";
import { applyEffectTick, calcEventProbModifier } from "./effect.js";
import { applyRework, getCompletionRate, updateTaskProgress } from "./gantt.js";
import { applyTurnDecay, applyWeekendRecovery } from "./member.js";
import type {
  CardEffect,
  CardName,
  GameEvent,
  GameState,
  MemberUpdate,
  ProgressUpdate,
  TurnResult,
} from "./types.js";

export function processTurn(state: GameState, cards: CardName[]): TurnResult {
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

  // Step 5: Rework event with probability modifier
  const reworkProb = calcEventProbModifier(
    currentEffects,
    EVENT_PROB.REWORK,
    "rework_prob_reduced",
  );
  if (Math.random() < reworkProb) {
    const activeTasks = state.gantt.tasks.filter((t) => t.status === "active");
    if (activeTasks.length > 0) {
      const target = activeTasks[Math.floor(Math.random() * activeTasks.length)];
      if (target !== undefined) {
        const avgSkill =
          state.members.length > 0
            ? state.members.reduce((sum, m) => sum + m.skill, 0) / state.members.length
            : 0;
        const reworked = applyRework(target, avgSkill);
        const reworkDelta = reworked.progress - target.progress;
        progressMap.set(target.id, (progressMap.get(target.id) ?? 0) + reworkDelta);
        events.push({
          id: `rework-${state.turn}-${target.id}`,
          type: "ネガティブ",
          category: "進捗ダウン",
          targetId: target.id,
          params: { reworkDelta },
        });
      }
    }
  }

  const progressUpdates: ProgressUpdate[] = Array.from(progressMap.entries()).map(
    ([taskId, delta]) => ({ taskId, delta }),
  );

  // Step 6: applyEffectTick
  const activeEffectsAfterTick = applyEffectTick(currentEffects);

  // Game-over detection on virtual gantt
  const virtualTasks = state.gantt.tasks.map((task) => {
    const delta = progressMap.get(task.id);
    return delta !== undefined ? updateTaskProgress(task, delta) : task;
  });
  const virtualGantt = { ...state.gantt, tasks: virtualTasks };

  const allDone = state.gantt.tasks.length > 0 && getCompletionRate(virtualGantt) >= 1.0;
  const deadlineExceeded = state.turn > state.deadline;
  const isGameOver = allDone || deadlineExceeded;
  const gameOverReason = allDone ? "全タスク完了" : deadlineExceeded ? "納期超過" : null;

  const costDelta = POC_STAGE.DAILY_COST_CAP * state.members.length;

  // Step 7: memberUpdates = カード由来 + decay 由来を統合
  const memberUpdates: MemberUpdate[] = [...cardMemberUpdates, ...decayMemberUpdates];

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
