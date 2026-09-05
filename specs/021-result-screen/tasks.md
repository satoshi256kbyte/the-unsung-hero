# Tasks: ゲームクリア/失敗のリザルト画面

**Input**: Design documents from `/specs/021-result-screen/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/module-contracts.md

**Tests**: テストタスクを含む。plan.md の Constitution Check II（Test Coverage Gates）で
result.ts の純関数テスト（Vitest + fast-check）とリザルト表示・遷移の E2E（Playwright）が
明示的に要求されている。

**Organization**: タスクはユーザーストーリー単位でグループ化し、各ストーリーを独立して
実装・テストできるようにする。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並列実行可能（別ファイル・依存なし）
- **[Story]**: 対応するユーザーストーリー（US1, US2, US3）
- 説明には正確なファイルパスを含める

## Path Conventions

単一プロジェクト構成。ロジック層 `src/game/`、DOM 層 `src/ui/`、Scene `src/scenes/`、
テスト `tests/unit/`・`tests/e2e/`。パスは plan.md の Project Structure に従う。

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 本フィーチャーで参照する既存資産と拡張ポイントを確認する

- [X] T001 既存の終了判定（`src/game/turn.ts` の isGameOver/gameOverReason）、利益率算出
  （`src/ui/MainGameUI.ts`）、`getCompletionRate`（`src/game/gantt.ts`）、目標利益率
  （`GLOBAL_RULES.TARGET_PROFIT_RATE`）の取得方法を確認する
- [X] T002 [P] 既存 DOM オーバーレイUI（`src/ui/StageSelectUI.ts` 等）の `data-testid` 付与と
  show/hide/コールバック登録パターン、`MainScene` の Scene 配線・遷移方法を確認する

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 成否判定の純関数と型を用意する（全ストーリーの土台）

**⚠️ CRITICAL**: このフェーズ完了までユーザーストーリーの実装は開始できない

- [X] T003 `src/game/result.ts`（新規）に `GameOutcome` 型と `GameResult` インターフェースを
  定義する（contracts/module-contracts.md の型契約に準拠）

**Checkpoint**: 型が整い、判定ロジックと UI の実装を開始できる

---

## Phase 3: User Story 1 - 成否と最終利益率の提示 (Priority: P1) 🎯 MVP

**Goal**: ゲーム終了時にリザルト画面を表示し、成否判定（クリア／失敗）と最終利益・利益率を示す。
未終了時は表示しない。

**Independent Test**: ゲームを終了状態まで進めるとリザルト画面が表示され、成否判定と最終利益率が
確認できる。未終了ターンでは表示されない。

### Tests for User Story 1 ⚠️（実装前に FAIL することを確認）

- [X] T004 [P] [US1] `tests/unit/result.test.ts` に `evaluateResult` の成否・利益率テストを追加:
  全タスク完了かつ利益率≥目標→clear / 全タスク完了だが利益率<目標→fail / 納期超過→fail /
  budget=0でゼロ除算にならず profitRate=0（FR-003,FR-004,FR-009）/ 入力を破壊しない（純関数）
- [X] T005 [P] [US1] `tests/e2e/result.spec.ts` にリザルト表示 E2E を追加:
  ゲーム終了後に `result-screen` が表示され `result-outcome`・`result-profit-rate` が出る /
  未終了ターンでは `result-screen` が出ない（US1/AC1-3, FR-007）

### Implementation for User Story 1

- [X] T006 [US1] `src/game/result.ts` に `evaluateResult(state, targetProfitRate)` を純関数として
  実装する。profit=budget−totalCost、profitRate=budget>0?profit/budget:0、
  outcome=(reason==="全タスク完了" && profitRate>=targetProfitRate)?"clear":"fail"、
  completionRate=getCompletionRate(state.gantt)。入力を変更しない（Phaser/DOM 非依存）
- [X] T007 [US1] `src/ui/ResultUI.ts`（新規）を実装する。`show(result)`/`hide()`/
  `setOnBackToTitle(cb)`。`result-screen`・`result-outcome`・`result-profit-rate`・`result-profit`
  を `data-testid` 付きで描画（既存 DOM オーバーレイ流儀）
- [X] T008 [US1] `src/scenes/MainScene.ts` の `confirmTurn` 末尾で `engine.getState().isGameOver` が
  true のとき `evaluateResult(state, TARGET_PROFIT_RATE)` を算出し ResultUI を表示する。
  ResultUI を create() で初期化・配線する

**Checkpoint**: US1 単独で「終了→リザルト表示・成否と利益率提示、未終了は非表示」が動作し独立テスト可能

---

## Phase 4: User Story 2 - 成否理由と結果の内訳の提示 (Priority: P2)

**Goal**: リザルトに成否理由（目標利益率達成可否・納期内完遂か納期超過か）と主要数値
（目標利益率・予算・総消費コスト・経過ターン・タスク完了状況）を表示する。

**Independent Test**: 異なる終了状況でリザルトを表示し、成否理由と主要数値が状況に応じて
正しく示される。

### Tests for User Story 2 ⚠️（実装前に FAIL することを確認）

- [X] T009 [P] [US2] `tests/unit/result.test.ts` に内訳テストを追加:
  reason が state.gameOverReason（全タスク完了／納期超過）と一致 / completionRate が
  getCompletionRate と一致 / totalCost>budget で profit 負・profitRate 負（FR-005,FR-006）

### Implementation for User Story 2

- [X] T010 [US2] `src/ui/ResultUI.ts` に `result-reason` と `result-stats`（目標利益率・予算・
  総消費コスト・経過ターン・完了率）の描画を追加する。成否理由を成否ルールに沿って文言化する

**Checkpoint**: US1 と US2 が両立し、成否理由と内訳の提示が独立テスト可能

---

## Phase 5: User Story 3 - リザルトからタイトルへ戻る導線 (Priority: P3)

**Goal**: リザルトから「タイトルへ戻る」でタイトル画面へ遷移し、再スタートできる。

**Independent Test**: リザルトで「タイトルへ戻る」を選ぶとタイトル画面へ遷移し、再びゲームを
開始できる。

### Tests for User Story 3 ⚠️（実装前に FAIL することを確認）

- [X] T011 [P] [US3] `tests/e2e/result.spec.ts` に導線 E2E を追加:
  `result-back-to-title` クリックでタイトル画面へ遷移し再開できる（US3/AC1-2, SC-004）/
  リザルト表示後にターン確定操作をしても二重進行・多重表示しない（Edge Case, FR-011）

### Implementation for User Story 3

- [X] T012 [US3] `src/ui/ResultUI.ts` に `result-back-to-title` ボタンと onBackToTitle 発火を実装し、
  `src/scenes/MainScene.ts` で onBackToTitle 時に ResultUI を隠して `this.scene.start("TitleScene")`
  へ遷移する。ゲーム終了後は確定ボタンを無効化して多重進行を防ぐ

**Checkpoint**: 全ユーザーストーリーが独立して機能する

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 回帰確認と検証

- [X] T013 回帰確認: 既存のターン確定・進行・終了判定が本フィーチャー導入後も従来どおり動作する
  ことを確認する（FR-011, SC-005）。`turn.ts`/`engine.ts` のシグネチャ・終了判定が不変であることを確認
- [X] T014 `npx tsc --noEmit` で型エラー 0 を確認し、`src/game/**` のカバレッジ閾値
  （lines≥80 / functions≥80 / branches≥75）を Vitest カバレッジで確認する
- [X] T015 quickstart.md の検証手順（自動検証＋手動6シナリオ）を実行し、リザルトの表示・成否・
  数値・遷移・多重進行なしが期待どおりであることを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし。即開始可能
- **Foundational (Phase 2)**: Setup 完了に依存。全ユーザーストーリーをブロックする
- **User Stories (Phase 3-5)**: すべて Foundational（GameResult 型）完了に依存
  - US1（P1）は evaluateResult と ResultUI の基本表示・MainScene 配線で完結する MVP
  - US2（P2）は US1 の ResultUI/evaluateResult に理由・内訳の描画を足す
  - US3（P3）は US1 の ResultUI/MainScene 配線に戻る導線を足す
- **Polish (Phase 6)**: 対象ストーリー完了に依存

### User Story Dependencies

- **US1 (P1)**: Foundational 完了後に開始可能。単独で完結（MVP）
- **US2 (P2)**: US1 の ResultUI と evaluateResult（GameResult 全項目算出）を前提とする
- **US3 (P3)**: US1 の ResultUI と MainScene 配線を前提とする

### Within Each User Story

- テストを先に書き FAIL を確認してから実装する
- result.ts（純関数）→ ResultUI（表示）→ MainScene（配線）の順で実装する

### Parallel Opportunities

- Setup の T002 は [P]
- 各ストーリーのテストタスク（T004/T005, T009, T011）は [P]
- US2/US3 の実装は同一ファイル `ResultUI.ts` を触るため、US1 完了後に順次

---

## Parallel Example: User Story 1

```bash
# US1 のテストを並列で着手（実装前に FAIL 確認）:
Task: "tests/unit/result.test.ts に evaluateResult の成否・利益率テストを追加"
Task: "tests/e2e/result.spec.ts にリザルト表示 E2E を追加"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup を完了
2. Phase 2: Foundational（GameResult 型）を完了
3. Phase 3: US1 を完了
4. **STOP and VALIDATE**: US1 を独立テスト（終了→表示・成否と利益率、未終了は非表示）
5. 動作すれば MVP としてデモ可能

### Incremental Delivery

1. Setup + Foundational → 土台完成
2. US1 追加 → 独立テスト → MVP
3. US2 追加（成否理由・内訳）→ 独立テスト
4. US3 追加（タイトルへ戻る）→ 独立テスト
5. Polish（回帰・型/カバレッジ・quickstart 検証）

---

## Notes

- [P] = 別ファイル・依存なし
- [Story] ラベルでタスクとユーザーストーリーを対応付ける
- 各ユーザーストーリーは独立して完了・テスト可能
- 実装前にテストが FAIL することを確認する
- `src/game/result.ts` は Phaser/DOM 非依存を維持（Constitution 原則 I）
- turn.ts / engine.ts の終了判定・シグネチャは変更しない（互換性契約）
- 新規の数値パラメータは導入しない（目標利益率は既存 TARGET_PROFIT_RATE を参照）
