// カード配布ロジック（純関数）。Phaser / DOM 非依存（Constitution 原則 I）。
// 手札を配布プールから手札上限まで補充する。乱数は rng 引数で注入可能にしテスト可能にする。

import type { CardName, CardPoolEntry } from "./types.js";

/**
 * maxDraws 未到達で配布可能なプールエントリを返す。
 * maxDraws が省略されたエントリは常に配布可能。指定されている場合は
 * drawCounts[name] が maxDraws 未満のときのみ配布可能。
 */
export function eligibleEntries(
  pool: CardPoolEntry[],
  drawCounts: Record<string, number>,
): CardPoolEntry[] {
  return pool.filter((entry) => {
    if (entry.maxDraws === undefined) {
      return true;
    }
    const drawn = drawCounts[entry.name] ?? 0;
    return drawn < entry.maxDraws;
  });
}

/**
 * 重み付き抽選で1エントリを選ぶ。weight に比例した確率。
 * entries が空なら undefined を返す。rng は [0,1) を返す関数。
 */
function pickWeighted(entries: CardPoolEntry[], rng: () => number): CardPoolEntry | undefined {
  if (entries.length === 0) {
    return undefined;
  }
  const totalWeight = entries.reduce((acc, e) => acc + e.weight, 0);
  if (totalWeight <= 0) {
    return undefined;
  }
  let threshold = rng() * totalWeight;
  for (const entry of entries) {
    threshold -= entry.weight;
    if (threshold < 0) {
      return entry;
    }
  }
  // 浮動小数の誤差で末尾まで到達した場合は最後のエントリを返す
  return entries[entries.length - 1];
}

/**
 * 手札を handLimit まで補充する。純関数（入力を変更しない）。
 * - 補充対象は配布プール内かつ maxDraws 未到達のカードのみ（プール外は配らない）。
 * - weight に比例した確率で抽選する。
 * - 各配布で drawCounts を加算し、maxDraws 到達カードは以降の補充対象から除外する。
 * - 配布可能カードが尽きたら不足のまま打ち切る（エラーにしない）。
 * @param rng [0,1) を返す関数。デフォルト Math.random。テストで決定論的に注入可能。
 */
export function drawCards(
  pool: CardPoolEntry[],
  drawCounts: Record<string, number>,
  hand: CardName[],
  handLimit: number,
  rng: () => number = Math.random,
): { hand: CardName[]; drawCounts: Record<string, number> } {
  const nextHand: CardName[] = [...hand];
  const nextCounts: Record<string, number> = { ...drawCounts };

  while (nextHand.length < handLimit) {
    const candidates = eligibleEntries(pool, nextCounts);
    const picked = pickWeighted(candidates, rng);
    if (picked === undefined) {
      // 配布可能カードが尽きた → 補充を打ち切る（不足のまま）
      break;
    }
    nextHand.push(picked.name);
    nextCounts[picked.name] = (nextCounts[picked.name] ?? 0) + 1;
  }

  return { hand: nextHand, drawCounts: nextCounts };
}
