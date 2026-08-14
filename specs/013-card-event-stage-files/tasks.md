# Tasks: カード・イベント・ステージのファイル構造再編

**Input**: Design documents from `specs/013-card-event-stage-files/`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並行実行可（異なるファイル、依存なし）
- **[Story]**: 対応ユーザーストーリー（US1〜US4）

---

## Phase 1: Setup

**Purpose**: ディレクトリ雛形の作成と既存実装の確認

- [X] T001 `src/game/cards/` `src/game/events/` `tests/unit/cards/` `tests/unit/events/`
      ディレクトリを作成する
- [X] T002 `docs/03-詳細設計/カード/` `イベント/` `ステージ/` ディレクトリを作成する
- [X] T003 既存の `src/game/card.ts` `event.ts` `constants.ts`
      （`CARD_COSTS` `EVENT_PROB`）の内容を確認し、26カード・15イベントの
      移行元マッピング表を作る（実装済み6カード・5イベント／未実装20カード・10イベント）

---

## Phase 2: User Story 1 - 新しいカードをファイル1つの追加だけで登録できる (Priority: P1) 🎯 MVP

**Goal**: `src/game/cards/` 配下にカード1件1ファイルの構造を作り、`card.ts` を置き換える

**Independent Test**: `applyCards` の入出力がリファクタリング前と完全に一致すること

### Tests for User Story 1

- [X] T004 [P] [US1] `tests/unit/card.test.ts` の該当ケースを
      `tests/unit/cards/daily.test.ts` に移す
- [X] T005 [P] [US1] 同様に `tests/unit/cards/review.test.ts` に移す
- [X] T006 [P] [US1] 同様に `tests/unit/cards/monitoring.test.ts` に移す
- [X] T007 [P] [US1] 同様に `tests/unit/cards/one-on-one.test.ts`（個別面談）に移す
- [X] T008 [P] [US1] 同様に `tests/unit/cards/commendation.test.ts`（表彰）に移す
- [X] T009 [P] [US1] 同様に `tests/unit/cards/planned-leave.test.ts`（計画休）に移す
- [X] T010 [US1] 未実装20種（デイリー中止・サマライズ・臨時MTG・臨時モニタリング・
      臨時サマライズ・教育・ペアプログラミング・雑談・停滞対応・残業許可・アサイン・
      入れ替え・巻取り・進捗ブースト・強制締め・リスケ・メンバー追加・休出・納期交渉・
      スコープ交渉）について、コストのみ・効果が空であることを検証する
      `tests/unit/cards/stubs.test.ts` を作成する

**Checkpoint**: 上記テストが（移行元と同じアサーションのまま）FAILしないことを確認
してから実装に進む（既存ロジックの移動のみのため、内容自体は変更しない）

### Implementation for User Story 1

- [X] T011 [P] [US1] `src/game/cards/daily.ts` を作成し `CardDefinition`
      （`cost: 1`、デイリーの `effectsToAdd` 生成ロジック）を実装する
- [X] T012 [P] [US1] `src/game/cards/review.ts` を作成する（`cost: 1`）
- [X] T013 [P] [US1] `src/game/cards/monitoring.ts` を作成する（`cost: 1`）
- [X] T014 [P] [US1] `src/game/cards/one-on-one.ts`（個別面談）を作成する（`cost: 2`）
- [X] T015 [P] [US1] `src/game/cards/commendation.ts`（表彰）を作成する（`cost: 2`）
- [X] T016 [P] [US1] `src/game/cards/planned-leave.ts`（計画休）を作成する（`cost: 2`）
- [X] T017 [US1] 未実装20種について、コストのみを持ち `applyEffect` が
      `{ effectsToAdd: [], memberUpdates: [] }` を返すスタブファイルを
      `src/game/cards/` 配下に作成する（コスト値は既存の `CARD_COSTS` を転記）
- [X] T018 [US1] `src/game/cards/index.ts` を作成し、`CARD_REGISTRY`
      （`satisfies Record<CardName, CardDefinition>`）と `applyCards` を実装する
      （T011〜T017 の全26ファイルをimport）
- [X] T019 [US1] `src/game/card.ts` を削除する
- [X] T020 [US1] `src/game/constants.ts` から `CARD_COSTS` を削除する
- [X] T021 [US1] `src/ui/MainGameUI.ts` の `CARD_COSTS[cardName]` 参照を
      `CARD_REGISTRY[cardName].cost` に置き換える（`cards/index.ts` からimport）
