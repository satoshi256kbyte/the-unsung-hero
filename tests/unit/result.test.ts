import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import { getCompletionRate } from "../../src/game/gantt.js";
import { evaluateResult } from "../../src/game/result.js";
import type { GameState, GanttTask } from "../../src/game/types.js";

function makeTask(overrides: Partial<GanttTask> = {}): GanttTask {
  return {
    id: "t1",
    name: "設計",
    phase: "設計",
    startTurn: 1,
    duration: 5,
    assignedMemberId: "m1",
    progress: 0,
    status: "active",
    dependencies: [],
    actualStartTurn: null,
    actualEndTurn: null,
    ...overrides,
  };
}

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    turn: 30,
    members: [],
    gantt: { tasks: [makeTask({ id: "t1", progress: 100, status: "done" })], variantId: null },
    totalCost: 4_000_000,
    budget: 5_000_000,
    deadline: 30,
    hand: [],
    activeEffects: [],
    transparency: 100,
    tension: 100,
    isGameOver: true,
    gameOverReason: "全タスク完了",
    drawCounts: {},
    ...overrides,
  };
}

// =============================================================================
// US1: 成否判定と利益率
// =============================================================================

describe("evaluateResult - US1 成否と利益率", () => {
  it("全タスク完了かつ利益率≥目標 → clear", () => {
    // profit=1,000,000 / budget=5,000,000 = 0.2 >= 0.05
    const r = evaluateResult(makeState(), 0.05);
    expect(r.outcome).toBe("clear");
    expect(r.profit).toBe(1_000_000);
    expect(r.profitRate).toBeCloseTo(0.2, 5);
  });

  it("全タスク完了だが利益率<目標 → fail", () => {
    // profit=100,000 / 5,000,000 = 0.02 < 0.05
    const r = evaluateResult(makeState({ totalCost: 4_900_000 }), 0.05);
    expect(r.outcome).toBe("fail");
    expect(r.profitRate).toBeCloseTo(0.02, 5);
  });

  it("納期超過 → 利益率が高くても fail", () => {
    const r = evaluateResult(makeState({ gameOverReason: "納期超過", totalCost: 1_000_000 }), 0.05);
    expect(r.outcome).toBe("fail");
    expect(r.reason).toBe("納期超過");
  });

  it("budget=0 でゼロ除算にならず profitRate=0", () => {
    const r = evaluateResult(makeState({ budget: 0, totalCost: 0 }), 0.05);
    expect(Number.isFinite(r.profitRate)).toBe(true);
    expect(r.profitRate).toBe(0);
  });

  it("入力 state を変更しない（純関数）", () => {
    const state = makeState();
    const before = JSON.stringify(state);
    evaluateResult(state, 0.05);
    expect(JSON.stringify(state)).toBe(before);
  });
});

// =============================================================================
// US2: 成否理由と内訳
// =============================================================================

describe("evaluateResult - US2 理由と内訳", () => {
  it("reason は state.gameOverReason と一致する", () => {
    expect(evaluateResult(makeState(), 0.05).reason).toBe("全タスク完了");
    expect(evaluateResult(makeState({ gameOverReason: "納期超過" }), 0.05).reason).toBe("納期超過");
  });

  it("completionRate は getCompletionRate と一致する", () => {
    const state = makeState({
      gantt: {
        tasks: [
          makeTask({ id: "t1", progress: 100, status: "done" }),
          makeTask({ id: "t2", progress: 0, status: "active" }),
        ],
        variantId: null,
      },
    });
    const r = evaluateResult(state, 0.05);
    expect(r.completionRate).toBe(getCompletionRate(state.gantt));
  });

  it("totalCost>budget で profit 負・profitRate 負・fail", () => {
    const r = evaluateResult(makeState({ totalCost: 6_000_000 }), 0.05);
    expect(r.profit).toBe(-1_000_000);
    expect(r.profitRate).toBeLessThan(0);
    expect(r.outcome).toBe("fail");
  });

  it("主要数値（budget/totalCost/turn/targetProfitRate）を返す", () => {
    const r = evaluateResult(makeState({ turn: 22 }), 0.05);
    expect(r.budget).toBe(5_000_000);
    expect(r.totalCost).toBe(4_000_000);
    expect(r.turn).toBe(22);
    expect(r.targetProfitRate).toBe(0.05);
  });
});

// =============================================================================
// プロパティテスト
// =============================================================================

describe("evaluateResult - fast-check properties", () => {
  it("outcome は clear/fail のいずれか、profitRate は有限数", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 0, max: 10_000_000 }),
        fc.integer({ min: 0, max: 20_000_000 }),
        fc.constantFrom("全タスク完了", "納期超過"),
        (budget, totalCost, reason) => {
          const state = makeState({ budget, totalCost, gameOverReason: reason });
          const r = evaluateResult(state, 0.05);
          return (r.outcome === "clear" || r.outcome === "fail") && Number.isFinite(r.profitRate);
        },
      ),
    );
  });

  it("納期超過なら常に fail", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 10_000_000 }),
        fc.integer({ min: 0, max: 10_000_000 }),
        (budget, totalCost) => {
          const state = makeState({ budget, totalCost, gameOverReason: "納期超過" });
          return evaluateResult(state, 0.05).outcome === "fail";
        },
      ),
    );
  });
});
