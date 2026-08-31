import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import { drawCards, eligibleEntries } from "../../src/game/deck.js";
import type { CardName, CardPoolEntry } from "../../src/game/types.js";

// 決定論的な rng を作る（与えた配列の値を順に返し、尽きたら 0 を返す）
function seqRng(values: number[]): () => number {
  let i = 0;
  return () => (i < values.length ? (values[i++] as number) : 0);
}

// =============================================================================
// US1: 基本補充（drawCards）
// =============================================================================

describe("drawCards - US1 基本補充", () => {
  const pool: CardPoolEntry[] = [
    { name: "デイリー", weight: 1 },
    { name: "レビュー", weight: 1 },
  ];

  it("不足分だけ handLimit まで補充する", () => {
    const hand: CardName[] = ["モニタリング"];
    // rng=0 は常に先頭候補（デイリー）を選ぶ
    const result = drawCards(pool, {}, hand, 4, seqRng([0, 0, 0]));
    expect(result.hand.length).toBe(4);
    // 元の1枚 + 補充3枚
    expect(result.hand[0]).toBe("モニタリング");
  });

  it("既に handLimit 以上なら補充しない", () => {
    const hand: CardName[] = ["デイリー", "レビュー", "モニタリング"];
    const result = drawCards(pool, {}, hand, 3, seqRng([0, 0]));
    expect(result.hand).toEqual(hand);
  });

  it("handLimit を超えて増えない", () => {
    const hand: CardName[] = [];
    const result = drawCards(pool, {}, hand, 5, seqRng([0, 0, 0, 0, 0]));
    expect(result.hand.length).toBe(5);
  });

  it("入力を破壊しない（純関数）", () => {
    const hand: CardName[] = ["モニタリング"];
    const drawCounts = { モニタリング: 1 };
    const handCopy = [...hand];
    const countsCopy = { ...drawCounts };
    drawCards(pool, drawCounts, hand, 4, seqRng([0, 0, 0]));
    expect(hand).toEqual(handCopy);
    expect(drawCounts).toEqual(countsCopy);
  });

  it("補充のたびに drawCounts が加算される", () => {
    const result = drawCards(pool, {}, [], 3, seqRng([0, 0, 0]));
    const totalDrawn = Object.values(result.drawCounts).reduce((a, b) => a + b, 0);
    expect(totalDrawn).toBe(3);
  });
});

// =============================================================================
// US2: 配布プールによる制御（プール内限定・重み）
// =============================================================================

describe("drawCards - US2 プール制御", () => {
  it("補充されるカードは必ずプール内である（プール外は配らない）", () => {
    const pool: CardPoolEntry[] = [
      { name: "教育", weight: 1 },
      { name: "表彰", weight: 1 },
    ];
    const poolNames = new Set(pool.map((e) => e.name));
    const result = drawCards(pool, {}, [], 6, seqRng([0.1, 0.6, 0.2, 0.9, 0.4, 0.7]));
    for (const name of result.hand) {
      expect(poolNames.has(name)).toBe(true);
    }
  });

  it("プールが空なら補充されない", () => {
    const result = drawCards([], {}, [], 5, seqRng([0, 0]));
    expect(result.hand).toEqual([]);
  });

  it("重みの大きいカードほど多く配布される傾向がある（統計）", () => {
    // 重み 9:1 なら 「雑談」が「停滞対応」より明確に多いはず
    const pool: CardPoolEntry[] = [
      { name: "雑談", weight: 9 },
      { name: "停滞対応", weight: 1 },
    ];
    let heavy = 0;
    let light = 0;
    // 決定論のため Math.random ではなく多数サンプルを線形 rng で回す
    for (let i = 0; i < 1000; i++) {
      const r = (i * 0.6180339887) % 1; // 黄金比による一様分布近似
      const result = drawCards(pool, {}, [], 1, seqRng([r]));
      if (result.hand[0] === "雑談") heavy++;
      else light++;
    }
    expect(heavy).toBeGreaterThan(light);
  });

  it("fast-check: 補充後の手札は常にプール内のカードのみ", () => {
    fc.assert(
      fc.property(
        fc.array(fc.double({ min: 0, max: 0.999, noNaN: true }), { minLength: 1 }),
        (rs) => {
          const pool: CardPoolEntry[] = [
            { name: "教育", weight: 2 },
            { name: "雑談", weight: 3 },
            { name: "表彰", weight: 1 },
          ];
          const poolNames = new Set<CardName>(pool.map((e) => e.name));
          const result = drawCards(pool, {}, [], 5, seqRng(rs));
          return result.hand.every((n) => poolNames.has(n));
        },
      ),
    );
  });
});

