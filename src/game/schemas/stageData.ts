import { z } from "zod";

const memberSchema = z.object({
  id: z.string(),
  name: z.string(),
  skill: z.number(),
  exp: z.number(),
  morale: z.number(),
  health: z.number(),
});

const ganttTaskSchema = z.object({
  id: z.string(),
  name: z.string(),
  phase: z.string(),
  startTurn: z.number(),
  duration: z.number(),
  assignedMemberId: z.string(),
  progress: z.number(),
  status: z.enum(["active", "stalled", "done"]),
  dependencies: z.array(z.string()),
  actualStartTurn: z.number().nullable().default(null),
  actualEndTurn: z.number().nullable().default(null),
});

const ganttChartSchema = z.object({
  tasks: z.array(ganttTaskSchema),
  variantId: z.string().nullable(),
});

const conditionalEventSchema = z.object({
  id: z.string(),
  turn: z.number(),
  condition: z.string(),
  eventType: z.enum(["ニュートラル", "ネガティブ", "ポジティブ"]),
  params: z.record(z.string(), z.unknown()),
});

export const stageDataSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string(),
  budget: z.number(),
  deadline: z.number(),
  initialMembers: z.array(memberSchema),
  initialGantt: ganttChartSchema,
  ganttVariants: z.record(z.string(), ganttChartSchema),
  conditionalEvents: z.array(conditionalEventSchema),
  initialCards: z.array(z.string()),
});

export type StageDataJson = z.infer<typeof stageDataSchema>;
