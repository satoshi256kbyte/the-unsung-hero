# Tasks: ガントチャート・タスクモデル

**Input**: Design documents from `specs/002-gantt-task-model/`

**Prerequisites**: plan.md ✅, spec.md ✅, data-model.md ✅, quickstart.md ✅

---

## Phase 1: Setup

**Purpose**: `src/game/gantt.ts` と `tests/unit/gantt.test.ts` のファイル骨格を確認する

- [ ] T001 `src/game/gantt.ts` を作成し、`src/game/types.ts` と `src/game/constants.ts` の
  import 宣言のみを記述して `npm run typecheck` がエラーゼロで通ることを確認する

---

## Phase 2: User Story 1 — タスクの進捗を更新できる (P1)

**Goal**: `updateTaskProgress` を実装し、0〜100クランプと `done` 自動遷移を確認する。

**Independent Test**: `npm test` で `gantt.test.ts` の US1 テストが全 PASS すること。

- [ ] T002 [US1] `updateTaskProgress(task, delta): GanttTask` を `src/game/gantt.ts` に実装する
  （進捗 = clamp(progress + delta, 0, 100)、100 到達で status → `done`）
- [ ] T003 [US1] `tests/unit/gantt.test.ts` を作成し `updateTaskProgress` の境界値テストを実装する
  （進捗 0→+20、80→+30、100→+10、+マイナス delta のクランプ）
- [ ] T004 [US1] fast-check プロパティテストを追加する
  （任意の progress 0〜100・delta -50〜50 で結果が 0〜100 に収まる）
- [ ] T005 [US1] `npm test` を実行して US1 テスト全 PASS を確認する

**Checkpoint**: T005 通過で User Story 1 完了。進捗更新が型安全・境界値安全な状態。

---

## Phase 3: User Story 2 — タスクの状態を遷移できる (P2)

**Goal**: `setTaskStatus` と `applyRework` を実装し、状態遷移と手戻り計算を確認する。

**Independent Test**: `npm test` で `gantt.test.ts` の US2 テストが全 PASS すること。

- [ ] T006 [P] [US2] `setTaskStatus(task, status): GanttTask` を `src/game/gantt.ts` に実装する
- [ ] T007 [P] [US2] `applyRework(task, skill): GanttTask` を `src/game/gantt.ts` に実装する
  （巻き戻し率 = REWORK.ROLLBACK_BASE − skill × REWORK.ROLLBACK_COEFF、progress を減算後クランプ）
- [ ] T008 [US2] `setTaskStatus` のテストを `gantt.test.ts` に追加する
  （active→stalled、stalled→active、active→done の各遷移）
- [ ] T009 [US2] `applyRework` の境界値テストを `gantt.test.ts` に追加する
  （技 0 / 10 / 99 の各巻き戻し率・progress 0 のクランプ確認）
- [ ] T010 [US2] fast-check プロパティテストを追加する
  （任意の技 0〜99・progress 0〜100 で applyRework がパニックせず 0〜100 を返す）
- [ ] T011 [US2] `npm test` を実行して US2 テスト全 PASS を確認する

**Checkpoint**: T011 通過で User Story 2 完了。状態遷移・手戻りが仕様通り動作する状態。

---

## Phase 4: User Story 3 — バリアントへ切り替えられる (P3)

**Goal**: `getCompletionRate` と `applyVariant` を実装し、完了率計算とバリアント差し替えを確認する。

**Independent Test**: `npm test` で `gantt.test.ts` の US3 テストが全 PASS すること。

- [ ] T012 [P] [US3] `getCompletionRate(gantt): number` を `src/game/gantt.ts` に実装する
  （done タスク数 ÷ 全タスク数、タスク 0 件は 0.0）
- [ ] T013 [P] [US3] `applyVariant(gantt, variantId, variants): GanttChart` を
  `src/game/gantt.ts` に実装する
  （variantId が存在する場合は差し替え・存在しない場合は元の gantt を返す）
- [ ] T014 [US3] `getCompletionRate` のテストを `gantt.test.ts` に追加する
  （全完了・部分完了・全未完了・タスク 0 件の各ケース）
- [ ] T015 [US3] `applyVariant` のテストを `gantt.test.ts` に追加する
  （存在するID→差し替え確認、存在しないID→元の gantt 保持確認）
- [ ] T016 [US3] `npm test` を実行して US3 テスト全 PASS を確認する

**Checkpoint**: T016 通過で User Story 3 完了。バリアント切り替えが安全に動作する状態。

---

## Phase 5: Polish

- [ ] T017 quickstart.md の全検証コマンド（typecheck / test / Phaser依存なし / DOM依存なし）を
  実行して全項目クリアを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: 即時開始可能
- **Phase 2 (US1)**: Phase 1 完了後
- **Phase 3 (US2)**: Phase 2 完了後（`src/game/gantt.ts` が存在する必要がある）。T006/T007 は並列実行可
- **Phase 4 (US3)**: Phase 3 完了後。T012/T013 は並列実行可
- **Phase 5 (Polish)**: 全フェーズ完了後

### Parallel Opportunities

```
Phase 3:
  T006 (setTaskStatus)
  T007 (applyRework)
    ↓ 完了後
  T008〜T011 (テスト・確認)

Phase 4:
  T012 (getCompletionRate)
  T013 (applyVariant)
    ↓ 完了後
  T014〜T016 (テスト・確認)
```

---

## Implementation Strategy

### MVP (US1 のみ)

1. T001: Setup
2. T002〜T005: `updateTaskProgress` + テスト
3. → **Stop and validate**: Spec-05 が進捗更新を呼び出せる状態

### Full Delivery (全 US)

1. MVP 完了後、T006〜T011 で状態遷移・手戻り
2. T012〜T016 で完了率・バリアント切り替え
3. T017 で全体検証

---

## Notes

- [P] タスク = 同フェーズ内で依存なし・並列実行可
- [USn] ラベル = 対応するユーザーストーリー
- 全関数はイミュータブル操作（引数を変更せず新オブジェクトを返す）
- `tsc --noEmit` は各フェーズ末に実行してエラーゼロを確認する
