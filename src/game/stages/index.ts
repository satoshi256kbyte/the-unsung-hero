import type { StageData } from "../types.js";

export const STAGE_JSON_FILES: Record<string, string> = {
  "poc-01": "poc-01",
};

export function buildStageRegistry(
  stageDataList: Record<string, StageData>,
): Record<string, StageData> {
  return { ...stageDataList };
}

let stageRegistry: Record<string, StageData> | null = null;

export function initStageRegistry(stageDataList: Record<string, StageData>): void {
  stageRegistry = buildStageRegistry(stageDataList);
}

export function getStage(id: string): StageData {
  if (stageRegistry === null) {
    throw new Error("Stage registry is not initialized. Call initStageRegistry() first.");
  }
  const stage = stageRegistry[id];
  if (stage === undefined) {
    throw new Error(`Unknown stage id: ${id}`);
  }
  return stage;
}
