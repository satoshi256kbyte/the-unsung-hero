import type { CardDefinition } from "./index.js";

export const emergencyMeeting: CardDefinition = {
  cost: 1,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
