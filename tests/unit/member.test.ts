import * as fc from "fast-check";
import { describe, expect, it } from "vitest";
import { applyExperience, applyTurnDecay, applyWeekendRecovery } from "../../src/game/member.js";
import type { Member } from "../../src/game/types.js";

function makeMember(overrides: Partial<Member> = {}): Member {
  return {
    id: "m1",
    name: "Test",
    skill: 10,
    exp: 0,
    morale: 100,
    health: 100,
    ...overrides,
  };
}

// =============================================================================
// applyTurnDecay (US1)
// =============================================================================

describe("applyTurnDecay", () => {
  it("morale stays >= 0 when starting at 0 (下限クランプ)", () => {
    for (let i = 0; i < 50; i++) {
      const result = applyTurnDecay(makeMember({ morale: 0, health: 50 }));
      expect(result.morale).toBeGreaterThanOrEqual(0);
    }
  });

  it("morale stays <= 150 when starting at 150 (上限クランプ)", () => {
    for (let i = 0; i < 50; i++) {
      const result = applyTurnDecay(makeMember({ morale: 150, health: 50 }));
      expect(result.morale).toBeLessThanOrEqual(150);
    }
  });

  it("health stays >= 0 when starting at 0 (下限クランプ)", () => {
    for (let i = 0; i < 50; i++) {
      const result = applyTurnDecay(makeMember({ health: 0 }));
      expect(result.health).toBeGreaterThanOrEqual(0);
    }
  });

  it("health stays <= 100 when starting at 100 (上限クランプ)", () => {
    for (let i = 0; i < 50; i++) {
      const result = applyTurnDecay(makeMember({ health: 100 }));
      expect(result.health).toBeLessThanOrEqual(100);
    }
  });

  it("morale changes by integer in [-3, +1]", () => {
    const original = makeMember({ morale: 50, health: 50 });
    for (let i = 0; i < 100; i++) {
      const result = applyTurnDecay(original);
      const delta = result.morale - original.morale;
      expect(delta).toBeGreaterThanOrEqual(-3);
      expect(delta).toBeLessThanOrEqual(1);
      expect(Number.isInteger(delta)).toBe(true);
    }
  });

  it("health decreases by integer in [-3, -1]", () => {
    const original = makeMember({ morale: 50, health: 50 });
    for (let i = 0; i < 100; i++) {
      const result = applyTurnDecay(original);
      const delta = result.health - original.health;
      expect(delta).toBeGreaterThanOrEqual(-3);
      expect(delta).toBeLessThanOrEqual(-1);
      expect(Number.isInteger(delta)).toBe(true);
    }
  });

  it("does not mutate the input member (イミュータブル)", () => {
    const member = makeMember({ morale: 80, health: 80 });
    applyTurnDecay(member);
    expect(member.morale).toBe(80);
    expect(member.health).toBe(80);
  });

  it("preserves skill, exp, id, name unchanged", () => {
    const member = makeMember({ skill: 15, exp: 42 });
    const result = applyTurnDecay(member);
    expect(result.skill).toBe(15);
    expect(result.exp).toBe(42);
    expect(result.id).toBe(member.id);
    expect(result.name).toBe(member.name);
  });
});

// =============================================================================
// applyWeekendRecovery (US2)
// =============================================================================

describe("applyWeekendRecovery", () => {
  it("morale increases by exactly 8 when not near cap", () => {
    const member = makeMember({ morale: 90, health: 80 });
    const result = applyWeekendRecovery(member);
    expect(result.morale).toBe(98);
  });

  it("health increases by exactly 12 when not near cap", () => {
    const member = makeMember({ morale: 90, health: 80 });
    const result = applyWeekendRecovery(member);
    expect(result.health).toBe(92);
  });

  it("morale clamps to 150 when near cap (145+8=150)", () => {
    const result = applyWeekendRecovery(makeMember({ morale: 145, health: 50 }));
    expect(result.morale).toBe(150);
  });

  it("morale clamps to 150 when would exceed cap (148+8=150)", () => {
    const result = applyWeekendRecovery(makeMember({ morale: 148, health: 50 }));
    expect(result.morale).toBe(150);
  });

  it("health clamps to 100 when near cap (95+12=100)", () => {
    const result = applyWeekendRecovery(makeMember({ morale: 50, health: 95 }));
    expect(result.health).toBe(100);
  });

  it("health clamps to 100 when would exceed cap (98+12=100)", () => {
    const result = applyWeekendRecovery(makeMember({ morale: 50, health: 98 }));
    expect(result.health).toBe(100);
  });

  it("does not mutate the input member (イミュータブル)", () => {
    const member = makeMember({ morale: 90, health: 80 });
    applyWeekendRecovery(member);
    expect(member.morale).toBe(90);
    expect(member.health).toBe(80);
  });

  it("preserves skill, exp, id, name unchanged", () => {
    const member = makeMember({ skill: 20, exp: 99 });
    const result = applyWeekendRecovery(member);
    expect(result.skill).toBe(20);
    expect(result.exp).toBe(99);
  });
});

// =============================================================================
// applyExperience (US3)
// =============================================================================

