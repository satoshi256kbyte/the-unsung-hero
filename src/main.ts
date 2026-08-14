import { BootScene } from "@scenes/BootScene";
import { MainScene } from "@scenes/MainScene";
import { PreloadScene } from "@scenes/PreloadScene";
import { StageSelectScene } from "@scenes/StageSelectScene";
import { TitleScene } from "@scenes/TitleScene";
import Phaser from "phaser";

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  parent: "game-container",
  width: 960,
  height: 540,
  backgroundColor: "#1a1a2e",
  scene: [BootScene, PreloadScene, TitleScene, StageSelectScene, MainScene],
};

new Phaser.Game(config);
