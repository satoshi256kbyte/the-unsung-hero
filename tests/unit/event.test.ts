import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import {
  applyEventToMember,
  applyEventToProgress,
  rollRandomEvents,
} from "../../src/game/event.js";
import type { CardEffect, GameEvent, GameState, GanttTask, Member } from "../../src/game/types.js";

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

function makeEvent(overrides: Partial<GameEvent> = {}): GameEvent {
  return {
    id: "rework-1-t1",
    type: "ネガティブ",
    category: "進捗ダウン",
    targetId: "t1",
    params: { reworkDelta: -15 },
    ...overrides,
  };
}

// =============================================================================
// US2: applyEventToProgress
// =============================================================================

describe("applyEventToProgress", () => {
  it("rework イベントで progressMap のデルタが reworkDelta 分変化する", () => {
    const event = makeEvent({ id: "rework-1-t1", params: { reworkDelta: -15 } });
    const progressMap = new Map([["t1", 5]]);
    const result = applyEventToProgress(event, progressMap);
    expect(result.get("t1")).toBe(5 + -15);
  });

  it("stall イベントで progressMap のデルタが 0 にリセットされる", () => {
    const event = makeEvent({ id: "stall-1-t1", params: { stallTurns: 1 } });
    const progressMap = new Map([["t1", 8]]);
    const result = applyEventToProgress(event, progressMap);
    expect(result.get("t1")).toBe(0);
  });

  it("メンバーイベント（sick）では progressMap が変化しない", () => {
    const event = makeEvent({
      id: "sick-1-m1",
      category: "デバフ系",
      targetId: "m1",
      params: { moraleDelta: -8, healthDelta: -10 },
    });
    const progressMap = new Map([
      ["t1", 5],
      ["t2", 3],
    ]);
    const result = applyEventToProgress(event, progressMap);
    expect(result.get("t1")).toBe(5);
    expect(result.get("t2")).toBe(3);
  });

  it("引数の Map が変化しない（イミュータブル）", () => {
    const event = makeEvent({ params: { reworkDelta: -10 } });
    const progressMap = new Map([["t1", 5]]);
    applyEventToProgress(event, progressMap);
    expect(progressMap.get("t1")).toBe(5);
  });

  it("t1 が progressMap に存在しない場合は reworkDelta のみが格納される", () => {
    const event = makeEvent({ params: { reworkDelta: -10 } });
    const progressMap = new Map<string, number>();
    const result = applyEventToProgress(event, progressMap);
    expect(result.get("t1")).toBe(-10);
  });
});

// =============================================================================
// US3: applyEventToMember
// =============================================================================

describe("applyEventToMember", () => {
  it("sick イベントで morale -8、health -10 になる", () => {
    const event = makeEvent({
      id: "sick-1-m1",
      category: "デバフ系",
      targetId: "m1",
      params: { moraleDelta: -8, healthDelta: -10 },
    });
    const member = makeMember({ morale: 100, health: 100 });
    const result = applyEventToMember(event, member);
    expect(result.morale).toBe(92);
    expect(result.health).toBe(90);
  });

  it("low_motivation イベントで morale -10 になる（health 変化なし）", () => {
    const event = makeEvent({
      id: "low_motivation-1-m1",
      category: "デバフ系",
      targetId: "m1",
      params: { moraleDelta: -10 },
    });
    const member = makeMember({ morale: 100, health: 80 });
    const result = applyEventToMember(event, member);
    expect(result.morale).toBe(90);
    expect(result.health).toBe(80);
  });

  it("fatigue イベントで health -8 になる（morale 変化なし）", () => {
    const event = makeEvent({
      id: "fatigue-1-m1",
      category: "デバフ系",
      targetId: "m1",
      params: { healthDelta: -8 },
    });
    const member = makeMember({ morale: 90, health: 60 });
    const result = applyEventToMember(event, member);
    expect(result.morale).toBe(90);
    expect(result.health).toBe(52);
  });

  it("health が 0 を下回らない（MIN クランプ）", () => {
    const event = makeEvent({
      id: "fatigue-1-m1",
      category: "デバフ系",
      targetId: "m1",
      params: { healthDelta: -8 },
    });
    const member = makeMember({ health: 5 });
    const result = applyEventToMember(event, member);
    expect(result.health).toBe(0);
  });

  it("morale が 0 を下回らない（MIN クランプ）", () => {
    const event = makeEvent({
      id: "sick-1-m1",
      category: "デバフ系",
      targetId: "m1",
      params: { moraleDelta: -8, healthDelta: -10 },
    });
    const member = makeMember({ morale: 5, health: 100 });
    const result = applyEventToMember(event, member);
    expect(result.morale).toBe(0);
  });

  it("rework イベント（タスクイベント）ではメンバーが変化しない", () => {
    const event = makeEvent({ id: "rework-1-t1", params: { reworkDelta: -15 } });
    const member = makeMember({ morale: 100, health: 100 });
    const result = applyEventToMember(event, member);
    expect(result.morale).toBe(100);
    expect(result.health).toBe(100);
  });

  it("stall イベントではメンバーが変化しない", () => {
    const event = makeEvent({ id: "stall-1-t1", params: { stallTurns: 1 } });
    const member = makeMember();
    const result = applyEventToMember(event, member);
    expect(result).toEqual(member);
  });

  it("引数の Member が変化しない（イミュータブル）", () => {
    const event = makeEvent({
      id: "sick-1-m1",
      category: "デバフ系",
      targetId: "m1",
      params: { moraleDelta: -8, healthDelta: -10 },
    });
    const member = makeMember({ morale: 100, health: 100 });
    applyEventToMember(event, member);
    expect(member.morale).toBe(100);
    expect(member.health).toBe(100);
  });
});

