import { getConfig } from "../game/config.js";
import { getStage, STAGE_JSON_FILES } from "../game/stages/index.js";

export class StageSelectUI {
  private root: HTMLElement;
  private listEl!: HTMLElement;
  private confirmEl!: HTMLElement;
  private selectedStageId: string | null = null;
  private onStart: ((stageId: string) => void) | null = null;

  constructor(container: HTMLElement) {
    this.root = document.createElement("div");
    this.root.style.cssText = [
      "position:absolute",
      "inset:0",
      "display:flex",
      "flex-direction:column",
      "align-items:center",
      "justify-content:center",
      "pointer-events:auto",
    ].join(";");

    this.buildList();
    this.buildConfirm();

    container.appendChild(this.root);
    this.showList();
  }

  private buildList(): void {
    this.listEl = document.createElement("div");
    this.listEl.dataset.testid = "stage-list";
    this.listEl.style.cssText = "display:flex;flex-direction:column;gap:12px;";

    for (const stageId of Object.keys(STAGE_JSON_FILES)) {
      const stage = getStage(stageId);
      const card = document.createElement("button");
      card.dataset.testid = `stage-card-${stageId}`;
      card.textContent = stage.name;
      card.classList.add("interactive");
      card.style.cssText = [
        "background:#1a1a3e",
        "color:#fff",
        "border:1px solid #4a9eff",
        "border-radius:6px",
        "padding:16px 32px",
        "font-size:16px",
        "cursor:pointer",
      ].join(";");
      card.addEventListener("click", () => {
        this.selectedStageId = stageId;
        this.showConfirm(stageId);
      });
      this.listEl.appendChild(card);
    }

    this.root.appendChild(this.listEl);
  }

  private buildConfirm(): void {
    this.confirmEl = document.createElement("div");
    this.confirmEl.dataset.testid = "stage-confirm";
    this.confirmEl.style.cssText = [
      "display:flex",
      "flex-direction:column",
      "align-items:center",
      "gap:12px",
      "background:#1a1a3e",
      "border-radius:6px",
      "padding:24px 32px",
      "color:#fff",
      "max-width:480px",
    ].join(";");

    const description = document.createElement("p");
    description.dataset.testid = "stage-confirm-description";
    this.confirmEl.appendChild(description);

    const budget = document.createElement("p");
    budget.dataset.testid = "stage-confirm-budget";
    this.confirmEl.appendChild(budget);

    const profitRate = document.createElement("p");
    profitRate.dataset.testid = "stage-confirm-profit-rate";
    this.confirmEl.appendChild(profitRate);

    const buttonRow = document.createElement("div");
    buttonRow.style.cssText = "display:flex;gap:12px;";

    const backBtn = document.createElement("button");
    backBtn.dataset.testid = "stage-confirm-back-btn";
    backBtn.textContent = "もどる";
    backBtn.classList.add("interactive");
    backBtn.style.cssText =
      "background:#444;color:#fff;border:none;border-radius:6px;padding:8px 20px;cursor:pointer;";
    backBtn.addEventListener("click", () => {
      this.selectedStageId = null;
      this.showList();
    });
    buttonRow.appendChild(backBtn);

    const startBtn = document.createElement("button");
    startBtn.dataset.testid = "stage-confirm-start-btn";
    startBtn.textContent = "開始する";
    startBtn.classList.add("interactive");
    startBtn.style.cssText =
      "background:#4a9eff;color:#fff;border:none;border-radius:6px;padding:8px 20px;cursor:pointer;";
    startBtn.addEventListener("click", () => {
      if (this.selectedStageId !== null) {
        this.onStart?.(this.selectedStageId);
      }
    });
    buttonRow.appendChild(startBtn);

    this.confirmEl.appendChild(buttonRow);
    this.root.appendChild(this.confirmEl);
  }

  private showList(): void {
    this.listEl.style.display = "flex";
    this.confirmEl.style.display = "none";
  }

  private showConfirm(stageId: string): void {
    const stage = getStage(stageId);
    const profitRatePercent = (getConfig().balance.GLOBAL_RULES.TARGET_PROFIT_RATE * 100).toFixed(
      0,
    );

    const description = this.confirmEl.querySelector<HTMLElement>(
      '[data-testid="stage-confirm-description"]',
    );
    if (description) description.textContent = stage.description;

    const budget = this.confirmEl.querySelector<HTMLElement>(
      '[data-testid="stage-confirm-budget"]',
    );
    if (budget) budget.textContent = `予算: ¥${stage.budget.toLocaleString()}`;

    const profitRate = this.confirmEl.querySelector<HTMLElement>(
      '[data-testid="stage-confirm-profit-rate"]',
    );
    if (profitRate) profitRate.textContent = `目標利益率 ${profitRatePercent}%以上`;

    this.listEl.style.display = "none";
    this.confirmEl.style.display = "flex";
  }

  setOnStart(cb: (stageId: string) => void): void {
    this.onStart = cb;
  }

  destroy(): void {
    this.root.remove();
  }
}
