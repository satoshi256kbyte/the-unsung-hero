import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import { applyCards } from "../../src/game/card.js";
import { PARAM_DELTA } from "../../src/game/constants.js";
import type { GameState } from "../../src/game/types.js";

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

// =============================================================================
// US1: 確率低減カード3種 (グループA)
// =============================================================================

describe("applyCards - US1 確率低減カード", () => {
  it("デイリー → effectType='task_event_prob_reduced' が effectsToAdd に含まれる", () => {
    const result = applyCards(makeState(), ["デイリー"]);
    expect(result.effectsToAdd.some((e) => e.effectType === "task_event_prob_reduced")).toBe(true);
  });

  it("レビュー → effectType='rework_prob_reduced' が effectsToAdd に含まれる", () => {
    const result = applyCards(makeState(), ["レビュー"]);
    expect(result.effectsToAdd.some((e) => e.effectType === "rework_prob_reduced")).toBe(true);
  });

  it("モニタリング → effectType='overreport_prob_reduced' が effectsToAdd に含まれる", () => {
    const result = applyCards(makeState(), ["モニタリング"]);
    expect(result.effectsToAdd.some((e) => e.effectType === "overreport_prob_reduced")).toBe(true);
  });

  it("3種同時 → effectsToAdd に3エントリ", () => {
    const result = applyCards(makeState(), ["デイリー", "レビュー", "モニタリング"]);
    expect(result.effectsToAdd).toHaveLength(3);
    expect(result.memberUpdates).toHaveLength(0);
  });

  it("effectsToAdd の targetId はすべて 'project'", () => {
    const result = applyCards(makeState(), ["デイリー", "レビュー", "モニタリング"]);
    expect(result.effectsToAdd.every((e) => e.targetId === "project")).toBe(true);
  });

  it("effectsToAdd の remainingTurns はすべて null", () => {
    const result = applyCards(makeState(), ["デイリー", "レビュー", "モニタリング"]);
    expect(result.effectsToAdd.every((e) => e.remainingTurns === null)).toBe(true);
  });

  it("effectsToAdd の cardName がカード名と一致する", () => {
    const result = applyCards(makeState(), ["デイリー"]);
    expect(result.effectsToAdd[0]?.cardName).toBe("デイリー");
  });

  it("空の cards 配列 → effectsToAdd と memberUpdates がどちらも空", () => {
    const result = applyCards(makeState(), []);
    expect(result.effectsToAdd).toHaveLength(0);
    expect(result.memberUpdates).toHaveLength(0);
  });

  it("同じカードを複数含む → 複数エントリを生成する", () => {
    const result = applyCards(makeState(), ["デイリー", "デイリー"]);
    expect(result.effectsToAdd).toHaveLength(2);
  });
});

// =============================================================================
// US2: 即時メンバー系カード3種 (グループB)
// =============================================================================

describe("applyCards - US2 即時メンバー系カード", () => {
  it("個別面談 → moraleDelta = ONE_ON_ONE_MORALE (15)", () => {
    const result = applyCards(makeState(), ["個別面談"]);
    expect(result.memberUpdates[0]?.moraleDelta).toBe(PARAM_DELTA.ONE_ON_ONE_MORALE);
    expect(result.memberUpdates[0]?.healthDelta).toBe(0);
    expect(result.effectsToAdd).toHaveLength(0);
  });

  it("表彰 → moraleDelta = COMMENDATION_MORALE (30)", () => {
    const result = applyCards(makeState(), ["表彰"]);
    expect(result.memberUpdates[0]?.moraleDelta).toBe(PARAM_DELTA.COMMENDATION_MORALE);
    expect(result.memberUpdates[0]?.healthDelta).toBe(0);
  });

  it("計画休 → moraleDelta = PLANNED_LEAVE_MORALE (20), healthDelta = PLANNED_LEAVE_HEALTH (25)", () => {
    const result = applyCards(makeState(), ["計画休"]);
    expect(result.memberUpdates[0]?.moraleDelta).toBe(PARAM_DELTA.PLANNED_LEAVE_MORALE);
    expect(result.memberUpdates[0]?.healthDelta).toBe(PARAM_DELTA.PLANNED_LEAVE_HEALTH);
  });

  it("即時カードの memberId は state.members[0].id", () => {
    const result = applyCards(makeState(), ["個別面談"]);
    expect(result.memberUpdates[0]?.memberId).toBe("m1");
  });

  it("メンバーが 0 人のとき memberUpdates が空（パニックしない）", () => {
    const emptyState = makeState({ members: [] });
    const result = applyCards(emptyState, ["個別面談", "表彰", "計画休"]);
    expect(result.memberUpdates).toHaveLength(0);
  });

  it("スコープ外カード（納期交渉）は無視される", () => {
    const result = applyCards(makeState(), ["納期交渉"]);
    expect(result.effectsToAdd).toHaveLength(0);
    expect(result.memberUpdates).toHaveLength(0);
  });

  it("スコープ外カード（スコープ交渉）は無視される", () => {
    const result = applyCards(makeState(), ["スコープ交渉"]);
    expect(result.effectsToAdd).toHaveLength(0);
    expect(result.memberUpdates).toHaveLength(0);
  });

  it("スコープ外カードと有効カードの混在 → 有効カードのみ処理される", () => {
    const result = applyCards(makeState(), ["リスケ", "デイリー", "メンバー追加"]);
    expect(result.effectsToAdd).toHaveLength(1);
    expect(result.effectsToAdd[0]?.effectType).toBe("task_event_prob_reduced");
  });
});

// =============================================================================
// US3: イミュータブル操作
// =============================================================================

describe("applyCards - US3 イミュータブル", () => {
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

// =============================================================================
// Fast-check property tests
// =============================================================================

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
