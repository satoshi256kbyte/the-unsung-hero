import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import { evaluateCondition, rollConditionalEvents } from "../../src/game/conditional.js";
import type { ConditionalEvent, GameState } from "../../src/game/types.js";

// ===== テスト用ヘルパー =====

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    turn: 1,
    members: [],
    gantt: { tasks: [], variantId: null },
    totalCost: 0,
    budget: 1000000,
    deadline: 20,
    hand: [],
    activeEffects: [],
    transparency: 50,
    tension: 50,
    isGameOver: false,
    gameOverReason: null,
    ...overrides,
  };
}

function makeMember(morale: number, health: number) {
  return {
    id: `m-${morale}-${health}`,
    name: "テスト",
    skill: 50,
    exp: 0,
    morale,
    health,
  };
}

function makeTask(progress: number) {
  return {
    id: "task-1",
    name: "タスク",
    phase: "A",
    startTurn: 1,
    duration: 5,
    assignedMemberId: "m1",
    progress,
    status: "active" as const,
    dependencies: [],
  };
}

// ===== evaluateCondition: turn 条件 =====

describe("evaluateCondition - turn", () => {
  it("turn >= N: 成立", () => {
    const state = makeState({ turn: 5 });
    expect(evaluateCondition(state, "turn >= 5")).toBe(true);
  });

  it("turn >= N: 不成立", () => {
    const state = makeState({ turn: 3 });
    expect(evaluateCondition(state, "turn >= 5")).toBe(false);
  });

  it("turn <= N: 成立", () => {
    const state = makeState({ turn: 3 });
    expect(evaluateCondition(state, "turn <= 5")).toBe(true);
  });

  it("turn <= N: 不成立", () => {
    const state = makeState({ turn: 6 });
    expect(evaluateCondition(state, "turn <= 5")).toBe(false);
  });

  it("turn == N: 成立", () => {
    const state = makeState({ turn: 5 });
    expect(evaluateCondition(state, "turn == 5")).toBe(true);
  });

  it("turn == N: 不成立", () => {
    const state = makeState({ turn: 4 });
    expect(evaluateCondition(state, "turn == 5")).toBe(false);
  });
});

// ===== evaluateCondition: completion_rate 条件 =====

describe("evaluateCondition - completion_rate", () => {
  it("completion_rate >= N: 成立（全タスク完了）", () => {
    const task = { ...makeTask(100), status: "done" as const };
    const state = makeState({ gantt: { tasks: [task], variantId: null } });
    expect(evaluateCondition(state, "completion_rate >= 0.9")).toBe(true);
  });

  it("completion_rate >= N: 不成立（未完了タスクあり）", () => {
    const task = makeTask(20);
    const state = makeState({ gantt: { tasks: [task], variantId: null } });
    expect(evaluateCondition(state, "completion_rate >= 0.9")).toBe(false);
  });

  it("completion_rate < N: 成立（低進捗）", () => {
    const task = makeTask(10);
    const state = makeState({ gantt: { tasks: [task], variantId: null } });
    expect(evaluateCondition(state, "completion_rate < 0.5")).toBe(true);
  });

  it("completion_rate < N: 不成立（高進捗）", () => {
    const task = { ...makeTask(100), status: "done" as const };
    const state = makeState({ gantt: { tasks: [task], variantId: null } });
    expect(evaluateCondition(state, "completion_rate < 0.5")).toBe(false);
  });
});

// ===== evaluateCondition: budget_remaining 条件 =====

describe("evaluateCondition - budget_remaining", () => {
  it("budget_remaining <= N: 成立（残予算が N 以下）", () => {
    const state = makeState({ budget: 1000000, totalCost: 800000 });
    expect(evaluateCondition(state, "budget_remaining <= 200000")).toBe(true);
  });

  it("budget_remaining <= N: 不成立（残予算が N より多い）", () => {
    const state = makeState({ budget: 1000000, totalCost: 100000 });
    expect(evaluateCondition(state, "budget_remaining <= 200000")).toBe(false);
  });
});

// ===== evaluateCondition: メンバー条件 =====

