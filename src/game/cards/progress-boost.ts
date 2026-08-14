import type { CardEffectLogic } from "./index.js";

export const progressBoost: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
