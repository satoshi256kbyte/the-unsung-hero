import { getConfig } from "../config.js";
import { calcEventProbModifier } from "../effect.js";
import type { EventData } from "../schemas/eventData.js";
import type { EventDefinition } from "./index.js";

export function createRoll(data: EventData): EventDefinition["roll"] {
  return (state, activeEffects) => {
    const activeTasks = state.gantt.tasks.filter((t) => t.status === "active");
    const prob = calcEventProbModifier(activeEffects, data.baseProb, "task_event_prob_reduced");
    if (Math.random() >= prob || activeTasks.length === 0) {
      return null;
    }
    const target = activeTasks[Math.floor(Math.random() * activeTasks.length)];
    if (target === undefined) {
      return null;
    }
    const stallTurns = Math.random() < getConfig().balance.STALL.ONE_TURN_PROB ? 1 : 2;
    return {
      id: `stall-${state.turn}-${target.id}`,
      type: "ネガティブ",
      category: "進捗ダウン",
      targetId: target.id,
      params: { stallTurns },
    };
  };
}
