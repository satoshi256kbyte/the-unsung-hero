import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import { processTurn } from "../../src/game/turn.js";
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
    ...overrides,
  };
}

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    turn: 1,
    deadline: 22,
    members: [
      { id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 },
      { id: "m2", name: "Bob", skill: 8, exp: 0, morale: 100, health: 100 },
    ],
    gantt: {
      tasks: [
        makeTask({ id: "t1", assignedMemberId: "m1" }),
        makeTask({ id: "t2", assignedMemberId: "m2" }),
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

// =============================================================================
// US1: 1ターンの基本処理
// =============================================================================

describe("processTurn - US1 basic turn", () => {
  it("progressUpdates contains delta for each member's active task", () => {
    const state = makeState();
    const result = processTurn(state, []);
    expect(result.progressUpdates.some((u) => u.taskId === "t1")).toBe(true);
    expect(result.progressUpdates.some((u) => u.taskId === "t2")).toBe(true);
  });

  it("progressUpdates delta is finite number", () => {
    const state = makeState();
    const result = processTurn(state, []);
    for (const u of result.progressUpdates) {
      expect(Number.isFinite(u.delta)).toBe(true);
    }
  });

  it("memberUpdates contains entry for each member", () => {
    const state = makeState();
    const result = processTurn(state, []);
    expect(result.memberUpdates.some((u) => u.memberId === "m1")).toBe(true);
    expect(result.memberUpdates.some((u) => u.memberId === "m2")).toBe(true);
  });

  it("memberUpdates count equals number of members", () => {
    const state = makeState();
    const result = processTurn(state, []);
    expect(result.memberUpdates).toHaveLength(state.members.length);
  });

  it("costDelta = DAILY_COST_CAP * member count", () => {
    const state = makeState();
    const result = processTurn(state, []);
    expect(result.costDelta).toBe(8 * 2);
  });

  it("isGameOver is boolean", () => {
    const state = makeState();
    const result = processTurn(state, []);
    expect(typeof result.isGameOver).toBe("boolean");
  });

  it("stalled task receives no progress", () => {
    const state = makeState({
      gantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1", status: "stalled" })],
        variantId: null,
      },
    });
    const result = processTurn(state, []);
    expect(result.progressUpdates.every((u) => u.taskId !== "t1")).toBe(true);
  });

  it("done task receives no progress", () => {
    const state = makeState({
      gantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1", status: "done", progress: 100 })],
        variantId: null,
      },
    });
    const result = processTurn(state, []);
    expect(result.progressUpdates.every((u) => u.taskId !== "t1")).toBe(true);
  });
});

// =============================================================================
// US1: Immutability
// =============================================================================

describe("processTurn - immutability", () => {
  it("state.turn is unchanged after processTurn", () => {
    const state = makeState({ turn: 3 });
    processTurn(state, []);
    expect(state.turn).toBe(3);
  });

  it("state.members are unchanged after processTurn", () => {
    const state = makeState();
    const moraleBefore = state.members[0]!.morale;
    processTurn(state, []);
    expect(state.members[0]!.morale).toBe(moraleBefore);
  });

  it("state.gantt.tasks are unchanged after processTurn", () => {
    const state = makeState();
    const progressBefore = state.gantt.tasks[0]!.progress;
    processTurn(state, []);
    expect(state.gantt.tasks[0]!.progress).toBe(progressBefore);
  });
});

// =============================================================================
// US1: Rework event with no active tasks
// =============================================================================

describe("processTurn - rework with no active tasks", () => {
  it("no progressUpdates when all tasks are done", () => {
    const state = makeState({
      gantt: {
        tasks: [
          makeTask({ id: "t1", assignedMemberId: "m1", status: "done", progress: 100 }),
          makeTask({ id: "t2", assignedMemberId: "m2", status: "done", progress: 100 }),
        ],
        variantId: null,
      },
    });
    const result = processTurn(state, []);
    expect(
      result.progressUpdates.filter((u) => u.taskId === "t1" || u.taskId === "t2"),
    ).toHaveLength(0);
  });
});

// =============================================================================
// US2: Weekend recovery
// =============================================================================

describe("processTurn - US2 weekend recovery", () => {
  it("healthDelta is greater on turn=5 than on turn=4 (averaged over samples)", () => {
    const state4 = makeState({ turn: 4 });
    const state5 = makeState({ turn: 5 });

    let sumDelta4 = 0;
    let sumDelta5 = 0;
    const N = 100;
    for (let i = 0; i < N; i++) {
      const r4 = processTurn(state4, []);
      const r5 = processTurn(state5, []);
      sumDelta4 += r4.memberUpdates[0]!.healthDelta;
      sumDelta5 += r5.memberUpdates[0]!.healthDelta;
    }
    expect(sumDelta5 / N).toBeGreaterThan(sumDelta4 / N);
  });

  it("weekend recovery boosts healthDelta by at least 9 when health=50 (12 - 3)", () => {
    // With health=50 (no clamping), healthDelta >= WEEKEND_HEALTH_RECOVERY + HEALTH_NATURAL_MIN = 12 + (-3) = 9
    const state5 = makeState({
      turn: 5,
      members: [
        { id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 50 },
        { id: "m2", name: "Bob", skill: 8, exp: 0, morale: 100, health: 50 },
      ],
    });
    for (let i = 0; i < 200; i++) {
      const r5 = processTurn(state5, []);
      expect(r5.memberUpdates[0]!.healthDelta).toBeGreaterThanOrEqual(9);
    }
  });

  it("no weekend recovery on turn=4", () => {
    // On turn=4, healthDelta should be <= HEALTH_NATURAL_MAX = -1
    const state4 = makeState({ turn: 4 });
    for (let i = 0; i < 200; i++) {
      const r4 = processTurn(state4, []);
      expect(r4.memberUpdates[0]!.healthDelta).toBeLessThanOrEqual(-1);
    }
  });
});

