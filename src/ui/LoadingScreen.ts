import { pmTerms } from "./pmTerms.js";

export class LoadingScreen {
  private el: HTMLElement;
  private termEl: HTMLElement;
  private usedIndices: Set<number> = new Set();

  constructor(container: HTMLElement) {
    this.el = document.createElement("div");
    this.el.dataset.testid = "loading-screen";
    this.el.setAttribute("aria-hidden", "true");
    this.el.style.cssText = [
      "position:absolute",
      "inset:0",
      "display:none",
      "flex-direction:column",
      "align-items:center",
      "justify-content:center",
      "background:rgba(0,0,0,0.85)",
      "color:#fff",
      "z-index:100",
    ].join(";");

    const spinner = document.createElement("div");
    spinner.textContent = "⏳";
    spinner.style.cssText = "font-size:48px;margin-bottom:24px;";

    this.termEl = document.createElement("p");
    this.termEl.dataset.testid = "pm-term-text";
    this.termEl.style.cssText = "max-width:480px;text-align:center;line-height:1.6;padding:0 16px;";

    this.el.appendChild(spinner);
    this.el.appendChild(this.termEl);
    container.appendChild(this.el);
  }

  show(): void {
    if (this.usedIndices.size >= pmTerms.length) {
      this.usedIndices.clear();
    }
    let idx: number;
    do {
      idx = Math.floor(Math.random() * pmTerms.length);
    } while (this.usedIndices.has(idx));
    this.usedIndices.add(idx);

    const term = pmTerms[idx];
    if (term) {
      this.termEl.textContent = `${term.name} — ${term.description}`;
    }

    this.el.style.display = "flex";
    this.el.setAttribute("aria-hidden", "false");
  }

  hide(): void {
    this.el.style.display = "none";
    this.el.setAttribute("aria-hidden", "true");
  }
}
