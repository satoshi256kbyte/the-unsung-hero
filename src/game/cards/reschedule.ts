import type { CardEffectLogic } from "./index.js";

export const reschedule: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
