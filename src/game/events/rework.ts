import { calcEventProbModifier } from "../effect.js";
import { applyRework } from "../gantt.js";
import type { EventDefinition } from "./index.js";

const BASE_PROB = 0.08;

/** レビューカード使用時の発生確率（現状は calcEventProbModifier による半減で代替） */
export const WITH_DAILY_REVIEW_PROB = 0.05;

export const rework: EventDefinition = {
  roll(state, activeEffects) {
    const activeTasks = state.gantt.tasks.filter((t) => t.status === "active");
    const prob = calcEventProbModifier(activeEffects, BASE_PROB, "rework_prob_reduced");
    if (Math.random() >= prob || activeTasks.length === 0) {
      return null;
    }
    const target = activeTasks[Math.floor(Math.random() * activeTasks.length)];
    if (target === undefined) {
      return null;
    }
    const assignedMember = state.members.find((m) => m.id === target.assignedMemberId);
    const skill = assignedMember?.skill ?? 0;
    const reworkedTask = applyRework(target, skill);
    const reworkDelta = reworkedTask.progress - target.progress;
    return {
      id: `rework-${state.turn}-${target.id}`,
      type: "ネガティブ",
      category: "進捗ダウン",
      targetId: target.id,
      params: { reworkDelta },
    };
  },
};
