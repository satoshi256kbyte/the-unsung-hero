import { REWORK } from "./constants.js";
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
  return variants[variantId] ?? gantt;
}