// =============================================================================
// US1: rollRandomEvents
// =============================================================================

describe("rollRandomEvents", () => {
  it("アクティブタスク0件のとき stall・rework イベントが発生しない", () => {
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
      expect(events.every((e) => !e.id.startsWith("stall") && !e.id.startsWith("rework"))).toBe(
        true,
      );
    }
  });

  it("メンバー0人のとき sick・low_motivation・fatigue イベントが発生しない", () => {
    const state = makeState({ members: [] });
    for (let i = 0; i < 200; i++) {
      const events = rollRandomEvents(state, []);
      expect(
        events.every(
          (e) =>
            !e.id.startsWith("sick") &&
            !e.id.startsWith("low_motivation") &&
            !e.id.startsWith("fatigue"),
        ),
      ).toBe(true);
    }
  });

  it("返却値は GameEvent[] 型（配列）である", () => {
    const state = makeState();
    const events = rollRandomEvents(state, []);
    expect(Array.isArray(events)).toBe(true);
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

  it("sick イベントが発生した場合 targetId がメンバーIDである", () => {
    const state = makeState();
    const memberIds = new Set(state.members.map((m) => m.id));
    for (let i = 0; i < 500; i++) {
      const events = rollRandomEvents(state, []);
      for (const e of events.filter((ev) => ev.id.startsWith("sick"))) {
        expect(memberIds.has(e.targetId ?? "")).toBe(true);
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

// =============================================================================
// US5: Immutability
// =============================================================================

describe("applyEventToProgress - immutability", () => {
  it("引数の Map は変化しない", () => {
    const event = makeEvent({ params: { reworkDelta: -10 } });
    const progressMap = new Map([
      ["t1", 5],
      ["t2", 3],
    ]);
    const before = JSON.stringify([...progressMap.entries()]);
    applyEventToProgress(event, progressMap);
    expect(JSON.stringify([...progressMap.entries()])).toBe(before);
  });
});

describe("applyEventToMember - immutability", () => {
  it("引数の Member は変化しない", () => {
    const event = makeEvent({
      id: "sick-1-m1",
      category: "デバフ系",
      targetId: "m1",
      params: { moraleDelta: -8, healthDelta: -10 },
    });
    const member = makeMember();
    const before = JSON.stringify(member);
    applyEventToMember(event, member);
    expect(JSON.stringify(member)).toBe(before);
  });
});

describe("rollRandomEvents - immutability", () => {
  it("引数の state が変化しない", () => {
    const state = makeState();
    const before = JSON.stringify(state);
    rollRandomEvents(state, []);
    expect(JSON.stringify(state)).toBe(before);
  });

  it("引数の activeEffects が変化しない", () => {
    const state = makeState();
    const effects: CardEffect[] = [
      {
        cardName: "デイリー",
        targetId: "project",
        effectType: "task_event_prob_reduced",
        remainingTurns: 3,
      },
    ];
    const before = JSON.stringify(effects);
    rollRandomEvents(state, effects);
    expect(JSON.stringify(effects)).toBe(before);
  });
});

// =============================================================================
// Fast-check property tests
// =============================================================================

const arbEventCategory = fc.constantFrom(
  "進捗ダウン" as const,
  "進捗アップ" as const,
  "デバフ系" as const,
  "バフ系" as const,
  "メンバー稼働系" as const,
  "スコープ変化系" as const,
);

const arbGameEvent = fc.record({
  id: fc.string({ minLength: 1, maxLength: 20 }),
  type: fc.constantFrom("ニュートラル" as const, "ネガティブ" as const, "ポジティブ" as const),
  category: fc.oneof(fc.constant(null), arbEventCategory),
  targetId: fc.oneof(fc.constant(null), fc.string({ minLength: 1, maxLength: 10 })),
  params: fc.record({
    reworkDelta: fc.option(fc.float({ min: -50, max: 0, noNaN: true }), { nil: undefined }),
    stallTurns: fc.option(fc.constantFrom(1, 2), { nil: undefined }),
    moraleDelta: fc.option(fc.float({ min: -30, max: 0, noNaN: true }), { nil: undefined }),
    healthDelta: fc.option(fc.float({ min: -30, max: 0, noNaN: true }), { nil: undefined }),
  }),
});

describe("applyEventToProgress - fast-check", () => {
  it("任意の GameEvent と Map で例外が発生しない", () => {
    fc.assert(
      fc.property(
        arbGameEvent,
        fc.array(
          fc.tuple(
            fc.string({ minLength: 1, maxLength: 5 }),
            fc.float({ min: -100, max: 100, noNaN: true }),
          ),
        ),
        (event, entries) => {
          const progressMap = new Map(entries);
          expect(() => applyEventToProgress(event, progressMap)).not.toThrow();
        },
      ),
      { numRuns: 200 },
    );
  });

  it("引数の Map が変化しない", () => {
    fc.assert(
      fc.property(
        arbGameEvent,
        fc.array(
          fc.tuple(
            fc.string({ minLength: 1, maxLength: 5 }),
            fc.float({ min: -100, max: 100, noNaN: true }),
          ),
        ),
        (event, entries) => {
          const progressMap = new Map(entries);
          const before = new Map(progressMap);
          applyEventToProgress(event, progressMap);
          for (const [k, v] of before) {
            expect(progressMap.get(k)).toBe(v);
          }
          expect(progressMap.size).toBe(before.size);
        },
      ),
      { numRuns: 200 },
    );
  });
});

describe("applyEventToMember - fast-check", () => {
  it("任意の GameEvent と Member で例外が発生しない", () => {
    fc.assert(
      fc.property(
        arbGameEvent,
        fc.record({
          id: fc.string({ minLength: 1, maxLength: 5 }),
          name: fc.string({ minLength: 1, maxLength: 10 }),
          skill: fc.integer({ min: 0, max: 99 }),
          exp: fc.integer({ min: 0, max: 1000 }),
          morale: fc.integer({ min: 0, max: 150 }),
          health: fc.integer({ min: 0, max: 100 }),
        }),
        (event, member) => {
          expect(() => applyEventToMember(event, member)).not.toThrow();
        },
      ),
      { numRuns: 200 },
    );
  });

  it("結果の morale は 0〜150 の範囲内", () => {
    fc.assert(
      fc.property(
        arbGameEvent,
        fc.record({
          id: fc.string({ minLength: 1, maxLength: 5 }),
          name: fc.string({ minLength: 1, maxLength: 10 }),
          skill: fc.integer({ min: 0, max: 99 }),
          exp: fc.integer({ min: 0, max: 1000 }),
          morale: fc.integer({ min: 0, max: 150 }),
          health: fc.integer({ min: 0, max: 100 }),
        }),
        (event, member) => {
          const result = applyEventToMember(event, member);
          expect(result.morale).toBeGreaterThanOrEqual(0);
          expect(result.morale).toBeLessThanOrEqual(150);
          expect(result.health).toBeGreaterThanOrEqual(0);
          expect(result.health).toBeLessThanOrEqual(100);
        },
      ),
      { numRuns: 200 },
    );
  });
});
