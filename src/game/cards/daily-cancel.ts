import type { CardEffectLogic } from "./index.js";

export const dailyCancel: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
