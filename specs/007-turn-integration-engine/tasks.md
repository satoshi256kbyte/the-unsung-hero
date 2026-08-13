# Tasks: ターン統合エンジン（カード効果 × アクティブ効果管理）

**Input**: Design documents from `specs/007-turn-integration-engine/`

**Branch**: `007-turn-integration-engine`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: 型拡張・定数追加・ファイルスケルトンの作成

- [x] T001 `src/game/types.ts` の `TurnResult` インターフェースに
  `activeEffectsAdded: CardEffect[]` と `activeEffectsAfterTick: CardEffect[]` を追加する
- [x] T002 `src/game/constants.ts` の `EVENT_PROB` に `STALL: 0.05` を追加する
- [x] T003 `src/game/effect.ts` を作成し、`applyEffectTick` と `calcEventProbModifier` の
  エクスポート宣言スケルトンを記述する

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 型チェック通過の確認（全 US の前提）

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 `npx tsc --noEmit` でスケルトンの型チェックが 0 エラーであることを確認する
  （TurnResult 型拡張・constants.ts 追加・effect.ts スケルトンを含む）

**Checkpoint**: 型チェック通過 → 各 User Story 実装可

---

## Phase 3: User Story 2 - applyEffectTick（Priority: P2）🔑 effect.ts 基盤

**Goal**: `applyEffectTick` を実装し、アクティブ効果のライフサイクル管理を完成させる

**Independent Test**: `npx vitest run tests/unit/effect.test.ts` で
applyEffectTick の全テストが PASS すること

### Tests for User Story 2 (TDD: 実装前に作成し FAIL を確認)

- [ ] T005 [P] [US2] `tests/unit/effect.test.ts` に applyEffectTick のテストを記述する
  - remainingTurns=1 の効果が除去されること
  - remainingTurns=3 が remainingTurns=2 にデクリメントされること
  - remainingTurns=null が保持されること
  - 混在効果リストで各ルールが独立して適用されること
  - remainingTurns=0 の効果が即除去されること

### Implementation for User Story 2

- [ ] T006 [US2] `src/game/effect.ts` に `applyEffectTick(effects: CardEffect[]): CardEffect[]`
  を実装する（null 保持・デクリメント・0除去のロジック）

**Checkpoint**: applyEffectTick テスト全 PASS → US3 実装可

---

## Phase 4: User Story 3 - calcEventProbModifier（Priority: P2）

**Goal**: `calcEventProbModifier` を実装し、確率補正計算を完成させる

**Independent Test**: `npx vitest run tests/unit/effect.test.ts` で
calcEventProbModifier の全テストが PASS すること

### Tests for User Story 3 (TDD: 実装前に作成し FAIL を確認)

- [ ] T007 [P] [US3] `tests/unit/effect.test.ts` に calcEventProbModifier のテストを記述する
  - rework_prob_reduced があれば baseProb × 0.5 を返すこと
  - 効果がなければ baseProb をそのまま返すこと
  - task_event_prob_reduced があれば baseProb × 0.5 を返すこと
  - 同 effectType が複数あっても 0.5 倍のみ（重複スタックなし）
  - activeEffects が空配列のとき baseProb をそのまま返すこと

### Implementation for User Story 3

- [ ] T008 [US3] `src/game/effect.ts` に
  `calcEventProbModifier(effects, baseProb, effectType): number` を実装する

**Checkpoint**: calcEventProbModifier テスト全 PASS → US1 実装可

---

## Phase 5: User Story 1 - processTurn カード統合（Priority: P1）🎯 MVP

**Goal**: `processTurn` の `void cards` を実際のカード処理に置き換え、
カード効果・確率補正・TurnResult 拡張フィールドを返すエンドツーエンドパイプラインを完成させる

**Independent Test**: `npx vitest run tests/unit/turn.test.ts` で
カード有りターンのテストが全 PASS すること

### Tests for User Story 1 (TDD: 実装前に作成し FAIL を確認)

- [ ] T009 [P] [US1] `tests/unit/turn.test.ts` にカード統合テストを追加する
  - デイリーカードありのとき activeEffectsAdded に task_event_prob_reduced が含まれること
  - 個別面談カードありのとき memberUpdates に moraleDelta > 0 が含まれること
  - cards=[] のとき activeEffectsAdded が空配列であること
  - activeEffectsAfterTick が TurnResult に含まれること
- [ ] T010 [P] [US1] `tests/unit/turn.test.ts` に確率補正統合テストを追加する
  - レビューカードありのとき手戻りイベント確率が低減されること（Math.random モック使用）

### Implementation for User Story 1

