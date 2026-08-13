import { expect, test } from "@playwright/test";

test.describe("US2: カード枠でターンのアクションを組み立てられる", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForSelector('[data-testid="hand-card-デイリー"]', { timeout: 10000 });
  });

  test("初期状態でスロット0はdata-occupied=falseである", async ({ page }) => {
    const slot0 = page.locator('[data-testid="card-slot-0"]');
    await expect(slot0).toHaveAttribute("data-occupied", "false");
  });

  test("初期状態でtotal-costは0である", async ({ page }) => {
    await expect(page.locator('[data-testid="total-cost"]')).toHaveText("0");
  });

  test("手札カードをスロットにドラッグ＆ドロップするとdata-occupied=trueになる", async ({
    page,
  }) => {
    const handCard = page.locator('[data-testid="hand-card-デイリー"]');
    const slot0 = page.locator('[data-testid="card-slot-0"]');

    await handCard.dragTo(slot0);

    await expect(slot0).toHaveAttribute("data-occupied", "true");
  });

  test("カードを配置するとdata-cardにカード名が設定される", async ({ page }) => {
    const handCard = page.locator('[data-testid="hand-card-デイリー"]');
    const slot0 = page.locator('[data-testid="card-slot-0"]');

    await handCard.dragTo(slot0);

    await expect(slot0).toHaveAttribute("data-card", "デイリー");
  });

  test("カードを配置するとtotal-costが更新される", async ({ page }) => {
    const handCard = page.locator('[data-testid="hand-card-デイリー"]');
    const slot0 = page.locator('[data-testid="card-slot-0"]');

    await handCard.dragTo(slot0);

    const totalCost = page.locator('[data-testid="total-cost"]');
    const costText = await totalCost.textContent();
    const cost = parseInt(costText ?? "0", 10);
    expect(cost).toBeGreaterThan(0);
  });

  test("スロットをクリックするとカードが除去されdata-occupied=falseになる", async ({ page }) => {
    const handCard = page.locator('[data-testid="hand-card-デイリー"]');
    const slot0 = page.locator('[data-testid="card-slot-0"]');

    await handCard.dragTo(slot0);
    await expect(slot0).toHaveAttribute("data-occupied", "true");

    await slot0.click();
    await expect(slot0).toHaveAttribute("data-occupied", "false");
  });

  test("カードを除去するとtotal-costが0に戻る", async ({ page }) => {
    const handCard = page.locator('[data-testid="hand-card-デイリー"]');
    const slot0 = page.locator('[data-testid="card-slot-0"]');

    await handCard.dragTo(slot0);
    await slot0.click();

    await expect(page.locator('[data-testid="total-cost"]')).toHaveText("0");
  });
});
