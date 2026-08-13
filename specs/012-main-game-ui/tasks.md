# Tasks: メイン画面UI

**Input**: Design documents from `/specs/012-main-game-ui/`

**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

**Organization**: フェーズ別・ユーザーストーリー別。実装ファイル 6 件 + E2E テスト 3 件。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並行実行可能（異なるファイル・依存なし）
- **[Story]**: 対応するユーザーストーリー（US1/US2/US3）

---

## Phase 1: Setup（ファイル骨格作成）

**Purpose**: ディレクトリ作成と空ファイルの骨格を用意する

- [X] T001 Create `src/ui/pmTerms.ts` with PM terminology array (15 entries)
- [X] T002 [P] Create `src/ui/MainGameUI.ts` with class skeleton and `render(state: GameState)` stub
- [X] T003 [P] Create `src/ui/CardSlot.ts` with class skeleton
- [X] T004 [P] Create `src/ui/LoadingScreen.ts` with class skeleton
- [X] T005 [P] Create `src/scenes/MainScene.ts` as Phaser.Scene subclass skeleton

---

## Phase 2: Foundational（共通基盤）

**Purpose**: 全ユーザーストーリーが依存する共通実装

**⚠️ CRITICAL**: Phase 1 完了後に実施。US1〜US3 はこの Phase 完了後に開始できる

- [X] T006 Implement `pmTerms.ts` — 15件の `{ name: string; description: string }` 配列を定義する
  in `src/ui/pmTerms.ts`
- [X] T007 Implement `LoadingScreen` class in `src/ui/LoadingScreen.ts`
  — `el`・`termEl` フィールド、`show()` / `hide()` メソッド、
  `show()` 時に pmTerms からランダム選択して表示
- [X] T008 Implement `MainScene.create()` in `src/scenes/MainScene.ts`
  — `GameEngine(pocStage)` 生成・`#ui-overlay` div 取得・`MainGameUI` インスタンス生成・初期 `render()` 呼び出し
- [X] T009 Register `MainScene` in `src/main.ts` — scene 配列に `MainScene` を追加

**Checkpoint**: `npm run dev` でブラウザ起動し、空の UI 骨格が表示される

---

## Phase 3: User Story 1 - ダッシュボードでゲーム状態を確認できる (Priority: P1) 🎯 MVP

**Goal**: `GameState` をダッシュボードに正しく表示する（ヘッダー・KPI・メンバーステータス・手札）

**Independent Test**: `[data-testid="header-turn"]` に「ターン 1」、
`[data-testid="member-alice-skill"]` に「12」、手札カードが表示される
（`tests/e2e/dashboard.spec.ts` PASS）

- [X] T010 [US1] Implement header area in `src/ui/MainGameUI.ts`
  — `data-testid="header-turn"` 要素にターン番号と残りターン数を表示
- [X] T011 [P] [US1] Implement KPI area in `src/ui/MainGameUI.ts`
  — `data-testid="kpi-profit"` / `kpi-profit-rate"` / `kpi-spi"` / `kpi-cpi"` /
  `kpi-transparency"` / `kpi-tension"` を render() で更新
- [X] T012 [P] [US1] Implement member status area in `src/ui/MainGameUI.ts`
  — `data-testid="member-{id}"` / `member-{id}-skill"` / `member-{id}-morale"` /
  `member-{id}-health"` を render() で更新
- [X] T013 [P] [US1] Implement hand display in `src/ui/MainGameUI.ts`
  — `data-testid="hand-card-{name}"` 要素を hand 配列から生成
- [X] T014 [US1] Write E2E test `tests/e2e/dashboard.spec.ts`
  — US1 Acceptance Scenarios を Playwright で実装（contracts/ui-contracts.md 参照）

**Checkpoint**: `npx playwright test tests/e2e/dashboard.spec.ts` PASS

---

## Phase 4: User Story 2 - カード枠でターンのアクションを組み立てられる (Priority: P2)

**Goal**: 手札からカードをスロットに配置・除去し、8コスト制限が機能する

**Independent Test**: ドラッグ＆ドロップでスロットに配置でき、
`data-occupied="true"` になり合計コストが更新される
（`tests/e2e/card-slot.spec.ts` PASS）

- [X] T015 [US2] Implement `CardSlot` class in `src/ui/CardSlot.ts`
  — `el`・`card`・`cost` フィールド、`data-occupied` / `data-card` / `data-blocked` 属性管理
- [X] T016 [US2] Implement card slot area in `src/ui/MainGameUI.ts`
  — `card-slot-{n}` スロット 8 枠を生成・`total-cost` 表示・合計コスト計算と上限チェック
- [X] T017 [US2] Implement HTML5 drag events on hand cards and slots in `src/ui/MainGameUI.ts`
  — `draggable="true"` + `dragstart` / `dragover` (preventDefault) / `drop` ハンドラ
