import { dayOfWeek, isWeekend } from "../game/calendar.js";
import { actualPosition, plannedRate } from "../game/gantt.js";
import type { GameState, GanttTask } from "../game/types.js";

const DAY_LABELS = ["月", "火", "水", "木", "金", "土", "日"] as const;
const COL_WIDTH = 28; // px per turn column
const ROW_HEIGHT = 18; // px per planned/actual row

/**
 * ゲーム内ガントチャート画面（DOM overlay、閲覧専用）。
 * 各タスクの予定行・実績行の2行と、現在ターンの稲妻線を表示する。
 * タスク選択で先行タスク（依存）をハイライトする。
 * Phaser / canvas を使わず DOM で構築し、Playwright E2E から参照可能にする。
 */
export class GanttChartUI {
  private root: HTMLElement;
  private container: HTMLElement;
  private selectedTaskId: string | null = null;
  private lastState: GameState | null = null;

  constructor(container: HTMLElement) {
    this.container = container;
    this.root = document.createElement("div");
    this.root.dataset.testid = "gantt-screen";
    this.root.style.cssText = [
      "position:absolute",
      "inset:0",
      "display:none",
      "flex-direction:column",
      "background:#12122e",
      "color:#e0e0e0",
      "font-family:monospace",
      "font-size:12px",
      "padding:8px",
      "gap:6px",
      "overflow:auto",
      "pointer-events:auto",
      "z-index:5",
    ].join(";");
    this.container.appendChild(this.root);
  }

  show(): void {
    this.root.style.display = "flex";
    if (this.lastState) this.render(this.lastState);
  }

  hide(): void {
    this.root.style.display = "none";
  }

  render(state: GameState): void {
    this.lastState = state;
    this.root.innerHTML = "";

    const header = document.createElement("div");
    header.style.cssText = "display:flex;justify-content:space-between;align-items:center;";
    const title = document.createElement("span");
    title.textContent = "ガントチャート";
    const back = document.createElement("button");
    back.dataset.testid = "nav-dashboard-btn";
    back.textContent = "ダッシュボードへ戻る";
    back.classList.add("interactive");
    back.style.cssText =
      "background:#4a9eff;color:#fff;border:none;border-radius:6px;padding:6px 12px;cursor:pointer;";
    back.addEventListener("click", () => {
      this.hide();
      this.onBack?.();
    });
    header.appendChild(title);
    header.appendChild(back);
    this.root.appendChild(header);

    // 凡例
    const legend = document.createElement("div");
    legend.dataset.testid = "gantt-legend";
    legend.style.cssText = "font-size:11px;color:#aaa;";
    legend.textContent =
      "上段=予定 / 下段=実績 / 縦線=現在ターン（稲妻線は予定対実績の遅れ・前倒し）";
    this.root.appendChild(legend);

    // スクロール可能な表領域
    const scroll = document.createElement("div");
    scroll.dataset.testid = "gantt-scroll";
    scroll.style.cssText = "overflow:auto;flex:1;min-height:0;";

    const grid = document.createElement("div");
    grid.style.cssText = "display:inline-block;min-width:100%;";

    grid.appendChild(this.buildTurnHeader(state));
    for (const task of state.gantt.tasks) {
      grid.appendChild(this.buildTaskRow(task, state));
    }

    scroll.appendChild(grid);
    this.root.appendChild(scroll);

    // 依存表示エリア（選択中タスクの先行タスク）
    this.root.appendChild(this.buildDependencyPanel(state));
  }

  private buildTurnHeader(state: GameState): HTMLElement {
    const row = document.createElement("div");
    row.dataset.testid = "gantt-turn-header";
    row.style.cssText = "display:flex;align-items:flex-end;";

    // タスク名列のスペーサー
    const spacer = document.createElement("div");
    spacer.style.cssText = "width:120px;flex:none;";
    row.appendChild(spacer);

    for (let turn = 1; turn <= state.deadline; turn++) {
      const col = document.createElement("div");
      col.dataset.testid = `gantt-turn-col-${turn}`;
      const weekend = isWeekend(turn);
      col.style.cssText = [
        `width:${COL_WIDTH}px`,
        "flex:none",
        "text-align:center",
        "font-size:9px",
        `color:${weekend ? "#7a7a9a" : "#ccc"}`,
        weekend ? "background:#1a1a3e" : "",
      ].join(";");
      col.textContent = `${turn}(${DAY_LABELS[dayOfWeek(turn)]})`;
      row.appendChild(col);
    }
    return row;
  }

