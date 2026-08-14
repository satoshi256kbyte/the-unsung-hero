import Phaser from "phaser";
import { TitleUI } from "../ui/TitleUI.js";

export class TitleScene extends Phaser.Scene {
  private ui!: TitleUI;

  constructor() {
    super({ key: "TitleScene" });
  }

  create(): void {
    const overlay = document.getElementById("ui-overlay");
    if (!overlay) {
      throw new Error("#ui-overlay not found in DOM");
    }

    this.ui = new TitleUI(overlay);
    this.ui.setOnStart(() => {
      this.ui.destroy();
      this.scene.start("StageSelectScene");
    });
  }
}
