import type { CardEffectLogic } from "./index.js";

export const education: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
