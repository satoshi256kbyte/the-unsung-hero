# Quickstart: ゲーム内ガントチャートUI

**Spec**: [spec.md](./spec.md) | **Date**: 2026-08-30

本フィーチャーが正しく動作することを検証する手順。実装完了後にこの手順で受け入れ確認する。
契約の詳細は [contracts/ui-and-module-contracts.md](./contracts/ui-and-module-contracts.md)、
データ定義は [data-model.md](./data-model.md) を参照。

## 前提

```bash
npm install
docker compose up -d   # ナレッジグラフ（設計参照用、実行検証には必須ではない）
```

## 自動検証（ユニット・型・E2E）

```bash
npx vitest run          # ユニット/プロパティテスト（gantt 実績・稲妻線算出）
npx tsc --noEmit        # 型エラー 0
npx playwright test     # E2E（ガント画面の DOM 検証）
```

期待結果:

- ユニットテスト全 PASS。`src/game/**` のカバレッジが Constitution の閾値
  （lines ≥ 80% / functions ≥ 80% / branches ≥ 75%）を満たす。
- `tsc --noEmit` が 0 で終了する。
- E2E 全 PASS。

## 手動検証（受け入れシナリオ）

```bash
npm run dev
```

表示された URL（既定 <http://localhost:5173>）を開き、タイトル →
ステージセレクト（PoCステージ）→ 確認 → 開始 でメイン画面に入る。

### シナリオ 1: ガント画面の表示切替（US1 / FR-001）

1. メイン画面のメニューで「ガントチャート」（`nav-gantt-btn`）を押す。
2. ガントチャート画面（`gantt-screen`）が表示され、9タスク（t01〜t09）それぞれに
   予定行（`gantt-planned-row-<id>`）と実績行（`gantt-actual-row-<id>`）が並ぶ。
3. ターン列見出し（`gantt-turn-col-<turn>`）がターン1〜30まで「N(曜)」形式で並ぶ。
4. 「ダッシュボード」（`nav-dashboard-btn`）で元の画面に戻れる。

### シナリオ 2: 稲妻線の遅れ/前倒し表示（US1 / FR-006, FR-007 / SC-002）

1. ターンを数回確定して進める。
2. ガント画面を開き、各タスクの稲妻線（`gantt-lightning-line-<id>`）の `data-deviation` を確認する。
   - 進捗が予定より遅れているタスク: `behind`（現在ターン列より左に折れる）
   - 予定より進んでいるタスク: `ahead`（右に折れる）
   - 予定どおり: `ontrack`（折れなし）

### シナリオ 3: 実績行の帯（US2 / FR-004, FR-005 / SC-003）

1. 未着手タスクの実績行に帯が無いことを確認する。
2. 進行中タスクの実績行が実際の着手ターンから現在ターンまで帯で表示されることを確認する。
3. 完了済みタスクの実績行が着手ターンから完了ターンまでで止まることを確認する。

### シナリオ 4: 依存タスクのハイライト（US3 / FR-009, FR-010 / SC-004）

1. 先行タスクを持つタスク（例: t04 は t02・t03 に依存）を選択（`gantt-task-select-t04`）する。
2. 先行タスク（t02・t03）がハイライト（`gantt-dep-highlight-t02` 等）される。
3. 先行タスクを持たないタスク（t01）を選択すると、依存なし表示（`gantt-no-dep-t01`）になる。
4. 別タスクを選択すると、ハイライトが新しい選択に更新される。

### シナリオ 5: スクロールと最終ターン（Edge Cases / FR-011）

1. ターン列が画面に収まらない場合、横スクロールで最終ターン（30）まで閲覧できる。
2. 現在ターンが締切ターン（30）に達しても、稲妻線と各行が破綻せず表示される。

## 検証と Spec の対応

| シナリオ | 対応 User Story / FR / SC |
|---------|--------------------------|
| 1 | US1 / FR-001, FR-002, FR-003, FR-008 / SC-005 |
| 2 | US1 / FR-006, FR-007 / SC-001, SC-002 |
| 3 | US2 / FR-004, FR-005 / SC-003 |
| 4 | US3 / FR-009, FR-010 / SC-004 |
| 5 | Edge Cases / FR-011, FR-012 |
