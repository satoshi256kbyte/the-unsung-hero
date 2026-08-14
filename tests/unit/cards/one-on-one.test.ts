import { describe, expect, it } from "vitest";
import { applyCards } from "../../../src/game/cards/index.js";
import { PARAM_DELTA } from "../../../src/game/constants.js";
import type { GameState } from "../../../src/game/types.js";

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    turn: 1,
    deadline: 22,
    members: [
      { id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 },
      { id: "m2", name: "Bob", skill: 8, exp: 0, morale: 100, health: 100 },
    ],
    gantt: { tasks: [], variantId: null },
    totalCost: 0,
    budget: 200,
    hand: [],
    activeEffects: [],
    transparency: 100,
    tension: 100,
    isGameOver: false,
    gameOverReason: null,
    ...overrides,
  };
}

describe("applyCards - 個別面談", () => {
  it("個別面談 → moraleDelta = ONE_ON_ONE_MORALE (15)", () => {
    const result = applyCards(makeState(), ["個別面談"]);
    expect(result.memberUpdates[0]?.moraleDelta).toBe(PARAM_DELTA.ONE_ON_ONE_MORALE);
    expect(result.memberUpdates[0]?.healthDelta).toBe(0);
    expect(result.effectsToAdd).toHaveLength(0);
  });

  it("memberId は state.members[0].id", () => {
    const result = applyCards(makeState(), ["個別面談"]);
    expect(result.memberUpdates[0]?.memberId).toBe("m1");
  });

  it("メンバーが 0 人のとき memberUpdates が空（パニックしない）", () => {
    const emptyState = makeState({ members: [] });
    const result = applyCards(emptyState, ["個別面談"]);
    expect(result.memberUpdates).toHaveLength(0);
  });
});
