import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import { applyEffectTick, calcEventProbModifier } from "../../src/game/effect.js";
import type { CardEffect } from "../../src/game/types.js";

function makeEffect(
  effectType: CardEffect["effectType"],
  remainingTurns: number | null,
): CardEffect {
  return { cardName: "デイリー", targetId: "project", effectType, remainingTurns };
}

// =============================================================================
// US2: applyEffectTick
// =============================================================================

describe("applyEffectTick", () => {
  it("remainingTurns=1 の効果は除去される", () => {
    const effects = [makeEffect("rework_prob_reduced", 1)];
    const result = applyEffectTick(effects);
    expect(result).toHaveLength(0);
  });

  it("remainingTurns=0 の効果は即除去される", () => {
    const effects = [makeEffect("rework_prob_reduced", 0)];
    const result = applyEffectTick(effects);
    expect(result).toHaveLength(0);
  });

  it("remainingTurns=3 は remainingTurns=2 にデクリメントされる", () => {
    const effects = [makeEffect("rework_prob_reduced", 3)];
    const result = applyEffectTick(effects);
    expect(result).toHaveLength(1);
    expect(result[0]?.remainingTurns).toBe(2);
  });

  it("remainingTurns=null の効果は保持される（永続効果）", () => {
    const effects = [makeEffect("task_event_prob_reduced", null)];
    const result = applyEffectTick(effects);
    expect(result).toHaveLength(1);
    expect(result[0]?.remainingTurns).toBeNull();
  });

  it("混在効果リストで各ルールが独立して適用される", () => {
    const effects = [
      makeEffect("rework_prob_reduced", 1), // 除去
      makeEffect("task_event_prob_reduced", null), // 保持
      makeEffect("overreport_prob_reduced", 3), // デクリメント
    ];
    const result = applyEffectTick(effects);
    expect(result).toHaveLength(2);
    expect(result.some((e) => e.effectType === "rework_prob_reduced")).toBe(false);
    expect(result.some((e) => e.effectType === "task_event_prob_reduced")).toBe(true);
    const dec = result.find((e) => e.effectType === "overreport_prob_reduced");
    expect(dec?.remainingTurns).toBe(2);
  });

  it("空配列を渡すと空配列が返る", () => {
    expect(applyEffectTick([])).toHaveLength(0);
  });

  it("引数配列の参照・値が変化しない（イミュータブル）", () => {
    const effects = [makeEffect("rework_prob_reduced", 3)];
    const before = JSON.stringify(effects);
    applyEffectTick(effects);
    expect(JSON.stringify(effects)).toBe(before);
    expect(effects).toHaveLength(1);
  });
});

// =============================================================================
// US3: calcEventProbModifier
// =============================================================================

describe("calcEventProbModifier", () => {
  it("rework_prob_reduced があれば baseProb × 0.5 を返す", () => {
    const effects = [makeEffect("rework_prob_reduced", null)];
    expect(calcEventProbModifier(effects, 0.08, "rework_prob_reduced")).toBeCloseTo(0.04);
  });

  it("rework_prob_reduced がなければ baseProb をそのまま返す", () => {
    expect(calcEventProbModifier([], 0.08, "rework_prob_reduced")).toBeCloseTo(0.08);
  });

  it("task_event_prob_reduced があれば baseProb × 0.5 を返す", () => {
    const effects = [makeEffect("task_event_prob_reduced", null)];
    expect(calcEventProbModifier(effects, 0.05, "task_event_prob_reduced")).toBeCloseTo(0.025);
  });

  it("異なる effectType の効果があっても補正しない", () => {
    const effects = [makeEffect("rework_prob_reduced", null)];
    expect(calcEventProbModifier(effects, 0.05, "task_event_prob_reduced")).toBeCloseTo(0.05);
  });

  it("同種 effectType が複数あっても 0.5 倍のみ（重複スタックなし）", () => {
    const effects = [
      makeEffect("rework_prob_reduced", null),
      makeEffect("rework_prob_reduced", null),
    ];
    expect(calcEventProbModifier(effects, 0.08, "rework_prob_reduced")).toBeCloseTo(0.04);
  });

  it("activeEffects が空配列のとき baseProb をそのまま返す", () => {
    expect(calcEventProbModifier([], 0.1, "rework_prob_reduced")).toBeCloseTo(0.1);
  });
});

// =============================================================================
// Fast-check property tests
// =============================================================================

const arbEffectType = fc.constantFrom(
  "task_event_prob_reduced" as const,
  "rework_prob_reduced" as const,
  "overreport_prob_reduced" as const,
  "morale_decay_mitigated" as const,
  "overtime_cap_extended" as const,
  "education_stall" as const,
  "pair_prog_stall" as const,
);

const arbCardEffect = fc.record({
  cardName: fc.constantFrom("デイリー" as const, "レビュー" as const, "モニタリング" as const),
  targetId: fc.constantFrom("project" as const, "m1" as const),
  effectType: arbEffectType,
  remainingTurns: fc.oneof(fc.constant(null), fc.integer({ min: 0, max: 10 })),
});

describe("applyEffectTick - fast-check properties", () => {
  it("任意の CardEffect[] で例外が発生しない", () => {
    fc.assert(
      fc.property(fc.array(arbCardEffect, { maxLength: 10 }), (effects) => {
        expect(() => applyEffectTick(effects)).not.toThrow();
      }),
      { numRuns: 200 },
    );
  });

  it("結果の remainingTurns は null か 1以上の整数", () => {
    fc.assert(
      fc.property(fc.array(arbCardEffect, { maxLength: 10 }), (effects) => {
        const result = applyEffectTick(effects);
        for (const e of result) {
          if (e.remainingTurns !== null) {
            expect(e.remainingTurns).toBeGreaterThanOrEqual(1);
            expect(Number.isInteger(e.remainingTurns)).toBe(true);
          }
        }
      }),
      { numRuns: 200 },
    );
  });

  it("引数配列がイミュータブル", () => {
    fc.assert(
      fc.property(fc.array(arbCardEffect, { maxLength: 10 }), (effects) => {
        const before = JSON.stringify(effects);
        applyEffectTick(effects);
        expect(JSON.stringify(effects)).toBe(before);
      }),
      { numRuns: 200 },
    );
  });
});

describe("calcEventProbModifier - fast-check properties", () => {
  it("任意の入力で例外が発生しない", () => {
    fc.assert(
      fc.property(
        fc.array(arbCardEffect, { maxLength: 10 }),
        fc.float({ min: 0, max: 1, noNaN: true }),
        arbEffectType,
        (effects, baseProb, effectType) => {
          expect(() => calcEventProbModifier(effects, baseProb, effectType)).not.toThrow();
        },
      ),
      { numRuns: 200 },
    );
  });

  it("戻り値は有限数かつ 0 ≤ result ≤ baseProb", () => {
    fc.assert(
      fc.property(
        fc.array(arbCardEffect, { maxLength: 10 }),
        fc.float({ min: 0, max: 1, noNaN: true }),
        arbEffectType,
        (effects, baseProb, effectType) => {
          const result = calcEventProbModifier(effects, baseProb, effectType);
          expect(Number.isFinite(result)).toBe(true);
          expect(result).toBeGreaterThanOrEqual(0);
          expect(result).toBeLessThanOrEqual(baseProb + 1e-10);
        },
      ),
      { numRuns: 200 },
    );
  });
});
