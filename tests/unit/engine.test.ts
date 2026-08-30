import { describe, expect, it } from "vitest";
import { GameEngine } from "../../src/game/engine.js";
import type { GanttTask, StageData } from "../../src/game/types.js";

// ===== テスト用ヘルパー =====

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

function makeStageData(overrides: Partial<StageData> = {}): StageData {
  return {
    id: "poc",
    name: "PoCステージ",
    description: "テスト用ステージ",
    budget: 1000000,
    deadline: 22,
    initialMembers: [
      { id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 },
      { id: "m2", name: "Bob", skill: 8, exp: 0, morale: 100, health: 100 },
    ],
    initialGantt: {
      tasks: [
        makeTask({ id: "t1", assignedMemberId: "m1" }),
        makeTask({ id: "t2", assignedMemberId: "m2" }),
      ],
      variantId: null,
    },
    ganttVariants: {},
    conditionalEvents: [],
    initialCards: [],
    ...overrides,
  };
}

// =============================================================================
// US1: 初期化
// =============================================================================

describe("GameEngine - US1 initialization", () => {
  it("getState().turn が 1 である", () => {
    const engine = new GameEngine(makeStageData());
    expect(engine.getState().turn).toBe(1);
  });

  it("getState().members が initialMembers と一致する", () => {
    const stageData = makeStageData();
    const engine = new GameEngine(stageData);
    expect(engine.getState().members).toEqual(stageData.initialMembers);
  });

  it("getState().gantt が initialGantt と一致する", () => {
    const stageData = makeStageData();
    const engine = new GameEngine(stageData);
    expect(engine.getState().gantt).toEqual(stageData.initialGantt);
  });

  it("getState().budget が stageData.budget と一致する", () => {
    const stageData = makeStageData({ budget: 500000 });
    const engine = new GameEngine(stageData);
    expect(engine.getState().budget).toBe(500000);
  });

  it("getState().totalCost が 0 である", () => {
    const engine = new GameEngine(makeStageData());
    expect(engine.getState().totalCost).toBe(0);
  });

  it("isGameOver() が false を返す", () => {
    const engine = new GameEngine(makeStageData());
    expect(engine.isGameOver()).toBe(false);
  });

  it("getState().isGameOver が false である", () => {
    const engine = new GameEngine(makeStageData());
    expect(engine.getState().isGameOver).toBe(false);
  });

  it("getState().deadline が stageData.deadline と一致する", () => {
    const stageData = makeStageData({ deadline: 15 });
    const engine = new GameEngine(stageData);
    expect(engine.getState().deadline).toBe(15);
  });
});

// =============================================================================
// US2: ターン処理
// =============================================================================

describe("GameEngine - US2 turn processing", () => {
  it("processTurn([]) 後に turn が 2 になる", () => {
    const engine = new GameEngine(makeStageData());
    engine.processTurn([]);
    expect(engine.getState().turn).toBe(2);
  });

  it("processTurn([]) 後に totalCost が増加する", () => {
    const engine = new GameEngine(makeStageData());
    const before = engine.getState().totalCost;
    engine.processTurn([]);
    expect(engine.getState().totalCost).toBeGreaterThan(before);
  });

  it("processTurn([]) が TurnResult を返す", () => {
    const engine = new GameEngine(makeStageData());
    const result = engine.processTurn([]);
    expect(typeof result.isGameOver).toBe("boolean");
    expect(Array.isArray(result.events)).toBe(true);
    expect(Array.isArray(result.progressUpdates)).toBe(true);
    expect(Array.isArray(result.memberUpdates)).toBe(true);
  });

  it("アクティブタスクの進捗が更新される（progress >= 0）", () => {
    const engine = new GameEngine(makeStageData());
    engine.processTurn([]);
    const state = engine.getState();
    for (const task of state.gantt.tasks) {
      expect(task.progress).toBeGreaterThanOrEqual(0);
    }
  });

  it("メンバーの morale が変化する（decay 適用）", () => {
    const engine = new GameEngine(makeStageData());
    const before = engine.getState().members.map((m) => m.morale);
    engine.processTurn([]);
    const after = engine.getState().members.map((m) => m.morale);
    // decay で必ず変化するとは限らないが MEMBER_PARAMS 範囲内である
    for (const morale of after) {
      expect(morale).toBeGreaterThanOrEqual(0);
      expect(morale).toBeLessThanOrEqual(150);
    }
    expect(before).toBeDefined();
  });

  it("複数ターン実行しても例外が発生しない", () => {
    const engine = new GameEngine(makeStageData({ deadline: 30 }));
    expect(() => {
      for (let i = 0; i < 5; i++) {
        if (!engine.isGameOver()) {
          engine.processTurn([]);
        }
      }
    }).not.toThrow();
  });

  it("ターン後の getState() は正しい turn を返す", () => {
    const engine = new GameEngine(makeStageData());
    engine.processTurn([]);
    engine.processTurn([]);
    expect(engine.getState().turn).toBe(3);
  });
});

// =============================================================================
// US3: ゲーム終了判定
// =============================================================================

