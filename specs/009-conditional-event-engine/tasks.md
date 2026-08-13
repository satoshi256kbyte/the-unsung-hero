# Tasks: 条件付きイベントエンジン

**Input**: Design documents from `specs/009-conditional-event-engine/`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並行実行可（異なるファイル、依存なし）
- **[Story]**: 対応ユーザーストーリー（US1〜US4）

---

## Phase 1: Setup

**Purpose**: 既存ファイルの確認・実装開始の準備

- [ ] T001 types.ts の ConditionalEvent 型定義を確認する（src/game/types.ts）
- [ ] T002 gantt.ts の getCompletionRate シグネチャを確認する（src/game/gantt.ts）

---

## Phase 2: US1 + US2 — evaluateCondition テスト（TDD: FAILから開始）

**Goal**: evaluateCondition の9パターン全テスト + rollConditionalEvents のテストを先行作成

**Independent Test**: `npm test tests/unit/conditional.test.ts` でテストが FAIL すること（実装前）

> **NOTE: 実装前にテストを書き、FAIL を確認してから実装に進む**

- [ ] T003 [P] [US1] evaluateCondition のテストファイルを作成する（tests/unit/conditional.test.ts）
  - turn 条件 3パターン（>=, <=, ==）
  - completion_rate 条件 2パターン（>=, <）
  - budget_remaining 条件（<=）
  - any_member_morale / any_member_health（<）
  - all_members_morale（<）
  - 未知条件（false を返す）
  - 空文字列（false を返す）
- [ ] T004 [P] [US2] rollConditionalEvents のテストを conditional.test.ts に追加する
  - 条件成立: 1件返る
  - 条件不成立: 空配列
  - turn フィルタ（future turn → スキップ）
  - 複数イベントで2件成立
  - 空配列入力 → 空配列
- [ ] T005 [P] [US4] イミュータブルテストを conditional.test.ts に追加する
  - evaluateCondition 後 GameState が変化しない
  - rollConditionalEvents 後 ConditionalEvent[] が変化しない
- [ ] T006 [P] [US1] fast-check プロパティテストを conditional.test.ts に追加する
  - 任意の条件文字列で例外がスローされない
  - 任意の state で evaluateCondition が boolean を返す

**Checkpoint**: `npm test tests/unit/conditional.test.ts` が全テスト FAIL すること

---

## Phase 3: US1 — evaluateCondition 実装

**Goal**: 9パターンの条件式評価が全テスト PASS する

**Independent Test**: evaluateCondition の全テストが PASS すること

- [ ] T007 [US1] src/game/conditional.ts を新規作成し evaluateCondition を実装する
  - imports: getCompletionRate from "./gantt.js", GameState from "./types.js"
  - completion_rate パターン（>=, <）を正規表現でマッチング
  - turn パターン（>=, <=, ==）を正規表現でマッチング
  - budget_remaining パターン（<=）を正規表現でマッチング
  - any_member_morale パターン（<）を正規表現でマッチング
  - any_member_health パターン（<）を正規表現でマッチング
  - all_members_morale パターン（<）を正規表現でマッチング
  - 未マッチは false を返す

**Checkpoint**: `npm test tests/unit/conditional.test.ts` の evaluateCondition テストが全 PASS

---

## Phase 4: US2 — rollConditionalEvents 実装

**Goal**: 条件成立/不成立・turnフィルタが正しく動作し全テスト PASS する

**Independent Test**: rollConditionalEvents の全テストが PASS すること

- [ ] T008 [US2] rollConditionalEvents を conditional.ts に追加する
  - imports: ConditionalEvent, GameEvent, EventCategory from "./types.js"
  - turn フィルタ: conditionalEvent.turn > state.turn → スキップ
  - evaluateCondition で条件評価
  - GameEvent 生成: id = `conditional-${state.turn}-${ce.id}`
  - category, targetId は ce.params から取り出す
  - 純粋関数（入力を変更しない）

**Checkpoint**: `npm test tests/unit/conditional.test.ts` が全テスト PASS

---

## Phase 5: US3 — processTurn 統合

**Goal**: processTurn に conditionalEvents 引数を追加し既存テストが全 PASS を維持する

**Independent Test**: `npm test tests/unit/turn.test.ts` の全テストが PASS すること

- [ ] T009 [US3] turn.test.ts に条件付きイベント統合テストを追加する（tests/unit/turn.test.ts）
  - 条件成立イベントが TurnResult.events に含まれる
  - 第3引数なし呼び出しで既存テストが全 PASS（後方互換）
  - 空配列渡しでランダムイベントのみが events に含まれる
- [ ] T010 [US3] turn.ts の processTurn シグネチャを更新する（src/game/turn.ts）
  - `conditionalEvents?: ConditionalEvent[]` を第3引数として追加
  - imports に rollConditionalEvents from "./conditional.js" を追加
  - imports に ConditionalEvent from "./types.js" を追加
  - Step 5.5 を追加: `rollConditionalEvents(state, conditionalEvents ?? [])` → events.push(...)

**Checkpoint**: `npm test` で全テストが PASS すること（既存 206 件 + 新規テスト）

---

## Phase 6: US4 — イミュータブル検証

**Goal**: 全関数が入力を変更しないことをテストで確認する

**Independent Test**: イミュータブルテストが全 PASS すること

- [ ] T011 [US4] `npm test tests/unit/conditional.test.ts` でイミュータブルテストが全 PASS することを確認する

**Checkpoint**: 副作用がないことが自動テストで保証されている

---

## Phase 7: Polish

**Purpose**: カバレッジ・型チェック・アーキテクチャ境界チェック

- [ ] T012 `npm run typecheck` でエラー0を確認する
- [ ] T013 `npm run test:coverage` でカバレッジ lines/functions ≥ 80% を確認する
- [ ] T014 Phaser/DOM import がないことを確認する
  - `grep -r "phaser\|document\.\|window\." src/game/conditional.ts && echo VIOLATION || echo OK`
- [ ] T015 `npm run lint` (Biome) でエラー0を確認する

---

## Dependencies & Execution Order

- **Phase 1**: すぐ開始可能
- **Phase 2**: Phase 1 完了後（テストは並行作成可）
- **Phase 3**: Phase 2 完了後（evaluateCondition のテストが FAIL してから実装）
- **Phase 4**: Phase 3 完了後（rollConditionalEvents の依存なし、独立実装可）
- **Phase 5**: Phase 4 完了後（processTurn 統合は conditional.ts 完成後）
- **Phase 6**: Phase 5 完了後（イミュータブルテストは Phase 2 で既に作成済み）
- **Phase 7**: Phase 6 完了後

### Parallel Opportunities

- T003〜T006（テスト作成）は並行作成可
- T007（evaluateCondition）と T008（rollConditionalEvents）は独立関数なので
  Phase 3・4 を同時並行で進めることも可能
- T012〜T015（Polish）は並行実行可

---

## Implementation Strategy

### MVP First (US1 + US2)

1. Phase 1: Setup 確認
2. Phase 2: テスト先行作成（FAIL を確認）
3. Phase 3: evaluateCondition 実装 → PASS
4. Phase 4: rollConditionalEvents 実装 → PASS
5. STOP and VALIDATE: conditional.ts 単体で完結している

### Full Implementation

1. Phase 1〜4 完了後
2. Phase 5: processTurn 統合
3. Phase 6〜7: イミュータブル検証・Polish
