import type { GameResult } from "../game/result.js";

/**
 * リザルト画面の DOM オーバーレイ。GameResult を描画し、成否・利益率・理由・主要数値と
 * 「タイトルへ戻る」導線を表示する。Playwright から data-testid で参照可能。
 */
export class ResultUI {
  private root: HTMLElement;
  private onBackToTitle: (() => void) | null = null;

  constructor(container: HTMLElement) {
    this.root = document.createElement("div");
    this.root.dataset.testid = "result-screen";
    this.root.style.cssText = [
      "position:absolute",
      "inset:0",
      "display:none",
      "flex-direction:column",
      "align-items:center",
      "justify-content:center",
      "gap:12px",
      "background:rgba(0,0,0,0.85)",
      "color:#e0e0e0",
      "font-family:monospace",
      "pointer-events:auto",
      "z-index:20",
    ].join(";");
    container.appendChild(this.root);
  }

  setOnBackToTitle(cb: () => void): void {
    this.onBackToTitle = cb;
  }

  /** GameResult を描画してリザルト画面を表示する */
  show(result: GameResult): void {
    this.root.innerHTML = "";

    // 成否判定（US1）
    const outcome = document.createElement("div");
    outcome.dataset.testid = "result-outcome";
    outcome.textContent = result.outcome === "clear" ? "CLEAR" : "FAILED";
    outcome.style.cssText = [
      "font-size:32px",
      "font-weight:bold",
      `color:${result.outcome === "clear" ? "#4a9eff" : "#ff6b6b"}`,
    ].join(";");
    this.root.appendChild(outcome);

    // 終了理由（US2）
    const reason = document.createElement("div");
    reason.dataset.testid = "result-reason";
    reason.textContent = this.buildReasonText(result);
    this.root.appendChild(reason);

    // 最終利益率（US1）
    const profitRate = document.createElement("div");
    profitRate.dataset.testid = "result-profit-rate";
    profitRate.textContent = `利益率: ${this.formatRate(result.profitRate)}`;
    profitRate.style.fontSize = "20px";
    this.root.appendChild(profitRate);

    // 最終利益（US1）
    const profit = document.createElement("div");
    profit.dataset.testid = "result-profit";
    profit.textContent = `利益: ¥${result.profit.toLocaleString()}`;
    this.root.appendChild(profit);

    // 主要数値の内訳（US2）
    const stats = document.createElement("div");
    stats.dataset.testid = "result-stats";
    stats.style.cssText = "font-size:12px;line-height:1.6;text-align:left;";
    stats.textContent = [
      `目標利益率: ${this.formatRate(result.targetProfitRate)}`,
      `予算: ¥${result.budget.toLocaleString()}`,
      `総消費コスト: ¥${result.totalCost.toLocaleString()}`,
      `経過ターン: ${result.turn}`,
      `タスク完了率: ${(result.completionRate * 100).toFixed(0)}%`,
    ].join("\n");
    stats.style.whiteSpace = "pre-line";
    this.root.appendChild(stats);

    // タイトルへ戻る（US3）
    const backBtn = document.createElement("button");
    backBtn.dataset.testid = "result-back-to-title";
    backBtn.textContent = "タイトルへ戻る";
    backBtn.classList.add("interactive");
    backBtn.style.cssText = [
      "background:#4a9eff",
      "color:#fff",
      "border:none",
      "border-radius:6px",
      "padding:8px 20px",
      "font-size:14px",
      "cursor:pointer",
    ].join(";");
    backBtn.addEventListener("click", () => {
      this.onBackToTitle?.();
    });
    this.root.appendChild(backBtn);

    this.root.style.display = "flex";
  }

  hide(): void {
    this.root.style.display = "none";
  }

  private formatRate(rate: number): string {
    return `${(rate * 100).toFixed(1)}%`;
  }

  private buildReasonText(result: GameResult): string {
    const base = result.reason === "全タスク完了" ? "納期内に全タスク完了" : "納期超過";
    const profitPart =
      result.profitRate >= result.targetProfitRate ? "目標利益率を達成" : "目標利益率に未達";
    return `${base}・${profitPart}`;
  }
}
