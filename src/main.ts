import Phaser from "phaser";
import { BootScene } from "@scenes/BootScene";

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  parent: "game-container",
  width: 960,
  height: 540,
  backgroundColor: "#1a1a2e",
  scene: [BootScene],
};

new Phaser.Game(config);
