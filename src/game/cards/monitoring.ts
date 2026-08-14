import type { CardDefinition } from "./index.js";

export const monitoring: CardDefinition = {
  cost: 1,
  applyEffect(_state) {
    return {
      effectsToAdd: [
        {
          cardName: "モニタリング",
          targetId: "project",
          effectType: "overreport_prob_reduced",
          remainingTurns: null,
        },
      ],
      memberUpdates: [],
    };
  },
};
