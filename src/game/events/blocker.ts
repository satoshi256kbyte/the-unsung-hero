import type { EventDefinition } from "./index.js";

/** ブロッカー発生イベントの基本発生確率（未実装のため未使用） */
export const BASE_PROB = 0.04;

/** デイリーカード使用時の発生確率（未実装のため未使用） */
export const WITH_DAILY_PROB = 0.03;

export const blocker: EventDefinition = {
  roll() {
    return null;
  },
};
