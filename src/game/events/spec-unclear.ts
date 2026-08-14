import type { EventDefinition } from "./index.js";

/** 仕様不明確イベントの基本発生確率（未実装のため未使用） */
export const BASE_PROB = 0.05;

/** デイリーカード使用時の発生確率（未実装のため未使用） */
export const WITH_DAILY_PROB = 0.03;

export const specUnclear: EventDefinition = {
  roll() {
    return null;
  },
};
