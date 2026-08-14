import Phaser from "phaser";
import { GameEngine } from "../game/engine.js";
import { pocStage } from "../game/stages/poc-01.js";
import type { CardName } from "../game/types.js";
import { MainGameUI } from "../ui/MainGameUI.js";

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export class MainScene extends Phaser.Scene {
  private engine!: GameEngine;
  private ui!: MainGameUI;

  constructor() {
    super({ key: "MainScene" });
  }

  create(): void {
    this.engine = new GameEngine(pocStage);

    const overlay = document.getElementById("ui-overlay");
    if (!overlay) {
      throw new Error("#ui-overlay not found in DOM");
    }

    this.ui = new MainGameUI(overlay);
    this.ui.setOnConfirm((cards) => {
      void this.confirmTurn(cards);
    });

    this.ui.render(this.engine.getState());
  }

  async confirmTurn(cards: CardName[]): Promise<void> {
    this.ui.loading.show();

    const [result] = await Promise.all([
      Promise.resolve(this.engine.processTurn(cards)),
      sleep(1000),
    ]);

    this.ui.loading.hide();
    this.ui.reset();
    this.ui.render(this.engine.getState());

    if (result.events.length > 0) {
      const eventIds = result.events.map((e) => e.id).join(", ");
      console.info("Events:", eventIds);
    }
  }
}
