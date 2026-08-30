import {
  actualPosition,
  applyRework,
  applyVariant,
  getCompletionRate,
  plannedRate,
  progressDeviation,
  setTaskStatus,
  updateTaskProgress,
} from "@game/gantt.js";
import type { GanttChart, GanttTask } from "@game/types.js";
import * as fc from "fast-check";
import { describe, expect, it } from "vitest";

// ---------------------------------------------------------------------------
// テストヘルパー
// ---------------------------------------------------------------------------

function makeTask(overrides: Partial<GanttTask> = {}): GanttTask {
  return {
    id: "t1",
    name: "テストタスク",
    phase: "実装",
    startTurn: 1,
    duration: 5,
    assignedMemberId: "m1",
    progress: 50,
    status: "active",
    dependencies: [],
    actualStartTurn: null,
    actualEndTurn: null,
    ...overrides,
  };
}

function makeGantt(tasks: GanttTask[], variantId: string | null = null): GanttChart {
  return { tasks, variantId };
}

// ---------------------------------------------------------------------------
// US1: タスクの進捗を更新できる
// ---------------------------------------------------------------------------

describe("updateTaskProgress", () => {
  describe("境界値テスト", () => {
    it("progress 0 に +20 delta → 20 に更新される", () => {
      const task = makeTask({ progress: 0, status: "active" });
      const result = updateTaskProgress(task, 20);
      expect(result.progress).toBe(20);
      expect(result.status).toBe("active");
    });

    it("progress 80 に +30 delta → 100 にクランプされ done に遷移", () => {
      const task = makeTask({ progress: 80, status: "active" });
      const result = updateTaskProgress(task, 30);
      expect(result.progress).toBe(100);
      expect(result.status).toBe("done");
    });

    it("progress 100 に +10 delta → 100 のまま（オーバーフローなし）", () => {
      const task = makeTask({ progress: 100, status: "done" });
      const result = updateTaskProgress(task, 10);
      expect(result.progress).toBe(100);
    });

    it("マイナス delta → 0 にクランプ（アンダーフローなし）", () => {
      const task = makeTask({ progress: 10, status: "active" });
      const result = updateTaskProgress(task, -50);
      expect(result.progress).toBe(0);
      expect(result.status).toBe("active");
    });

    it("progress が 100 になったとき stalled → done に遷移", () => {
      const task = makeTask({ progress: 90, status: "stalled" });
      const result = updateTaskProgress(task, 10);
      expect(result.progress).toBe(100);
      expect(result.status).toBe("done");
    });

    it("元のタスクはイミュータブル（元オブジェクトを変更しない）", () => {
      const task = makeTask({ progress: 50 });
      updateTaskProgress(task, 30);
      expect(task.progress).toBe(50);
    });
  });

  describe("fast-check: 任意の delta で結果が 0〜100 に収まる", () => {
    it("property: clamp invariant", () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 0, max: 100 }),
          fc.integer({ min: -50, max: 50 }),
          (progress, delta) => {
            const task = makeTask({ progress });
            const result = updateTaskProgress(task, delta);
            return result.progress >= 0 && result.progress <= 100;
          },
        ),
      );
    });

    it("property: delta >= 0 のとき progress は単調非減少", () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 0, max: 100 }),
          fc.integer({ min: 0, max: 100 }),
          (progress, delta) => {
            const task = makeTask({ progress });
            const result = updateTaskProgress(task, delta);
            return result.progress >= task.progress;
          },
        ),
      );
    });
  });
});

// ---------------------------------------------------------------------------
// US2: タスクの状態を遷移できる
// ---------------------------------------------------------------------------

describe("setTaskStatus", () => {
  it("active → stalled に遷移できる", () => {
    const task = makeTask({ status: "active" });
    expect(setTaskStatus(task, "stalled").status).toBe("stalled");
  });

  it("stalled → active に遷移できる", () => {
    const task = makeTask({ status: "stalled" });
    expect(setTaskStatus(task, "active").status).toBe("active");
  });

  it("active → done に遷移できる", () => {
    const task = makeTask({ status: "active" });
    expect(setTaskStatus(task, "done").status).toBe("done");
  });

  it("元のタスクはイミュータブル", () => {
    const task = makeTask({ status: "active" });
    setTaskStatus(task, "done");
    expect(task.status).toBe("active");
  });
});

