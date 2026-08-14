import type { CardEffect, CardName, GameState, MemberUpdate } from "../types.js";
import { addMember } from "./add-member.js";
import { assign } from "./assign.js";
import { chat } from "./chat.js";
import { commendation } from "./commendation.js";
import { daily } from "./daily.js";
import { dailyCancel } from "./daily-cancel.js";
import { deadlineNegotiation } from "./deadline-negotiation.js";
import { education } from "./education.js";
import { emergencyMeeting } from "./emergency-meeting.js";
import { emergencyMonitoring } from "./emergency-monitoring.js";
import { emergencySummarize } from "./emergency-summarize.js";
import { forcedClosing } from "./forced-closing.js";
import { holidayWork } from "./holiday-work.js";
import { monitoring } from "./monitoring.js";
import { oneOnOne } from "./one-on-one.js";
import { overtimePermission } from "./overtime-permission.js";
import { pairProgramming } from "./pair-programming.js";
import { plannedLeave } from "./planned-leave.js";
import { progressBoost } from "./progress-boost.js";
import { reschedule } from "./reschedule.js";
import { review } from "./review.js";
import { scopeNegotiation } from "./scope-negotiation.js";
import { stallResponse } from "./stall-response.js";
import { summarize } from "./summarize.js";
import { swap } from "./swap.js";
import { takeover } from "./takeover.js";

export interface CardDefinition {
  readonly cost: number;
  applyEffect(state: GameState): { effectsToAdd: CardEffect[]; memberUpdates: MemberUpdate[] };
}

export interface CardApplicationResult {
  effectsToAdd: CardEffect[];
  memberUpdates: MemberUpdate[];
}

export const CARD_REGISTRY = {
  デイリー: daily,
  デイリー中止: dailyCancel,
  レビュー: review,
  モニタリング: monitoring,
  サマライズ: summarize,
  臨時MTG: emergencyMeeting,
  臨時モニタリング: emergencyMonitoring,
  臨時サマライズ: emergencySummarize,
  教育: education,
  ペアプログラミング: pairProgramming,
  雑談: chat,
  停滞対応: stallResponse,
  個別面談: oneOnOne,
  表彰: commendation,
  計画休: plannedLeave,
  残業許可: overtimePermission,
  アサイン: assign,
  入れ替え: swap,
  巻取り: takeover,
  進捗ブースト: progressBoost,
  強制締め: forcedClosing,
  リスケ: reschedule,
  メンバー追加: addMember,
  休出: holidayWork,
  納期交渉: deadlineNegotiation,
  スコープ交渉: scopeNegotiation,
} satisfies Record<CardName, CardDefinition>;

export function applyCards(state: GameState, cards: CardName[]): CardApplicationResult {
  const effectsToAdd: CardEffect[] = [];
  const memberUpdates: MemberUpdate[] = [];

  for (const card of cards) {
    const result = CARD_REGISTRY[card].applyEffect(state);
    effectsToAdd.push(...result.effectsToAdd);
    memberUpdates.push(...result.memberUpdates);
  }

  return { effectsToAdd, memberUpdates };
}
