import { getConfig } from "./config.js";

/**
 * 技レベルに対応する skill_factor の [min, max] を返す。
 * バランスパラメータ.md の skill_factor テーブルに準拠。
 */
export function getSkillFactorRange(skill: number): [number, number] {
  const table = getConfig().balance.SKILL_FACTOR_TABLE;
  let result: readonly [number, number] = table[0]?.[1] ?? [1, 1];
  for (const [threshold, range] of table) {
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
  const table = getConfig().balance.HEALTH_FACTOR_TABLE;
  let result: readonly [number, number] = table[0]?.[1] ?? [1, 1];
  for (const [threshold, range] of table) {
    if (health >= threshold) {
      result = range;
    }
  }
  return [result[0], result[1]];
}
