import type { CardEffectLogic } from "./index.js";

export const emergencySummarize: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
