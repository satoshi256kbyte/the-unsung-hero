import type { EventDefinition } from "./index.js";

const BASE_PROB = 0.06;

export const lowMotivation: EventDefinition = {
  roll(state) {
    const members = state.members;
    if (Math.random() >= BASE_PROB || members.length === 0) {
      return null;
    }
    const target = members[Math.floor(Math.random() * members.length)];
    if (target === undefined) {
      return null;
    }
    return {
      id: `low_motivation-${state.turn}-${target.id}`,
      type: "ネガティブ",
      category: "デバフ系",
      targetId: target.id,
      params: { moraleDelta: -10 },
    };
  },
};
