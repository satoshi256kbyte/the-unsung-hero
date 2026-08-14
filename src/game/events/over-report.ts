import type { EventDefinition } from "./index.js";

/** 過大報告発覚イベントの基本発生確率（未実装のため未使用） */
export const BASE_PROB = 0.04;

/** モニタリングカード使用時の発生確率（未実装のため未使用） */
export const WITH_MONITORING_PROB = 0.02;

export const overReport: EventDefinition = {
  roll() {
    return null;
  },
};
