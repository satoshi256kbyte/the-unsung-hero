import { EXP, LEVEL_UP_EXP, MEMBER_PARAMS, PARAM_DELTA } from "./constants.js";
import type { Member } from "./types.js";

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function randInt(min: number, max: number): number {
  return Math.floor(min + (max - min + 1) * Math.random());
}

function requiredExp(skill: number): number {
  let required: number = EXP.BASE_EXP;
  for (const [threshold, exp] of LEVEL_UP_EXP) {
    if (skill >= threshold) required = exp;
  }
  return required;
}

export function applyTurnDecay(member: Member): Member {
  const moraleDelta = randInt(PARAM_DELTA.MORALE_NATURAL_MIN, PARAM_DELTA.MORALE_NATURAL_MAX);
  const healthDelta = randInt(PARAM_DELTA.HEALTH_NATURAL_MIN, PARAM_DELTA.HEALTH_NATURAL_MAX);
  return {
    ...member,
    morale: clamp(member.morale + moraleDelta, MEMBER_PARAMS.MORALE.MIN, MEMBER_PARAMS.MORALE.MAX),
    health: clamp(member.health + healthDelta, MEMBER_PARAMS.HEALTH.MIN, MEMBER_PARAMS.HEALTH.MAX),
  };
}

export function applyWeekendRecovery(member: Member): Member {
  return {
    ...member,
    morale: clamp(
      member.morale + PARAM_DELTA.WEEKEND_MORALE_RECOVERY,
      MEMBER_PARAMS.MORALE.MIN,
      MEMBER_PARAMS.MORALE.MAX,
    ),
    health: clamp(
      member.health + PARAM_DELTA.WEEKEND_HEALTH_RECOVERY,
      MEMBER_PARAMS.HEALTH.MIN,
      MEMBER_PARAMS.HEALTH.MAX,
    ),
  };
}

export function applyExperience(member: Member, expGain: number): Member {
  if (expGain <= 0 || member.skill >= MEMBER_PARAMS.SKILL.MAX) {
    return member;
  }
  const newExp = member.exp + expGain;
  const required = requiredExp(member.skill);
  if (newExp >= required) {
    return {
      ...member,
      skill: member.skill + 1,
      exp: newExp - required,
    };
  }
  return { ...member, exp: newExp };
}
