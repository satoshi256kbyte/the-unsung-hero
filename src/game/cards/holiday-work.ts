import type { CardEffectLogic } from "./index.js";

export const holidayWork: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
