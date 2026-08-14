export class TitleUI {
  private root: HTMLElement;
  private onStart: (() => void) | null = null;

  constructor(container: HTMLElement) {
    this.root = document.createElement("div");
    this.root.style.cssText = [
      "position:absolute",
      "inset:0",
      "display:flex",
      "flex-direction:column",
      "align-items:center",
      "justify-content:center",
      "gap:24px",
      "pointer-events:auto",
    ].join(";");

    const logo = document.createElement("div");
    logo.dataset.testid = "title-logo";
    logo.textContent = "The Unsung Hero";
    logo.style.cssText = "font-size:32px;color:#fff;font-family:monospace;";
    this.root.appendChild(logo);

    const startBtn = document.createElement("button");
    startBtn.dataset.testid = "title-start-btn";
    startBtn.textContent = "スタート";
    startBtn.classList.add("interactive");
    startBtn.style.cssText = [
      "background:#4a9eff",
      "color:#fff",
      "border:none",
      "border-radius:6px",
      "padding:12px 32px",
      "font-size:16px",
      "cursor:pointer",
    ].join(";");
    startBtn.addEventListener("click", () => {
      this.onStart?.();
    });
    this.root.appendChild(startBtn);

    container.appendChild(this.root);
  }

  setOnStart(cb: () => void): void {
    this.onStart = cb;
  }

  destroy(): void {
    this.root.remove();
  }
}
