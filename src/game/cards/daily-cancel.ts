import type { CardDefinition } from "./index.js";

export const dailyCancel: CardDefinition = {
  cost: 0,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
