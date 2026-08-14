import { z } from "zod";

const rangeTupleSchema = z.tuple([z.number(), z.number()]);
const bracketTableSchema = z.array(z.tuple([z.number(), rangeTupleSchema]));

export const balanceConstantsSchema = z.object({
  GLOBAL_RULES: z.object({
    BUFFER_RATIO: z.number(),
    TARGET_PROFIT_RATE: z.number(),
    DAILY_COST_CAP: z.number(),
    OVERTIME_COST_CAP: z.number(),
  }),
  MEMBER_PARAMS: z.object({
    SKILL: z.object({
      MIN: z.number(),
      MAX: z.number(),
      INITIAL_A: z.number(),
      INITIAL_B: z.number(),
    }),
    EXP: z.object({ MIN: z.number() }),
    MORALE: z.object({ MIN: z.number(), MAX: z.number(), INITIAL: z.number() }),
    HEALTH: z.object({ MIN: z.number(), MAX: z.number(), INITIAL: z.number() }),
    TRANSPARENCY: z.object({ MIN: z.number(), MAX: z.number(), INITIAL: z.number() }),
    TENSION: z.object({ MIN: z.number(), MAX: z.number(), INITIAL: z.number() }),
  }),
  PROGRESS_DICE: z.object({
    BASE_MIN: z.number(),
    BASE_MAX: z.number(),
  }),
  EXP: z.object({
    BASE_EXP: z.number(),
    LEVEL_FACTOR_MIN: z.number(),
    LEVEL_FACTOR_COEFF: z.number(),
    EDUCATION_GRANT: z.number(),
    PAIR_PROG_GRANT: z.number(),
  }),
  LEVEL_UP_EXP: z.array(z.tuple([z.number(), z.number()])),
  PARAM_DELTA: z.object({
    MORALE_NATURAL_MIN: z.number(),
    MORALE_NATURAL_MAX: z.number(),
    HEALTH_NATURAL_MIN: z.number(),
    HEALTH_NATURAL_MAX: z.number(),
    TENSION_NATURAL_DELTA: z.number(),
    WEEKEND_MORALE_RECOVERY: z.number(),
    WEEKEND_HEALTH_RECOVERY: z.number(),
    CHAT_MORALE_MITIGATION: z.number(),
    CHAT_DURATION: z.number(),
    ONE_ON_ONE_MORALE: z.number(),
    COMMENDATION_MORALE: z.number(),
    PLANNED_LEAVE_MORALE: z.number(),
    PLANNED_LEAVE_HEALTH: z.number(),
    EVENT_SICK_MORALE: z.number(),
    EVENT_SICK_HEALTH: z.number(),
    EVENT_REWORK_MORALE: z.number(),
    EVENT_STALL_MORALE: z.number(),
    EVENT_STALL_DEADLINE_MORALE: z.number(),
    EVENT_INSPIRATION_MORALE: z.number(),
    EVENT_REST_MORALE: z.number(),
    EVENT_REST_HEALTH: z.number(),
    EVENT_LOCAL_WIN_MORALE: z.number(),
  }),
  THRESHOLDS: z.object({
    MORALE_LOW_START: z.number(),
    MORALE_LOW_DOUBLE: z.number(),
    MORALE_HIGH_START: z.number(),
    HEALTH_LOW_START: z.number(),
    HEALTH_LOW_DOUBLE: z.number(),
    TRANSPARENCY_LOW_START: z.number(),
    TRANSPARENCY_HIGH_START: z.number(),
    TENSION_LOW_START: z.number(),
    TENSION_HIGH_START: z.number(),
    MILESTONE_FAIL_RATE: z.number(),
    PROGRESS_BOOST_LINE: z.number(),
  }),
  REWORK: z.object({
    ROLLBACK_BASE: z.number(),
    ROLLBACK_COEFF: z.number(),
  }),
  STALL: z.object({
    ONE_TURN_PROB: z.number(),
    TWO_TURN_PROB: z.number(),
    EDUCATION_STALL_TEACHER: z.number(),
    EDUCATION_STALL_LEARNER: z.number(),
    PAIR_PROG_STALL: z.number(),
    ONBOARDING_STALL: z.number(),
  }),
  CHECKPOINT_PROB: z.object({
    KICKOFF: z.number(),
    WEEKLY_MEETING: z.number(),
    WEEKLY_MEETING_SECOND: z.number(),
    MILESTONE_PASS: z.number(),
    CLOSING: z.number(),
  }),
  SKILL_FACTOR_TABLE: bracketTableSchema,
  HEALTH_FACTOR_TABLE: bracketTableSchema,
});

export type BalanceConstants = z.infer<typeof balanceConstantsSchema>;
