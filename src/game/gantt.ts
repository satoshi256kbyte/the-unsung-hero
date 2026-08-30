import { getConfig } from "./config.js";
import type { GanttChart, GanttTask, TaskStatus } from "./types.js";

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

export function updateTaskProgress(task: GanttTask, delta: number): GanttTask {
  const progress = clamp(task.progress + delta, 0, 100);
  return {
    ...task,
    progress,
    status: progress === 100 ? "done" : task.status,
  };
}

export function setTaskStatus(task: GanttTask, status: TaskStatus): GanttTask {
  return { ...task, status };
}

export function applyRework(task: GanttTask, skill: number): GanttTask {
  const { REWORK } = getConfig().balance;
  const rollbackRate = REWORK.ROLLBACK_BASE - skill * REWORK.ROLLBACK_COEFF;
  const progress = clamp(task.progress - task.progress * rollbackRate, 0, 100);
  return { ...task, progress };
}

export function getCompletionRate(gantt: GanttChart): number {
  if (gantt.tasks.length === 0) return 0.0;
  const done = gantt.tasks.filter((t) => t.status === "done").length;
  return done / gantt.tasks.length;
}

export function applyVariant(
  gantt: GanttChart,
  variantId: string,
  variants: Record<string, GanttChart>,
): GanttChart {
  const variant = variants[variantId];
  if (variant === undefined) return gantt;
  // リスケ差し替え時、同一 task id の実績（actualStartTurn/actualEndTurn）を引き継ぐ。
  // 消えた id の実績は破棄、新規 id は実績 null のまま。
  const prevActuals = new Map(
    gantt.tasks.map((t) => [t.id, { start: t.actualStartTurn, end: t.actualEndTurn }]),
  );
  return {
    ...variant,
    tasks: variant.tasks.map((t) => {
      const prev = prevActuals.get(t.id);
      return prev === undefined
        ? t
        : { ...t, actualStartTurn: prev.start, actualEndTurn: prev.end };
    }),
  };
}

// ===== 稲妻線（進捗ライン）算出（表示専用の純関数、DOM/Phaser 非依存） =====

/** 現在ターン currentTurn 時点で予定上あるべき進捗率（%、0〜100 にクランプ） */
export function plannedRate(task: GanttTask, currentTurn: number): number {
  if (task.duration <= 0) return currentTurn >= task.startTurn ? 100 : 0;
  return clamp(((currentTurn - task.startTurn + 1) / task.duration) * 100, 0, 100);
}

/** 予定に対する乖離（progress - plannedRate）。正=前倒し 負=遅れ 0=予定どおり */
export function progressDeviation(task: GanttTask, currentTurn: number): number {
  return task.progress - plannedRate(task, currentTurn);
}

/** 実績到達ターン座標（稲妻線の折れ位置）。startTurn〜startTurn+duration の範囲 */
export function actualPosition(task: GanttTask): number {
  return task.startTurn - 1 + task.duration * (task.progress / 100);
}
