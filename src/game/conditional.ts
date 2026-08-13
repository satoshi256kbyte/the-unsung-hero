import { getCompletionRate } from "./gantt.js";
import type { ConditionalEvent, EventCategory, GameEvent, GameState } from "./types.js";

export function evaluateCondition(state: GameState, condition: string): boolean {
  let m: RegExpMatchArray | null;

  m = condition.match(/^turn\s*(>=|<=|==)\s*(\d+)$/);
  if (m) {
    const n = parseInt(m[2] as string, 10);
    if (m[1] === ">=") return state.turn >= n;
    if (m[1] === "<=") return state.turn <= n;
    if (m[1] === "==") return state.turn === n;
  }

  m = condition.match(/^completion_rate\s*(>=|<)\s*([\d.]+)$/);
  if (m) {
    const n = parseFloat(m[2] as string);
    const rate = getCompletionRate(state.gantt);
    if (m[1] === ">=") return rate >= n;
    if (m[1] === "<") return rate < n;
  }

  m = condition.match(/^budget_remaining\s*<=\s*(\d+)$/);
  if (m) {
    const n = parseInt(m[1] as string, 10);
    return state.budget - state.totalCost <= n;
  }

  m = condition.match(/^any_member_morale\s*<\s*(\d+)$/);
  if (m) {
    const n = parseInt(m[1] as string, 10);
    return state.members.some((member) => member.morale < n);
  }

  m = condition.match(/^any_member_health\s*<\s*(\d+)$/);
  if (m) {
    const n = parseInt(m[1] as string, 10);
    return state.members.some((member) => member.health < n);
  }

  m = condition.match(/^all_members_morale\s*<\s*(\d+)$/);
  if (m) {
    const n = parseInt(m[1] as string, 10);
    return state.members.every((member) => member.morale < n);
  }

  return false;
}

export function rollConditionalEvents(
  state: GameState,
  conditionalEvents: ConditionalEvent[],
): GameEvent[] {
  const events: GameEvent[] = [];

  for (const ce of conditionalEvents) {
    if (ce.turn > state.turn) continue;
    if (!evaluateCondition(state, ce.condition)) continue;

    events.push({
      id: `conditional-${state.turn}-${ce.id}`,
      type: ce.eventType,
      category: (ce.params.category as EventCategory | undefined) ?? null,
      targetId: (ce.params.targetId as string | undefined) ?? null,
      params: ce.params,
    });
  }

  return events;
}
