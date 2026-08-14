import type { EventDefinition } from "./index.js";

/** 一発合格イベントの基本発生確率（未実装のため未使用） */
export const BASE_PROB = 0.02;

export const firstPass: EventDefinition = {
  roll() {
    return null;
  },
};