- [X] T022 [US1] `card.ts` を参照していた既存ファイル（`turn.ts` 等）のimport元を
      `cards/index.ts` に更新する

**Checkpoint**: `npm run test -- tests/unit/cards` が全件PASSし、
`applyCards` を経由する既存の統合テスト（`turn.test.ts` 等）も全件PASSすること

---

## Phase 3: User Story 2 - 新しいランダムイベントをファイル1つの追加だけで登録できる (Priority: P2)

**Goal**: `src/game/events/` 配下にイベント1種1ファイルの構造を作り、`event.ts` を置き換える

**Independent Test**: `rollRandomEvents` の入出力がリファクタリング前と完全に一致すること
（同一の乱数シードで比較）

### Tests for User Story 2

- [X] T023 [P] [US2] `tests/unit/event.test.ts` の該当ケースを
      `tests/unit/events/stall.test.ts` に移す
- [X] T024 [P] [US2] 同様に `tests/unit/events/rework.test.ts` に移す
- [X] T025 [P] [US2] 同様に `tests/unit/events/sick.test.ts` に移す
- [X] T026 [P] [US2] 同様に `tests/unit/events/low-motivation.test.ts` に移す
- [X] T027 [P] [US2] 同様に `tests/unit/events/fatigue.test.ts` に移す
- [X] T028 [US2] 未実装10種（仕様不明確・ブロッカー発生・環境障害・過大報告発覚・
      過小報告発覚・報告漏れ・ひらめき・一発合格・休息・地元優勝）について、
      `roll()` が常に `null` を返すことを検証する `tests/unit/events/stubs.test.ts`
      を作成する
- [X] T029 [P] [US2] `applyEventToProgress` / `applyEventToMember`
      （汎用適用処理）のテストを `tests/unit/events/apply.test.ts` に移す

### Implementation for User Story 2

- [X] T030 [P] [US2] `src/game/events/stall.ts` を作成し `EventDefinition`
      （基本確率 `EVENT_PROB.STALL` 相当、`roll()` に停滞イベント生成ロジック）を実装する
- [X] T031 [P] [US2] `src/game/events/rework.ts` を作成する
      （`REWORK` 基本確率＋`REWORK_WITH_DAILY_REVIEW` 補正込み）
- [X] T032 [P] [US2] `src/game/events/sick.ts` を作成する
- [X] T033 [P] [US2] `src/game/events/low-motivation.ts` を作成する
- [X] T034 [P] [US2] `src/game/events/fatigue.ts` を作成する
- [X] T035 [US2] 未実装10種について、基本確率のみを持ち `roll()` が常に `null` を
      返すスタブファイルを `src/game/events/` 配下に作成する
      （確率値は既存の `EVENT_PROB` を転記。`REWORK_WITH_DAILY_REVIEW` 等の
      派生確率は対応する基本イベントファイルに持たせる）
- [X] T036 [US2] `src/game/events/index.ts` を作成し、`EVENT_REGISTRY`・
      `rollRandomEvents`・`applyEventToProgress`・`applyEventToMember` を実装する
      （T030〜T035 の全15ファイルをimport）
- [X] T037 [US2] `src/game/event.ts` を削除する
- [X] T038 [US2] `src/game/constants.ts` から `EVENT_PROB` を削除する
- [X] T039 [US2] `event.ts` を参照していた既存ファイル（`turn.ts` 等）のimport元を
      `events/index.ts` に更新する

**Checkpoint**: `npm run test -- tests/unit/events` が全件PASSし、
`rollRandomEvents` を経由する既存の統合テスト（`engine.test.ts` 等）も
全件PASSすること

---

## Phase 4: User Story 4 - バランス調整担当者がカード・イベントの内容をファイル単位で編集できる (Priority: P2)

**Goal**: `docs/03-詳細設計/カード.md` `イベント.md` を個別ファイルに分割する

**Independent Test**: 分割前後で情報が1件も欠落していないこと（目視比較）

- [X] T040 [P] [US4] `docs/03-詳細設計/カード.md` の26行分の内容を
      `docs/03-詳細設計/カード/<カード名>.md` に分割する。`カード.md` には
      横断的な説明（適用方式・未決定事項）のみ残す
- [X] T041 [P] [US4] `docs/03-詳細設計/イベント.md` の23件分（プロジェクト7・
      タスク9・メンバー7）の内容を `docs/03-詳細設計/イベント/<イベント名>.md`
      に分割する。`イベント.md` には横断的な説明（分類・カテゴリ・リスクグラフ・
      固定イベント・手戻り停滞・未決定事項）のみ残す
