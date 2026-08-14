import type { CardEffectLogic } from "./index.js";

export const addMember: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
