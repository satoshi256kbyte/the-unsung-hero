import { expect, test } from "@playwright/test";

test.describe("US2: 起動時にJSONの内容を検証する", () => {
  test("正常系: 全JSONが正しい場合はPreloadSceneを経てゲームが開始される", async ({ page }) => {
    await page.goto("/");
    await page.waitForSelector('[data-testid="confirm-turn-btn"]', { timeout: 10000 });
    await expect(page.locator('[data-testid="confirm-turn-btn"]')).toBeVisible();
  });

  test("異常系: 必須フィールドが欠落したJSONの場合はゲームが開始されない", async ({ page }) => {
    // 実ファイルを書き換えると他のE2Eテスト（別ワーカーで並列実行される開発サーバーを
    // 共有している）とレースするため、このページのリクエストだけをインターセプトして
    // 不正なJSONを返す。ディスク上のファイルには一切触れない。
    await page.route("**/data/cards/daily.json", (route) => {
      route.fulfill({ status: 200, contentType: "application/json", body: "{}" });
    });

    const pageErrors: string[] = [];
    page.on("pageerror", (error) => {
      pageErrors.push(error.message);
    });

    await page.goto("/");
    await page
      .waitForSelector('[data-testid="confirm-turn-btn"]', { timeout: 3000 })
      .catch(() => undefined);

    await expect(page.locator('[data-testid="confirm-turn-btn"]')).not.toBeVisible();
    expect(pageErrors.length).toBeGreaterThan(0);
  });
});
