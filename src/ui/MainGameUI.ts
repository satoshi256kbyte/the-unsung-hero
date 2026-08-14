import { CARD_REGISTRY } from "../game/cards/index.js";
import type { CardName, GameState } from "../game/types.js";
import { CardSlot } from "./CardSlot.js";
import { LoadingScreen } from "./LoadingScreen.js";

const MAX_COST = 8;
const SLOT_COUNT = 8;

function gauge(value: number, max: number): string {
  const pct = Math.min(Math.max(value / max, 0), 1);
  const filled = Math.round(pct * 10);
  return "█".repeat(filled) + "░".repeat(10 - filled);
}

export class MainGameUI {
  private root: HTMLElement;
  readonly loading: LoadingScreen;
  private slots: CardSlot[] = [];
  private totalCostEl!: HTMLElement;
  private confirmBtn!: HTMLButtonElement;
  private onConfirm: ((cards: CardName[]) => void) | null = null;

  constructor(container: HTMLElement) {
    this.root = container;
    this.root.style.cssText = [
      "position:absolute",
      "inset:0",
      "display:flex",
      "flex-direction:column",
      "font-family:monospace",
      "font-size:13px",
      "color:#e0e0e0",
      "padding:8px",
      "gap:6px",
      "pointer-events:none",
    ].join(";");

    this.loading = new LoadingScreen(this.root);
    this.buildHeader();
    this.buildDashboard();
    this.buildCardArea();
    this.buildFooter();
  }

  private buildHeader(): void {
    const header = document.createElement("div");
    header.style.cssText = "background:#1a1a3e;border-radius:6px;padding:4px 10px;";
    const turn = document.createElement("span");
    turn.dataset.testid = "header-turn";
    turn.textContent = "ターン - / 残り -";
    header.appendChild(turn);
    this.root.appendChild(header);
  }

  private buildDashboard(): void {
    const dash = document.createElement("div");
    dash.style.cssText = ["display:flex", "gap:8px", "flex:1", "min-height:0"].join(";");

    // KPI
    const kpi = document.createElement("div");
    kpi.style.cssText = "background:#1a1a3e;border-radius:6px;padding:8px;flex:1;";
    for (const [id, label] of [
      ["kpi-profit", "予想利益"],
      ["kpi-profit-rate", "利益率"],
      ["kpi-spi", "SPI"],
      ["kpi-cpi", "CPI"],
      ["kpi-transparency", "透明性"],
      ["kpi-tension", "緊張感"],
    ] as [string, string][]) {
      const row = document.createElement("div");
      row.style.marginBottom = "4px";
      const label_el = document.createElement("span");
      label_el.textContent = `${label}: `;
      const val = document.createElement("span");
      val.dataset.testid = id;
      val.setAttribute("aria-valuenow", "0");
      val.textContent = "-";
      row.appendChild(label_el);
      row.appendChild(val);
      kpi.appendChild(row);
    }
    dash.appendChild(kpi);

    // Members
    const members = document.createElement("div");
    members.dataset.testid = "member-list";
    members.style.cssText = "background:#1a1a3e;border-radius:6px;padding:8px;flex:1;";
    dash.appendChild(members);

    this.root.appendChild(dash);
  }

  private buildCardArea(): void {
    const area = document.createElement("div");
    area.style.cssText = [
      "background:#1a1a3e",
      "border-radius:6px",
      "padding:8px",
      "display:flex",
      "align-items:center",
      "gap:6px",
      "pointer-events:auto",
      "flex-wrap:wrap",
    ].join(";");

    for (let i = 0; i < SLOT_COUNT; i++) {
      const slot = new CardSlot(i);
      this.slots.push(slot);
      slot.el.addEventListener("dragover", (e) => {
        e.preventDefault();
      });
      slot.el.addEventListener("drop", (e) => {
        e.preventDefault();
        const cardName = (e as DragEvent).dataTransfer?.getData("text/plain") as
          | CardName
          | undefined;
        if (!cardName) return;
        this.handleDrop(slot, cardName);
      });
      slot.el.addEventListener("click", () => {
        if (slot.card !== null) {
          slot.remove();
          this.updateTotalCost();
        }
      });
      area.appendChild(slot.el);
    }

    const costRow = document.createElement("div");
    costRow.style.cssText = "margin-left:auto;white-space:nowrap;";
    costRow.textContent = "合計: ";
    this.totalCostEl = document.createElement("span");
    this.totalCostEl.dataset.testid = "total-cost";
    this.totalCostEl.textContent = "0";
    costRow.appendChild(this.totalCostEl);
    area.appendChild(costRow);

    this.root.appendChild(area);
  }

  private buildFooter(): void {
    const footer = document.createElement("div");
    footer.style.cssText = [
      "background:#1a1a3e",
      "border-radius:6px",
      "padding:6px 10px",
      "display:flex",
      "justify-content:flex-end",
      "pointer-events:auto",
    ].join(";");

    this.confirmBtn = document.createElement("button");
    this.confirmBtn.dataset.testid = "confirm-turn-btn";
    this.confirmBtn.textContent = "ターン確定";
    this.confirmBtn.classList.add("interactive");
    this.confirmBtn.style.cssText = [
      "background:#4a9eff",
      "color:#fff",
      "border:none",
      "border-radius:6px",
      "padding:8px 20px",
      "font-size:14px",
      "cursor:pointer",
    ].join(";");
    this.confirmBtn.addEventListener("click", () => {
      if (this.onConfirm) {
        this.onConfirm(this.getPlacedCards());
      }
    });
    footer.appendChild(this.confirmBtn);
    this.root.appendChild(footer);
  }

