import { dayOfWeek } from "../calendar.js";
import type { CardEffectLogic } from "./index.js";

const SUNDAY = 6;

export const holidayWorkSun: CardEffectLogic = {
  requiresTarget: true,
  applyEffect(state, targetId) {
    if (targetId === undefined) {
      return { effectsToAdd: [], memberUpdates: [] };
    }
    const turnsUntilSunday = (SUNDAY - dayOfWeek(state.turn) + 7) % 7;
    return {
      effectsToAdd: [
        {
          cardName: "休出（日）",
          targetId,
          effectType: "holiday_work_sun",
          remainingTurns: turnsUntilSunday + 1,
        },
      ],
      memberUpdates: [],
    };
  },
};
