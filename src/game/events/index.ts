import { getConfig } from "../config.js";
import type { EventData } from "../schemas/eventData.js";
import type { CardEffect, GameEvent, GameState, Member } from "../types.js";
import { createRoll as createBlockerRoll } from "./blocker.js";
import { createRoll as createEnvIssueRoll } from "./env-issue.js";
import { createRoll as createFatigueRoll } from "./fatigue.js";
import { createRoll as createFirstPassRoll } from "./first-pass.js";
import { createRoll as createInspirationRoll } from "./inspiration.js";
import { createRoll as createLocalWinRoll } from "./local-win.js";
import { createRoll as createLowMotivationRoll } from "./low-motivation.js";
import { createRoll as createMissingReportRoll } from "./missing-report.js";
import { createRoll as createOverReportRoll } from "./over-report.js";
import { createRoll as createRestRoll } from "./rest.js";
import { createRoll as createReworkRoll } from "./rework.js";
import { createRoll as createSickRoll } from "./sick.js";
import { createRoll as createSpecUnclearRoll } from "./spec-unclear.js";
import { createRoll as createStallRoll } from "./stall.js";
import { createRoll as createUnderReportRoll } from "./under-report.js";

export interface EventDefinition {
  roll(state: GameState, activeEffects: CardEffect[]): GameEvent | null;
}

/**
 * イベントキー → JSONファイル名（拡張子なし）。public/data/events/配下の
 * ファイル名と一致させる。キーは旧EVENT_PROBのキー名を踏襲し、実装済み
 * イベントを先に並べて乱数消費順を旧event.tsと一致させる。
 */
export const EVENT_JSON_FILES: Record<string, string> = {
  STALL: "stall",
  REWORK: "rework",
  SICK: "sick",
  LOW_MOTIVATION: "low-motivation",
  FATIGUE: "fatigue",
  SPEC_UNCLEAR: "spec-unclear",
  BLOCKER: "blocker",
  ENV_ISSUE: "env-issue",
  OVER_REPORT: "over-report",
  UNDER_REPORT: "under-report",
  MISSING_REPORT: "missing-report",
  INSPIRATION: "inspiration",
  FIRST_PASS: "first-pass",
  REST: "rest",
  LOCAL_WIN: "local-win",
};

const ROLL_FACTORIES: Record<string, (data: EventData) => EventDefinition["roll"]> = {
  STALL: createStallRoll,
  REWORK: createReworkRoll,
  SICK: createSickRoll,
  LOW_MOTIVATION: createLowMotivationRoll,
  FATIGUE: createFatigueRoll,
  SPEC_UNCLEAR: createSpecUnclearRoll,
  BLOCKER: createBlockerRoll,
  ENV_ISSUE: createEnvIssueRoll,
  OVER_REPORT: createOverReportRoll,
  UNDER_REPORT: createUnderReportRoll,
  MISSING_REPORT: createMissingReportRoll,
  INSPIRATION: createInspirationRoll,
  FIRST_PASS: createFirstPassRoll,
  REST: createRestRoll,
  LOCAL_WIN: createLocalWinRoll,
};

export function buildEventRegistry(
  probData: Record<string, EventData>,
): Record<string, EventDefinition> {
  const result: Record<string, EventDefinition> = {};
  for (const key of Object.keys(EVENT_JSON_FILES)) {
    const factory = ROLL_FACTORIES[key];
    const data = probData[key];
    if (factory === undefined || data === undefined) {
      throw new Error(`Missing event roll factory or data for key: ${key}`);
    }
    result[key] = { roll: factory(data) };
  }
  return result;
}

let eventRegistry: Record<string, EventDefinition> | null = null;

export function initEventRegistry(probData: Record<string, EventData>): void {
  eventRegistry = buildEventRegistry(probData);
}

export function getEventRegistry(): Record<string, EventDefinition> {
  if (eventRegistry === null) {
    throw new Error("Event registry is not initialized. Call initEventRegistry() first.");
  }
  return eventRegistry;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

export function rollRandomEvents(state: GameState, activeEffects: CardEffect[]): GameEvent[] {
  if (eventRegistry === null) {
    throw new Error("Event registry is not initialized. Call initEventRegistry() first.");
  }
  const events: GameEvent[] = [];
  for (const definition of Object.values(eventRegistry)) {
    const event = definition.roll(state, activeEffects);
    if (event !== null) {
      events.push(event);
    }
  }
  return events;
}

export function applyEventToProgress(
  event: GameEvent,
  progressMap: Map<string, number>,
): Map<string, number> {
  const result = new Map(progressMap);
  if (event.id.startsWith("stall") && event.targetId !== null) {
    result.set(event.targetId, 0);
  } else if (event.id.startsWith("rework") && event.targetId !== null) {
    const reworkDelta = event.params.reworkDelta as number | undefined;
    if (reworkDelta !== undefined) {
      result.set(event.targetId, (result.get(event.targetId) ?? 0) + reworkDelta);
    }
  }
  return result;
}

export function applyEventToMember(event: GameEvent, member: Member): Member {
  const moraleDelta = event.params.moraleDelta as number | undefined;
  const healthDelta = event.params.healthDelta as number | undefined;
  if (moraleDelta === undefined && healthDelta === undefined) {
    return member;
  }
  const { MORALE, HEALTH } = getConfig().balance.MEMBER_PARAMS;
  return {
    ...member,
    morale: clamp(member.morale + (moraleDelta ?? 0), MORALE.MIN, MORALE.MAX),
    health: clamp(member.health + (healthDelta ?? 0), HEALTH.MIN, HEALTH.MAX),
  };
}
