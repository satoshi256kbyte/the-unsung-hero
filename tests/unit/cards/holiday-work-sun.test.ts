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

describe("applyCards - 休出（日）", () => {
  it("対象が指定されている場合、holiday_work_sun の CardEffect を追加する", () => {
    const result = applyCards(makeState(), [{ name: "休出（日）", targetId: "m1" }]);
    expect(result.effectsToAdd).toHaveLength(1);
    expect(result.effectsToAdd[0]?.effectType).toBe("holiday_work_sun");
    expect(result.effectsToAdd[0]?.targetId).toBe("m1");
  });

  it("月曜（ターン1）に使うと remainingTurns は7（月〜日）", () => {
    const result = applyCards(makeState({ turn: 1 }), [{ name: "休出（日）", targetId: "m1" }]);
    expect(result.effectsToAdd[0]?.remainingTurns).toBe(7);
  });

  it("日曜（ターン7）に使うと remainingTurns は1（当日のみ）", () => {
    const result = applyCards(makeState({ turn: 7 }), [{ name: "休出（日）", targetId: "m1" }]);
    expect(result.effectsToAdd[0]?.remainingTurns).toBe(1);
  });

  it("対象が指定されていない場合は効果を追加しない", () => {
    const result = applyCards(makeState(), [{ name: "休出（日）" }]);
    expect(result.effectsToAdd).toHaveLength(0);
    expect(result.memberUpdates).toHaveLength(0);
  });
});
