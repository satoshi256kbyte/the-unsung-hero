import type { CardDefinition } from "./index.js";

export const stallResponse: CardDefinition = {
  cost: 1,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
