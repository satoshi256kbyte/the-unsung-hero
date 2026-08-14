import type { EventDefinition } from "./index.js";

/** 報告漏れイベントの基本発生確率（未実装のため未使用） */
export const BASE_PROB = 0.03;

/** モニタリングカード使用時の発生確率（未実装のため未使用） */
export const WITH_MONITORING_PROB = 0.01;

export const missingReport: EventDefinition = {
  roll() {
    return null;
  },
};
