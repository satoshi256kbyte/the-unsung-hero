import type { CardEffectLogic } from "./index.js";

export const monitoring: CardEffectLogic = {
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
