# Tasks: PoCステージデータ

**Input**: Design documents from `/specs/011-poc-stage-data/`

**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, quickstart.md ✓

**Organization**: フェーズ別・ユーザーストーリー別に整理。実装ファイル2件のみ。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並行実行可能（異なるファイル・依存なし）
- **[Story]**: 対応するユーザーストーリー（US1/US2/US3）

---

## Phase 1: Setup（ファイル骨格作成）

**Purpose**: 実装・テストファイルの骨格を作成する

- [X] T001 Create `src/game/stages/pocStage.ts` with StageData import and empty export stub
- [X] T002 [P] Create `tests/unit/stages/pocStage.test.ts` with GameEngine/pocStage import skeleton

---

## Phase 2: User Story 1 - PoCステージで GameEngine を初期化できる (Priority: P1) 🎯 MVP

**Goal**: `pocStage` 定数を完全実装し、`new GameEngine(pocStage)` が期待する初期状態を返す

**Independent Test**: `new GameEngine(pocStage)` が例外なく生成でき、`getState()` が
`turn=1 / members=3 / budget=5_000_000 / deadline=22 / hand=3枚 / gantt.tasks=9件` を返す

- [X] T003 [US1] Write failing US1 tests in `tests/unit/stages/pocStage.test.ts`
  (初期化・turn・members数・budget・deadline・hand枚数・gantt.tasks数)
- [X] T004 [US1] Implement full pocStage constant in `src/game/stages/pocStage.ts`
  (id/name/budget/deadline + initialMembers 3名 + initialGantt 9タスク +
  conditionalEvents 5件 + initialCards 3枚 + ganttVariants:{})

**Checkpoint**: `new GameEngine(pocStage)` が例外なく動作しUS1テストが全PASS

---

## Phase 3: User Story 2 - ガントチャートタスクが PoC の工程を正しく表現する (Priority: P2)

**Goal**: 全タスクが deadline 以内に収まり、依存関係に循環がなく、assignedMemberId が一致する

**Independent Test**: `startTurn + duration <= 22`・循環依存なし・`assignedMemberId` 一致の
3条件が全タスクで成立する

- [X] T005 [P] [US2] Write US2 deadline constraint tests in `tests/unit/stages/pocStage.test.ts`
  (全タスク startTurn + duration <= deadline=22)
- [X] T006 [P] [US2] Write US2 dependency integrity tests in `tests/unit/stages/pocStage.test.ts`
  (assignedMemberId が initialMembers に存在する・dependencies 参照先が有効)

**Checkpoint**: US2テストが全PASS（pocStage実装変更なしで通過することを確認）

---

## Phase 4: User Story 3 - 条件付きイベントが適切な条件で発火する (Priority: P3)

**Goal**: 全条件付きイベントの condition 文字列が `evaluateCondition` の9パターンに適合し、
22ターン進行で発火することを確認する

**Independent Test**: 各 `conditionalEvents[i].condition` が正規表現パターンにマッチし、
`evaluateCondition` が期待値を返す

- [X] T007 [US3] Write US3 condition pattern validation tests in `tests/unit/stages/pocStage.test.ts`
  (全5件の condition が evaluateCondition の9パターンのいずれかに一致する)
- [X] T008 [US3] Write US3 22-turn integration test in `tests/unit/stages/pocStage.test.ts`
  (GameEngine で22ターン processTurn([]) を例外なく完走できる)

**Checkpoint**: US3テストが全PASS

---

## Phase 5: Polish & 検証

**Purpose**: 型チェック・カバレッジゲート・トークンログの確認

- [X] T009 [P] Run `npx tsc --noEmit` and confirm 0 type errors
- [X] T010 [P] Run `npx vitest run --coverage` and verify coverage gates
  (src/game/\*\*: lines ≥ 80%, functions ≥ 80%, branches ≥ 75%)
- [X] T011 Append Spec-11 token log row to `docs/sdd-token-log.md`
  (Spec番号・コマンド名・日付・inputトークン・outputトークン・メモ)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし・即開始可能
- **US1 (Phase 2)**: Phase 1 完了後。T003（テスト）→ T004（実装）の順
- **US2 (Phase 3)**: Phase 2 完了後。T005・T006 は並行実行可
- **US3 (Phase 4)**: Phase 2 完了後（Phase 3 と並行も可）
- **Polish (Phase 5)**: Phase 2〜4 完了後

### User Story Dependencies

- **US1**: Phase 1 後に開始可。MVPスコープ
- **US2**: US1 完了後（pocStage実装が前提）
- **US3**: US1 完了後（pocStage実装が前提）。US2 と並行実行可

### Within Each User Story

- テストを先に書き FAIL を確認してから実装する（TDD）
- US2・US3 のテストは pocStage が実装済みであれば追加テストのみ

---

## Parallel Example: Setup Phase

```bash
# T001 と T002 は並行実行可（異なるファイル）
Task: "Create src/game/stages/pocStage.ts stub"
Task: "Create tests/unit/stages/pocStage.test.ts skeleton"
```

## Parallel Example: US2 Phase

```bash
# T005 と T006 は並行実行可（同一ファイルへの追記だが独立したdescribeブロック）
Task: "US2 deadline constraint tests"
Task: "US2 dependency integrity tests"
```

---

## Implementation Strategy

### MVP First（US1のみ）

1. Phase 1: T001・T002（骨格作成）
2. Phase 2: T003（テスト先行）→ T004（実装）→ US1テスト全PASS
3. **STOP and VALIDATE**: `npx vitest run` でUS1テスト確認
4. MVP完成

### Incremental Delivery

1. Phase 1 + US1 → GameEngine初期化動作 → MVP確認
2. US2テスト追加 → ガントデータの整合性検証
3. US3テスト追加 → 条件付きイベント動作確認
4. Polish → 型チェック・カバレッジ確認

---

## Notes

- `src/game/stages/` ディレクトリは新規作成（既存コード変更なし）
- `tests/unit/stages/` ディレクトリも新規作成
- pocStage は単一の定数オブジェクト。US2・US3 は追加テストのみで実装変更不要
- `waiting` ステータスは型定義に存在しないため全タスク初期値は `"active"` を使用
- conditionalEvents の condition は evaluateCondition の9パターンから選択