// =============================================================================
// US3: 配布回数上限（eligibleEntries / maxDraws）
// =============================================================================

describe("eligibleEntries - US3 配布可能判定", () => {
  it("maxDraws 未到達のエントリを返す", () => {
    const pool: CardPoolEntry[] = [
      { name: "メンバー追加", weight: 1, maxDraws: 1 },
      { name: "デイリー", weight: 1 },
    ];
    const eligible = eligibleEntries(pool, { メンバー追加: 0 });
    expect(eligible.map((e) => e.name)).toContain("メンバー追加");
  });

  it("maxDraws 到達したエントリを除外する", () => {
    const pool: CardPoolEntry[] = [
      { name: "メンバー追加", weight: 1, maxDraws: 1 },
      { name: "デイリー", weight: 1 },
    ];
    const eligible = eligibleEntries(pool, { メンバー追加: 1 });
    expect(eligible.map((e) => e.name)).not.toContain("メンバー追加");
    expect(eligible.map((e) => e.name)).toContain("デイリー");
  });

  it("maxDraws を持たないエントリは常に配布可能", () => {
    const pool: CardPoolEntry[] = [{ name: "デイリー", weight: 1 }];
    const eligible = eligibleEntries(pool, { デイリー: 100 });
    expect(eligible.map((e) => e.name)).toContain("デイリー");
  });
});

describe("drawCards - US3 配布回数上限", () => {
  it("maxDraws=1 のカードは最大1回しか配布されない", () => {
    const pool: CardPoolEntry[] = [{ name: "メンバー追加", weight: 1, maxDraws: 1 }];
    // handLimit=5 でも配布可能が尽きるので1枚で打ち切り
    const result = drawCards(pool, {}, [], 5, seqRng([0, 0, 0, 0, 0]));
    const count = result.hand.filter((n) => n === "メンバー追加").length;
    expect(count).toBe(1);
    expect(result.drawCounts["メンバー追加"]).toBe(1);
  });

  it("maxDraws 無しのカードは回数による除外を受けない", () => {
    const pool: CardPoolEntry[] = [{ name: "デイリー", weight: 1 }];
    const result = drawCards(pool, {}, [], 4, seqRng([0, 0, 0, 0]));
    expect(result.hand.filter((n) => n === "デイリー").length).toBe(4);
  });

  it("配布可能カードが尽きたら補充を打ち切る（不足のまま・エラーにしない）", () => {
    const pool: CardPoolEntry[] = [
      { name: "メンバー追加", weight: 1, maxDraws: 1 },
      { name: "巻取り", weight: 1, maxDraws: 1 },
    ];
    // handLimit=5 だが配布可能は最大2枚
    const result = drawCards(pool, {}, [], 5, seqRng([0, 0, 0, 0, 0]));
    expect(result.hand.length).toBe(2);
  });

  it("初期配布分の drawCounts を考慮して maxDraws を判定する", () => {
    const pool: CardPoolEntry[] = [{ name: "メンバー追加", weight: 1, maxDraws: 1 }];
    // 既に1回配布済みなら追加配布されない
    const result = drawCards(pool, { メンバー追加: 1 }, ["メンバー追加"], 3, seqRng([0, 0]));
    expect(result.hand.filter((n) => n === "メンバー追加").length).toBe(1);
  });
});