describe("applyRework", () => {
  // REWORK.ROLLBACK_BASE = 0.4, ROLLBACK_COEFF = 0.01
  // rollbackRate = 0.4 - skill * 0.01

  describe("境界値テスト", () => {
    it("技 0: 巻き戻し率 40%（progress 100 → 60）", () => {
      const task = makeTask({ progress: 100 });
      const result = applyRework(task, 0);
      expect(result.progress).toBeCloseTo(60, 5);
    });

    it("技 10: 巻き戻し率 30%（progress 100 → 70）", () => {
      const task = makeTask({ progress: 100 });
      const result = applyRework(task, 10);
      expect(result.progress).toBeCloseTo(70, 5);
    });

    it("技 99: 巻き戻し率 −59% → 負にならず progress は元より大きくなる（clampで100以下）", () => {
      const task = makeTask({ progress: 80 });
      const result = applyRework(task, 99);
      // rollbackRate = 0.4 - 99*0.01 = -0.59 → progress += 47.2 → clamp to 100
      expect(result.progress).toBe(100);
    });

    it("progress 0 のとき手戻りしても 0 のまま（0クランプ確認）", () => {
      const task = makeTask({ progress: 0 });
      const result = applyRework(task, 0);
      expect(result.progress).toBe(0);
    });

    it("status は active のまま変わらない", () => {
      const task = makeTask({ progress: 80, status: "active" });
      const result = applyRework(task, 5);
      expect(result.status).toBe("active");
    });
  });

  describe("fast-check: 任意の技レベル・進捗でパニックなし", () => {
    it("property: 結果は常に 0〜100 の範囲", () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 0, max: 100 }),
          fc.integer({ min: 0, max: 99 }),
          (progress, skill) => {
            const task = makeTask({ progress });
            const result = applyRework(task, skill);
            return result.progress >= 0 && result.progress <= 100;
          },
        ),
      );
    });
  });
});

// ---------------------------------------------------------------------------
// US3: バリアントへ切り替えられる
// ---------------------------------------------------------------------------

describe("getCompletionRate", () => {
  it("全タスク done → 1.0", () => {
    const tasks = [makeTask({ id: "t1", status: "done" }), makeTask({ id: "t2", status: "done" })];
    expect(getCompletionRate(makeGantt(tasks))).toBe(1.0);
  });

  it("半分 done → 0.5", () => {
    const tasks = [
      makeTask({ id: "t1", status: "done" }),
      makeTask({ id: "t2", status: "active" }),
    ];
    expect(getCompletionRate(makeGantt(tasks))).toBe(0.5);
  });

  it("全タスク active → 0.0", () => {
    const tasks = [
      makeTask({ id: "t1", status: "active" }),
      makeTask({ id: "t2", status: "active" }),
    ];
    expect(getCompletionRate(makeGantt(tasks))).toBe(0.0);
  });

  it("タスク 0 件 → 0.0（ゼロ除算なし）", () => {
    expect(getCompletionRate(makeGantt([]))).toBe(0.0);
  });
});

describe("applyVariant", () => {
  const base = makeGantt([makeTask({ id: "base-task" })], null);
  const variantA = makeGantt([makeTask({ id: "variant-a-task" })], "variant-a");
  const variants: Record<string, GanttChart> = {
    "variant-a": variantA,
  };

  it("存在するバリアントIDを指定 → バリアントに差し替わる", () => {
    const result = applyVariant(base, "variant-a", variants);
    // Spec-18: 実績引き継ぎのため新しいオブジェクトを返す。id が一致するタスクが無いので内容は variantA と同一
    expect(result).toEqual(variantA);
  });

  it("存在しないIDを指定 → 元の gantt をそのまま返す", () => {
    const result = applyVariant(base, "nonexistent", variants);
    expect(result).toBe(base);
  });

  it("空の variants を指定 → 元の gantt を返す", () => {
    const result = applyVariant(base, "variant-a", {});
    expect(result).toBe(base);
  });
});

// ---------------------------------------------------------------------------
// Spec-18: 稲妻線算出（plannedRate / progressDeviation / actualPosition）
// ---------------------------------------------------------------------------