  private buildTaskRow(task: GanttTask, state: GameState): HTMLElement {
    const wrapper = document.createElement("div");
    wrapper.dataset.testid = `gantt-task-row-${task.id}`;
    wrapper.style.cssText = "display:flex;flex-direction:column;border-bottom:1px solid #23234a;";

    // タスク名（選択操作の対象）
    const label = document.createElement("button");
    label.dataset.testid = `gantt-task-select-${task.id}`;
    label.textContent = task.name;
    label.classList.add("interactive");
    label.style.cssText = [
      "width:120px",
      "flex:none",
      "text-align:left",
      "background:transparent",
      `color:${this.selectedTaskId === task.id ? "#ffd75f" : "#e0e0e0"}`,
      "border:none",
      "cursor:pointer",
      "font-family:monospace",
      "font-size:11px",
      "padding:0",
    ].join(";");
    label.addEventListener("click", () => {
      this.selectedTaskId = task.id;
      if (this.lastState) this.render(this.lastState);
    });

    // 予定行と実績行を含むトラック（稲妻線を重畳するため position:relative）
    const track = document.createElement("div");
    track.style.cssText = "position:relative;display:flex;flex-direction:column;";

    track.appendChild(this.buildBandRow(task, state, "planned"));
    track.appendChild(this.buildBandRow(task, state, "actual"));
    track.appendChild(this.buildLightningLine(task, state));

    // 先頭にラベル、その後にトラック（横並び）
    const rowFlex = document.createElement("div");
    rowFlex.style.cssText = "display:flex;align-items:stretch;";
    rowFlex.appendChild(label);
    rowFlex.appendChild(track);
    wrapper.appendChild(rowFlex);
    return wrapper;
  }

  private buildBandRow(task: GanttTask, state: GameState, kind: "planned" | "actual"): HTMLElement {
    const row = document.createElement("div");
    row.dataset.testid = `gantt-${kind}-row-${task.id}`;
    row.style.cssText = `display:flex;height:${ROW_HEIGHT}px;`;

    const [from, to] = this.bandRange(task, state, kind);

    for (let turn = 1; turn <= state.deadline; turn++) {
      const cell = document.createElement("div");
      cell.dataset.testid = `gantt-${kind}-cell-${task.id}-${turn}`;
      const inBand = from !== null && to !== null && turn >= from && turn <= to;
      const weekend = isWeekend(turn);
      const color =
        kind === "planned"
          ? inBand
            ? weekend
              ? "#3a5a8a"
              : "#4a9eff"
            : "transparent"
          : inBand
            ? "#5fd77a"
            : "transparent";
      cell.style.cssText = [
        `width:${COL_WIDTH}px`,
        "flex:none",
        `background:${color}`,
        "box-sizing:border-box",
        weekend && !inBand ? "background:#16163200" : "",
      ].join(";");
      cell.dataset.inBand = String(inBand);
      row.appendChild(cell);
    }
    return row;
  }

  /** 帯の [開始ターン, 終了ターン]。描画なしは [null, null] */
  private bandRange(
    task: GanttTask,
    state: GameState,
    kind: "planned" | "actual",
  ): [number | null, number | null] {
    if (kind === "planned") {
      return [task.startTurn, task.startTurn + task.duration - 1];
    }
    // actual
    if (task.actualStartTurn === null) return [null, null];
    const end = task.actualEndTurn ?? state.turn;
    return [task.actualStartTurn, end];
  }

  private buildLightningLine(task: GanttTask, state: GameState): HTMLElement {
    const line = document.createElement("div");
    line.dataset.testid = `gantt-lightning-line-${task.id}`;

    const dev = task.progress - plannedRate(task, state.turn);
    const deviation = dev > 0.5 ? "ahead" : dev < -0.5 ? "behind" : "ontrack";
    line.dataset.deviation = deviation;

    // 現在ターン列の中心 x 座標（タスク名列は track の外なので 0 基準）
    const currentX = (state.turn - 0.5) * COL_WIDTH;
    // 実績到達位置（折れ先）
    const actualX = actualPosition(task) * COL_WIDTH;

    line.style.cssText = [
      "position:absolute",
      "top:0",
      "bottom:0",
      `left:${Math.max(0, Math.min(currentX, actualX))}px`,
      `width:${Math.max(2, Math.abs(currentX - actualX))}px`,
      "border-left:2px solid #ffd75f",
      "pointer-events:none",
    ].join(";");
    return line;
  }

  private buildDependencyPanel(state: GameState): HTMLElement {
    const panel = document.createElement("div");
    panel.dataset.testid = "gantt-dependency-panel";
    panel.style.cssText = "border-top:1px solid #23234a;padding-top:4px;min-height:20px;";

    if (this.selectedTaskId === null) {
      panel.textContent = "タスクを選択すると先行タスクを表示します";
      return panel;
    }

    const selected = state.gantt.tasks.find((t) => t.id === this.selectedTaskId);
    if (!selected) {
      panel.textContent = "タスクを選択すると先行タスクを表示します";
      return panel;
    }

    if (selected.dependencies.length === 0) {
      const noDep = document.createElement("span");
      noDep.dataset.testid = `gantt-no-dep-${selected.id}`;
      noDep.textContent = `「${selected.name}」に先行タスクはありません`;
      panel.appendChild(noDep);
      return panel;
    }

    const title = document.createElement("span");
    title.textContent = `「${selected.name}」の先行タスク: `;
    panel.appendChild(title);

    for (const depId of selected.dependencies) {
      const dep = state.gantt.tasks.find((t) => t.id === depId);
      const chip = document.createElement("span");
      chip.dataset.testid = `gantt-dep-highlight-${depId}`;
      chip.textContent = dep ? dep.name : depId;
      chip.style.cssText =
        "display:inline-block;background:#ffd75f;color:#12122e;border-radius:4px;padding:1px 6px;margin-right:4px;";
      panel.appendChild(chip);
    }
    return panel;
  }

  private onBack: (() => void) | null = null;

  /** ダッシュボードへ戻るボタン押下時のコールバック */
  setOnBack(cb: () => void): void {
    this.onBack = cb;
  }
}
