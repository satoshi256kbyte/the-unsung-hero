import type { CardEffectLogic } from "./index.js";

export const stallResponse: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
