import { expect, test } from "@playwright/test";
import { startGame } from "./helpers.js";

test.describe("Spec-16: 休出カードの対象選択UI", () => {
  test.beforeEach(async ({ page }) => {
    await startGame(page);
    await page.waitForSelector('[data-testid="hand-card-休出（土）"]', { timeout: 10000 });
  });

  test("休出（土）カードをスロットに置くと対象選択オーバーレイが表示される", async ({ page }) => {
    const handCard = page.locator('[data-testid="hand-card-休出（土）"]');
    const slot0 = page.locator('[data-testid="card-slot-0"]');

    await handCard.dragTo(slot0);

    await expect(page.locator('[data-testid="target-picker"]')).toBeVisible();
    await expect(page.locator('[data-testid="target-member-alice"]')).toBeVisible();
  });

  test("対象メンバーを選ぶとオーバーレイが閉じる", async ({ page }) => {
    const handCard = page.locator('[data-testid="hand-card-休出（土）"]');
    const slot0 = page.locator('[data-testid="card-slot-0"]');

    await handCard.dragTo(slot0);
    await page.locator('[data-testid="target-member-alice"]').click();

    await expect(page.locator('[data-testid="target-picker"]')).not.toBeVisible();
  });
});
