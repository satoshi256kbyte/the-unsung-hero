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

describe("applyCards - 表彰", () => {
  it("表彰 → moraleDelta = COMMENDATION_MORALE (30)", () => {
    const result = applyCards(makeState(), ["表彰"]);
    expect(result.memberUpdates[0]?.moraleDelta).toBe(PARAM_DELTA.COMMENDATION_MORALE);
    expect(result.memberUpdates[0]?.healthDelta).toBe(0);
  });

  it("メンバーが 0 人のとき memberUpdates が空（パニックしない）", () => {
    const emptyState = makeState({ members: [] });
    const result = applyCards(emptyState, ["表彰"]);
    expect(result.memberUpdates).toHaveLength(0);
  });
});