- [X] T018 [US2] Implement confirm turn button in `src/ui/MainGameUI.ts`
  — `data-testid="confirm-turn-btn"` ボタン、クリック時に `getPlacedCards()` を返すコールバック
- [X] T019 [US2] Connect confirm turn button to `MainScene.confirmTurn()` in `src/scenes/MainScene.ts`
  — `Promise.all([Promise.resolve(engine.processTurn(cards)), sleep(1000)])` パターンで実装
- [X] T020 [US2] Write E2E test `tests/e2e/card-slot.spec.ts`
  — US2 Acceptance Scenarios を Playwright で実装（drag-and-drop・コスト制限）

**Checkpoint**: `npx playwright test tests/e2e/card-slot.spec.ts` PASS

---

## Phase 5: User Story 3 - ターン確定後にターン移行ロード画面が表示される (Priority: P3)

**Goal**: ターン確定→ロード画面（最低1秒・PM用語表示）→次ターン更新のフローが完成する

**Independent Test**: ターン確定後に `loading-screen` が表示され、PM用語テキストが存在し、
ターン番号が更新される（`tests/e2e/turn-cycle.spec.ts` PASS）

- [X] T021 [US3] Wire `LoadingScreen.show()/hide()` into `MainScene.confirmTurn()` in
  `src/scenes/MainScene.ts`
  — show → Promise.all → ui.render → hide の順で呼び出す
- [X] T022 [US3] Handle game over state in `src/ui/MainGameUI.ts`
  — `isGameOver === true` のとき `confirm-turn-btn` を `disabled` にする
- [X] T023 [US3] Write E2E test `tests/e2e/turn-cycle.spec.ts`
  — US3 Acceptance Scenarios を Playwright で実装（ローディング最低1秒・ターン番号更新）

**Checkpoint**: `npx playwright test tests/e2e/turn-cycle.spec.ts` PASS

---

## Phase 6: Polish & 検証

**Purpose**: 型チェック・E2E 全件・回帰テスト・アーキテクチャ確認・トークンログ

- [ ] T024 [P] Run `npx tsc --noEmit` and confirm 0 type errors
- [ ] T025 [P] Run `npx playwright test` and confirm all E2E tests PASS
- [ ] T026 [P] Run `npx vitest run` and confirm existing 291 unit tests PASS (no regression)
- [ ] T027 Verify architecture boundaries: confirm `src/ui/` has no Phaser imports
  (`grep -r "from 'phaser'" src/ui/` returns nothing)
- [ ] T028 Append Spec-12 token log rows to `docs/sdd-token-log.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし・即開始可能
- **Foundational (Phase 2)**: Phase 1 完了後
- **US1 (Phase 3)**: Phase 2 完了後
- **US2 (Phase 4)**: Phase 2 完了後（US1 と並行可）
- **US3 (Phase 5)**: Phase 4 完了後（T019 の confirmTurn が必要）
- **Polish (Phase 6)**: Phase 3〜5 完了後

### User Story Dependencies

- **US1**: Phase 2 後に開始可。MVPスコープ
- **US2**: Phase 2 後に開始可。US1 と並行可
- **US3**: US2 の confirmTurn 実装（T019）完了後

### Within Each User Story

- UI コンポーネント実装 → E2E テスト の順
- T011・T012・T013 は同一ファイルへの追加だが独立した render() ブロックのため並行可

---

## Parallel Example: Phase 1 Setup

```bash
# T002〜T005 は並行実行可（異なるファイル）
Task: "Create src/ui/MainGameUI.ts skeleton"
Task: "Create src/ui/CardSlot.ts skeleton"
Task: "Create src/ui/LoadingScreen.ts skeleton"
Task: "Create src/scenes/MainScene.ts skeleton"
```

## Parallel Example: US1 Phase

```bash
# T011・T012・T013 は render() への追加なので並行作業可
Task: "Implement KPI area (kpi-profit etc.)"
Task: "Implement member status area (member-alice etc.)"
Task: "Implement hand display (hand-card-{name})"
```

---

## Implementation Strategy

### MVP First（US1のみ）

1. Phase 1 + Phase 2: ファイル骨格・基盤
2. Phase 3 (US1): ダッシュボード表示 → `dashboard.spec.ts` PASS
3. **STOP and VALIDATE**: ブラウザで初期画面を確認

### Incremental Delivery

1. Phase 1 + 2 + US1 → ダッシュボード表示 → MVP
2. US2 → カード枠操作 → ゲームプレイ可能
3. US3 → ターン移行フロー完成 → ゲームループ完結
4. Polish → 全テスト GREEN

---

## Notes

- `src/ui/` は Phaser import 禁止（Constitution 原則 I）
- `src/scenes/` が `src/ui/` と `src/game/` の両方を import して協調する
- SPI・CPI は初期実装では `GameState` に存在しないため `0` or `N/A` 表示で代替可
  （GameState 拡張は別 Spec スコープ）
- カードの `.interactive` クラス付与を忘れると drag events が `pointer-events: none` でブロックされる
