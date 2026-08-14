import type { CardDefinition } from "./index.js";

export const assign: CardDefinition = {
  cost: 1,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
