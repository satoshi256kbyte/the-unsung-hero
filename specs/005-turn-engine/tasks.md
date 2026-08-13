# Tasks: ターン処理エンジン

**Input**: Design documents from `specs/005-turn-engine/`

**Branch**: `005-turn-engine`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: ファイルスケルトンの作成

- [x] T001 `src/game/turn.ts` を作成し、imports（constants.ts・types.ts・gantt.ts・dice.ts・member.ts）と
  export 宣言のスケルトンを記述する

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 依存モジュールの疎通確認

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 `npx tsc --noEmit` でスケルトンの型チェックが 0 エラーであることを確認する

**Checkpoint**: スケルトンが型チェック通過 → 各 User Story 実装可

---

## Phase 3: User Story 1 - 1ターンの基本処理が実行される (Priority: P1) 🎯 MVP

**Goal**: `processTurn(state, cards): TurnResult` を実装し、進捗ダイス・パラメータ変動・手戻りが
正しく TurnResult に格納されることを保証する

**Independent Test**: `npx vitest run tests/unit/turn.test.ts` で
基本ターン処理のテストが全 PASS すること

### Tests for User Story 1 (TDD: 実装前に作成し FAIL を確認)

- [x] T003 [P] [US1] `tests/unit/turn.test.ts` に基本ターン処理のテストを記述する
  （progressUpdates に担当タスクの delta が含まれること、memberUpdates に全メンバーが含まれること）
- [x] T004 [P] [US1] `tests/unit/turn.test.ts` にイミュータブル確認テストを記述する
  （呼び出し後に state.turn / state.members / state.gantt.tasks が変化しないこと）
- [x] T005 [P] [US1] `tests/unit/turn.test.ts` に手戻りイベント関連テストを記述する
  （active タスクが 0 件のとき手戻りが発生しないこと）

### Implementation for User Story 1

- [x] T006 [US1] `src/game/turn.ts` に進捗ダイス処理を実装する
  （各メンバーの active 担当タスクに rollProgress の結果を ProgressUpdate として記録）
- [x] T007 [US1] `src/game/turn.ts` にパラメータ変動処理を実装する
  （applyTurnDecay を全メンバーに適用し MemberUpdate を記録）
- [x] T008 [US1] `src/game/turn.ts` に手戻りイベント判定を実装する
  （EVENT_PROB.REWORK の確率で active タスクにランダム applyRework を適用）
- [x] T009 [US1] `src/game/turn.ts` にコスト計算を実装する
  （costDelta = POC_STAGE.DAILY_COST_CAP × members.length）

**Checkpoint**: 基本ターン処理の全テスト PASS → US2 実装可

---

## Phase 4: User Story 2 - 5ターンごとに週末回復が適用される (Priority: P2)

**Goal**: `turn % 5 === 0` のターンで applyWeekendRecovery が適用され、
MemberUpdate の healthDelta が通常より大きくなることを保証する

**Independent Test**: `npx vitest run tests/unit/turn.test.ts` で
turn=5 のとき週末回復テストが PASS すること

### Tests for User Story 2 (TDD: 実装前に作成し FAIL を確認)

- [x] T010 [P] [US2] `tests/unit/turn.test.ts` に週末回復テストを記述する
  （turn=5 のとき healthDelta が通常の自然低下より大きいこと）
- [x] T011 [P] [US2] `tests/unit/turn.test.ts` に週末非発動テストを記述する
  （turn=4 のとき週末回復が適用されないこと）

### Implementation for User Story 2

- [x] T012 [US2] `src/game/turn.ts` にパラメータ変動処理へ週末判定を追加する
  （turn % 5 === 0 のとき applyWeekendRecovery も適用し MemberUpdate に加算）

**Checkpoint**: 週末回復テスト全 PASS → US3 実装可

---

## Phase 5: User Story 3 - ゲームオーバー条件が判定される (Priority: P3)