describe("evaluateCondition - member params", () => {
  it("any_member_morale < N: 成立（いずれかのメンバーが N 未満）", () => {
    const state = makeState({ members: [makeMember(20, 80), makeMember(90, 80)] });
    expect(evaluateCondition(state, "any_member_morale < 30")).toBe(true);
  });

  it("any_member_morale < N: 不成立（全員 N 以上）", () => {
    const state = makeState({ members: [makeMember(50, 80), makeMember(90, 80)] });
    expect(evaluateCondition(state, "any_member_morale < 30")).toBe(false);
  });

  it("any_member_health < N: 成立", () => {
    const state = makeState({ members: [makeMember(80, 10)] });
    expect(evaluateCondition(state, "any_member_health < 20")).toBe(true);
  });

  it("any_member_health < N: 不成立", () => {
    const state = makeState({ members: [makeMember(80, 80)] });
    expect(evaluateCondition(state, "any_member_health < 20")).toBe(false);
  });

  it("all_members_morale < N: 成立（全員 N 未満）", () => {
    const state = makeState({ members: [makeMember(10, 80), makeMember(20, 80)] });
    expect(evaluateCondition(state, "all_members_morale < 30")).toBe(true);
  });

  it("all_members_morale < N: 不成立（一人でも N 以上）", () => {
    const state = makeState({ members: [makeMember(10, 80), makeMember(80, 80)] });
    expect(evaluateCondition(state, "all_members_morale < 30")).toBe(false);
  });

  it("all_members_morale < N: メンバー0人は true（空配列のevery）", () => {
    const state = makeState({ members: [] });
    expect(evaluateCondition(state, "all_members_morale < 30")).toBe(true);
  });

  it("any_member_morale < N: メンバー0人は false", () => {
    const state = makeState({ members: [] });
    expect(evaluateCondition(state, "any_member_morale < 30")).toBe(false);
  });
});

// ===== evaluateCondition: 未知条件 =====

describe("evaluateCondition - unknown/edge cases", () => {
  it("未知の条件式は false を返す（例外なし）", () => {
    const state = makeState();
    expect(evaluateCondition(state, "unknown_condition")).toBe(false);
  });

  it("空文字列は false を返す（例外なし）", () => {
    const state = makeState();
    expect(evaluateCondition(state, "")).toBe(false);
  });

  it("パターンは合うが演算子が未知の場合は false", () => {
    const state = makeState({ turn: 5 });
    expect(evaluateCondition(state, "turn != 5")).toBe(false);
  });
});

// ===== rollConditionalEvents =====

describe("rollConditionalEvents", () => {
  function makeConditionalEvent(overrides: Partial<ConditionalEvent> = {}): ConditionalEvent {
    return {
      id: "evt-01",
      turn: 1,
      condition: "turn >= 1",
      eventType: "ネガティブ",
      params: {},
      ...overrides,
    };
  }

  it("条件成立: GameEvent が1件返る", () => {
    const state = makeState({ turn: 3 });
    const ce = makeConditionalEvent({ turn: 3, condition: "turn >= 3" });
    const events = rollConditionalEvents(state, [ce]);
    expect(events).toHaveLength(1);
  });

  it("条件不成立: 空配列を返す", () => {
    const state = makeState({ turn: 2 });
    const ce = makeConditionalEvent({ turn: 5, condition: "turn >= 5" });
    const events = rollConditionalEvents(state, [ce]);
    expect(events).toHaveLength(0);
  });

  it("turn フィルタ: conditionalEvent.turn > state.turn はスキップ", () => {
    const state = makeState({ turn: 3 });
    const ce = makeConditionalEvent({ turn: 10, condition: "turn >= 3" });
    const events = rollConditionalEvents(state, [ce]);
    expect(events).toHaveLength(0);
  });

  it("複数イベントで条件成立が2件", () => {
    const state = makeState({ turn: 5 });
    const events = rollConditionalEvents(state, [
      makeConditionalEvent({ id: "evt-01", turn: 1, condition: "turn >= 1" }),
      makeConditionalEvent({ id: "evt-02", turn: 5, condition: "turn == 5" }),
    ]);
    expect(events).toHaveLength(2);
  });

  it("空配列入力は空配列を返す", () => {
    const state = makeState();
    expect(rollConditionalEvents(state, [])).toHaveLength(0);
  });

  it("生成される GameEvent の id が conditional-{turn}-{id} 形式", () => {
    const state = makeState({ turn: 3 });
    const ce = makeConditionalEvent({ id: "evt-01", turn: 1, condition: "turn >= 1" });
    const events = rollConditionalEvents(state, [ce]);
    expect(events[0]?.id).toBe("conditional-3-evt-01");
  });

  it("GameEvent の type が ConditionalEvent.eventType と一致する", () => {
    const state = makeState({ turn: 1 });
    const ce = makeConditionalEvent({ eventType: "ポジティブ" });
    const events = rollConditionalEvents(state, [ce]);
    expect(events[0]?.type).toBe("ポジティブ");
  });

  it("params に category/targetId がある場合 GameEvent に反映される", () => {
    const state = makeState({ turn: 1 });
    const ce = makeConditionalEvent({
      params: { category: "デバフ系", targetId: "member-1", moraleDelta: -5 },
    });
    const events = rollConditionalEvents(state, [ce]);
    expect(events[0]?.category).toBe("デバフ系");
    expect(events[0]?.targetId).toBe("member-1");
  });

  it("params に category/targetId がない場合は null", () => {
    const state = makeState({ turn: 1 });
    const ce = makeConditionalEvent({ params: {} });
    const events = rollConditionalEvents(state, [ce]);
    expect(events[0]?.category).toBeNull();
    expect(events[0]?.targetId).toBeNull();
  });
});

