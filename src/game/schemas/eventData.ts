import { z } from "zod";

export const eventDataSchema = z
  .object({
    baseProb: z.number().min(0).max(1),
  })
  .catchall(z.number().min(0).max(1));

export type EventData = z.infer<typeof eventDataSchema>;
