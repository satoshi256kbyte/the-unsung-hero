import { expect, test } from "@playwright/test";

test.describe("US3: ターン確定後にターン移行ロード画面が表示される", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForSelector('[data-testid="confirm-turn-btn"]', { timeout: 10000 });
  });

  test("初期状態でローディング画面は非表示である", async ({ page }) => {
    const loading = page.locator('[data-testid="loading-screen"]');
    await expect(loading).toHaveAttribute("aria-hidden", "true");
  });

  test("ターン確定ボタンクリック後にローディング画面が表示される", async ({ page }) => {
    const confirmBtn = page.locator('[data-testid="confirm-turn-btn"]');
    await confirmBtn.click();

    const loading = page.locator('[data-testid="loading-screen"]');
    await expect(loading).toHaveAttribute("aria-hidden", "false");
  });

  test("ローディング中にPM用語テキストが表示される", async ({ page }) => {
    await page.locator('[data-testid="confirm-turn-btn"]').click();

    const pmTerm = page.locator('[data-testid="pm-term-text"]');
    await expect(pmTerm).not.toBeEmpty();
  });

  test("1秒以上後にローディング画面が非表示になる", async ({ page }) => {
    const start = Date.now();
    await page.locator('[data-testid="confirm-turn-btn"]').click();

    const loading = page.locator('[data-testid="loading-screen"]');
    await expect(loading).toHaveAttribute("aria-hidden", "true", { timeout: 5000 });

    const elapsed = Date.now() - start;
    expect(elapsed).toBeGreaterThanOrEqual(1000);
  });

  test("ターン確定後にターン番号が2に更新される", async ({ page }) => {
    await page.locator('[data-testid="confirm-turn-btn"]').click();

    await page.locator('[data-testid="loading-screen"]').waitFor({
      state: "hidden",
      timeout: 5000,
    });

    await expect(page.locator('[data-testid="header-turn"]')).toContainText("ターン 2");
  });
});
