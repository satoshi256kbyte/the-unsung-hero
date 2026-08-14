import { describe, expect, it } from "vitest";
import { applyCards } from "../../../src/game/cards/index.js";
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

describe("applyCards - モニタリング", () => {
  it("モニタリング → effectType='overreport_prob_reduced' が effectsToAdd に含まれる", () => {
    const result = applyCards(makeState(), ["モニタリング"]);
    expect(result.effectsToAdd.some((e) => e.effectType === "overreport_prob_reduced")).toBe(true);
  });

  it("effectsToAdd の targetId は 'project'", () => {
    const result = applyCards(makeState(), ["モニタリング"]);
    expect(result.effectsToAdd.every((e) => e.targetId === "project")).toBe(true);
  });

  it("effectsToAdd の remainingTurns は null", () => {
    const result = applyCards(makeState(), ["モニタリング"]);
    expect(result.effectsToAdd.every((e) => e.remainingTurns === null)).toBe(true);
  });
});
