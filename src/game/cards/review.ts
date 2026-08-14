import type { CardEffectLogic } from "./index.js";

export const review: CardEffectLogic = {
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