- [X] T042 [US4] `npx markdownlint-cli2` で分割後の全ファイルがエラーゼロで
      通ることを確認する

**Checkpoint**: `カード/` `イベント/` 配下のファイル数がそれぞれ26件・23件であること

---

## Phase 5: User Story 3 - 新しいステージをファイル1つの追加だけで登録できる (Priority: P3)

**Goal**: `pocStage.ts` を `stages/poc-01.ts` にリネームし、`stages/index.ts`
レジストリを作る

**Independent Test**: `GameEngine` の初期化結果がリファクタリング前と完全に一致すること

- [X] T043 [US3] `src/game/stages/pocStage.ts` を `src/game/stages/poc-01.ts` に
      リネームし、`id: "poc"` を `id: "poc-01"` に変更する
- [X] T044 [US3] `src/game/stages/index.ts` を作成し、`STAGE_REGISTRY`
      （`{ "poc-01": ... }`）を実装する
- [X] T045 [US3] `src/scenes/MainScene.ts` の
      `import { pocStage } from "../game/stages/pocStage.js"` を更新する
- [X] T046 [US3] `tests/unit/stages/pocStage.test.ts` を
      `tests/unit/stages/poc-01.test.ts` にリネームし、import元を更新する
- [X] T047 [US4] `docs/03-詳細設計/ステージ/PoCステージ01.md` を新規作成する。
      冒頭に「ステージID: `poc-01`（`src/game/stages/poc-01.ts` に対応）」を記載し、
      ガントチャート表（タスクID・タスク名・工程・開始ターン・期間・担当・依存タスク、
      担当は `assignedMemberId` を初期メンバー名に変換）と
      ターンごとの条件付きイベント表（ターン・発生イベント・条件）を記載する

**Checkpoint**: `npm run test -- tests/unit/stages tests/unit/engine.test.ts` が
全件PASSすること

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 全体の整合性確認

- [X] T048 `npm run typecheck` でエラー0を確認する
- [X] T049 `npm run test` で全テストPASSを確認する（既存件数 + 新規分割分、329件）
- [X] T050 `npm run test:coverage` でカバレッジ lines/functions ≥ 80%,
      branches ≥ 75%（`src/game/**`）を確認する（実測: lines 98.3%, functions 100%,
      branches 93.91%）
- [X] T051 `grep -r "phaser\|document\.\|window\." src/game/cards src/game/events
      src/game/stages && echo VIOLATION || echo OK` でPhaser/DOM非依存を確認する（OK）
- [X] T052 `npm run lint` (Biome) でエラー0を確認する
      （balance.ts に既存2件のwarningがあるが本Specの変更対象外・error 0件）
- [X] T053 `grep -rl "card.ts\|event.ts\|pocStage" src tests` が
      0件であることを確認する（旧ファイル参照の残存チェック、実際のヒットは
      意図的に残した`pocStage`エクスポート名とコメント内の`event.ts`言及のみで
      壊れたimportはなし）
- [X] T054 `quickstart.md` の手動確認手順（新規カード追加テスト）を実施する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし、即開始可能
- **US1 カード (Phase 2)**: Phase 1 完了後。他ストーリーへの依存なし
- **US2 イベント (Phase 3)**: Phase 1 完了後。US1と独立（並行実施可）
- **US4 docs分割 (Phase 4)**: Phase 1 完了後。コード側（US1/US2）と独立
- **US3 ステージ (Phase 5)**: Phase 1 完了後。他ストーリーと独立
  （T047のみUS4のドキュメント新規作成を兼ねる）
- **Polish (Phase 6)**: 全User Story完了後

### Parallel Opportunities

- Phase 2〜5は全て独立しており並行実施可能
- 各PhaseないのT0xx [P] タスク（カード・イベント個別ファイル）は並行実施可能

---

## Implementation Strategy

### MVP First (User Story 1 のみ)

1. Phase 1: Setup
2. Phase 2: US1（カード）
3. STOP and VALIDATE: `tests/unit/cards` が独立して全件PASS

### Incremental Delivery

1. Setup → Phase 2（US1: カード）→ 検証
2. Phase 3（US2: イベント）→ 検証
3. Phase 4（US4: docs分割）→ 検証
4. Phase 5（US3: ステージ）→ 検証
5. Phase 6: Polish
