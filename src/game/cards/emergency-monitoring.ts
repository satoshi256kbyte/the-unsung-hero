import type { CardDefinition } from "./index.js";

export const emergencyMonitoring: CardDefinition = {
  cost: 1,
  applyEffect(_state) {
    return { effectsToAdd: [], memberUpdates: [] };
  },
};
