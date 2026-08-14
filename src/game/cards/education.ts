import type { CardDefinition } from "./index.js";

export const education: CardDefinition = {
  cost: 2,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
