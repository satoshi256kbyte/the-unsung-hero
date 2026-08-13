import { expect, test } from "@playwright/test";

test.describe("US1: ダッシュボードでゲーム状態を確認できる", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForSelector('[data-testid="header-turn"]', { timeout: 10000 });
  });

  test("ヘッダーにターン1が表示される", async ({ page }) => {
    const headerTurn = page.locator('[data-testid="header-turn"]');
    await expect(headerTurn).toContainText("ターン 1");
  });

  test("KPIエリアが表示される", async ({ page }) => {
    await expect(page.locator('[data-testid="kpi-profit"]')).toBeVisible();
    await expect(page.locator('[data-testid="kpi-profit-rate"]')).toBeVisible();
    await expect(page.locator('[data-testid="kpi-spi"]')).toBeVisible();
    await expect(page.locator('[data-testid="kpi-cpi"]')).toBeVisible();
    await expect(page.locator('[data-testid="kpi-transparency"]')).toBeVisible();
    await expect(page.locator('[data-testid="kpi-tension"]')).toBeVisible();
  });

  test("メンバーaliceのスキルが12と表示される", async ({ page }) => {
    const memberRow = page.locator('[data-testid="member-alice"]');
    await expect(memberRow).toBeVisible();
    const skillEl = page.locator('[data-testid="member-alice-skill"]').first();
    await expect(skillEl).toContainText("12");
  });

  test("メンバーbobとcarolも表示される", async ({ page }) => {
    await expect(page.locator('[data-testid="member-bob"]')).toBeVisible();
    await expect(page.locator('[data-testid="member-carol"]')).toBeVisible();
  });

  test("手札カード（デイリー）が表示される", async ({ page }) => {
    const handCard = page.locator('[data-testid="hand-card-デイリー"]');
    await expect(handCard).toBeVisible();
  });

  test("手札カードがdraggable属性を持つ", async ({ page }) => {
    const handCard = page.locator('[data-testid="hand-card-デイリー"]');
    await expect(handCard).toHaveAttribute("draggable", "true");
  });

  test("8枚のカードスロットが存在する", async ({ page }) => {
    for (let i = 0; i < 8; i++) {
      await expect(page.locator(`[data-testid="card-slot-${i}"]`)).toBeVisible();
    }
  });

  test("ターン確定ボタンが存在する", async ({ page }) => {
    await expect(page.locator('[data-testid="confirm-turn-btn"]')).toBeVisible();
  });
});
