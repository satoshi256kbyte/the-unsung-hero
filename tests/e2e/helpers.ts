import type { Page } from "@playwright/test";

/**
 * タイトル→ステージセレクト→確認画面→開始 の一連の遷移を経てMainSceneまで進む。
 */
export async function startGame(page: Page): Promise<void> {
  await page.goto("/");
  await page.waitForSelector('[data-testid="title-start-btn"]', { timeout: 10000 });
  await page.locator('[data-testid="title-start-btn"]').click();
  await page.waitForSelector('[data-testid="stage-card-poc-01"]', { timeout: 10000 });
  await page.locator('[data-testid="stage-card-poc-01"]').click();
  await page.waitForSelector('[data-testid="stage-confirm-start-btn"]', { timeout: 10000 });
  await page.locator('[data-testid="stage-confirm-start-btn"]').click();
  await page.waitForSelector('[data-testid="confirm-turn-btn"]', { timeout: 10000 });
}
