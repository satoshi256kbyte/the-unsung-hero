import type { EventDefinition } from "./index.js";

const BASE_PROB = 0.05;

export const sick: EventDefinition = {
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
      id: `sick-${state.turn}-${target.id}`,
      type: "ネガティブ",
      category: "デバフ系",
      targetId: target.id,
      params: { moraleDelta: -8, healthDelta: -10 },
    };
  },
};