// =============================================================================
// US3: Game-over detection
// =============================================================================

describe("processTurn - US3 game-over", () => {
  it("isGameOver=true when all tasks are done (status=done)", () => {
    const state = makeState({
      gantt: {
        tasks: [
          makeTask({ id: "t1", assignedMemberId: "m1", status: "done", progress: 100 }),
          makeTask({ id: "t2", assignedMemberId: "m2", status: "done", progress: 100 }),
        ],
        variantId: null,
      },
    });
    const result = processTurn(state, []);
    expect(result.isGameOver).toBe(true);
    expect(result.gameOverReason).toBeTruthy();
  });

  it("isGameOver=true when turn > deadline", () => {
    const state = makeState({ turn: 23, deadline: 22 });
    const result = processTurn(state, []);
    expect(result.isGameOver).toBe(true);
    expect(result.gameOverReason).toContain("納期超過");
  });

  it("isGameOver=false when tasks in progress and turn <= deadline", () => {
    const state = makeState({ turn: 1, deadline: 22 });
    const result = processTurn(state, []);
    expect(result.isGameOver).toBe(false);
    expect(result.gameOverReason).toBeNull();
  });

  it("gameOverReason contains '全タスク完了' when all done", () => {
    const state = makeState({
      gantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1", status: "done", progress: 100 })],
        variantId: null,
      },
    });
    const result = processTurn(state, []);
    expect(result.gameOverReason).toBe("全タスク完了");
  });

  it("isGameOver=false when turn equals deadline (not exceeded)", () => {
    const state = makeState({ turn: 22, deadline: 22 });
    const result = processTurn(state, []);
    expect(result.isGameOver).toBe(false);
  });
});

// =============================================================================
// Fast-check property tests
// =============================================================================

const arbMember = fc.record({
  id: fc.uuid(),
  name: fc.string({ minLength: 1, maxLength: 10 }),
  skill: fc.integer({ min: 0, max: 99 }),
  exp: fc.integer({ min: 0, max: 500 }),
  morale: fc.integer({ min: 0, max: 150 }),
  health: fc.integer({ min: 0, max: 100 }),
});

const arbTaskStatus = fc.constantFrom("active" as const, "stalled" as const, "done" as const);

const arbTask = (memberIds: string[]) =>
  fc.record({
    id: fc.uuid(),
    name: fc.string({ minLength: 1, maxLength: 10 }),
    phase: fc.string({ minLength: 1, maxLength: 10 }),
    startTurn: fc.integer({ min: 1, max: 22 }),
    duration: fc.integer({ min: 1, max: 10 }),
    assignedMemberId: fc.constantFrom(...(memberIds.length > 0 ? memberIds : ["none"])),
    progress: fc.float({ min: 0, max: 100, noNaN: true }),
    status: arbTaskStatus,
    dependencies: fc.array(fc.string()),
  });

const arbGameState = fc
  .array(arbMember, { minLength: 1, maxLength: 4 })
  .chain((members) =>
    fc.array(arbTask(members.map((m) => m.id)), { minLength: 0, maxLength: 6 }).map((tasks) => ({
      members,
      tasks,
    })),
  )
  .chain(({ members, tasks }) =>
    fc
      .record({
        turn: fc.integer({ min: 1, max: 30 }),
        deadline: fc.integer({ min: 1, max: 30 }),
        totalCost: fc.integer({ min: 0, max: 1000 }),
        budget: fc.integer({ min: 0, max: 1000 }),
        transparency: fc.integer({ min: 0, max: 150 }),
        tension: fc.integer({ min: 0, max: 150 }),
      })
      .map((rest) => ({
        ...rest,
        members,
        gantt: { tasks, variantId: null },
        hand: [] as GameState["hand"],
        activeEffects: [] as GameState["activeEffects"],
        isGameOver: false,
        gameOverReason: null,
      })),
  );

describe("processTurn - fast-check properties", () => {
  it("never throws for any valid GameState", () => {
    fc.assert(
      fc.property(arbGameState, (state) => {
        expect(() => processTurn(state, [])).not.toThrow();
      }),
      { numRuns: 200 },
    );
  });

  it("returns TurnResult with boolean isGameOver", () => {
    fc.assert(
      fc.property(arbGameState, (state) => {
        const result = processTurn(state, []);
        expect(typeof result.isGameOver).toBe("boolean");
      }),
      { numRuns: 200 },
    );
  });

  it("all progressUpdates have finite delta", () => {
    fc.assert(
      fc.property(arbGameState, (state) => {
        const result = processTurn(state, []);
        for (const u of result.progressUpdates) {
          expect(Number.isFinite(u.delta)).toBe(true);
        }
      }),
      { numRuns: 200 },
    );
  });

  it("GameState is not mutated", () => {
    fc.assert(
      fc.property(arbGameState, (state) => {
        const turnBefore = state.turn;
        const membersBefore = JSON.stringify(state.members);
        const tasksBefore = JSON.stringify(state.gantt.tasks);
        processTurn(state, []);
        expect(state.turn).toBe(turnBefore);
        expect(JSON.stringify(state.members)).toBe(membersBefore);
        expect(JSON.stringify(state.gantt.tasks)).toBe(tasksBefore);
      }),
      { numRuns: 200 },
    );
  });
});
