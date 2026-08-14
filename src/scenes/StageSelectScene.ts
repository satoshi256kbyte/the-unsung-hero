import Phaser from "phaser";
import { StageSelectUI } from "../ui/StageSelectUI.js";

export class StageSelectScene extends Phaser.Scene {
  private ui!: StageSelectUI;

  constructor() {
    super({ key: "StageSelectScene" });
  }

  create(): void {
    const overlay = document.getElementById("ui-overlay");
    if (!overlay) {
      throw new Error("#ui-overlay not found in DOM");
    }

    this.ui = new StageSelectUI(overlay);
    this.ui.setOnStart((stageId) => {
      this.ui.destroy();
      this.scene.start("MainScene", { stageId });
    });
  }
}
