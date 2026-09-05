import type { Page } from "@playwright/test";
import { expect, test } from "@playwright/test";
import { startGame } from "./helpers.js";

/**
 * ゲームが終了（納期到達）するまでターン確定を繰り返す。
 * poc-01 の deadline=30。turn > deadline でゲームオーバーになる。
 * リザルト画面が出たら早期に打ち切る。
 */
async function playUntilResult(page: Page, maxTurns = 35): Promise<void> {
  const confirmBtn = page.locator('[data-testid="confirm-turn-btn"]');
  const resultScreen = page.locator('[data-testid="result-screen"]');
  for (let i = 0; i < maxTurns; i++) {
    if (await resultScreen.isVisible()) {
      return;
    }
    if (!(await confirmBtn.isEnabled())) {
      return;
    }
    await confirmBtn.click();
    // ターン移行ローディング（約1秒）を待つ
    await page.waitForTimeout(1200);
  }
}

test.describe("Spec-20: ゲームクリア/失敗のリザルト画面", () => {
  test.beforeEach(async ({ page }) => {
    await startGame(page);
  });

  test("ゲーム未終了のターンではリザルト画面が表示されない", async ({ page }) => {
    // 開始直後（1ターン目）はゲーム終了していない
    await expect(page.locator('[data-testid="result-screen"]')).not.toBeVisible();
    // 1ターン確定してもまだ終了していない（deadline=30）
    await page.locator('[data-testid="confirm-turn-btn"]').click();
    await page.waitForTimeout(1200);
    await expect(page.locator('[data-testid="result-screen"]')).not.toBeVisible();
  });

  test("ゲーム終了後にリザルト画面と成否・利益率が表示される", async ({ page }) => {
    test.setTimeout(90_000);
    await playUntilResult(page);

    const resultScreen = page.locator('[data-testid="result-screen"]');
    await expect(resultScreen).toBeVisible();
    await expect(page.locator('[data-testid="result-outcome"]')).toBeVisible();
    await expect(page.locator('[data-testid="result-reason"]')).toBeVisible();
    await expect(page.locator('[data-testid="result-profit-rate"]')).toBeVisible();
    await expect(page.locator('[data-testid="result-profit"]')).toBeVisible();
    await expect(page.locator('[data-testid="result-stats"]')).toBeVisible();
  });

  test("リザルトからタイトルへ戻ると再びゲームを開始できる", async ({ page }) => {
    test.setTimeout(90_000);
    await playUntilResult(page);
    await expect(page.locator('[data-testid="result-screen"]')).toBeVisible();

    await page.locator('[data-testid="result-back-to-title"]').click();
    // タイトル画面へ遷移する
    await expect(page.locator('[data-testid="title-start-btn"]')).toBeVisible({ timeout: 10_000 });

    // 再開できる（ステージセレクトへ進める）
    await page.locator('[data-testid="title-start-btn"]').click();
    await expect(page.locator('[data-testid="stage-card-poc-01"]')).toBeVisible({
      timeout: 10_000,
    });
  });
});
