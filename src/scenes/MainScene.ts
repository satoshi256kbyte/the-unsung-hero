import Phaser from "phaser";
import { GameEngine } from "../game/engine.js";
import { getStage } from "../game/stages/index.js";
import { GanttChartUI } from "../ui/GanttChartUI.js";
import type { PlacedCard } from "../ui/MainGameUI.js";
import { MainGameUI } from "../ui/MainGameUI.js";

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export class MainScene extends Phaser.Scene {
  private engine!: GameEngine;
  private ui!: MainGameUI;
  private gantt!: GanttChartUI;
  private stageId!: string;

  constructor() {
    super({ key: "MainScene" });
  }

  init(data: { stageId: string }): void {
    this.stageId = data.stageId;
  }

  create(): void {
    this.engine = new GameEngine(getStage(this.stageId));

    const overlay = document.getElementById("ui-overlay");
    if (!overlay) {
      throw new Error("#ui-overlay not found in DOM");
    }

    this.ui = new MainGameUI(overlay);
    this.gantt = new GanttChartUI(overlay);

    this.ui.setOnConfirm((cards) => {
      void this.confirmTurn(cards);
    });
    // 画面切替: ダッシュボード ⇔ ガントチャート
    this.ui.setOnNavGantt(() => {
      this.gantt.render(this.engine.getState());
      this.gantt.show();
    });
    this.gantt.setOnBack(() => {
      this.gantt.hide();
    });

    this.ui.render(this.engine.getState());
  }

  async confirmTurn(cards: PlacedCard[]): Promise<void> {
    this.ui.loading.show();

    const [result] = await Promise.all([
      Promise.resolve(this.engine.processTurn(cards)),
      sleep(1000),
    ]);

    this.ui.loading.hide();
    this.ui.reset();
    this.ui.render(this.engine.getState());
    this.gantt.render(this.engine.getState());

    if (result.events.length > 0) {
      const eventIds = result.events.map((e) => e.id).join(", ");
      console.info("Events:", eventIds);
    }
  }
}
