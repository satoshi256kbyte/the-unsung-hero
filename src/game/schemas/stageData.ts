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

const cardPoolEntrySchema = z.object({
  name: z.string(),
  weight: z.number().positive(),
  maxDraws: z.number().int().positive().optional(),
});

export const stageDataSchema = z
  .object({
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
    // 配布プール（未記載の既存ステージJSONは既定 [] で補完し後方互換を保つ）
    cardPool: z.array(cardPoolEntrySchema).default([]),
    // 手札上限（未記載時は initialCards の枚数を既定値とする）
    handLimit: z.number().int().positive().optional(),
  })
  .transform((data) => ({
    ...data,
    handLimit: data.handLimit ?? Math.max(1, data.initialCards.length),
  }));

export type StageDataJson = z.infer<typeof stageDataSchema>;
