# Tasks: メンバーパラメータ変動エンジン

**Input**: Design documents from `specs/004-member-params-engine/`

**Branch**: `004-member-params-engine`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: ファイルスケルトンの作成

- [ ] T001 `src/game/member.ts` を作成し、imports（constants.ts・types.ts）と export 宣言のスケルトンを記述する

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 依存定数・型の疎通確認

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T002 `src/game/constants.ts` から PARAM_DELTA・MEMBER_PARAMS・EXP・LEVEL_UP_EXP を import できることを
  `npx tsc --noEmit` で確認する
- [ ] T003 `src/game/types.ts` の Member 型を import できることを確認する

**Checkpoint**: スケルトンが型チェック通過 → 各 User Story 実装可

---

## Phase 3: User Story 1 - 毎ターンの心・体が自然変動する (Priority: P1) 🎯 MVP

**Goal**: `applyTurnDecay(member): Member` を実装し、心・体が整数乱数で変動しクランプされることを保証する

**Independent Test**: `npx vitest run tests/unit/member.test.ts` で
applyTurnDecay の境界値テストが全 PASS すること

### Tests for User Story 1 (TDD: 実装前に作成し FAIL を確認)

- [ ] T004 [P] [US1] `tests/unit/member.test.ts` に applyTurnDecay の境界値テストを記述する
  （心=0のクランプ、心=150のクランプ、体=0のクランプ、体=100のクランプ）
- [ ] T005 [P] [US1] `tests/unit/member.test.ts` に applyTurnDecay のイミュータブル確認テストを記述する
  （引数 member のフィールドが変化しないこと）

### Implementation for User Story 1

- [ ] T006 [US1] `src/game/member.ts` に `applyTurnDecay` を実装する
  （`Math.floor(min + (max - min + 1) * Math.random())` で整数乱数、clamp で範囲保証）

**Checkpoint**: applyTurnDecay の全テスト PASS → US2 実装可

---

## Phase 4: User Story 2 - 週末に心・体が自動回復する (Priority: P2)

**Goal**: `applyWeekendRecovery(member): Member` を実装し、週末回復量が正しく適用されることを保証する

**Independent Test**: `npx vitest run tests/unit/member.test.ts` で
applyWeekendRecovery の境界値テストが全 PASS すること

### Tests for User Story 2 (TDD: 実装前に作成し FAIL を確認)

- [ ] T007 [P] [US2] `tests/unit/member.test.ts` に applyWeekendRecovery の境界値テストを記述する
  （心145+8→150クランプ、体95+12→100クランプ、通常回復値の正確性）
- [ ] T008 [P] [US2] `tests/unit/member.test.ts` に applyWeekendRecovery のイミュータブル確認テストを記述する

### Implementation for User Story 2

- [ ] T009 [US2] `src/game/member.ts` に `applyWeekendRecovery` を実装する
  （WEEKEND_MORALE_RECOVERY・WEEKEND_HEALTH_RECOVERY を加算し clamp）

**Checkpoint**: applyWeekendRecovery の全テスト PASS → US3 実装可

---

## Phase 5: User Story 3 - タスク完了時に経験値が付与されレベルアップする (Priority: P3)

**Goal**: `applyExperience(member, expGain): Member` を実装し、
LEVEL_UP_EXP テーブルに基づいたレベルアップ判定が正しく動作することを保証する

**Independent Test**: `npx vitest run tests/unit/member.test.ts` で
applyExperience の境界値テストが全 PASS すること

### Tests for User Story 3 (TDD: 実装前に作成し FAIL を確認)

- [ ] T010 [P] [US3] `tests/unit/member.test.ts` に applyExperience のレベルアップ境界値テストを記述する
  （技8・経験値40+15でレベルアップ確認、技99の上限確認、閾値未満の場合の確認）
- [ ] T011 [P] [US3] `tests/unit/member.test.ts` に applyExperience のイミュータブル確認テストを記述する

### Implementation for User Story 3

- [ ] T012 [US3] `src/game/member.ts` に LEVEL_UP_EXP ルックアップヘルパーを実装する
  （skill 以下で最大の下限行を返す関数、balance.ts の getSkillFactorRange と同パターン）
- [ ] T013 [US3] `src/game/member.ts` に `applyExperience` を実装する
  （expGain 加算 → テーブルルックアップ → 閾値判定 → レベルアップ or 経験値累積）

**Checkpoint**: applyExperience の全テスト PASS → 全 US 実装完了

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: プロパティテスト・Lint・最終バリデーション

- [ ] T014 [P] `tests/unit/member.test.ts` に fast-check プロパティテストを追加する
  （任意の心0〜150×体0〜100×技0〜99×経験値0〜500で全パラメータが範囲内に収まること）
- [ ] T015 [P] `npx biome check --write src/game/member.ts tests/unit/member.test.ts` でフォーマット適用
- [ ] T016 `npx tsc --noEmit` で型チェックが 0 エラーであることを確認する
- [ ] T017 `npx vitest run --coverage` で coverage ≥ 80%（lines・functions）であることを確認する
- [ ] T018 `grep -r "phaser\|document\|window" src/game/member.ts` が 0 件であることを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし、即座に開始可
- **Foundational (Phase 2)**: Phase 1 完了後 — 全 US をブロック
- **US1 (Phase 3)**: Foundational 完了後
- **US2 (Phase 4)**: Foundational 完了後（US1 と並行可能だが、同ファイルのため順次推奨）
- **US3 (Phase 5)**: Foundational 完了後（同上）
- **Polish (Phase 6)**: 全 US 完了後

### Within Each User Story

- テストを先に書き FAIL を確認 → 実装 → PASS を確認（TDD）
- 同一ファイル（member.ts・member.test.ts）のためストーリー間は順次実行

### Parallel Opportunities

- T004・T005 は同時作成可（テスト記述のみ）
- T007・T008 は同時作成可
- T010・T011 は同時作成可
- T014・T015 は並行実行可（Phase 6）

---

## Implementation Strategy

### MVP First (User Story 1 のみ)

1. Phase 1: Setup
2. Phase 2: Foundational
3. Phase 3: US1 (applyTurnDecay)
4. **STOP and VALIDATE**: テスト全 PASS を確認

### Incremental Delivery

1. Setup + Foundational → スケルトン完成
2. US1 → applyTurnDecay 動作確認
3. US2 → applyWeekendRecovery 動作確認
4. US3 → applyExperience 動作確認
5. Polish → 全品質ゲート通過

---

## Notes

- [P] tasks = different files or independent test descriptions, no blocking deps
- 全関数イミュータブル: 戻り値は `{ ...member, field: newValue }` パターン
- 整数乱数: `Math.floor(min + (max - min + 1) * Math.random())`
- LEVEL_UP_EXP ルックアップ: skill 以下で最大の下限行（balance.ts の getSkillFactorRange と同パターン）
- Biome format + tsc + vitest coverage を全て通してから /sync-graphdb を実行する
