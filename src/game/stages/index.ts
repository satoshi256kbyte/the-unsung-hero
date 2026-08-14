import type { StageData } from "../types.js";
import { pocStage } from "./poc-01.js";

export const STAGE_REGISTRY: Record<string, StageData> = {
  "poc-01": pocStage,
};
