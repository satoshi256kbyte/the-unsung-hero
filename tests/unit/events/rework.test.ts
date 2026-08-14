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

describe("rework イベント", () => {
  it("アクティブタスク0件のとき rework イベントが発生しない", () => {
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
      expect(events.every((e) => !e.id.startsWith("rework"))).toBe(true);
    }
  });

  it("rework イベントが発生した場合 params.reworkDelta が負値または 0 である", () => {
    const state = makeState();
    const allReworkEvents: GameEvent[] = [];
    for (let i = 0; i < 1000; i++) {
      const events = rollRandomEvents(state, []);
      allReworkEvents.push(...events.filter((e) => e.id.startsWith("rework")));
    }
    for (const e of allReworkEvents) {
      expect(e.params.reworkDelta as number).toBeLessThanOrEqual(0);
    }
  });

  it("rework イベントの targetId がアクティブタスクIDである", () => {
    const state = makeState();
    const taskIds = new Set(state.gantt.tasks.map((t) => t.id));
    for (let i = 0; i < 500; i++) {
      const events = rollRandomEvents(state, []);
      for (const e of events.filter((ev) => ev.id.startsWith("rework"))) {
        expect(taskIds.has(e.targetId ?? "")).toBe(true);
      }
    }
  });

  it("rework_prob_reduced 効果ありのとき rework 発生率が下がる（大量サンプル）", () => {
    const state = makeState();
    const effect: CardEffect = {
      cardName: "レビュー",
      targetId: "project",
      effectType: "rework_prob_reduced",
      remainingTurns: null,
    };

    let countWithout = 0;
    let countWith = 0;
    const N = 5000;
    for (let i = 0; i < N; i++) {
      if (rollRandomEvents(state, []).some((e) => e.id.startsWith("rework"))) countWithout++;
      if (rollRandomEvents(state, [effect]).some((e) => e.id.startsWith("rework"))) countWith++;
    }
    expect(countWith).toBeLessThan(countWithout * 0.75);
  });
});
