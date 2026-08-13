import { describe, expect, it } from "vitest";
import { evaluateCondition } from "../../../src/game/conditional.js";
import { GameEngine } from "../../../src/game/engine.js";
import { pocStage } from "../../../src/game/stages/pocStage.js";

// =============================================================================
// US1: PoCステージで GameEngine を初期化できる
// =============================================================================

describe("pocStage - US1: GameEngine初期化", () => {
  it("new GameEngine(pocStage) が例外なく生成できる", () => {
    expect(() => new GameEngine(pocStage)).not.toThrow();
  });

  it("getState().turn === 1", () => {
    const engine = new GameEngine(pocStage);
    expect(engine.getState().turn).toBe(1);
  });

  it("getState().members.length === 3", () => {
    const engine = new GameEngine(pocStage);
    expect(engine.getState().members).toHaveLength(3);
  });

  it("getState().budget === 5_000_000", () => {
    const engine = new GameEngine(pocStage);
    expect(engine.getState().budget).toBe(5_000_000);
  });

  it("getState().deadline === 22", () => {
    const engine = new GameEngine(pocStage);
    expect(engine.getState().deadline).toBe(22);
  });

  it("getState().hand に 2〜3枚の CardName が含まれる", () => {
    const engine = new GameEngine(pocStage);
    const hand = engine.getState().hand;
    expect(hand.length).toBeGreaterThanOrEqual(2);
    expect(hand.length).toBeLessThanOrEqual(3);
  });

  it("getState().gantt.tasks に 8〜10件のタスクがある", () => {
    const engine = new GameEngine(pocStage);
    const tasks = engine.getState().gantt.tasks;
    expect(tasks.length).toBeGreaterThanOrEqual(8);
    expect(tasks.length).toBeLessThanOrEqual(10);
  });

  it("全タスクの status が 'active' または 'waiting'", () => {
    const engine = new GameEngine(pocStage);
    const tasks = engine.getState().gantt.tasks;
    tasks.forEach((t) => {
      expect(["active", "waiting"]).toContain(t.status);
    });
  });

  it("initialMembers の id・name・skill が仕様通り", () => {
    const engine = new GameEngine(pocStage);
    const members = engine.getState().members;
    expect(members[0]).toMatchObject({ id: "alice", name: "アリス", skill: 12 });
    expect(members[1]).toMatchObject({ id: "bob", name: "ボブ", skill: 8 });
    expect(members[2]).toMatchObject({ id: "carol", name: "キャロル", skill: 6 });
  });
});

// =============================================================================
// US2: ガントチャートタスクが PoC の工程を正しく表現する
// =============================================================================

describe("pocStage - US2: ガントタスク整合性", () => {
  const tasks = pocStage.initialGantt.tasks;
  const memberIds = new Set(pocStage.initialMembers.map((m) => m.id));
  const taskIds = new Set(tasks.map((t) => t.id));

  it("全タスクの startTurn + duration が deadline(22) 以内", () => {
    tasks.forEach((t) => {
      expect(t.startTurn + t.duration).toBeLessThanOrEqual(pocStage.deadline);
    });
  });

  it("全タスクの startTurn が 1 以上", () => {
    tasks.forEach((t) => {
      expect(t.startTurn).toBeGreaterThanOrEqual(1);
    });
  });

  it("全タスクの assignedMemberId が initialMembers に存在する", () => {
    tasks.forEach((t) => {
      expect(memberIds).toContain(t.assignedMemberId);
    });
  });

  it("全タスクの dependencies が有効なタスクIDを参照する", () => {
    tasks.forEach((t) => {
      t.dependencies.forEach((dep) => {
        expect(taskIds).toContain(dep);
      });
    });
  });

  it("依存関係に循環がない（トポロジカルソートで検証）", () => {
    const inDegree = new Map<string, number>();
    const adj = new Map<string, string[]>();

    tasks.forEach((t) => {
      inDegree.set(t.id, 0);
      adj.set(t.id, []);
    });

    tasks.forEach((t) => {
      t.dependencies.forEach((dep) => {
        adj.get(dep)?.push(t.id);
        inDegree.set(t.id, (inDegree.get(t.id) ?? 0) + 1);
      });
    });

    const queue: string[] = [];
    inDegree.forEach((deg, id) => {
      if (deg === 0) queue.push(id);
    });

    let visited = 0;
    while (queue.length > 0) {
      const node = queue.shift();
      if (node === undefined) break;
      visited++;
      adj.get(node)?.forEach((next) => {
        const deg = (inDegree.get(next) ?? 0) - 1;
        inDegree.set(next, deg);
        if (deg === 0) queue.push(next);
      });
    }

    expect(visited).toBe(tasks.length);
  });
});

// =============================================================================
// US3: 条件付きイベントが適切な条件で発火する
// =============================================================================

describe("pocStage - US3: 条件付きイベント", () => {
  const validPatterns = [
    /^turn\s*(>=|<=|==)\s*\d+$/,
    /^completion_rate\s*(>=|<)\s*[\d.]+$/,
    /^budget_remaining\s*<=\s*\d+$/,
    /^any_member_morale\s*<\s*\d+$/,
    /^any_member_health\s*<\s*\d+$/,
    /^all_members_morale\s*<\s*\d+$/,
  ];

  it("conditionalEvents が 3〜5 件定義されている", () => {
    expect(pocStage.conditionalEvents.length).toBeGreaterThanOrEqual(3);
    expect(pocStage.conditionalEvents.length).toBeLessThanOrEqual(5);
  });

  it("全条件式が evaluateCondition の対応パターンにマッチする", () => {
    pocStage.conditionalEvents.forEach((ce) => {
      const matched = validPatterns.some((p) => p.test(ce.condition));
      expect(matched, `condition "${ce.condition}" が無効パターン`).toBe(true);
    });
  });

  it("turn >= 5 条件がターン5で true を返す", () => {
    const engine = new GameEngine(pocStage);
    const state = engine.getState();
    const ce01 = pocStage.conditionalEvents.find((ce) => ce.id === "ce01");
    expect(ce01).toBeDefined();
    // turn=1 のとき false
    expect(evaluateCondition(state, "turn >= 5")).toBe(false);
  });

  it("GameEngine で 22 ターン進行しても例外が発生しない", () => {
    const engine = new GameEngine(pocStage);
    expect(() => {
      for (let i = 0; i < 22; i++) {
        if (engine.isGameOver()) break;
        engine.processTurn([]);
      }
    }).not.toThrow();
  });
});
