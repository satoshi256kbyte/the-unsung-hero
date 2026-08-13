import { rollProgress } from "@game/dice.js";
import type { Member } from "@game/types.js";
import * as fc from "fast-check";
import { describe, expect, it } from "vitest";

function makeMember(skill: number, health: number): Member {
  return {
    id: "m1",
    name: "テストメンバー",
    skill,
    exp: 0,
    morale: 100,
    health,
  };
}

// ---------------------------------------------------------------------------
// US1: メンバーの1ターン進捗量を計算できる
// ---------------------------------------------------------------------------

describe("rollProgress", () => {
  describe("技の境界値テスト（体=100固定）", () => {
    const skillBoundaries = [0, 4, 5, 9, 10, 14, 15, 24, 25, 99];

    for (const skill of skillBoundaries) {
      it(`技${skill}: 戻り値が正数`, () => {
        const result = rollProgress(makeMember(skill, 100));
        expect(result).toBeGreaterThan(0);
      });
    }

    it("元の Member オブジェクトを変更しない（イミュータブル）", () => {
      const member = makeMember(10, 100);
      rollProgress(member);
      expect(member.skill).toBe(10);
      expect(member.health).toBe(100);
    });
  });

  describe("fast-check: 任意の技(0〜99)・体(0〜100)でパニックなし・正数", () => {
    it("property: 戻り値は常に正数", () => {
      fc.assert(
        fc.property(
          fc.integer({ min: 0, max: 99 }),
          fc.integer({ min: 0, max: 100 }),
          (skill, health) => {
            const result = rollProgress(makeMember(skill, health));
            return result > 0;
          },
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // US2: 体が低いメンバーは進捗が下振れする
  // ---------------------------------------------------------------------------

  describe("体の境界値テスト（技=10固定）", () => {
    const healthBoundaries = [0, 29, 30, 49, 50, 69, 70, 100];

    for (const health of healthBoundaries) {
      it(`体${health}: 戻り値が正数`, () => {
        const result = rollProgress(makeMember(10, health));
        expect(result).toBeGreaterThan(0);
      });
    }

    it("体70以上: health_factor 上限が1.0（100回試行で base×skill_factor を超えない）", () => {
      // 技25のとき skill_factor_max = 1.05, base_max = 7.0 → 最大 7.35
      // health_factor_max = 1.0（体70以上）なので結果は 7.35 以下
      const skillMax = 25;
      const baseMax = 7.0;
      const skillFactorMax = 1.05;
      const theoreticalMax = baseMax * skillFactorMax * 1.0;
      for (let i = 0; i < 100; i++) {
        const result = rollProgress(makeMember(skillMax, 100));
        expect(result).toBeLessThanOrEqual(theoreticalMax + 0.001);
      }
    });
  });
});