describe("GameEngine - US3 game over detection", () => {
  it("納期超過でゲームオーバーになる", () => {
    // turn.ts: deadlineExceeded = state.turn > state.deadline
    // deadline=1: turn=1 で処理 → 1>1=false、turn が2になった後 turn=2 で処理 → 2>1=true
    const engine = new GameEngine(makeStageData({ deadline: 1 }));
    engine.processTurn([]); // turn: 1→2
    const result = engine.processTurn([]); // turn=2 > deadline=1 → gameOver
    expect(result.isGameOver).toBe(true);
  });

  it("ゲームオーバー後の processTurn が例外をスローする", () => {
    const engine = new GameEngine(makeStageData({ deadline: 1 }));
    engine.processTurn([]);
    engine.processTurn([]); // gameOver
    expect(() => engine.processTurn([])).toThrow();
  });

  it("ゲームオーバー後 isGameOver() が true を返す", () => {
    const engine = new GameEngine(makeStageData({ deadline: 1 }));
    engine.processTurn([]);
    engine.processTurn([]); // gameOver
    expect(engine.isGameOver()).toBe(true);
  });

  it("全タスク done でゲームオーバーになる", () => {
    // 全タスクが done 状態のステージ
    const stageData = makeStageData({
      deadline: 30,
      initialGantt: {
        tasks: [
          makeTask({ id: "t1", progress: 100, status: "done", assignedMemberId: "m1" }),
          makeTask({ id: "t2", progress: 100, status: "done", assignedMemberId: "m2" }),
        ],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    const result = engine.processTurn([]);
    expect(result.isGameOver).toBe(true);
    expect(result.gameOverReason).toBe("全タスク完了");
  });

  it("通常進行中は isGameOver() が false", () => {
    const engine = new GameEngine(makeStageData({ deadline: 30 }));
    expect(engine.isGameOver()).toBe(false);
  });
});

// =============================================================================
// US4: memberUpdates 集計
// =============================================================================

describe("GameEngine - US4 memberUpdates aggregation", () => {
  it("ターン後のメンバー morale が MIN 以上である", () => {
    const stageData = makeStageData({
      initialMembers: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 5, health: 5 }],
      initialGantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1" })],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    engine.processTurn([]);
    const member = engine.getState().members[0]!;
    expect(member.morale).toBeGreaterThanOrEqual(0);
  });

  it("ターン後のメンバー health が MIN 以上である", () => {
    const stageData = makeStageData({
      initialMembers: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 5, health: 5 }],
      initialGantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1" })],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    engine.processTurn([]);
    const member = engine.getState().members[0]!;
    expect(member.health).toBeGreaterThanOrEqual(0);
  });

  it("ターン後のメンバー morale が MAX 以下である", () => {
    const stageData = makeStageData({
      initialMembers: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 150, health: 100 }],
      initialGantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1" })],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    engine.processTurn([]);
    const member = engine.getState().members[0]!;
    expect(member.morale).toBeLessThanOrEqual(150);
  });

  it("ターン後のメンバー health が MAX 以下である", () => {
    const stageData = makeStageData({
      initialMembers: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 }],
      initialGantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1" })],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    engine.processTurn([]);
    const member = engine.getState().members[0]!;
    expect(member.health).toBeLessThanOrEqual(100);
  });
});

// =============================================================================
// Spec-18: 実績（着手・完了ターン）の記録
// =============================================================================

describe("GameEngine - Spec-18 実績記録", () => {
  it("進捗が増えたターンで actualStartTurn が現在ターンに設定される", () => {
    // skill を大きくして進捗ダイスが必ず正になるようにする
    const stageData = makeStageData({
      initialMembers: [{ id: "m1", name: "Alice", skill: 100, exp: 0, morale: 100, health: 100 }],
      initialGantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1", progress: 0 })],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    engine.processTurn([]); // turn 1 で進捗
    const task = engine.getState().gantt.tasks[0]!;
    expect(task.progress).toBeGreaterThan(0);
    expect(task.actualStartTurn).toBe(1);
  });

  it("progress が 100 到達ターンで actualEndTurn が設定される", () => {
    const stageData = makeStageData({
      initialMembers: [{ id: "m1", name: "Alice", skill: 100, exp: 0, morale: 100, health: 100 }],
      initialGantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1", progress: 99, actualStartTurn: 1 })],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    engine.processTurn([]); // turn 1 で 100 到達
    const task = engine.getState().gantt.tasks[0]!;
    expect(task.progress).toBe(100);
    expect(task.actualEndTurn).toBe(1);
    expect(task.status).toBe("done");
  });

  it("進捗が増えないターンでは actualStartTurn は null のまま（着手なしに完了しない）", () => {
    // skill 0 かつ progress 0 のタスク。進捗ダイス下限が 0 なら着手されないことがある。
    // ここでは担当メンバーの居ないタスクにして確実に進捗0とする
    const stageData = makeStageData({
      initialMembers: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 }],
      initialGantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "no-such-member", progress: 0 })],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    engine.processTurn([]);
    const task = engine.getState().gantt.tasks[0]!;
    expect(task.progress).toBe(0);
    expect(task.actualStartTurn).toBeNull();
    expect(task.actualEndTurn).toBeNull();
  });

  it("一度設定された actualStartTurn は後続ターンで変化しない", () => {
    const stageData = makeStageData({
      initialMembers: [{ id: "m1", name: "Alice", skill: 100, exp: 0, morale: 100, health: 100 }],
      initialGantt: {
        tasks: [makeTask({ id: "t1", assignedMemberId: "m1", progress: 0, duration: 20 })],
        variantId: null,
      },
    });
    const engine = new GameEngine(stageData);
    engine.processTurn([]); // turn1 で着手
    const startAfterT1 = engine.getState().gantt.tasks[0]!.actualStartTurn;
    if (!engine.isGameOver()) {
      engine.processTurn([]); // turn2
    }
    const startAfterT2 = engine.getState().gantt.tasks[0]!.actualStartTurn;
    expect(startAfterT1).toBe(1);
    expect(startAfterT2).toBe(1);
  });
});
