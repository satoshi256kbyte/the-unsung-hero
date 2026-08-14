import type { CardDefinition } from "./index.js";

export const progressBoost: CardDefinition = {
  cost: 3,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
