import type { CardDefinition } from "./index.js";

export const review: CardDefinition = {
  cost: 1,
  applyEffect(_state) {
    return {
      effectsToAdd: [
        {
          cardName: "レビュー",
          targetId: "project",
          effectType: "rework_prob_reduced",
          remainingTurns: null,
        },
      ],
      memberUpdates: [],
    };
  },
};
