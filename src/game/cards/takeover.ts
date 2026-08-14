import type { CardEffectLogic } from "./index.js";

export const takeover: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
