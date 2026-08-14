import { MEMBER_PARAMS } from "../constants.js";
import type { CardEffect, GameEvent, GameState, Member } from "../types.js";
import { blocker } from "./blocker.js";
import { envIssue } from "./env-issue.js";
import { fatigue } from "./fatigue.js";
import { firstPass } from "./first-pass.js";
import { inspiration } from "./inspiration.js";
import { localWin } from "./local-win.js";
import { lowMotivation } from "./low-motivation.js";
import { missingReport } from "./missing-report.js";
import { overReport } from "./over-report.js";
import { rest } from "./rest.js";
import { rework } from "./rework.js";
import { sick } from "./sick.js";
import { specUnclear } from "./spec-unclear.js";
import { stall } from "./stall.js";
import { underReport } from "./under-report.js";

export interface EventDefinition {
  roll(state: GameState, activeEffects: CardEffect[]): GameEvent | null;
}

/**
 * ランダムイベントのレジストリ。キーは旧 EVENT_PROB のキー名を踏襲する。
 * 実装済みイベントを先に並べ、乱数消費順を旧 event.ts と一致させる。
 */
export const EVENT_REGISTRY: Record<string, EventDefinition> = {
  STALL: stall,
  REWORK: rework,
  SICK: sick,
  LOW_MOTIVATION: lowMotivation,
  FATIGUE: fatigue,
  SPEC_UNCLEAR: specUnclear,
  BLOCKER: blocker,
  ENV_ISSUE: envIssue,
  OVER_REPORT: overReport,
  UNDER_REPORT: underReport,
  MISSING_REPORT: missingReport,
  INSPIRATION: inspiration,
  FIRST_PASS: firstPass,
  REST: rest,
  LOCAL_WIN: localWin,
};

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

export function rollRandomEvents(state: GameState, activeEffects: CardEffect[]): GameEvent[] {
  const events: GameEvent[] = [];
  for (const definition of Object.values(EVENT_REGISTRY)) {
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
  return {
    ...member,
    morale: clamp(
      member.morale + (moraleDelta ?? 0),
      MEMBER_PARAMS.MORALE.MIN,
      MEMBER_PARAMS.MORALE.MAX,
    ),
    health: clamp(
      member.health + (healthDelta ?? 0),
      MEMBER_PARAMS.HEALTH.MIN,
      MEMBER_PARAMS.HEALTH.MAX,
    ),
  };
}
