import { describe, expect, it } from "vitest";
import { rollRandomEvents } from "../../../src/game/events/index.js";
import type {
  CardEffect,
  GameEvent,
  GameState,
  GanttTask,
  Member,
} from "../../../src/game/types.js";

function makeTask(overrides: Partial<GanttTask> = {}): GanttTask {
  return {
    id: "t1",
    name: "設計",
    phase: "設計",
    startTurn: 1,
    duration: 5,
    assignedMemberId: "m1",
    progress: 50,
    status: "active",
    dependencies: [],
    ...overrides,
  };
}

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
    members: [
      makeMember({ id: "m1", name: "Alice", skill: 10 }),
      makeMember({ id: "m2", name: "Bob", skill: 8 }),
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

describe("stall イベント", () => {
  it("アクティブタスク0件のとき stall イベントが発生しない", () => {
    const state = makeState({
      gantt: {
        tasks: [
          makeTask({ id: "t1", status: "done", progress: 100 }),
          makeTask({ id: "t2", status: "done", progress: 100 }),
        ],
        variantId: null,
      },
    });
    for (let i = 0; i < 200; i++) {
      const events = rollRandomEvents(state, []);
      expect(events.every((e) => !e.id.startsWith("stall"))).toBe(true);
    }
  });

  it("stall イベントが発生した場合 params.stallTurns が 1 または 2 である", () => {
    const state = makeState();
    const allStallEvents: GameEvent[] = [];
    for (let i = 0; i < 1000; i++) {
      const events = rollRandomEvents(state, []);
      allStallEvents.push(...events.filter((e) => e.id.startsWith("stall")));
    }
    for (const e of allStallEvents) {
      expect([1, 2]).toContain(e.params.stallTurns);
    }
  });

  it("stall イベントの targetId がアクティブタスクIDである", () => {
    const state = makeState();
    const taskIds = new Set(state.gantt.tasks.map((t) => t.id));
    for (let i = 0; i < 500; i++) {
      const events = rollRandomEvents(state, []);
      for (const e of events.filter((ev) => ev.id.startsWith("stall"))) {
        expect(taskIds.has(e.targetId ?? "")).toBe(true);
      }
    }
  });

  it("task_event_prob_reduced 効果ありのとき stall 発生率が半減する（大量サンプル）", () => {
    const state = makeState();
    const effect: CardEffect = {
      cardName: "デイリー",
      targetId: "project",
      effectType: "task_event_prob_reduced",
      remainingTurns: null,
    };

    let countWithout = 0;
    let countWith = 0;
    const N = 5000;
    for (let i = 0; i < N; i++) {
      if (rollRandomEvents(state, []).some((e) => e.id.startsWith("stall"))) countWithout++;
      if (rollRandomEvents(state, [effect]).some((e) => e.id.startsWith("stall"))) countWith++;
    }
    expect(countWith).toBeLessThan(countWithout * 0.75);
  });
});
