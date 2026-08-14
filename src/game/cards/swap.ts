import type { CardEffectLogic } from "./index.js";

export const swap: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