  private handleDrop(slot: CardSlot, cardName: CardName): void {
    const cardCost = CARD_REGISTRY[cardName]?.cost ?? 0;
    const currentTotal = this.getTotalCost();
    const slotCurrentCost = slot.cost;
    const newTotal = currentTotal - slotCurrentCost + cardCost;

    if (newTotal > MAX_COST) {
      slot.markBlocked();
      setTimeout(() => slot.clearBlocked(), 800);
      return;
    }

    slot.place(cardName, cardCost);
    this.updateTotalCost();
  }

  private getTotalCost(): number {
    return this.slots.reduce((sum, s) => sum + s.cost, 0);
  }

  private updateTotalCost(): void {
    this.totalCostEl.textContent = String(this.getTotalCost());
  }

  getPlacedCards(): CardName[] {
    return this.slots.filter((s) => s.card !== null).map((s) => s.card as CardName);
  }

  reset(): void {
    for (const s of this.slots) {
      s.remove();
    }
    this.updateTotalCost();
  }

  setOnConfirm(cb: (cards: CardName[]) => void): void {
    this.onConfirm = cb;
  }

  render(state: GameState): void {
    // Header
    const turnEl = this.root.querySelector<HTMLElement>('[data-testid="header-turn"]');
    if (turnEl) {
      turnEl.textContent = `ターン ${state.turn} / 残り ${state.deadline - state.turn + 1}`;
    }

    // KPI
    const profit = state.budget - state.totalCost;
    const profitRate = state.budget > 0 ? ((profit / state.budget) * 100).toFixed(1) : "0.0";
    this.setKpi("kpi-profit", `¥${profit.toLocaleString()}`, profit);
    this.setKpi("kpi-profit-rate", `${profitRate}%`, Number(profitRate));
    this.setKpi("kpi-spi", "N/A", 0);
    this.setKpi("kpi-cpi", "N/A", 0);
    this.setKpi("kpi-transparency", gauge(state.transparency, 150), state.transparency);
    this.setKpi("kpi-tension", gauge(state.tension, 150), state.tension);

    // Members
    const memberList = this.root.querySelector<HTMLElement>('[data-testid="member-list"]');
    if (memberList) {
      memberList.innerHTML = "";
      for (const member of state.members) {
        const row = document.createElement("div");
        row.dataset.testid = `member-${member.id}`;
        row.style.marginBottom = "6px";

        const skill = document.createElement("span");
        skill.dataset.testid = `member-${member.id}-skill`;
        skill.textContent = `${member.name} 技`;

        const skillVal = document.createElement("span");
        skillVal.dataset.testid = `member-${member.id}-skill`;
        skillVal.textContent = String(member.skill);

        const morale = document.createElement("span");
        morale.dataset.testid = `member-${member.id}-morale`;
        morale.setAttribute("aria-valuenow", String(member.morale));
        morale.textContent = ` 心${gauge(member.morale, 150)}`;

        const health = document.createElement("span");
        health.dataset.testid = `member-${member.id}-health`;
        health.setAttribute("aria-valuenow", String(member.health));
        health.textContent = ` 体${gauge(member.health, 100)}`;

        row.appendChild(skill);
        row.appendChild(skillVal);
        row.appendChild(morale);
        row.appendChild(health);
        memberList.appendChild(row);
      }
    }

    // Hand
    this.renderHand(state);

    // Game over
    if (state.isGameOver) {
      this.confirmBtn.disabled = true;
      const msg = document.createElement("div");
      msg.textContent = `ゲームオーバー: ${state.gameOverReason ?? "終了"}`;
      msg.style.cssText = "color:#ff6b6b;text-align:center;padding:4px;";
      if (!this.root.querySelector(".gameover-msg")) {
        msg.classList.add("gameover-msg");
        this.root.insertBefore(msg, this.root.firstChild);
      }
    }
  }

  private setKpi(testid: string, text: string, value: number): void {
    const el = this.root.querySelector<HTMLElement>(`[data-testid="${testid}"]`);
    if (el) {
      el.textContent = text;
      el.setAttribute("aria-valuenow", String(value));
    }
  }

  private renderHand(state: GameState): void {
    const existing = this.root.querySelectorAll<HTMLElement>("[data-testid^='hand-card-']");
    for (const el of existing) {
      el.remove();
    }

    const cardArea = this.root.querySelector<HTMLElement>(
      '[data-testid^="card-slot-0"]',
    )?.parentElement;
    if (!cardArea) return;

    const handContainer =
      cardArea.querySelector<HTMLElement>(".hand-container") ??
      (() => {
        const c = document.createElement("div");
        c.classList.add("hand-container");
        c.style.cssText = "display:flex;gap:6px;flex-wrap:wrap;width:100%;margin-top:6px;";
        cardArea.appendChild(c);
        return c;
      })();
    handContainer.innerHTML = "";

    for (const cardName of state.hand) {
      const card = document.createElement("div");
      card.dataset.testid = `hand-card-${cardName}`;
      card.draggable = true;
      card.classList.add("interactive");
      card.textContent = cardName;
      card.style.cssText = [
        "background:#2a2a5e",
        "border:1px solid #4a9eff",
        "border-radius:6px",
        "padding:4px 8px",
        "font-size:11px",
        "cursor:grab",
        "white-space:nowrap",
      ].join(";");
      card.addEventListener("dragstart", (e) => {
        (e as DragEvent).dataTransfer?.setData("text/plain", cardName);
      });
      handContainer.appendChild(card);
    }
  }
}
