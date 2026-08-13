import { EVENT_PROB, POC_STAGE } from "./constants.js";
import { rollProgress } from "./dice.js";
import { applyRework, getCompletionRate, updateTaskProgress } from "./gantt.js";
import { applyTurnDecay, applyWeekendRecovery } from "./member.js";
import type {
  CardName,
  GameEvent,
  GameState,
  MemberUpdate,
  ProgressUpdate,
  TurnResult,
} from "./types.js";

export function processTurn(state: GameState, cards: CardName[]): TurnResult {
  void cards;

  const events: GameEvent[] = [];
  const progressMap = new Map<string, number>();
  const memberUpdates: MemberUpdate[] = [];

  // Progress dice: roll for each member's active tasks
  for (const member of state.members) {
    const activeTasks = state.gantt.tasks.filter(
      (t) => t.assignedMemberId === member.id && t.status === "active",
    );
    for (const task of activeTasks) {
      const delta = rollProgress(member);
      progressMap.set(task.id, (progressMap.get(task.id) ?? 0) + delta);
    }
  }

  // Parameter decay + weekend recovery
  for (const member of state.members) {
    const decayed = applyTurnDecay(member);
    const final = state.turn % 5 === 0 ? applyWeekendRecovery(decayed) : decayed;
    memberUpdates.push({
      memberId: member.id,
      moraleDelta: final.morale - member.morale,
      healthDelta: final.health - member.health,
    });
  }

  // Rework event
  if (Math.random() < EVENT_PROB.REWORK) {
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

  return { events, progressUpdates, memberUpdates, costDelta, isGameOver, gameOverReason };
}
