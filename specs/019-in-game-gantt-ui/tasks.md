---
description: "Task list for ゲーム内ガントチャートUI"
---

# Tasks: ゲーム内ガントチャートUI

**Input**: Design documents from `/specs/019-in-game-gantt-ui/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: 本プロジェクトは Constitution 原則 II（テストカバレッジゲート）によりテスト必須。
`src/game/**` はユニット/プロパティテスト（Vitest + fast-check）、`src/ui/**` は Playwright
E2E で検証する。したがってテストタスクを含める。

**Organization**: タスクは User Story ごとにグループ化し、各ストーリーを独立して実装・
テストできるようにする。US1（P1）が MVP。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並列実行可能（別ファイル・未完了タスクに依存しない）
- **[Story]**: US1 / US2 / US3（spec.md のユーザーストーリーに対応）
- 各タスクに正確なファイルパスを記載する

## Path Conventions

- `src/game/` ロジック層（Phaser/DOM 非依存）、`src/ui/` DOM 層、`src/scenes/` Phaser 層
- テスト: `src/game/**` に隣接する `*.test.ts`（Vitest）、`tests/e2e/*.spec.ts`（Playwright）

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 本フィーチャー着手の前提確認（新規プロジェクト初期化は不要。既存リポジトリに追加）

- [X] T001 `public/data/stages/poc-01.json` の現行 gantt タスク（t01〜t09、startTurn/duration/
      dependencies）と `deadline`=30 を確認し、実績フィールドが未記載であることを確認する
- [X] T002 `src/game/calendar.ts` の `dayOfWeek`/`isWeekend` の契約（0=月〜6=日、土日=5,6）を
      確認し、ターン軸の曜日表示に流用できることを確認する

**Checkpoint**: 既存データ・契約の把握完了。Foundational に着手できる

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 全ユーザーストーリーが依存するデータモデル・ロジックの基盤

**⚠️ CRITICAL**: このフェーズ完了まで US1〜US3 の実装は開始できない

- [X] T003 [P] `src/game/types.ts` の `GanttTask` に `actualStartTurn: number | null` と
      `actualEndTurn: number | null` を追加する（data-model.md 準拠）
- [X] T004 [P] `src/game/schemas/stageData.ts` の `ganttTaskSchema` に実績2フィールドを
      optional（`.nullable().optional()`）で追加し、ロード時に既定値 null を補完する
- [X] T005 `src/game/engine.ts` の `GameEngine.processTurn` のタスク更新時に実績を記録する:
      progress が 0→正 に増えたターンで `actualStartTurn` が null なら現在ターンを設定、
      progress が 100 到達ターンで `actualEndTurn` が null なら現在ターンを設定する
      （T003 に依存）
- [X] T006 [P] `src/game/engine.test.ts` に実績記録のユニットテストを追加する:
      未着手→着手（actualStartTurn 設定）、進行→完了（actualEndTurn 設定）、
      stalled で actualStartTurn 不変、着手なしに完了しない不変条件（fast-check）
- [X] T007 [P] `src/game/gantt.ts` に稲妻線算出の純関数を追加する:
      `plannedRate(task, currentTurn)`・`progressDeviation(task, currentTurn)`・
      `actualPosition(task)`（research.md Decision 3・contracts 準拠、DOM/Phaser 非依存）
- [X] T008 [P] `src/game/gantt.test.ts` に稲妻線算出のユニット/プロパティテストを追加する:
      plannedRate が 0〜100 にクランプされる、遅れ/前倒し/予定どおりで deviation の符号が
      正しい、actualPosition が startTurn〜startTurn+duration の範囲に収まる（fast-check）
- [X] T009 `src/game/gantt.ts` に、リスケ（ganttVariants 差し替え）時に同一 task id の実績
      （actualStartTurn/actualEndTurn）を引き継ぐ処理を追加する（`applyVariant` 拡張または
      補助関数、research.md Decision 4 準拠）（T003 に依存）
- [X] T010 [P] `src/game/gantt.test.ts` に、リスケ差し替え時に同一 id の実績が引き継がれ、
      消えた id は破棄・新規 id は null になることを検証するテストを追加する

**Checkpoint**: 実績データと稲妻線算出ロジックが揃い、`src/game/**` のテストが全 PASS。
UI 層（US1〜US3）に着手できる

---

## Phase 3: User Story 1 - 予定と実績を見比べて遅れを把握する (Priority: P1) 🎯 MVP

**Goal**: メニューからガントチャート画面へ切り替え、各タスクの予定行・実績行の2行と
現在ターンの稲妻線を表示し、遅れ/前倒しを一目で読み取れるようにする

**Independent Test**: ガント画面を開くと9タスクに予定行・実績行の2行が並び、ターン列見出しが
1〜30まで「N(曜)」形式で表示され、数ターン進めると遅れタスクの稲妻線が左（behind）、
前倒しが右（ahead）、予定どおりが折れなし（ontrack）になることを確認できる

### Implementation for User Story 1

- [X] T011 [US1] `src/ui/GanttChartUI.ts` を新規作成し、`constructor(container)`・
      `render(state)`・`show()`・`hide()` を実装する（DOM overlay、Phaser 非使用、閲覧専用）。
      ルートに `data-testid="gantt-screen"` を付与する（contracts 準拠）
- [X] T012 [US1] `GanttChartUI.render` でターン軸の列見出し（ターン1〜`state.deadline`）を
      `data-testid="gantt-turn-col-<turn>"` で描画し、`dayOfWeek` を用いて「N(曜)」形式にする。
      土日列は淡色で区別する（FR-008、research.md Decision 6）
- [X] T013 [US1] `GanttChartUI.render` で各タスクに予定行
      （`gantt-planned-row-<id>` / `gantt-planned-cell-<id>-<turn>`）を描画する。
      帯範囲は startTurn〜startTurn+duration-1（data-model.md）（FR-002, FR-003）
- [X] T014 [US1] `GanttChartUI.render` で各タスクに実績行
      （`gantt-actual-row-<id>` / `gantt-actual-cell-<id>-<turn>`）を描画する。
      帯範囲は actualStartTurn〜（完了は actualEndTurn、進行中は現在ターン、未着手は帯なし）
      （FR-004）
- [X] T015 [US1] `GanttChartUI.render` で各タスク行に稲妻線
      （`gantt-lightning-line-<id>`、`data-deviation` = ahead/behind/ontrack）を、
      `progressDeviation`/`actualPosition` を用いて現在ターン列基準で描画する（FR-006, FR-007）
- [X] T016 [P] [US1] `src/ui/MainGameUI.ts` にメニューを追加する:
      `data-testid="nav-gantt-btn"`（ガント画面を開く）と `data-testid="nav-dashboard-btn"`
      （ダッシュボードへ戻る）。既存 render/getPlacedCards/setOnConfirm/reset のシグネチャは不変
- [X] T017 [US1] `src/scenes/MainScene.ts` で `GanttChartUI` を生成し、`nav-gantt-btn`/
      `nav-dashboard-btn` で MainGameUI とガント画面の表示/非表示をトグルする配線を追加する。
      ターン確定後に開くと最新 state が反映されるよう、開くたびに `render(state)` する
      （FR-001, FR-012）（T011, T016 に依存）
- [X] T018 [US1] `tests/e2e/gantt.spec.ts` を新規作成し、`startGame(page)` 後に
      nav-gantt-btn で gantt-screen が表示され、予定行/実績行の2行とターン列見出し（1〜30、
      曜日形式）が並ぶこと、nav-dashboard-btn で戻れることを検証する（quickstart シナリオ1）
- [X] T019 [US1] `tests/e2e/gantt.spec.ts` に、数ターン進めた後の稲妻線の `data-deviation`
      （behind/ahead/ontrack）が進捗状態と一致することを検証する E2E を追加する
      （quickstart シナリオ2、SC-001, SC-002）

**Checkpoint**: US1 が独立して機能・テスト可能（MVP 完成）。予定/実績2行＋稲妻線＋画面切替が動く

---

## Phase 4: User Story 2 - タスクの実績（着手・完了の時期）を確認する (Priority: P2)

**Goal**: 実績行を見て、各タスクが実際にいつ着手・完了したかを予定と対比して確認できる

**Independent Test**: 数ターン進めて着手・完了させたあと、実績行が実際の着手ターンから始まり、
完了済みタスクは完了ターンで止まり、未着手は帯なしであることを予定行と対比して確認できる

### Implementation for User Story 2

- [X] T020 [US2] `src/ui/GanttChartUI.ts` の実績行描画（T014）を、未着手（actualStartTurn=null）
      は帯なし、進行中は着手ターン〜現在ターン、完了は着手ターン〜完了ターンで止める3状態を
      明確に区別するよう仕上げる（FR-004, FR-005）
- [X] T021 [US2] `tests/e2e/gantt.spec.ts` に、未着手（帯なし）・進行中（着手〜現在）・
      完了（着手〜完了で停止）の3状態の実績行を検証する E2E を追加する
      （quickstart シナリオ3、SC-003）

**Checkpoint**: US1・US2 が独立して機能。実績行の帯が実状態と一致する

---

## Phase 5: User Story 3 - タスクの依存関係（先行タスク）をたどる (Priority: P3)

**Goal**: ガント画面でタスクを選択すると、その先行タスク（依存）を視覚的に確認できる
（独立 PERT ビューは持たない）

**Independent Test**: 先行タスクを持つタスク（例 t04→t02,t03）を選択すると先行タスクが
ハイライトされ、先行なしタスク（t01）は依存なし表示になり、別タスク選択で更新される

### Implementation for User Story 3

- [X] T022 [US3] `src/ui/GanttChartUI.ts` にタスク選択（`gantt-task-select-<id>`）を実装し、
      選択タスクの `dependencies` を辿って先行タスクを `gantt-dep-highlight-<id>` でハイライト
      する。先行なしは `gantt-no-dep-<id>` を表示する（FR-009）
- [X] T023 [US3] `src/ui/GanttChartUI.ts` で、別タスクを選択したときにハイライト表示を
      新しい選択に更新する（前の選択のハイライトを解除する）（FR-010）
- [X] T024 [US3] `tests/e2e/gantt.spec.ts` に、先行タスクありのハイライト・先行なしの表示・
      選択切替でのハイライト更新を検証する E2E を追加する（quickstart シナリオ4、SC-004）

**Checkpoint**: US1〜US3 すべて独立して機能する

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 全ストーリーに関わる仕上げと検証

- [X] T025 [US1] `src/ui/GanttChartUI.ts` のスクロール対応を仕上げる: ターン列が収まらない場合の
      横スクロール、タスクが多い場合の縦スクロール、締切ターン（30）到達時の稲妻線・行の
      非破綻を確認する（Edge Cases, FR-011）
- [X] T026 [P] `tests/e2e/gantt.spec.ts` に、最終ターン（30）でのガント画面の非破綻と
      スクロール可能性を検証する E2E を追加する（quickstart シナリオ5）
- [X] T027 `npx tsc --noEmit` で型エラー 0、`npx vitest run` で `src/game/**` カバレッジが
      閾値（lines≥80/functions≥80/branches≥75）を満たすこと、`npx playwright test` で E2E 全
      PASS を確認する
- [X] T028 `npm run lint:md` と Biome lint/format でエラー 0 を確認する
- [X] T029 `quickstart.md` の手動検証シナリオ1〜5を実施し、受け入れ基準（SC-001〜SC-005）を
      満たすことを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし。即着手可
- **Foundational (Phase 2)**: Setup 完了後。全ユーザーストーリーをブロックする
- **User Stories (Phase 3-5)**: Foundational 完了後に着手可。US1→US2→US3 の優先順で進める
  （US2/US3 は US1 が実装した `GanttChartUI` に描画を追加するため、実質 US1 に続けて行う）
- **Polish (Phase 6)**: 対象ストーリー完了後

### User Story Dependencies

- **US1 (P1)**: Foundational 完了後に着手可。他ストーリーに依存しない（MVP）
- **US2 (P2)**: Foundational 完了後に着手可。実績行の仕上げは US1 の GanttChartUI 上で行う
- **US3 (P3)**: Foundational 完了後に着手可。依存表示は US1 の GanttChartUI 上で行う

### Within Each User Story

- テストは実装対象の振る舞いを検証する。ロジック（Phase 2）はテストを先に用意して FAIL を
  確認してから実装するとよい（TDD 推奨、必須ではない）
- ロジック（gantt.ts/engine.ts）→ UI（GanttChartUI）→ シーン配線（MainScene）→ E2E の順

### Parallel Opportunities

- T003・T004（types/schema）は別ファイルのため並列可
- T006・T007・T008・T010（テスト・純関数）は別ファイル/独立ロジックのため並列可
- T016（MainGameUI メニュー）は GanttChartUI 本体（T011〜T015）と別ファイルのため並列可
- US2・US3 は同一ファイル（GanttChartUI）を編集するため、US1 完了後に逐次実施する

---

## Parallel Example: Phase 2 Foundational

```bash
# 別ファイル・独立ロジックのタスクを並列実行:
Task: "T003 GanttTask に実績フィールド追加 in src/game/types.ts"
Task: "T004 ganttTaskSchema に実績フィールド追加 in src/game/schemas/stageData.ts"
Task: "T007 稲妻線算出の純関数 in src/game/gantt.ts"
Task: "T008 稲妻線算出のテスト in src/game/gantt.test.ts"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1 Setup を完了
2. Phase 2 Foundational を完了（実績データ・稲妻線ロジック＋テスト）
3. Phase 3 US1 を完了（予定/実績2行＋稲妻線＋画面切替）
4. **STOP and VALIDATE**: US1 を独立テスト（quickstart シナリオ1・2）
5. デモ可能な MVP として成立

### Incremental Delivery

1. Setup + Foundational → 基盤完成
2. US1 → 独立テスト → MVP（予定/実績/稲妻線/画面切替）
3. US2 → 実績行の3状態を仕上げ → 独立テスト
4. US3 → 依存ハイライト → 独立テスト
5. Polish → スクロール・全ゲート確認・quickstart 検証

---

## Notes

- [P] = 別ファイル・依存なしで並列実行可能
- [Story] ラベルはトレーサビリティのためタスクをユーザーストーリーに対応づける
- 数値バランス（進捗ダイス・確率・コスト）は本フィーチャーで変更しない（Constitution III）
- `src/game/` は Phaser/DOM を import しない（Constitution I）
- 各タスクまたは論理単位ごとにコミットする
