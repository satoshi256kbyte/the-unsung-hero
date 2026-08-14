import { describe, expect, it } from "vitest";
import { CARD_REGISTRY } from "../../../src/game/cards/index.js";
import type { CardName, GameState } from "../../../src/game/types.js";

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    turn: 1,
    deadline: 22,
    members: [{ id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 }],
    gantt: { tasks: [], variantId: null },
    totalCost: 0,
    budget: 200,
    hand: [],
    activeEffects: [],
    transparency: 100,
    tension: 100,
    isGameOver: false,
    gameOverReason: null,
    ...overrides,
  };
}

const STUB_CARDS: Array<[CardName, number]> = [
  ["デイリー中止", 0],
  ["サマライズ", 1],
  ["臨時MTG", 1],
  ["臨時モニタリング", 1],
  ["臨時サマライズ", 1],
  ["教育", 2],
  ["ペアプログラミング", 2],
  ["雑談", 1],
  ["停滞対応", 1],
  ["残業許可", 1],
  ["アサイン", 1],
  ["入れ替え", 1],
  ["巻取り", 2],
  ["進捗ブースト", 3],
  ["強制締め", 4],
  ["リスケ", 2],
  ["メンバー追加", 4],
  ["休出", 6],
  ["納期交渉", 6],
  ["スコープ交渉", 6],
];

describe("CARD_REGISTRY - 未実装カードのスタブ", () => {
  it.each(STUB_CARDS)("%s のコストは %i で、効果は空である", (name, cost) => {
    const def = CARD_REGISTRY[name];
    expect(def.cost).toBe(cost);
    const result = def.applyEffect(makeState());
    expect(result.effectsToAdd).toHaveLength(0);
    expect(result.memberUpdates).toHaveLength(0);
  });
});
