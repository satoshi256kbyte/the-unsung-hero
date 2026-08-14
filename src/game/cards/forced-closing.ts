import type { CardEffectLogic } from "./index.js";

export const forcedClosing: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
