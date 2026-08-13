# Tasks: ランダムイベントエンジン（停滞・手戻り本体）

**Input**: Design documents from `specs/008-random-event-engine/`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1〜US5)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: event.ts スケルトン作成

- [x] T001 `src/game/event.ts` を新規作成し、`rollRandomEvents` / `applyEventToProgress` /
  `applyEventToMember` のエクスポート宣言スケルトンを記述する

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 型チェック通過の確認（全 US の前提）

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 `npx tsc --noEmit` でスケルトンの型チェックが 0 エラーであることを確認する

**Checkpoint**: 型チェック通過 → 各 User Story 実装可

---

## Phase 3: User Story 2 - applyEventToProgress（Priority: P2）

**Goal**: progressMap にイベントの影響を反映する純粋関数を実装する

**Independent Test**: `npx vitest run tests/unit/event.test.ts` で
applyEventToProgress の全テストが PASS すること

### Tests for User Story 2 (TDD: 実装前に作成し FAIL を確認)

- [x] T003 [P] [US2] `tests/unit/event.test.ts` に applyEventToProgress のテストを記述する
  - rework イベントで progressMap のデルタが reworkDelta 分変化すること
  - stall イベントで progressMap のデルタが 0 にリセットされること
  - メンバーイベント（sick 等）では progressMap が変化しないこと
  - 引数の Map が変化しないこと（イミュータブル）

### Implementation for User Story 2

- [x] T004 [US2] `src/game/event.ts` に
  `applyEventToProgress(event, progressMap): Map<string, number>` を実装する
  （rework: デルタ加算、stall: 0リセット、その他: そのままコピーして返す）

**Checkpoint**: applyEventToProgress テスト全 PASS → US3 実装可

---

## Phase 4: User Story 3 - applyEventToMember（Priority: P2）

**Goal**: メンバーパラメータにイベントの影響を反映する純粋関数を実装する

**Independent Test**: `npx vitest run tests/unit/event.test.ts` で
applyEventToMember の全テストが PASS すること

### Tests for User Story 3 (TDD: 実装前に作成し FAIL を確認)

- [x] T005 [P] [US3] `tests/unit/event.test.ts` に applyEventToMember のテストを記述する
  - sick イベントで morale -8、health -10 になること
  - low_motivation イベントで morale -10 になること（health 変化なし）
  - fatigue イベントで health -8 になること（morale 変化なし）
  - パラメータが MIN/MAX でクランプされること（health が 0 を下回らない等）
  - タスクイベント（rework 等）ではメンバーが変化しないこと
  - 引数の Member が変化しないこと（イミュータブル）

### Implementation for User Story 3

- [x] T006 [US3] `src/game/event.ts` に
  `applyEventToMember(event, member): Member` を実装する
  （sick/low_motivation/fatigue に対応、MEMBER_PARAMS でクランプ、その他はそのまま返す）

**Checkpoint**: applyEventToMember テスト全 PASS → US1 実装可

---

## Phase 5: User Story 1 - rollRandomEvents（Priority: P1）🎯 MVP

**Goal**: 5種のランダムイベントを独立した確率で判定し GameEvent[] を返す純粋関数を実装する

**Independent Test**: `npx vitest run tests/unit/event.test.ts` で
rollRandomEvents の全テストが PASS すること

### Tests for User Story 1 (TDD: 実装前に作成し FAIL を確認)

- [x] T007 [P] [US1] `tests/unit/event.test.ts` に rollRandomEvents のテストを記述する
  - アクティブタスク0件のとき stall・rework イベントが発生しないこと
  - メンバー0人のとき sick・low_motivation・fatigue イベントが発生しないこと
  - Math.random mock で stall イベントが発生し params.stallTurns が 1 または 2 であること
  - Math.random mock で rework イベントが発生し params.reworkDelta が負値であること
  - Math.random mock で sick イベントが発生し targetId がメンバーIDであること
  - task_event_prob_reduced 効果ありのとき stall 発生率が半減すること
    （大量サンプル確率テスト）

### Implementation for User Story 1

- [x] T008 [US1] `src/game/event.ts` に
  `rollRandomEvents(state, activeEffects): GameEvent[]` を実装する
  - stall / rework: calcEventProbModifier で確率補正→ランダム選択→イベント生成
  - rework: applyRework で reworkDelta を計算して params に格納
  - stall: STALL.ONE_TURN_PROB で stallTurns（1 or 2）を決定して params に格納
  - sick / low_motivation / fatigue: EVENT_PROB で確率判定→メンバーランダム選択→イベント生成

**Checkpoint**: rollRandomEvents テスト全 PASS → US4 実装可

---

## Phase 6: User Story 4 - processTurn イベント統合（Priority: P1）

**Goal**: `processTurn` の Step 5 を `rollRandomEvents` に置き換え、
イベント結果を TurnResult.events に格納し progressMap とメンバーパラメータへ反映する

**Independent Test**: `npx vitest run tests/unit/turn.test.ts` で
イベント統合テストが全 PASS すること

### Tests for User Story 4 (TDD: 実装前に作成し FAIL を確認)

