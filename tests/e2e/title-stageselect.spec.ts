import { expect, test } from "@playwright/test";

test.describe("US1: タイトル画面からゲームを始められる", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForSelector('[data-testid="title-logo"]', { timeout: 10000 });
  });

  test("タイトルロゴとスタートボタンが表示される", async ({ page }) => {
    await expect(page.locator('[data-testid="title-logo"]')).toBeVisible();
    await expect(page.locator('[data-testid="title-start-btn"]')).toBeVisible();
  });

  test("スタートボタン押下でステージセレクト画面に遷移する", async ({ page }) => {
    await page.locator('[data-testid="title-start-btn"]').click();
    await expect(page.locator('[data-testid="stage-list"]')).toBeVisible();
  });
});

test.describe("US2: ステージの内容を確認してからプレイを開始できる", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForSelector('[data-testid="title-start-btn"]', { timeout: 10000 });
    await page.locator('[data-testid="title-start-btn"]').click();
    await page.waitForSelector('[data-testid="stage-card-poc-01"]', { timeout: 10000 });
  });

  test("ステージカードをクリックすると確認画面が表示される", async ({ page }) => {
    await page.locator('[data-testid="stage-card-poc-01"]').click();
    await expect(page.locator('[data-testid="stage-confirm"]')).toBeVisible();
    await expect(page.locator('[data-testid="stage-confirm-description"]')).not.toBeEmpty();
    await expect(page.locator('[data-testid="stage-confirm-budget"]')).toContainText("予算");
    await expect(page.locator('[data-testid="stage-confirm-profit-rate"]')).toContainText(
      "目標利益率",
    );
  });

  test("確認画面で「もどる」を押すと一覧表示に戻る", async ({ page }) => {
    await page.locator('[data-testid="stage-card-poc-01"]').click();
    await page.locator('[data-testid="stage-confirm-back-btn"]').click();
    await expect(page.locator('[data-testid="stage-list"]')).toBeVisible();
  });

  test("確認画面で「開始する」を押すとゲームプレイ画面が始まる", async ({ page }) => {
    await page.locator('[data-testid="stage-card-poc-01"]').click();
    await page.locator('[data-testid="stage-confirm-start-btn"]').click();
    await page.waitForSelector('[data-testid="confirm-turn-btn"]', { timeout: 10000 });
    await expect(page.locator('[data-testid="confirm-turn-btn"]')).toBeVisible();
  });
});
