import type { EventDefinition } from "./index.js";

/** 休息イベントの基本発生確率（未実装のため未使用） */
export const BASE_PROB = 0.03;

export const rest: EventDefinition = {
  roll() {
    return null;
  },
};
