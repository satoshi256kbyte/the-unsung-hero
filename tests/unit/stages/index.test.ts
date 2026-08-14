import { describe, expect, it } from "vitest";
import { buildStageRegistry, getStage, initStageRegistry } from "../../../src/game/stages/index.js";
import type { StageData } from "../../../src/game/types.js";

function makeStageData(overrides: Partial<StageData> = {}): StageData {
  return {
    id: "test-stage",
    name: "テストステージ",
    description: "テスト用ステージ",
    budget: 1000,
    deadline: 10,
    initialMembers: [],
    initialGantt: { tasks: [], variantId: null },
    ganttVariants: {},
    conditionalEvents: [],
    initialCards: [],
    ...overrides,
  };
}

describe("buildStageRegistry", () => {
  it("渡したStageDataをそのままidキーで保持する", () => {
    const stage = makeStageData();
    const registry = buildStageRegistry({ "test-stage": stage });
    expect(registry["test-stage"]).toBe(stage);
  });
});

describe("initStageRegistry / getStage", () => {
  it("初期化後にidでStageDataを取得できる", () => {
    const stage = makeStageData({ id: "another-stage" });
    initStageRegistry({ "another-stage": stage });
    expect(getStage("another-stage")).toBe(stage);
  });

  it("未知のidを指定すると例外を投げる", () => {
    initStageRegistry({ "known-stage": makeStageData({ id: "known-stage" }) });
    expect(() => getStage("unknown-stage")).toThrow();
  });
});
