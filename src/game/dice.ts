import { getHealthFactor, getSkillFactorRange } from "./balance.js";
import { PROGRESS_DICE } from "./constants.js";
import type { Member } from "./types.js";

function randomInRange(min: number, max: number): number {
  return min + (max - min) * Math.random();
}

export function rollProgress(member: Member): number {
  const [sMin, sMax] = getSkillFactorRange(member.skill);
  const [hMin, hMax] = getHealthFactor(member.health);
  const base = randomInRange(PROGRESS_DICE.BASE_MIN, PROGRESS_DICE.BASE_MAX);
  const skillFactor = randomInRange(sMin, sMax);
  const healthFactor = randomInRange(hMin, hMax);
  return base * skillFactor * healthFactor;
}
