import * as fc from "fast-check";
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

describe("applyCards - 集約動作", () => {
  it("空の cards 配列 → effectsToAdd と memberUpdates がどちらも空", () => {
    const result = applyCards(makeState(), []);
    expect(result.effectsToAdd).toHaveLength(0);
    expect(result.memberUpdates).toHaveLength(0);
  });

  it("確率低減カードと即時メンバー系カードの混在", () => {
    const result = applyCards(makeState(), ["デイリー", "レビュー", "モニタリング", "個別面談"]);
    expect(result.effectsToAdd).toHaveLength(3);
    expect(result.memberUpdates).toHaveLength(1);
  });

  it("state.members が変化しない", () => {
    const state = makeState();
    const membersBefore = JSON.stringify(state.members);
    applyCards(state, ["個別面談", "表彰", "計画休"]);
    expect(JSON.stringify(state.members)).toBe(membersBefore);
  });

  it("state.activeEffects が変化しない", () => {
    const state = makeState();
    const effectsBefore = JSON.stringify(state.activeEffects);
    applyCards(state, ["デイリー", "レビュー", "モニタリング"]);
    expect(JSON.stringify(state.activeEffects)).toBe(effectsBefore);
  });

  it("state.members の参照が変化しない", () => {
    const state = makeState();
    const memberRef = state.members;
    applyCards(state, ["個別面談"]);
    expect(state.members).toBe(memberRef);
  });
});

const arbCardName = fc.constantFrom(
  "デイリー" as const,
  "レビュー" as const,
  "モニタリング" as const,
  "個別面談" as const,
  "表彰" as const,
  "計画休" as const,
  "納期交渉" as const,
  "スコープ交渉" as const,
  "リスケ" as const,
  "休出" as const,
);

const arbMember = fc.record({
  id: fc.uuid(),
  name: fc.string({ minLength: 1, maxLength: 10 }),
  skill: fc.integer({ min: 0, max: 99 }),
  exp: fc.integer({ min: 0, max: 500 }),
  morale: fc.integer({ min: 0, max: 150 }),
  health: fc.integer({ min: 0, max: 100 }),
});

const arbGameState = fc.record({
  turn: fc.integer({ min: 1, max: 30 }),
  deadline: fc.integer({ min: 1, max: 30 }),
  members: fc.array(arbMember, { minLength: 0, maxLength: 4 }),
  gantt: fc.constant({ tasks: [] as GameState["gantt"]["tasks"], variantId: null }),
  totalCost: fc.integer({ min: 0, max: 1000 }),
  budget: fc.integer({ min: 0, max: 1000 }),
  hand: fc.constant([] as GameState["hand"]),
  activeEffects: fc.constant([] as GameState["activeEffects"]),
  transparency: fc.integer({ min: 0, max: 150 }),
  tension: fc.integer({ min: 0, max: 150 }),
  isGameOver: fc.boolean(),
  gameOverReason: fc.constantFrom(null, "全タスク完了", "納期超過"),
});

describe("applyCards - fast-check properties", () => {
  it("任意の GameState・CardName[] で例外が発生しない", () => {
    fc.assert(
      fc.property(arbGameState, fc.array(arbCardName, { maxLength: 8 }), (state, cards) => {
        expect(() => applyCards(state, cards)).not.toThrow();
      }),
      { numRuns: 200 },
    );
  });

  it("memberUpdates の moraleDelta / healthDelta は有限数", () => {
    fc.assert(
      fc.property(arbGameState, fc.array(arbCardName, { maxLength: 8 }), (state, cards) => {
        const result = applyCards(state, cards);
        for (const u of result.memberUpdates) {
          expect(Number.isFinite(u.moraleDelta)).toBe(true);
          expect(Number.isFinite(u.healthDelta)).toBe(true);
        }
      }),
      { numRuns: 200 },
    );
  });

  it("GameState は変化しない（イミュータブル）", () => {
    fc.assert(
      fc.property(arbGameState, fc.array(arbCardName, { maxLength: 8 }), (state, cards) => {
        const membersBefore = JSON.stringify(state.members);
        const effectsBefore = JSON.stringify(state.activeEffects);
        applyCards(state, cards);
        expect(JSON.stringify(state.members)).toBe(membersBefore);
        expect(JSON.stringify(state.activeEffects)).toBe(effectsBefore);
      }),
      { numRuns: 200 },
    );
  });

  it("effectsToAdd の effectType はすべて有効な EffectType 文字列", () => {
    const validEffectTypes = new Set([
      "task_event_prob_reduced",
      "rework_prob_reduced",
      "overreport_prob_reduced",
      "morale_decay_mitigated",
      "overtime_cap_extended",
      "education_stall",
      "pair_prog_stall",
    ]);
    fc.assert(
      fc.property(arbGameState, fc.array(arbCardName, { maxLength: 8 }), (state, cards) => {
        const result = applyCards(state, cards);
        for (const e of result.effectsToAdd) {
          expect(validEffectTypes.has(e.effectType)).toBe(true);
        }
      }),
      { numRuns: 200 },
    );
  });
});