**Goal**: 全タスク完了または turn > deadline のとき TurnResult.isGameOver = true が返されることを保証する

**Independent Test**: `npx vitest run tests/unit/turn.test.ts` で
ゲームオーバー条件テストが全 PASS すること

### Tests for User Story 3 (TDD: 実装前に作成し FAIL を確認)

- [x] T013 [P] [US3] `tests/unit/turn.test.ts` に全タスク完了ゲームオーバーテストを記述する
  （全タスク status='done' の状態で processTurn を呼ぶと isGameOver=true になること）
- [x] T014 [P] [US3] `tests/unit/turn.test.ts` に納期超過ゲームオーバーテストを記述する
  （turn > deadline の状態で isGameOver=true になること）
- [x] T015 [P] [US3] `tests/unit/turn.test.ts` に継続中テストを記述する
  （タスク未完了かつ turn <= deadline のとき isGameOver=false になること）

### Implementation for User Story 3

- [x] T016 [US3] `src/game/turn.ts` にゲームオーバー判定を実装する
  （progressUpdates 適用後の仮想ガントで getCompletionRate >= 1.0、または turn > deadline を評価）

**Checkpoint**: ゲームオーバー判定テスト全 PASS → 全 US 実装完了

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: プロパティテスト・Lint・最終バリデーション

- [x] T017 [P] `tests/unit/turn.test.ts` に fast-check プロパティテストを追加する
  （任意の合法 GameState で processTurn を呼んでも例外なし・isGameOver が boolean・delta が有限数）
- [x] T018 [P] `npx biome check --write src/game/turn.ts tests/unit/turn.test.ts` でフォーマット適用
- [x] T019 `npx tsc --noEmit` で型チェックが 0 エラーであることを確認する
- [x] T020 `npx vitest run --coverage` で coverage ≥ 80%（lines・functions）であることを確認する
- [x] T021 `grep -r "phaser\|document\|window" src/game/turn.ts` が 0 件であることを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし、即座に開始可
- **Foundational (Phase 2)**: Phase 1 完了後 — 全 US をブロック
- **US1 (Phase 3)**: Foundational 完了後
- **US2 (Phase 4)**: US1 完了後（同ファイルのため順次推奨）
- **US3 (Phase 5)**: US1 完了後（US2 と並行可能だが同ファイルのため順次推奨）
- **Polish (Phase 6)**: 全 US 完了後

### Within Each User Story

- テストを先に書き FAIL を確認 → 実装 → PASS を確認（TDD）
- 同一ファイル（turn.ts・turn.test.ts）のためストーリー間は順次実行

### Parallel Opportunities

- T003・T004・T005 は同時作成可（テスト記述のみ）
- T006・T007・T008・T009 は US1 テスト作成後に並行実装可（同ファイル内の独立関数）
- T010・T011 は同時作成可
- T013・T014・T015 は同時作成可
- T017・T018 は並行実行可（Phase 6）

---

## Implementation Strategy

### MVP First (User Story 1 のみ)

1. Phase 1: Setup
2. Phase 2: Foundational
3. Phase 3: US1（基本ターン処理）
4. **STOP and VALIDATE**: テスト全 PASS を確認

### Incremental Delivery

1. Setup + Foundational → スケルトン完成
2. US1 → 進捗ダイス・パラメータ変動・手戻り動作確認
3. US2 → 週末回復動作確認
4. US3 → ゲームオーバー判定動作確認
5. Polish → 全品質ゲート通過

---

## Notes

- [P] tasks = different test descriptions or independent functions, no blocking deps
- 全処理イミュータブル: state を変更せず TurnResult（差分）を返す
- ゲームオーバー判定: progressUpdates を仮適用した仮想ガントで getCompletionRate を評価
- 手戻りターゲット: active タスクが 0 件の場合はスキップ
- Biome format + tsc + vitest coverage を全て通してから /sync-graphdb を実行する