- [x] T009 [P] [US4] `tests/unit/turn.test.ts` にイベント統合テストを追加する
  - Math.random mock で rework イベントが発生し TurnResult.events に含まれること
  - Math.random mock で sick イベントが発生し TurnResult.memberUpdates に
    sick 相当のデルタが含まれること
  - TurnResult.events が GameEvent[] 型であること（型チェック）

### Implementation for User Story 4

- [x] T010 [US4] `src/game/turn.ts` の Step 5（簡易 rework 判定）を完全に削除し、
  `rollRandomEvents(state, currentEffects)` の呼び出しに置き換える
  （`src/game/turn.ts`）
- [x] T011 [US4] `src/game/turn.ts` に `applyEventToProgress` を組み込み、
  rollRandomEvents の結果で progressMap を更新する
  （`src/game/turn.ts`）
- [x] T012 [US4] `src/game/turn.ts` に `applyEventToMember` を組み込み、
  イベント由来の MemberUpdate を生成して eventMemberUpdates に追加する。
  Step 7 で `memberUpdates = [...cardMemberUpdates, ...decayMemberUpdates, ...eventMemberUpdates]`
  として統合する（`src/game/turn.ts`）

**Checkpoint**: processTurn イベント統合テスト全 PASS → US5 実装可

---

## Phase 7: User Story 5 - イミュータブル検証（Priority: P3）

**Goal**: event.ts 全関数・processTurn がイベント関連引数を変更しないことをテストで保証する

**Independent Test**: `npx vitest run tests/unit/event.test.ts tests/unit/turn.test.ts` で
イミュータブルテストが全 PASS すること

### Tests for User Story 5 (TDD: 実装前に作成し FAIL を確認)

- [x] T013 [P] [US5] `tests/unit/event.test.ts` にイミュータブルテストを追加する
  - rollRandomEvents 後に引数 state・activeEffects が変化しないこと
  - applyEventToProgress 後に引数 progressMap が変化しないこと
  - applyEventToMember 後に引数 member が変化しないこと

### Implementation for User Story 5

イミュータブル操作は US1〜US4 の実装が正しければ自然に満たされる。
テストが FAIL した場合のみ event.ts / turn.ts を修正する。

**Checkpoint**: イミュータブルテスト全 PASS → 全 US 完了

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: プロパティテスト・Lint・最終バリデーション

- [x] T014 [P] `tests/unit/event.test.ts` に fast-check プロパティテストを追加する
  （任意の GameState・CardEffect[] で rollRandomEvents が例外なし・GameEvent[] を返す）
- [x] T015 [P] `tests/unit/event.test.ts` に fast-check で applyEventToProgress /
  applyEventToMember のプロパティテストを追加する
  （任意の入力で例外なし・イミュータブル）
- [x] T016 [P] `npx biome check --write src/game/event.ts src/game/turn.ts
  tests/unit/event.test.ts tests/unit/turn.test.ts` でフォーマット適用
- [x] T017 `npx tsc --noEmit` で型チェックが 0 エラーであることを確認する
- [x] T018 `npx vitest run --coverage` で coverage ≥ 80%（lines・functions）を確認する
- [x] T019 [P] `grep -r "phaser\|document\|window" src/game/event.ts` が 0 件であることを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし、即座に開始可
- **Foundational (Phase 2)**: Phase 1 完了後 — 全 US をブロック
- **US2 (Phase 3)**: Foundational 完了後（applyEventToProgress は最もシンプルな関数）
- **US3 (Phase 4)**: Foundational 完了後（US2 と並行可能だが順次推奨）
- **US1 (Phase 5)**: US2・US3 完了後（rollRandomEvents は概念的に US2/US3 に依存）
- **US4 (Phase 6)**: US1・US2・US3 完了後（3関数すべて必要）
- **US5 (Phase 7)**: US1〜US4 完了後
- **Polish (Phase 8)**: 全 US 完了後

### Within Each User Story

- テストを先に書き FAIL を確認 → 実装 → PASS を確認（TDD）
- T003・T005・T007 は [P] = 異なるテスト記述タスクのため並行可
- T013 は [P] = event.ts と turn.ts で異なるファイルのため並行可
- T014・T015・T016・T019 は [P] = 並行可

---

## Implementation Strategy

### MVP First (US2 → US3 → US1 → US4 の順)

1. Phase 1: Setup（スケルトン作成）
2. Phase 2: Foundational（型チェック通過）
3. Phase 3: US2（applyEventToProgress）
4. Phase 4: US3（applyEventToMember）
5. Phase 5: US1（rollRandomEvents）
6. Phase 6: US4（processTurn 統合）
7. **STOP and VALIDATE**: 全テスト PASS を確認

### Incremental Delivery

1. Setup + Foundational → 型環境整備
2. US2 + US3 → 反映関数の単体動作確認
3. US1 → イベント判定の単体動作確認
4. US4 → エンドツーエンド統合確認
5. US5 + Polish → 全品質ゲート通過

---

## Notes

- [P] tasks = different files or independent operations, no blocking deps
- 全処理イミュータブル: 引数を変更せず新しい値を返す
- turn.ts の既存 rework 判定（Step 5）は T010 で **完全削除**する（rollRandomEvents に統合）
- US2・US3 は US1 より先に実装する（シンプルな関数から順に積み上げる）
- Biome format + tsc + vitest coverage を全て通してから /sync-graphdb を実行する
