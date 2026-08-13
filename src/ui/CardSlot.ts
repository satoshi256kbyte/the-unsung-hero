import type { CardName } from "../game/types.js";

export class CardSlot {
  readonly el: HTMLElement;
  private _card: CardName | null = null;
  private _cost: number = 0;

  constructor(index: number) {
    this.el = document.createElement("div");
    this.el.dataset.testid = `card-slot-${index}`;
    this.el.dataset.occupied = "false";
    this.el.classList.add("interactive");
    this.el.style.cssText = [
      "width:80px",
      "height:100px",
      "border:2px dashed #666",
      "border-radius:8px",
      "display:flex",
      "align-items:center",
      "justify-content:center",
      "font-size:11px",
      "color:#aaa",
      "text-align:center",
      "cursor:pointer",
      "position:relative",
    ].join(";");
    this.el.textContent = "空";
  }

  get card(): CardName | null {
    return this._card;
  }

  get cost(): number {
    return this._cost;
  }

  place(cardName: CardName, cardCost: number): void {
    this._card = cardName;
    this._cost = cardCost;
    this.el.dataset.occupied = "true";
    this.el.dataset.card = cardName;
    this.el.dataset.blocked = "false";
    this.el.textContent = cardName;
    this.el.style.borderColor = "#4a9eff";
    this.el.style.color = "#fff";
  }

  remove(): void {
    this._card = null;
    this._cost = 0;
    delete this.el.dataset.card;
    this.el.dataset.occupied = "false";
    this.el.dataset.blocked = "false";
    this.el.textContent = "空";
    this.el.style.borderColor = "#666";
    this.el.style.color = "#aaa";
  }

  markBlocked(): void {
    this.el.dataset.blocked = "true";
  }

  clearBlocked(): void {
    this.el.dataset.blocked = "false";
  }
}
