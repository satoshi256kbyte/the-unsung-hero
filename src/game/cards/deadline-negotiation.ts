import type { CardEffectLogic } from "./index.js";

export const deadlineNegotiation: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
