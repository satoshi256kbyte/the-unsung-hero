import { describe, expect, it } from "vitest";
import { rollRandomEvents } from "../../../src/game/events/index.js";
import type { GameState, Member } from "../../../src/game/types.js";

function makeMember(overrides: Partial<Member> = {}): Member {
  return {
    id: "m1",
    name: "Alice",
    skill: 10,
    exp: 0,
    morale: 100,
    health: 100,
    ...overrides,
  };
}

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    turn: 1,
    deadline: 22,
    members: [makeMember({ id: "m1" }), makeMember({ id: "m2", name: "Bob" })],
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

describe("low_motivation イベント", () => {
  it("メンバー0人のとき low_motivation イベントが発生しない", () => {
    const state = makeState({ members: [] });
    for (let i = 0; i < 200; i++) {
      const events = rollRandomEvents(state, []);
      expect(events.every((e) => !e.id.startsWith("low_motivation"))).toBe(true);
    }
  });

  it("low_motivation イベントが発生した場合 targetId がメンバーIDである", () => {
    const state = makeState();
    const memberIds = new Set(state.members.map((m) => m.id));
    for (let i = 0; i < 500; i++) {
      const events = rollRandomEvents(state, []);
      for (const e of events.filter((ev) => ev.id.startsWith("low_motivation"))) {
        expect(memberIds.has(e.targetId ?? "")).toBe(true);
      }
    }
  });
});
