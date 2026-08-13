import type { CardEffect, EffectType } from "./types.js";

export function applyEffectTick(effects: CardEffect[]): CardEffect[] {
  const result: CardEffect[] = [];
  for (const e of effects) {
    if (e.remainingTurns === null) {
      result.push(e);
    } else if (e.remainingTurns > 1) {
      result.push({ ...e, remainingTurns: e.remainingTurns - 1 });
    }
    // remainingTurns <= 0 or === 1: drop (expired)
  }
  return result;
}

export function calcEventProbModifier(
  effects: CardEffect[],
  baseProb: number,
  effectType: EffectType,
): number {
  const hasEffect = effects.some((e) => e.effectType === effectType);
  return hasEffect ? baseProb * 0.5 : baseProb;
}
