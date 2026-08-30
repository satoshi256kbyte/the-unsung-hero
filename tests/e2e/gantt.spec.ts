import { expect, test } from "@playwright/test";
import { startGame } from "./helpers.js";

/** ターンを指定回数確定して進める（ローディング完了を待つ） */
async function advanceTurns(page: import("@playwright/test").Page, times: number): Promise<void> {
  for (let i = 0; i < times; i++) {
    await page.locator('[data-testid="confirm-turn-btn"]').click();
    await page.locator('[data-testid="loading-screen"]').waitFor({
      state: "hidden",
      timeout: 5000,
    });
  }
}

async function openGantt(page: import("@playwright/test").Page): Promise<void> {
  await page.locator('[data-testid="nav-gantt-btn"]').click();
  await page.locator('[data-testid="gantt-screen"]').waitFor({ state: "visible", timeout: 5000 });
}

test.describe("Spec-18 US1: ガントチャート画面の表示と稲妻線", () => {
  test.beforeEach(async ({ page }) => {
    await startGame(page);
  });

  test("メニューからガント画面を開き、ダッシュボードへ戻れる", async ({ page }) => {
    await openGantt(page);
    await expect(page.locator('[data-testid="gantt-screen"]')).toBeVisible();

    await page.locator('[data-testid="nav-dashboard-btn"]').click();
    await expect(page.locator('[data-testid="gantt-screen"]')).toBeHidden();
  });

  test("各タスクに予定行と実績行の2行が表示される", async ({ page }) => {
    await openGantt(page);
    // t01 は poc-01 の最初のタスク
    await expect(page.locator('[data-testid="gantt-planned-row-t01"]')).toBeVisible();
    await expect(page.locator('[data-testid="gantt-actual-row-t01"]')).toBeVisible();
    await expect(page.locator('[data-testid="gantt-task-row-t09"]')).toBeVisible();
  });

  test("ターン列見出しが1〜deadlineまで曜日付きで並ぶ", async ({ page }) => {
    await openGantt(page);
    // ターン1は月曜、ターン6は土曜
    await expect(page.locator('[data-testid="gantt-turn-col-1"]')).toContainText("1(月)");
    await expect(page.locator('[data-testid="gantt-turn-col-6"]')).toContainText("6(土)");
    await expect(page.locator('[data-testid="gantt-turn-col-30"]')).toContainText("30");
  });

  test("予定行はタスク期間内のセルが帯として塗られる", async ({ page }) => {
    await openGantt(page);
    // t01: startTurn1 duration3 → ターン1〜3が in-band
    await expect(page.locator('[data-testid="gantt-planned-cell-t01-1"]')).toHaveAttribute(
      "data-in-band",
      "true",
    );
    await expect(page.locator('[data-testid="gantt-planned-cell-t01-3"]')).toHaveAttribute(
      "data-in-band",
      "true",
    );
    await expect(page.locator('[data-testid="gantt-planned-cell-t01-10"]')).toHaveAttribute(
      "data-in-band",
      "false",
    );
  });

  test("数ターン進めると稲妻線に deviation 属性が付く", async ({ page }) => {
    await advanceTurns(page, 3);
    await openGantt(page);

    const line = page.locator('[data-testid="gantt-lightning-line-t01"]');
    await expect(line).toHaveCount(1);
    const deviation = await line.getAttribute("data-deviation");
    expect(["ahead", "behind", "ontrack"]).toContain(deviation);
  });
});

test.describe("Spec-18 US2: 実績行（着手・完了の時期）", () => {
  test.beforeEach(async ({ page }) => {
    await startGame(page);
  });

  test("未着手タスク（終盤のt09）の実績行は帯が無い", async ({ page }) => {
    await openGantt(page);
    // t09 は startTurn18。開始直後（turn1）は未着手なので実績帯なし
    const cell1 = page.locator('[data-testid="gantt-actual-cell-t09-1"]');
    await expect(cell1).toHaveAttribute("data-in-band", "false");
    const cell18 = page.locator('[data-testid="gantt-actual-cell-t09-18"]');
    await expect(cell18).toHaveAttribute("data-in-band", "false");
  });

  test("数ターン進めると着手済みタスクの実績行に帯が現れる", async ({ page }) => {
    await advanceTurns(page, 3);
    await openGantt(page);
    // t01 は turn1 から稼働。着手済みなら実績行のターン1が in-band
    const cell1 = page.locator('[data-testid="gantt-actual-cell-t01-1"]');
    await expect(cell1).toHaveAttribute("data-in-band", "true");
  });
});

test.describe("Spec-18 US3: 依存タスク（先行タスク）の表示", () => {
  test.beforeEach(async ({ page }) => {
    await startGame(page);
  });

  test("先行タスクを持つタスクを選択すると先行タスクがハイライトされる", async ({ page }) => {
    await openGantt(page);
    // t04 は t02・t03 に依存
    await page.locator('[data-testid="gantt-task-select-t04"]').click();
    await expect(page.locator('[data-testid="gantt-dep-highlight-t02"]')).toBeVisible();
    await expect(page.locator('[data-testid="gantt-dep-highlight-t03"]')).toBeVisible();
  });

  test("先行タスクを持たないタスクは依存なし表示になる", async ({ page }) => {
    await openGantt(page);
    // t01 は依存なし
    await page.locator('[data-testid="gantt-task-select-t01"]').click();
    await expect(page.locator('[data-testid="gantt-no-dep-t01"]')).toBeVisible();
  });

  test("別タスクを選択すると依存表示が更新される", async ({ page }) => {
    await openGantt(page);
    await page.locator('[data-testid="gantt-task-select-t04"]').click();
    await expect(page.locator('[data-testid="gantt-dep-highlight-t02"]')).toBeVisible();

    // t05 は t02 のみに依存 → t03 のハイライトは消える
    await page.locator('[data-testid="gantt-task-select-t05"]').click();
    await expect(page.locator('[data-testid="gantt-dep-highlight-t02"]')).toBeVisible();
    await expect(page.locator('[data-testid="gantt-dep-highlight-t03"]')).toHaveCount(0);
  });
});

test.describe("Spec-18 Polish: スクロールと最終ターン", () => {
  test.beforeEach(async ({ page }) => {
    await startGame(page);
  });

  test("スクロール領域が存在し、最終ターン列(30)が描画される", async ({ page }) => {
    await openGantt(page);
    const scroll = page.locator('[data-testid="gantt-scroll"]');
    await expect(scroll).toBeVisible();
    // 最終ターン列が DOM 上に存在する（横スクロールで到達可能）
    await expect(page.locator('[data-testid="gantt-turn-col-30"]')).toHaveCount(1);
  });

  test("最終ターン列でも稲妻線・行が破綻せず表示される", async ({ page }) => {
    await openGantt(page);
    // 全タスクの行が存在し、稲妻線も各タスクに1本ずつ
    await expect(page.locator('[data-testid="gantt-task-row-t01"]')).toBeVisible();
    await expect(page.locator('[data-testid="gantt-lightning-line-t09"]')).toHaveCount(1);
    await expect(page.locator('[data-testid="gantt-planned-cell-t09-30"]')).toHaveCount(1);
  });
});
