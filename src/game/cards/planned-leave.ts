import { PARAM_DELTA } from "../constants.js";
import type { CardDefinition } from "./index.js";

export const plannedLeave: CardDefinition = {
  cost: 2,
  applyEffect(state) {
    const memberUpdates = [];
    const target = state.members[0];
    if (target !== undefined) {
      memberUpdates.push({
        memberId: target.id,
        moraleDelta: PARAM_DELTA.PLANNED_LEAVE_MORALE,
        healthDelta: PARAM_DELTA.PLANNED_LEAVE_HEALTH,
      });
    }
    return { effectsToAdd: [], memberUpdates };
  },
};
