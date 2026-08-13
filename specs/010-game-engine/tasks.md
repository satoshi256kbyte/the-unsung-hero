# Tasks: GameEngine（フルターンループ）

**Input**: Design documents from `specs/010-game-engine/`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並行実行可（異なるファイル、依存なし）
- **[Story]**: 対応ユーザーストーリー（US1〜US4）

---

## Phase 1: Setup

**Purpose**: 既存依存の確認

- [ ] T001 types.ts の StageData / GameState フィールドを確認する（src/game/types.ts）
- [ ] T002 gantt.ts の updateTaskProgress / setTaskStatus シグネチャを確認する（src/game/gantt.ts）
- [ ] T003 constants.ts の MEMBER_PARAMS 境界値を確認する（src/game/constants.ts）

---

## Phase 2: US1 + US2 + US3 — テスト先行作成（TDD: FAILから開始）

**Goal**: GameEngine の初期化・ターン処理・ゲーム終了のテストを先行作成

**Independent Test**: `npm test tests/unit/engine.test.ts` でテストが FAIL すること（実装前）

> **NOTE: 実装前にテストを書き、FAIL を確認してから実装に進む**

- [ ] T004 [P] [US1] 初期化テストを作成する（tests/unit/engine.test.ts）
  - getState().turn === 1
  - getState().members が stageData.initialMembers と一致
  - getState().gantt が stageData.initialGantt と一致
  - getState().budget が stageData.budget と一致
  - isGameOver() が false
  - getState().totalCost === 0
- [ ] T005 [P] [US2] ターン処理テストを engine.test.ts に追加する
  - processTurn([]) 後に turn が 2 になる
  - processTurn([]) 後に totalCost が増加する
  - processTurn([]) が TurnResult を返す
  - アクティブタスクの進捗が更新される
  - メンバーの morale/health が変化する（decay）
- [ ] T006 [P] [US3] ゲーム終了テストを engine.test.ts に追加する
  - 納期超過でゲームオーバーになる
  - ゲームオーバー後の processTurn が例外をスローする
  - ゲームオーバー後 isGameOver() が true
  - 全タスク完了でゲームオーバーになる
- [ ] T007 [P] [US4] memberUpdates 集計テストを engine.test.ts に追加する
  - 複数 memberUpdate エントリが合算される
  - morale が MAX を超えてクランプされる
  - morale が MIN 未満にならない
  - health が MAX/MIN でクランプされる

**Checkpoint**: `npm test tests/unit/engine.test.ts` が全テスト FAIL すること

---

## Phase 3: US1 — GameEngine 初期化実装

**Goal**: コンストラクタ・getState・isGameOver が正しく動作する

**Independent Test**: US1 の初期化テストが全 PASS すること

- [ ] T008 [US1] src/game/engine.ts を新規作成し GameEngine クラスの骨格を実装する
  - import: processTurn from "./turn.js", updateTaskProgress / setTaskStatus from "./gantt.js"
  - import: MEMBER_PARAMS from "./constants.js"
  - import types: GameState, StageData, TurnResult, CardName, ConditionalEvent
  - private state: GameState
  - private readonly conditionalEvents: ConditionalEvent[]
  - constructor(stageData): 初期 GameState を構築（KD-2 参照）
  - getState(): { ...this.state } を返す
  - isGameOver(): this.state.isGameOver を返す

**Checkpoint**: US1 テストが全 PASS

---

## Phase 4: US2 + US3 — processTurn 実装

**Goal**: ターン処理・ゲーム終了判定・ゲームオーバーガードが正しく動作する

**Independent Test**: US2・US3 のテストが全 PASS すること

- [ ] T009 [US2] engine.ts に processTurn を実装する（ゲームオーバーガード + ターン処理コア）
  - isGameOver ガード: throw new Error("Game is already over")
  - processTurnCore(state, cards, conditionalEvents) を呼び出す
  - progressUpdates の適用（KD-3: updateTaskProgress + stall イベント検出）
  - state.turn += 1
  - state.totalCost += result.costDelta
  - state.isGameOver = result.isGameOver
  - state.gameOverReason = result.gameOverReason
  - state.activeEffects = result.activeEffectsAfterTick
  - return result
- [ ] T010 [US3] ゲームオーバー後ガードが例外をスローすることを確認する（T009 に含む）

**Checkpoint**: US2・US3 テストが全 PASS

---

## Phase 5: US4 — memberUpdates 集計実装

**Goal**: memberUpdates の合算・クランプが正しく適用される

**Independent Test**: US4 の memberUpdates テストが全 PASS すること

- [ ] T011 [US4] engine.ts の processTurn に memberUpdates 集計ロジックを追加する（KD-4 参照）
  - 同一 memberId のエントリを合算
  - morale: clamp(morale + delta, MORALE.MIN, MORALE.MAX)
  - health: clamp(health + delta, HEALTH.MIN, HEALTH.MAX)
  - skill: clamp(skill + delta, SKILL.MIN, SKILL.MAX)
  - exp: Math.max(exp + delta, EXP.MIN)
  - state.members = updatedMembers

**Checkpoint**: `npm test tests/unit/engine.test.ts` が全テスト PASS

---

## Phase 6: Polish

**Purpose**: 全テスト・カバレッジ・型チェック・アーキテクチャ境界チェック

- [ ] T012 `npm test` で全テストが PASS することを確認する（既存249件 + 新規テスト）
- [ ] T013 `npm run typecheck` でエラー0を確認する
- [ ] T014 `npm run test:coverage` でカバレッジ lines/functions ≥ 80% を確認する
- [ ] T015 Phaser/DOM import がないことを確認する
  - `grep -r "phaser\|document\.\|window\." src/game/engine.ts && echo VIOLATION || echo OK`
- [ ] T016 `npm run lint` (Biome) でエラー0を確認する

---

## Dependencies & Execution Order

- **Phase 1**: すぐ開始可能
- **Phase 2**: Phase 1 完了後（T004〜T007 は並行作成可）
- **Phase 3**: Phase 2 完了後（初期化テストが FAIL してから実装）
- **Phase 4**: Phase 3 完了後（processTurn は初期化実装後）
- **Phase 5**: Phase 4 完了後（memberUpdates は processTurn のフレームが必要）
- **Phase 6**: Phase 5 完了後

### Parallel Opportunities

- T004〜T007（テスト作成）は並行作成可
- T012〜T016（Polish）は並行実行可

---

## Implementation Strategy

### MVP First (US1 + US2)

1. Phase 1〜2: Setup・テスト先行作成
2. Phase 3: 初期化実装（US1）
3. Phase 4: processTurn 実装（US2 + US3）
4. STOP and VALIDATE: engine.ts が単独で動作

### Full Implementation

1. Phase 1〜4 完了後
2. Phase 5: memberUpdates 集計（US4）
3. Phase 6: Polish
