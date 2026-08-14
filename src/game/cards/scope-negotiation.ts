import type { CardEffectLogic } from "./index.js";

export const scopeNegotiation: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
