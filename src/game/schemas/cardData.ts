import { z } from "zod";

export const cardDataSchema = z.object({
  cost: z.number().int().nonnegative(),
});

export type CardData = z.infer<typeof cardDataSchema>;
