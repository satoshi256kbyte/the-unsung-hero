import type { CardDefinition } from "./index.js";

export const addMember: CardDefinition = {
  cost: 4,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
