import { PARAM_DELTA } from "./constants.js";
import type { CardEffect, CardName, GameState, MemberUpdate } from "./types.js";

export interface CardApplicationResult {
  effectsToAdd: CardEffect[];
  memberUpdates: MemberUpdate[];
}

export function applyCards(state: GameState, cards: CardName[]): CardApplicationResult {
  const effectsToAdd: CardEffect[] = [];
  const memberUpdates: MemberUpdate[] = [];

  for (const card of cards) {
    switch (card) {
      case "デイリー":
        effectsToAdd.push({
          cardName: card,
          targetId: "project",
          effectType: "task_event_prob_reduced",
          remainingTurns: null,
        });
        break;
      case "レビュー":
        effectsToAdd.push({
          cardName: card,
          targetId: "project",
          effectType: "rework_prob_reduced",
          remainingTurns: null,
        });
        break;
      case "モニタリング":
        effectsToAdd.push({
          cardName: card,
          targetId: "project",
          effectType: "overreport_prob_reduced",
          remainingTurns: null,
        });
        break;
      case "個別面談": {
        const target = state.members[0];
        if (target !== undefined) {
          memberUpdates.push({
            memberId: target.id,
            moraleDelta: PARAM_DELTA.ONE_ON_ONE_MORALE,
            healthDelta: 0,
          });
        }
        break;
      }
      case "表彰": {
        const target = state.members[0];
        if (target !== undefined) {
          memberUpdates.push({
            memberId: target.id,
            moraleDelta: PARAM_DELTA.COMMENDATION_MORALE,
            healthDelta: 0,
          });
        }
        break;
      }
      case "計画休": {
        const target = state.members[0];
        if (target !== undefined) {
          memberUpdates.push({
            memberId: target.id,
            moraleDelta: PARAM_DELTA.PLANNED_LEAVE_MORALE,
            healthDelta: PARAM_DELTA.PLANNED_LEAVE_HEALTH,
          });
        }
        break;
      }
      default:
        break;
    }
  }

  return { effectsToAdd, memberUpdates };
}
