import type { CardEffectLogic } from "./index.js";

export const pairProgramming: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
