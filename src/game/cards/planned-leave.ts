import { getConfig } from "../config.js";
import type { CardEffectLogic } from "./index.js";

export const plannedLeave: CardEffectLogic = {
  applyEffect(state) {
    const memberUpdates = [];
    const target = state.members[0];
    if (target !== undefined) {
      memberUpdates.push({
        memberId: target.id,
        moraleDelta: getConfig().balance.PARAM_DELTA.PLANNED_LEAVE_MORALE,
        healthDelta: getConfig().balance.PARAM_DELTA.PLANNED_LEAVE_HEALTH,
      });
    }
    return { effectsToAdd: [], memberUpdates };
  },
};
