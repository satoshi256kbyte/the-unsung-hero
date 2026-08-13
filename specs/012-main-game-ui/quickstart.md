# Quickstart Validation Guide: メイン画面UI

Phase 1 output for Spec-12

## Prerequisites

- Node.js 20+ インストール済み
- `npm install` 完了済み
- Playwright ブラウザ: `npx playwright install chromium`

## 開発サーバー起動

```sh
npm run dev
# → http://localhost:5173
```

## E2E テスト実行

```sh
# 全 E2E テスト
npx playwright test

# 特定ファイルのみ
npx playwright test tests/e2e/dashboard.spec.ts

# UI モードで確認
npx playwright test --ui
```

## 型チェック

```sh
npx tsc --noEmit
```

## 検証シナリオ

### シナリオ 1: ダッシュボード初期表示（SC-001・US1）

```sh
npx playwright test tests/e2e/dashboard.spec.ts
```

期待値:

- `[data-testid="header-turn"]` に「ターン 1」が含まれる
- `[data-testid="member-alice-skill"]` に「12」が含まれる
- `[data-testid="kpi-profit"]` が表示されている
- `[data-testid="hand-card-デイリー"]` が存在する

### シナリオ 2: カード枠操作（SC-002・US2）

```sh
npx playwright test tests/e2e/card-slot.spec.ts
```

期待値:

- 手札カードをスロットにドラッグ＆ドロップすると `data-occupied="true"` になる
- 合計コストが更新される
- 8 コスト超過のドロップが `data-blocked="true"` でブロックされる

### シナリオ 3: ターン確定・ロード画面（SC-003・US3）

```sh
npx playwright test tests/e2e/turn-cycle.spec.ts
```

期待値:

- ターン確定後に `[data-testid="loading-screen"]` が表示される
- `[data-testid="pm-term-text"]` にテキストが存在する
- 1 秒以上後にターン番号が「ターン 2」に更新される
- ローディング画面が非表示になる

## 期待する結果

| テスト | 期待値 |
|---|---|
| `npx playwright test` | 全 E2E テスト PASS |
| `npx tsc --noEmit` | エラー 0 |
| `npx vitest run` | 既存ユニットテスト 291 件 PASS（回帰なし） |
| Architecture 確認 | `src/ui/` に Phaser import がないこと |
