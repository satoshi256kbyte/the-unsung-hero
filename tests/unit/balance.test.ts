import { getHealthFactor, getSkillFactorRange } from "@game/balance.js";
import * as fc from "fast-check";
import { describe, expect, it } from "vitest";

describe("getSkillFactorRange", () => {
  describe("境界値テスト（バランスパラメータ.md skill_factor テーブル準拠）", () => {
    it.each([
      // 技 0〜4: [0.6, 1.2]
      [0, [0.6, 1.2]],
      [4, [0.6, 1.2]],
      // 技 5〜9: [0.75, 1.15]
      [5, [0.75, 1.15]],
      [9, [0.75, 1.15]],
      // 技 10〜14: [0.85, 1.10]
      [10, [0.85, 1.1]],
      [14, [0.85, 1.1]],
      // 技 15〜24: [0.90, 1.08]
      [15, [0.9, 1.08]],
      [24, [0.9, 1.08]],
      // 技 25以上: [0.95, 1.05]
      [25, [0.95, 1.05]],
      [99, [0.95, 1.05]],
    ] as Array<[number, [number, number]]>)("技レベル %i → %j", (skill, expected) => {
      expect(getSkillFactorRange(skill)).toEqual(expected);
    });
  });

  describe("プロパティテスト（fast-check）", () => {
    it("任意の技レベル 0〜99 で [min, max] 形式を返しパニックしない", () => {
      fc.assert(
        fc.property(fc.integer({ min: 0, max: 99 }), (skill) => {
          const [min, max] = getSkillFactorRange(skill);
          expect(typeof min).toBe("number");
          expect(typeof max).toBe("number");
          expect(min).toBeGreaterThan(0);
          expect(max).toBeGreaterThan(0);
          expect(min).toBeLessThanOrEqual(max);
        }),
      );
    });
  });
});

describe("getHealthFactor", () => {
  describe("境界値テスト（バランスパラメータ.md health_factor テーブル準拠）", () => {
    it.each([
      // 体 0〜29: [0.50, 1.0]
      [0, [0.5, 1.0]],
      [29, [0.5, 1.0]],
      // 体 30〜49: [0.70, 1.0]
      [30, [0.7, 1.0]],
      [49, [0.7, 1.0]],
      // 体 50〜69: [0.85, 1.0]
      [50, [0.85, 1.0]],
      [69, [0.85, 1.0]],
      // 体 70以上: [1.0, 1.0]
      [70, [1.0, 1.0]],
      [100, [1.0, 1.0]],
    ] as Array<[number, [number, number]]>)("体 %i → %j", (health, expected) => {
      expect(getHealthFactor(health)).toEqual(expected);
    });
  });

  describe("プロパティテスト（fast-check）", () => {
    it("任意の体の値 0〜100 で [min, max] 形式を返しパニックしない", () => {
      fc.assert(
        fc.property(fc.integer({ min: 0, max: 100 }), (health) => {
          const [min, max] = getHealthFactor(health);
          expect(typeof min).toBe("number");
          expect(typeof max).toBe("number");
          expect(min).toBeGreaterThan(0);
          expect(max).toBeGreaterThan(0);
          expect(min).toBeLessThanOrEqual(max);
        }),
      );
    });
  });
});