- [ ] T011 [US1] `src/game/turn.ts` の `void cards` を削除し、以下のフローを実装する:
  1. `applyCards(state, cards)` 呼び出し
  2. `currentEffects = [...state.activeEffects, ...effectsToAdd]`
  3. 手戻りイベント判定に `calcEventProbModifier` 適用
  4. `applyEffectTick(currentEffects)` で tick
  5. `TurnResult` に `activeEffectsAdded` / `activeEffectsAfterTick` を追加して返す
- [ ] T012 [US1] カード由来 `MemberUpdate[]` とターン decay 由来 `MemberUpdate[]` を
  統合して `memberUpdates` として返す（`src/game/turn.ts`）

**Checkpoint**: processTurn カード統合テスト全 PASS → US4 実装可

---

## Phase 6: User Story 4 - イミュータブル検証（Priority: P3）

**Goal**: effect.ts 全関数・processTurn が引数を変更しないことをテストで保証する

**Independent Test**: `npx vitest run tests/unit/effect.test.ts tests/unit/turn.test.ts` で
イミュータブルテストが全 PASS すること

### Tests for User Story 4 (TDD: 実装前に作成し FAIL を確認)

- [ ] T013 [P] [US4] `tests/unit/effect.test.ts` にイミュータブルテストを追加する
  - applyEffectTick 呼び出し後に引数 effects 配列の参照・値が変化しないこと
- [ ] T014 [P] [US4] `tests/unit/turn.test.ts` にイミュータブルテストを追加する
  - processTurn 呼び出し後に state.activeEffects・state.members が変化しないこと

### Implementation for User Story 4

イミュータブル操作は US1〜US3 の実装が正しければ自然に満たされる。
テストが FAIL した場合のみ effect.ts / turn.ts を修正する。

**Checkpoint**: イミュータブルテスト全 PASS → 全 US 完了

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: プロパティテスト・Lint・最終バリデーション

- [ ] T015 [P] `tests/unit/effect.test.ts` に fast-check プロパティテストを追加する
  （任意の CardEffect[] で applyEffectTick が例外なし・イミュータブル・
  remainingTurns が null か ≥0 の整数になること）
- [ ] T016 [P] `tests/unit/effect.test.ts` に calcEventProbModifier の fast-check テストを追加する
  （任意の effects・baseProb で例外なし・戻り値が有限数・0 < result ≤ baseProb になること）
- [ ] T017 [P] `npx biome check --write src/game/effect.ts src/game/turn.ts
  tests/unit/effect.test.ts tests/unit/turn.test.ts` でフォーマット適用
- [ ] T018 `npx tsc --noEmit` で型チェックが 0 エラーであることを確認する
- [ ] T019 `npx vitest run --coverage` で coverage ≥ 80%（lines・functions）を確認する
- [ ] T020 `grep -r "phaser\|document\|window" src/game/effect.ts` が 0 件であることを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし、即座に開始可
- **Foundational (Phase 2)**: Phase 1 完了後 — 全 US をブロック
- **US2 (Phase 3)**: Foundational 完了後（effect.ts 基盤として US3 より先）
- **US3 (Phase 4)**: US2 完了後（同ファイル effect.ts の順次推奨）
- **US1 (Phase 5)**: US2・US3 完了後（effect.ts の 2 関数が必要）
- **US4 (Phase 6)**: US1〜US3 完了後
- **Polish (Phase 7)**: 全 US 完了後

### Within Each User Story

- テストを先に書き FAIL を確認 → 実装 → PASS を確認（TDD）
- T005・T007・T009・T010 は [P] = 異なるテスト記述タスクのため並行可
- T013・T014 は [P] = 異なるファイルのため並行可
- T015・T016・T017 は [P] = 並行可

---

## Implementation Strategy

### MVP First (US2 → US3 → US1 の順)

1. Phase 1: Setup（型拡張・定数追加・スケルトン）
2. Phase 2: Foundational（型チェック通過）
3. Phase 3: US2（applyEffectTick）
4. Phase 4: US3（calcEventProbModifier）
5. Phase 5: US1（processTurn 統合）
6. **STOP and VALIDATE**: 全テスト PASS を確認

### Incremental Delivery

1. Setup + Foundational → 型環境整備
2. US2 → effect tick の単体動作確認
3. US3 → 確率補正の単体動作確認
4. US1 → エンドツーエンド統合確認
5. US4 + Polish → 全品質ゲート通過

---

## Notes

- [P] tasks = different test descriptions or independent functions, no blocking deps
- 全処理イミュータブル: state を変更せず TurnResult（差分）を返す
- US2・US3 を US1 より先に実装する（effect.ts が turn.ts の依存モジュールのため）
- TurnResult 型拡張後、既存 turn.test.ts が型エラーになる可能性あり → T004 で事前確認
- Biome format + tsc + vitest coverage を全て通してから /sync-graphdb を実行する
