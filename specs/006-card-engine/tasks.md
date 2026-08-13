# Tasks: カード効果エンジン

**Input**: Design documents from `specs/006-card-engine/`

**Branch**: `006-card-engine`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: ファイルスケルトンの作成

- [ ] T001 `src/game/card.ts` を作成し、`CardApplicationResult` インターフェースと
  `applyCards` のエクスポート宣言スケルトンを記述する

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 依存モジュールの疎通確認

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T002 `npx tsc --noEmit` でスケルトンの型チェックが 0 エラーであることを確認する

**Checkpoint**: スケルトンが型チェック通過 → 各 User Story 実装可

---

## Phase 3: User Story 1 - 確率低減カードが activeEffects に記録される (Priority: P1) 🎯 MVP

**Goal**: デイリー・レビュー・モニタリングを処理し、対応する effectType の CardEffect を
effectsToAdd として返すことを保証する

**Independent Test**: `npx vitest run tests/unit/card.test.ts` で
確率低減カード3種のテストが全 PASS すること

### Tests for User Story 1 (TDD: 実装前に作成し FAIL を確認)

- [ ] T003 [P] [US1] `tests/unit/card.test.ts` に確率低減カードのテストを記述する
  （デイリー→`task_event_prob_reduced` / レビュー→`rework_prob_reduced` /
  モニタリング→`overreport_prob_reduced` が effectsToAdd に含まれること）
- [ ] T004 [P] [US1] `tests/unit/card.test.ts` に effectsToAdd のフィールド値テストを記述する
  （targetId='project'・remainingTurns=null であること）
- [ ] T005 [P] [US1] `tests/unit/card.test.ts` に空配列テストを記述する
  （空の cards 配列のとき effectsToAdd と memberUpdates がどちらも空配列であること）

### Implementation for User Story 1

- [ ] T006 [US1] `src/game/card.ts` にデイリー・レビュー・モニタリングの
  確率低減処理を実装する（switch-case で effectsToAdd にプッシュ）

**Checkpoint**: 確率低減カードの全テスト PASS → US2 実装可

---

## Phase 4: User Story 2 - 即時メンバー系カードが memberUpdates として返される (Priority: P2)

**Goal**: 個別面談・表彰・計画休を処理し、対象メンバーの moraleDelta / healthDelta を
memberUpdates として返すことを保証する

**Independent Test**: `npx vitest run tests/unit/card.test.ts` で
即時メンバー系カード3種のテストが全 PASS すること

### Tests for User Story 2 (TDD: 実装前に作成し FAIL を確認)

- [ ] T007 [P] [US2] `tests/unit/card.test.ts` に個別面談・表彰・計画休のテストを記述する
  （moraleDelta / healthDelta が PARAM_DELTA の定数値と一致すること）
- [ ] T008 [P] [US2] `tests/unit/card.test.ts` にメンバー 0 人テストを記述する
  （members が空のとき memberUpdates が空配列でパニックしないこと）
- [ ] T009 [P] [US2] `tests/unit/card.test.ts` にスコープ外カードの無視テストを記述する
  （納期交渉・スコープ交渉などを渡しても effectsToAdd / memberUpdates が空であること）

### Implementation for User Story 2

- [ ] T010 [US2] `src/game/card.ts` に個別面談・表彰・計画休の即時メンバー処理を実装する
  （state.members[0] を対象、0 人のときはスキップ）

**Checkpoint**: 即時メンバー系テスト全 PASS → US3 実装可

---

## Phase 5: User Story 3 - 引数の GameState が変化しない (Priority: P3)

**Goal**: applyCards を呼び出した後も state.members / state.activeEffects が
変化しないことを保証する（イミュータブル操作）

**Independent Test**: `npx vitest run tests/unit/card.test.ts` で
イミュータブル確認テストが全 PASS すること

### Tests for User Story 3 (TDD: 実装前に作成し FAIL を確認)

- [ ] T011 [P] [US3] `tests/unit/card.test.ts` に state.members 不変テストを記述する
  （applyCards 呼び出し後に state.members の参照・値が変化しないこと）
- [ ] T012 [P] [US3] `tests/unit/card.test.ts` に state.activeEffects 不変テストを記述する
  （applyCards 呼び出し後に state.activeEffects の参照・値が変化しないこと）

### Implementation for User Story 3

イミュータブル操作は Phase 3・4 の実装が正しければ自然に満たされる。
テストが FAIL した場合のみ card.ts を修正する。

**Checkpoint**: イミュータブルテスト全 PASS → 全 US 実装完了

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: プロパティテスト・Lint・最終バリデーション

- [ ] T013 [P] `tests/unit/card.test.ts` に fast-check プロパティテストを追加する
  （任意の合法 GameState・CardName[] で applyCards を呼んでも例外なし・
  moraleDelta/healthDelta が有限数・GameState が変化しない）
- [ ] T014 [P] `npx biome check --write src/game/card.ts tests/unit/card.test.ts`
  でフォーマット適用
- [ ] T015 `npx tsc --noEmit` で型チェックが 0 エラーであることを確認する
- [ ] T016 `npx vitest run --coverage` で coverage ≥ 80%（lines・functions）であることを確認する
- [ ] T017 `grep -r "phaser\|document\|window" src/game/card.ts` が 0 件であることを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし、即座に開始可
- **Foundational (Phase 2)**: Phase 1 完了後 — 全 US をブロック
- **US1 (Phase 3)**: Foundational 完了後
- **US2 (Phase 4)**: US1 完了後（同ファイルのため順次推奨）
- **US3 (Phase 5)**: US1・US2 完了後（同ファイルのため順次推奨）
- **Polish (Phase 6)**: 全 US 完了後

### Within Each User Story

- テストを先に書き FAIL を確認 → 実装 → PASS を確認（TDD）
- 同一ファイル（card.ts・card.test.ts）のためストーリー間は順次実行

### Parallel Opportunities

- T003・T004・T005 は同時作成可（テスト記述のみ）
- T007・T008・T009 は同時作成可
- T011・T012 は同時作成可
- T013・T014 は並行実行可（Phase 6）

---

## Implementation Strategy

### MVP First (User Story 1 のみ)

1. Phase 1: Setup
2. Phase 2: Foundational
3. Phase 3: US1（確率低減カード3種）
4. **STOP and VALIDATE**: テスト全 PASS を確認

### Incremental Delivery

1. Setup + Foundational → スケルトン完成
2. US1 → 確率低減カード動作確認
3. US2 → 即時メンバー系動作確認
4. US3 → イミュータブル確認
5. Polish → 全品質ゲート通過

---

## Notes

- [P] tasks = different test descriptions or independent functions, no blocking deps
- 全処理イミュータブル: state を変更せず CardApplicationResult（差分）を返す
- CardApplicationResult は card.ts のローカル export 型（types.ts には追加しない）
- Biome format + tsc + vitest coverage を全て通してから /sync-graphdb を実行する
