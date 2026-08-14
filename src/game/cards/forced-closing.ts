import type { CardDefinition } from "./index.js";

export const forcedClosing: CardDefinition = {
  cost: 4,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
