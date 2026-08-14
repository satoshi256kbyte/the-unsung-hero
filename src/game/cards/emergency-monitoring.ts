import type { CardEffectLogic } from "./index.js";

export const emergencyMonitoring: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
