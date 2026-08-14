import type { CardEffectLogic } from "./index.js";

export const emergencyMeeting: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
