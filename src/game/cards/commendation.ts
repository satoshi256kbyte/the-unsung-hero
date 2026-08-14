import { getConfig } from "../config.js";
import type { CardEffectLogic } from "./index.js";

export const commendation: CardEffectLogic = {
  applyEffect(state) {
    const memberUpdates = [];
    const target = state.members[0];
    if (target !== undefined) {
      memberUpdates.push({
        memberId: target.id,
        moraleDelta: getConfig().balance.PARAM_DELTA.COMMENDATION_MORALE,
        healthDelta: 0,
      });
    }
    return { effectsToAdd: [], memberUpdates };
  },
};
