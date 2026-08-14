import type { CardDefinition } from "./index.js";

export const summarize: CardDefinition = {
  cost: 1,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
