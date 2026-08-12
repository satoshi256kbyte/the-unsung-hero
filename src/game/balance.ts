import { HEALTH_FACTOR_TABLE, SKILL_FACTOR_TABLE } from "./constants.js";

/**
 * 技レベルに対応する skill_factor の [min, max] を返す。
 * バランスパラメータ.md の skill_factor テーブルに準拠。
 */
export function getSkillFactorRange(skill: number): [number, number] {
  let result: readonly [number, number] = SKILL_FACTOR_TABLE[0]![1];
  for (const [threshold, range] of SKILL_FACTOR_TABLE) {
    if (skill >= threshold) {
      result = range;
    }
  }
  return [result[0], result[1]];
}

/**
 * 体の値に対応する health_factor の [min, max] を返す。
 * バランスパラメータ.md の health_factor テーブルに準拠。
 */
export function getHealthFactor(health: number): [number, number] {
  let result: readonly [number, number] = HEALTH_FACTOR_TABLE[0]![1];
  for (const [threshold, range] of HEALTH_FACTOR_TABLE) {
    if (health >= threshold) {
      result = range;
    }
  }
  return [result[0], result[1]];
}
