import Phaser from "phaser";

export class BootScene extends Phaser.Scene {
  constructor() {
    super({ key: "BootScene" });
  }

  create(): void {
    this.add.text(100, 100, "The Unsung Hero", {
      fontSize: "32px",
      color: "#ffffff",
    });
  }
}
