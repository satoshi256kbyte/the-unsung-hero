import { STALL } from "../constants.js";
import { calcEventProbModifier } from "../effect.js";
import type { EventDefinition } from "./index.js";

const BASE_PROB = 0.05;

export const stall: EventDefinition = {
  roll(state, activeEffects) {
    const activeTasks = state.gantt.tasks.filter((t) => t.status === "active");
    const prob = calcEventProbModifier(activeEffects, BASE_PROB, "task_event_prob_reduced");
    if (Math.random() >= prob || activeTasks.length === 0) {
      return null;
    }
    const target = activeTasks[Math.floor(Math.random() * activeTasks.length)];
    if (target === undefined) {
      return null;
    }
    const stallTurns = Math.random() < STALL.ONE_TURN_PROB ? 1 : 2;
    return {
      id: `stall-${state.turn}-${target.id}`,
      type: "ネガティブ",
      category: "進捗ダウン",
      targetId: target.id,
      params: { stallTurns },
    };
  },
};
