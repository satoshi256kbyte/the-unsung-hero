import { describe, expect, it } from "vitest";
import { applyCards } from "../../../src/game/cards/index.js";
import type { GameState } from "../../../src/game/types.js";
import { testBalanceConstants } from "../testConfig.js";

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
    drawCounts: {},
    ...overrides,
  };
}

describe("applyCards - 計画休", () => {
  it("計画休 → moraleDelta = PLANNED_LEAVE_MORALE (20), healthDelta = PLANNED_LEAVE_HEALTH (25)", () => {
    const result = applyCards(makeState(), [{ name: "計画休" }]);
    expect(result.memberUpdates[0]?.moraleDelta).toBe(
      testBalanceConstants.PARAM_DELTA.PLANNED_LEAVE_MORALE,
    );
    expect(result.memberUpdates[0]?.healthDelta).toBe(
      testBalanceConstants.PARAM_DELTA.PLANNED_LEAVE_HEALTH,
    );
  });

  it("メンバーが 0 人のとき memberUpdates が空（パニックしない）", () => {
    const emptyState = makeState({ members: [] });
    const result = applyCards(emptyState, [{ name: "計画休" }]);
    expect(result.memberUpdates).toHaveLength(0);
  });
});
