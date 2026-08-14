import type { CardEffectLogic } from "./index.js";

export const daily: CardEffectLogic = {
  applyEffect(_state) {
    return {
      effectsToAdd: [
        {
          cardName: "デイリー",
          targetId: "project",
          effectType: "task_event_prob_reduced",
          remainingTurns: null,
        },
      ],
      memberUpdates: [],
    };
  },
};
