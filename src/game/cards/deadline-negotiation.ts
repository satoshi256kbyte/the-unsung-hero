import type { CardDefinition } from "./index.js";

export const deadlineNegotiation: CardDefinition = {
  cost: 6,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