// ===== US4: イミュータブル =====

describe("immutability", () => {
  it("evaluateCondition は GameState を変更しない", () => {
    const state = makeState({ turn: 5, members: [makeMember(50, 80)] });
    const snapshot = JSON.stringify(state);
    evaluateCondition(state, "turn >= 3");
    expect(JSON.stringify(state)).toBe(snapshot);
  });

  it("rollConditionalEvents は ConditionalEvent[] を変更しない", () => {
    const state = makeState({ turn: 3 });
    const ces: ConditionalEvent[] = [
      { id: "evt-01", turn: 1, condition: "turn >= 1", eventType: "ネガティブ", params: {} },
    ];
    const snapshot = JSON.stringify(ces);
    rollConditionalEvents(state, ces);
    expect(JSON.stringify(ces)).toBe(snapshot);
  });

  it("rollConditionalEvents は GameState を変更しない", () => {
    const state = makeState({ turn: 3 });
    const snapshot = JSON.stringify(state);
    rollConditionalEvents(state, [
      { id: "evt-01", turn: 1, condition: "turn >= 1", eventType: "ネガティブ", params: {} },
    ]);
    expect(JSON.stringify(state)).toBe(snapshot);
  });
});

// ===== fast-check プロパティテスト =====

describe("evaluateCondition - property tests", () => {
  it("任意の条件文字列で例外がスローされない", () => {
    const state = makeState({ turn: 5, budget: 1000000, totalCost: 0 });
    fc.assert(
      fc.property(fc.string(), (condition) => {
        expect(() => evaluateCondition(state, condition)).not.toThrow();
      }),
    );
  });

  it("任意の state で evaluateCondition が boolean を返す", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 30 }),
        fc.integer({ min: 0, max: 1000000 }),
        fc.integer({ min: 0, max: 1000000 }),
        (turn, budget, totalCost) => {
          const state = makeState({ turn, budget, totalCost });
          const result = evaluateCondition(state, "turn >= 5");
          expect(typeof result).toBe("boolean");
        },
      ),
    );
  });

  it("turn == N は state.turn が N と等しいときのみ true", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 20 }),
        fc.integer({ min: 1, max: 20 }),
        (stateTurn, n) => {
          const state = makeState({ turn: stateTurn });
          const result = evaluateCondition(state, `turn == ${n}`);
          expect(result).toBe(stateTurn === n);
        },
      ),
    );
  });

  it("rollConditionalEvents は GameEvent[] を返す", () => {
    fc.assert(
      fc.property(fc.integer({ min: 1, max: 20 }), (turn) => {
        const state = makeState({ turn });
        const result = rollConditionalEvents(state, []);
        expect(Array.isArray(result)).toBe(true);
      }),
    );
  });
});