describe("plannedRate", () => {
  it("開始前のターンは 0", () => {
    const task = makeTask({ startTurn: 5, duration: 4, progress: 0 });
    expect(plannedRate(task, 4)).toBe(0);
  });

  it("期間の途中では 0〜100 の間", () => {
    const task = makeTask({ startTurn: 1, duration: 4, progress: 0 });
    // turn 2: (2-1+1)/4 = 0.5 → 50%
    expect(plannedRate(task, 2)).toBeCloseTo(50);
  });

  it("期間終了以降は 100 にクランプ", () => {
    const task = makeTask({ startTurn: 1, duration: 4, progress: 0 });
    expect(plannedRate(task, 10)).toBe(100);
  });

  it("プロパティ: 常に 0〜100 に収まる", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 30 }),
        fc.integer({ min: 1, max: 20 }),
        fc.integer({ min: 0, max: 40 }),
        (startTurn, duration, currentTurn) => {
          const task = makeTask({ startTurn, duration, progress: 0 });
          const r = plannedRate(task, currentTurn);
          return r >= 0 && r <= 100;
        },
      ),
    );
  });
});

describe("progressDeviation", () => {
  it("遅れているタスクは負", () => {
    // turn 3, startTurn1 duration4 → plannedRate=75、progress20 → deviation<0
    const task = makeTask({ startTurn: 1, duration: 4, progress: 20 });
    expect(progressDeviation(task, 3)).toBeLessThan(0);
  });

  it("前倒しのタスクは正", () => {
    const task = makeTask({ startTurn: 1, duration: 4, progress: 90 });
    expect(progressDeviation(task, 2)).toBeGreaterThan(0);
  });

  it("予定どおりはほぼ 0", () => {
    // turn2, startTurn1 duration4 → plannedRate=50、progress50 → 0
    const task = makeTask({ startTurn: 1, duration: 4, progress: 50 });
    expect(progressDeviation(task, 2)).toBeCloseTo(0);
  });
});

describe("actualPosition", () => {
  it("progress 0 は startTurn-1", () => {
    const task = makeTask({ startTurn: 5, duration: 4, progress: 0 });
    expect(actualPosition(task)).toBe(4);
  });

  it("progress 100 は startTurn-1+duration", () => {
    const task = makeTask({ startTurn: 5, duration: 4, progress: 100 });
    expect(actualPosition(task)).toBe(8);
  });

  it("プロパティ: startTurn-1 〜 startTurn-1+duration の範囲に収まる", () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 1, max: 30 }),
        fc.integer({ min: 1, max: 20 }),
        fc.float({ min: 0, max: 100, noNaN: true }),
        (startTurn, duration, progress) => {
          const task = makeTask({ startTurn, duration, progress });
          const pos = actualPosition(task);
          return pos >= startTurn - 1 && pos <= startTurn - 1 + duration;
        },
      ),
    );
  });
});

// ---------------------------------------------------------------------------
// Spec-18: リスケ差し替え時の実績引き継ぎ
// ---------------------------------------------------------------------------

describe("applyVariant - 実績引き継ぎ", () => {
  it("同一 id のタスクの実績（actualStartTurn/actualEndTurn）を引き継ぐ", () => {
    const current = makeGantt([
      makeTask({ id: "t1", startTurn: 1, duration: 3, actualStartTurn: 2, actualEndTurn: 5 }),
    ]);
    const variant = makeGantt([
      makeTask({ id: "t1", startTurn: 1, duration: 6, actualStartTurn: null, actualEndTurn: null }),
    ]);
    const result = applyVariant(current, "v1", { v1: variant });
    const t1 = result.tasks.find((t) => t.id === "t1")!;
    expect(t1.duration).toBe(6); // 予定は差し替わる
    expect(t1.actualStartTurn).toBe(2); // 実績は引き継ぐ
    expect(t1.actualEndTurn).toBe(5);
  });

  it("新規 id のタスクは実績 null のまま", () => {
    const current = makeGantt([makeTask({ id: "t1", actualStartTurn: 2 })]);
    const variant = makeGantt([makeTask({ id: "t2", actualStartTurn: null })]);
    const result = applyVariant(current, "v1", { v1: variant });
    const t2 = result.tasks.find((t) => t.id === "t2")!;
    expect(t2.actualStartTurn).toBeNull();
  });

  it("消えた id の実績は破棄される（結果に含まれない）", () => {
    const current = makeGantt([makeTask({ id: "t1", actualStartTurn: 2 })]);
    const variant = makeGantt([makeTask({ id: "t2" })]);
    const result = applyVariant(current, "v1", { v1: variant });
    expect(result.tasks.find((t) => t.id === "t1")).toBeUndefined();
  });
});
