import { describe, expect, it } from "vitest";
import { applyCards } from "../../../src/game/cards/index.js";
import type { GameState } from "../../../src/game/types.js";

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    turn: 1,
    deadline: 30,
    members: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 }],
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

describe("applyCards - 休出（土）", () => {
  it("対象が指定されている場合、holiday_work_sat の CardEffect を追加する", () => {
    const result = applyCards(makeState(), [{ name: "休出（土）", targetId: "m1" }]);
    expect(result.effectsToAdd).toHaveLength(1);
    expect(result.effectsToAdd[0]?.effectType).toBe("holiday_work_sat");
    expect(result.effectsToAdd[0]?.targetId).toBe("m1");
  });

  it("月曜（ターン1）に使うと remainingTurns は6（月〜土）", () => {
    const result = applyCards(makeState({ turn: 1 }), [{ name: "休出（土）", targetId: "m1" }]);
    expect(result.effectsToAdd[0]?.remainingTurns).toBe(6);
  });

  it("土曜（ターン6）に使うと remainingTurns は1（当日のみ）", () => {
    const result = applyCards(makeState({ turn: 6 }), [{ name: "休出（土）", targetId: "m1" }]);
    expect(result.effectsToAdd[0]?.remainingTurns).toBe(1);
  });

  it("対象が指定されていない場合は効果を追加しない", () => {
    const result = applyCards(makeState(), [{ name: "休出（土）" }]);
    expect(result.effectsToAdd).toHaveLength(0);
    expect(result.memberUpdates).toHaveLength(0);
  });
});
