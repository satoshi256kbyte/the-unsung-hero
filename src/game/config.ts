import type { BalanceConstants } from "./schemas/balanceConstants.js";

export interface GameConfig {
  balance: BalanceConstants;
}

let currentConfig: GameConfig | null = null;

export function initGameConfig(data: GameConfig): void {
  currentConfig = data;
}

export function getConfig(): GameConfig {
  if (currentConfig === null) {
    throw new Error("GameConfig is not initialized. Call initGameConfig() first.");
  }
  return currentConfig;
}
