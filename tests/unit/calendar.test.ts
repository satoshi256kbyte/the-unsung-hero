import { describe, expect, it } from "vitest";
import { dayOfWeek, isWeekend } from "../../src/game/calendar.js";

describe("calendar - dayOfWeek", () => {
  it("turn 1 is Monday (0)", () => {
    expect(dayOfWeek(1)).toBe(0);
  });

  it("turn 5 is Friday (4)", () => {
    expect(dayOfWeek(5)).toBe(4);
  });

  it("turn 6 is Saturday (5)", () => {
    expect(dayOfWeek(6)).toBe(5);
  });

  it("turn 7 is Sunday (6)", () => {
    expect(dayOfWeek(7)).toBe(6);
  });

  it("turn 8 is Monday of week 2 (0)", () => {
    expect(dayOfWeek(8)).toBe(0);
  });

  it("turn 30 is Tuesday of week 5 (1)", () => {
    expect(dayOfWeek(30)).toBe(1);
  });
});

describe("calendar - isWeekend", () => {
  it.each([1, 2, 3, 4, 5])("turn %i (Mon-Fri) is not weekend", (turn) => {
    expect(isWeekend(turn)).toBe(false);
  });

  it.each([6, 7])("turn %i (Sat/Sun) is weekend", (turn) => {
    expect(isWeekend(turn)).toBe(true);
  });

  it.each([13, 14])("turn %i (week2 Sat/Sun) is weekend", (turn) => {
    expect(isWeekend(turn)).toBe(true);
  });
});
