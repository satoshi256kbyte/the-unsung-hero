import type { CardEffectLogic } from "./index.js";

export const overtimePermission: CardEffectLogic = {
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
