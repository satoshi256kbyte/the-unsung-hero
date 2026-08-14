import type { CardDefinition } from "./index.js";

export const daily: CardDefinition = {
  cost: 1,
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
