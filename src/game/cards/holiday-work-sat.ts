import { dayOfWeek } from "../calendar.js";
import type { CardEffectLogic } from "./index.js";

const SATURDAY = 5;

export const holidayWorkSat: CardEffectLogic = {
  requiresTarget: true,
  applyEffect(state, targetId) {
    if (targetId === undefined) {
      return { effectsToAdd: [], memberUpdates: [] };
    }
    const turnsUntilSaturday = (SATURDAY - dayOfWeek(state.turn) + 7) % 7;
    return {
      effectsToAdd: [
        {
          cardName: "休出（土）",
          targetId,
          effectType: "holiday_work_sat",
          remainingTurns: turnsUntilSaturday + 1,
        },
      ],
      memberUpdates: [],
    };
  },
};
