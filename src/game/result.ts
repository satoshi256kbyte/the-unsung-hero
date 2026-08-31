// リザルト（成否判定・最終利益率）の算出ロジック（純関数）。
// Phaser / DOM 非依存（Constitution 原則 I）。GameState から派生値を算出し、状態は保持しない。

import { getCompletionRate } from "./gantt.js";
import type { GameState } from "./types.js";

export type GameOutcome = "clear" | "fail";

export interface GameResult {
  readonly outcome: GameOutcome;
  /** 終了理由（GameState.gameOverReason 由来）: "全タスク完了" | "納期超過" */
  readonly reason: string;
  /** 最終利益（budget − totalCost、負値もありうる） */
  readonly profit: number;
  /** 最終利益率（budget>0 なら profit/budget、else 0。ゼロ除算回避） */
  readonly profitRate: number;
  /** 目標利益率（判定基準） */
  readonly targetProfitRate: number;
  readonly budget: number;
  readonly totalCost: number;
  /** 経過ターン（終了時点） */
  readonly turn: number;
  /** タスク完了率 0.0–1.0 */
  readonly completionRate: number;
}

/**
 * GameState から成否判定・利益率を算出する純関数。入力を変更しない。
 * クリア条件: 全タスク完了（reason === "全タスク完了" = 納期内完遂）かつ
 * profitRate >= targetProfitRate。それ以外（納期超過、または利益率が目標未満）は "fail"。
 * budget が 0 のとき profitRate は 0（ゼロ除算回避）。
 */
export function evaluateResult(state: GameState, targetProfitRate: number): GameResult {
  const profit = state.budget - state.totalCost;
  const profitRate = state.budget > 0 ? profit / state.budget : 0;
  const reason = state.gameOverReason ?? "";
  const allDone = reason === "全タスク完了";
  const profitMet = profitRate >= targetProfitRate;
  const outcome: GameOutcome = allDone && profitMet ? "clear" : "fail";

  return {
    outcome,
    reason,
    profit,
    profitRate,
    targetProfitRate,
    budget: state.budget,
    totalCost: state.totalCost,
    turn: state.turn,
    completionRate: getCompletionRate(state.gantt),
  };
}
