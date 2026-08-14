import { describe, expect, it } from "vitest";
import { EVENT_REGISTRY } from "../../../src/game/events/index.js";
import type { GameState } from "../../../src/game/types.js";

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    turn: 1,
    deadline: 22,
    members: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 }],
    gantt: {
      tasks: [
        {
          id: "t1",
          name: "設計",
          phase: "設計",
          startTurn: 1,
          duration: 5,
          assignedMemberId: "m1",
          progress: 50,
          status: "active",
          dependencies: [],
        },
      ],
      variantId: null,
    },
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

const STUB_EVENT_KEYS = [
  "SPEC_UNCLEAR",
  "BLOCKER",
  "ENV_ISSUE",
  "OVER_REPORT",
  "UNDER_REPORT",
  "MISSING_REPORT",
  "INSPIRATION",
  "FIRST_PASS",
  "REST",
  "LOCAL_WIN",
];

describe("EVENT_REGISTRY - 未実装イベントのスタブ", () => {
  it.each(STUB_EVENT_KEYS)("%s の roll() は常に null を返す", (key) => {
    const state = makeState();
    for (let i = 0; i < 20; i++) {
      expect(EVENT_REGISTRY[key]?.roll(state, [])).toBeNull();
    }
  });
});
