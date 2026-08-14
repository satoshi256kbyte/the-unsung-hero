import type { CardEffectLogic } from "./index.js";

export const chat: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
