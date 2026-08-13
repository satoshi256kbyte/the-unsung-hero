import { EVENT_PROB, MEMBER_PARAMS, STALL } from "./constants.js";
import { calcEventProbModifier } from "./effect.js";
import { applyRework } from "./gantt.js";
import type { CardEffect, GameEvent, GameState, Member } from "./types.js";

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

export function rollRandomEvents(state: GameState, activeEffects: CardEffect[]): GameEvent[] {
  const events: GameEvent[] = [];
  const activeTasks = state.gantt.tasks.filter((t) => t.status === "active");
  const members = state.members;

  // stall イベント
  const stallProb = calcEventProbModifier(
    activeEffects,
    EVENT_PROB.STALL,
    "task_event_prob_reduced",
  );
  if (Math.random() < stallProb && activeTasks.length > 0) {
    const target = activeTasks[Math.floor(Math.random() * activeTasks.length)];
    if (target !== undefined) {
      const stallTurns = Math.random() < STALL.ONE_TURN_PROB ? 1 : 2;
      events.push({
        id: `stall-${state.turn}-${target.id}`,
        type: "ネガティブ",
        category: "進捗ダウン",
        targetId: target.id,
        params: { stallTurns },
      });
    }
  }

  // rework イベント
  const reworkProb = calcEventProbModifier(activeEffects, EVENT_PROB.REWORK, "rework_prob_reduced");
  if (Math.random() < reworkProb && activeTasks.length > 0) {
    const target = activeTasks[Math.floor(Math.random() * activeTasks.length)];
    if (target !== undefined) {
      const assignedMember = members.find((m) => m.id === target.assignedMemberId);
      const skill = assignedMember?.skill ?? 0;
      const reworkedTask = applyRework(target, skill);
      const reworkDelta = reworkedTask.progress - target.progress;
      events.push({
        id: `rework-${state.turn}-${target.id}`,
        type: "ネガティブ",
        category: "進捗ダウン",
        targetId: target.id,
        params: { reworkDelta },
      });
    }
  }

  // sick イベント
  if (Math.random() < EVENT_PROB.SICK && members.length > 0) {
    const target = members[Math.floor(Math.random() * members.length)];
    if (target !== undefined) {
      events.push({
        id: `sick-${state.turn}-${target.id}`,
        type: "ネガティブ",
        category: "デバフ系",
        targetId: target.id,
        params: { moraleDelta: -8, healthDelta: -10 },
      });
    }
  }

  // low_motivation イベント
  if (Math.random() < EVENT_PROB.LOW_MOTIVATION && members.length > 0) {
    const target = members[Math.floor(Math.random() * members.length)];
    if (target !== undefined) {
      events.push({
        id: `low_motivation-${state.turn}-${target.id}`,
        type: "ネガティブ",
        category: "デバフ系",
        targetId: target.id,
        params: { moraleDelta: -10 },
      });
    }
  }

  // fatigue イベント
  if (Math.random() < EVENT_PROB.FATIGUE && members.length > 0) {
    const target = members[Math.floor(Math.random() * members.length)];
    if (target !== undefined) {
      events.push({
        id: `fatigue-${state.turn}-${target.id}`,
        type: "ネガティブ",
        category: "デバフ系",
        targetId: target.id,
        params: { healthDelta: -8 },
      });
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
