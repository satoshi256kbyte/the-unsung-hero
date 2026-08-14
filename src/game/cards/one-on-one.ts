import { PARAM_DELTA } from "../constants.js";
import type { CardDefinition } from "./index.js";

export const oneOnOne: CardDefinition = {
  cost: 2,
  applyEffect(state) {
    const memberUpdates = [];
    const target = state.members[0];
    if (target !== undefined) {
      memberUpdates.push({
        memberId: target.id,
        moraleDelta: PARAM_DELTA.ONE_ON_ONE_MORALE,
        healthDelta: 0,
      });
    }
    return { effectsToAdd: [], memberUpdates };
  },
};
