import { BootScene } from "@scenes/BootScene";
import { MainScene } from "@scenes/MainScene";
import Phaser from "phaser";

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  parent: "game-container",
  width: 960,
  height: 540,
  backgroundColor: "#1a1a2e",
  scene: [BootScene, MainScene],
};

new Phaser.Game(config);
