import type { EventData } from "../schemas/eventData.js";
import type { EventDefinition } from "./index.js";

export function createRoll(_data: EventData): EventDefinition["roll"] {
  return () => null;
}
