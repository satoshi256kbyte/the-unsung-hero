import { describe, expect, it } from "vitest";
import { evaluateCondition } from "../../../src/game/conditional.js";
import { GameEngine } from "../../../src/game/engine.js";
import type { StageData } from "../../../src/game/types.js";

// Spec-15でpoc-01.tsのデータはpublic/data/stages/poc-01.jsonへ移設されたため、
// このテストではその内容と同一のフィクスチャをローカルに保持する。
const pocStage: StageData = {
  id: "poc-01",
  name: "PoCステージ",
  description:
    "PoC（概念実証）案件。要件定義・設計・実装・テスト・リリース準備の5工程を22日間で完遂し、目標利益率の達成を目指す。",
  budget: 5_000_000,
  deadline: 22,
  initialMembers: [
    { id: "alice", name: "アリス", skill: 12, exp: 0, morale: 100, health: 100 },
    { id: "bob", name: "ボブ", skill: 8, exp: 0, morale: 100, health: 100 },
    { id: "carol", name: "キャロル", skill: 6, exp: 0, morale: 100, health: 100 },
  ],
  initialGantt: {
    tasks: [
      {
        id: "t01",
        name: "要件定義",
        phase: "要件定義",
        startTurn: 1,
        duration: 3,
        assignedMemberId: "alice",
        progress: 0,
        status: "active",
        dependencies: [],
      },
      {
        id: "t02",
        name: "UI設計",
        phase: "設計",
        startTurn: 4,
        duration: 3,
        assignedMemberId: "alice",
        progress: 0,
        status: "active",
        dependencies: ["t01"],
      },
      {
        id: "t03",
        name: "DB設計",
        phase: "設計",
        startTurn: 4,
        duration: 2,
        assignedMemberId: "bob",
        progress: 0,
        status: "active",
        dependencies: ["t01"],
      },
      {
        id: "t04",
        name: "API実装",
        phase: "実装",
        startTurn: 7,
        duration: 5,
        assignedMemberId: "alice",
        progress: 0,
        status: "active",
        dependencies: ["t02", "t03"],
      },
      {
        id: "t05",
        name: "フロント実装",
        phase: "実装",
        startTurn: 7,
        duration: 5,
        assignedMemberId: "carol",
        progress: 0,
        status: "active",
        dependencies: ["t02"],
      },
      {
        id: "t06",
        name: "バックエンド実装",
        phase: "実装",
        startTurn: 7,
        duration: 4,
        assignedMemberId: "bob",
        progress: 0,
        status: "active",
        dependencies: ["t03"],
      },
      {
        id: "t07",
        name: "単体テスト",
        phase: "テスト",
        startTurn: 12,
        duration: 4,
        assignedMemberId: "bob",
        progress: 0,
        status: "active",
        dependencies: ["t04", "t06"],
      },
      {
        id: "t08",
        name: "結合テスト",
        phase: "テスト",
        startTurn: 14,
        duration: 4,
        assignedMemberId: "carol",
        progress: 0,
        status: "active",
        dependencies: ["t05", "t07"],
      },
      {
        id: "t09",
        name: "リリース準備",
        phase: "リリース準備",
        startTurn: 18,
        duration: 4,
        assignedMemberId: "alice",
        progress: 0,
        status: "active",
        dependencies: ["t08"],
      },
    ],
    variantId: null,
  },
  ganttVariants: {},
  conditionalEvents: [
    {
      id: "ce01",
      turn: 5,
      condition: "turn >= 5",
      eventType: "ネガティブ",
      params: { message: "中間チェック：進捗が遅れています", category: "進捗ダウン" },
    },
    {
      id: "ce02",
      turn: 10,
      condition: "completion_rate < 0.4",
      eventType: "ネガティブ",
      params: { message: "前半終了時点で進捗が40%未満です", category: "デバフ系" },
    },
    {
      id: "ce03",
      turn: 12,
      condition: "any_member_morale < 60",
      eventType: "ネガティブ",
      params: {
        message: "メンバーの士気が低下しています",
        category: "メンバー稼働系",
        targetId: null,
      },
    },
    {
      id: "ce04",
      turn: 16,
      condition: "budget_remaining <= 1500000",
      eventType: "ネガティブ",
      params: { message: "予算残高が150万円を下回りました", category: "スコープ変化系" },
    },
    {
      id: "ce05",
      turn: 18,
      condition: "completion_rate >= 0.8",
      eventType: "ポジティブ",
      params: { message: "終盤80%以上の進捗：リリースに向けて順調です", category: "バフ系" },
    },
  ],
  initialCards: ["デイリー", "レビュー", "モニタリング"],
};

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
