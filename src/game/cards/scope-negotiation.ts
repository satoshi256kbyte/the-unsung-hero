import type { CardDefinition } from "./index.js";

export const scopeNegotiation: CardDefinition = {
  cost: 6,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
