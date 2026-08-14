import type { CardEffectLogic } from "./index.js";

export const summarize: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