describe("applyExperience", () => {
  // skill=8 → LEVEL_UP_EXP: 5→50 → required=50
  it("levels up when exp crosses threshold (skill8 exp40+15=55>=50)", () => {
    const member = makeMember({ skill: 8, exp: 40 });
    const result = applyExperience(member, 15);
    expect(result.skill).toBe(9);
    expect(result.exp).toBe(5); // 55 - 50
  });

  it("does not level up when exp stays below threshold (skill10 exp0+50<80)", () => {
    const member = makeMember({ skill: 10, exp: 0 });
    const result = applyExperience(member, 50);
    expect(result.skill).toBe(10);
    expect(result.exp).toBe(50);
  });

  it("skill at max (99) does not level up regardless of exp", () => {
    const member = makeMember({ skill: 99, exp: 0 });
    const result = applyExperience(member, 9999);
    expect(result.skill).toBe(99);
  });

  it("returns same member when expGain is 0", () => {
    const member = makeMember({ skill: 5, exp: 10 });
    const result = applyExperience(member, 0);
    expect(result).toBe(member);
  });

  it("returns same member when expGain is negative", () => {
    const member = makeMember({ skill: 5, exp: 10 });
    const result = applyExperience(member, -5);
    expect(result).toBe(member);
  });

  // skill=0 → required=30
  it("levels up at skill 0 with required=30 (exp0+30=30>=30)", () => {
    const member = makeMember({ skill: 0, exp: 0 });
    const result = applyExperience(member, 30);
    expect(result.skill).toBe(1);
    expect(result.exp).toBe(0);
  });

  // skill=25 → required=200
  it("levels up at skill 25 threshold (exp0+200=200>=200)", () => {
    const member = makeMember({ skill: 25, exp: 0 });
    const result = applyExperience(member, 200);
    expect(result.skill).toBe(26);
    expect(result.exp).toBe(0);
  });

  it("accumulates exp correctly without level up (skill50 exp0+199<400)", () => {
    const member = makeMember({ skill: 50, exp: 0 });
    const result = applyExperience(member, 199);
    expect(result.skill).toBe(50);
    expect(result.exp).toBe(199);
  });

  it("does not mutate the input member (イミュータブル)", () => {
    const member = makeMember({ skill: 8, exp: 40 });
    applyExperience(member, 15);
    expect(member.skill).toBe(8);
    expect(member.exp).toBe(40);
  });

  it("preserves morale, health, id, name unchanged", () => {
    const member = makeMember({ skill: 5, exp: 0, morale: 120, health: 90 });
    const result = applyExperience(member, 10);
    expect(result.morale).toBe(120);
    expect(result.health).toBe(90);
    expect(result.id).toBe(member.id);
  });
});

// =============================================================================
// fast-check property tests (Phase 6 - T014)
// =============================================================================

describe("property tests", () => {
  const memberArb = fc.record({
    id: fc.constant("m1"),
    name: fc.constant("Test"),
    skill: fc.integer({ min: 0, max: 99 }),
    exp: fc.integer({ min: 0, max: 500 }),
    morale: fc.integer({ min: 0, max: 150 }),
    health: fc.integer({ min: 0, max: 100 }),
  });

  it("applyTurnDecay: all params stay in range for arbitrary member", () => {
    fc.assert(
      fc.property(memberArb, (member) => {
        const result = applyTurnDecay(member);
        return (
          result.morale >= 0 &&
          result.morale <= 150 &&
          result.health >= 0 &&
          result.health <= 100 &&
          result.skill === member.skill &&
          result.exp === member.exp
        );
      }),
    );
  });

  it("applyWeekendRecovery: all params stay in range for arbitrary member", () => {
    fc.assert(
      fc.property(memberArb, (member) => {
        const result = applyWeekendRecovery(member);
        return (
          result.morale >= 0 &&
          result.morale <= 150 &&
          result.health >= 0 &&
          result.health <= 100 &&
          result.skill === member.skill &&
          result.exp === member.exp
        );
      }),
    );
  });

  it("applyExperience: skill stays 0-99, exp >= 0 for arbitrary inputs", () => {
    fc.assert(
      fc.property(memberArb, fc.integer({ min: 0, max: 500 }), (member, expGain) => {
        const result = applyExperience(member, expGain);
        return result.skill >= 0 && result.skill <= 99 && result.exp >= 0;
      }),
    );
  });

  it("applyTurnDecay: input member is not mutated", () => {
    fc.assert(
      fc.property(memberArb, (member) => {
        const before = { ...member };
        applyTurnDecay(member);
        return member.morale === before.morale && member.health === before.health;
      }),
    );
  });

  it("applyWeekendRecovery: input member is not mutated", () => {
    fc.assert(
      fc.property(memberArb, (member) => {
        const before = { ...member };
        applyWeekendRecovery(member);
        return member.morale === before.morale && member.health === before.health;
      }),
    );
  });

  it("applyExperience: input member is not mutated", () => {
    fc.assert(
      fc.property(memberArb, fc.integer({ min: 1, max: 500 }), (member, expGain) => {
        const before = { ...member };
        applyExperience(member, expGain);
        return member.skill === before.skill && member.exp === before.exp;
      }),
    );
  });
});
