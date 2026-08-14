import type { CardEffectLogic } from "./index.js";

export const assign: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
