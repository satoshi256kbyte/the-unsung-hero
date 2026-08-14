import type { CardDefinition } from "./index.js";

export const reschedule: CardDefinition = {
  cost: 2,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
