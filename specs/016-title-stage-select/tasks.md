# Tasks: タイトル〜ステージセレクト画面遷移

**Input**: Design documents from `specs/016-title-stage-select/`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並行実行可（異なるファイル、依存なし）
- **[Story]**: 対応ユーザーストーリー（US1〜US2）

---

## Phase 1: Setup

**Purpose**: 既存依存の確認

- [X] T001 `src/game/config.ts`の`getConfig()`と`src/game/stages/index.ts`の
      `getStage()`のシグネチャを確認する（`PreloadScene`実行後に呼べることを確認）
- [X] T002 `src/ui/MainGameUI.ts`のDOM構築パターン（`container: HTMLElement`を
      受け取りoverlayに要素を追加する形）を確認する

---

## Phase 2: User Story 1 - タイトル画面からゲームを始められる (Priority: P1) 🎯 MVP

**Goal**: `PreloadScene`の後にタイトル画面が表示され、スタートボタンで
ステージセレクト画面（一覧表示）に遷移する

**Independent Test**: ゲームを起動し、タイトル画面が表示され、スタートボタン押下で
ステージセレクト画面に遷移することを確認できる

### Implementation for User Story 1

- [X] T003 [P] [US1] `src/ui/TitleUI.ts`を新規作成する。コンストラクタで
      `container: HTMLElement`を受け取り、タイトルロゴ（`data-testid="title-logo"`）と
      スタートボタン（`data-testid="title-start-btn"`）を構築する。
      `setOnStart(cb: () => void)`でボタン押下時のコールバックを登録できるようにする。
      `destroy()`でoverlay内の要素を除去する
- [X] T004 [P] [US1] `src/ui/StageSelectUI.ts`を新規作成する。
      `getStage()`レジストリに登録された全ステージをカード（
      `data-testid="stage-card-<stageId>"`）として表示する`data-testid="stage-list"`
      コンテナを構築する。`destroy()`を実装する（確認表示モードもT012で
      同時に実装済み。1ファイルなので分けて書くより一括実装の方が自然だった）
- [X] T005 [US1] `src/scenes/TitleScene.ts`を新規作成する。`create()`で
      `#ui-overlay`要素を取得し`TitleUI`を生成、`setOnStart`で
      `this.scene.start("StageSelectScene")`を呼ぶ
- [X] T006 [US1] `src/scenes/StageSelectScene.ts`を新規作成する。`create()`で
      `StageSelectUI`を生成する
- [X] T007 [US1] `src/scenes/PreloadScene.ts`の`create()`末尾を
      `this.scene.start("MainScene")`から`this.scene.start("TitleScene")`に変更する
- [X] T008 [US1] `src/main.ts`のscene配列に`TitleScene`・`StageSelectScene`を追加する
      （`[BootScene, PreloadScene, TitleScene, StageSelectScene, MainScene]`）

**Checkpoint**: `npm run dev`で起動しタイトル画面→スタートボタン→
ステージセレクト画面（一覧）まで遷移できることを手動確認

---

## Phase 3: User Story 2 - ステージの内容を確認してからプレイを開始できる (Priority: P1)

**Goal**: ステージカードクリックで確認画面（プロジェクト概要・予算・目標利益率）が
表示され、「開始する」でゲームが始まり「もどる」で一覧に戻る

**Independent Test**: ステージカードをクリックして確認画面が表示され、
「もどる」で一覧に戻り、「開始する」でゲームプレイ画面が始まることを確認できる

### Implementation for User Story 2

- [X] T009 [P] [US2] `src/game/types.ts`の`StageData`に`description: string`を追加する
- [X] T010 [P] [US2] `src/game/schemas/stageData.ts`の`stageDataSchema`に
      `description: z.string()`を追加する
- [X] T011 [P] [US2] `public/data/stages/poc-01.json`に`description`フィールドを追加する
      （PoCステージのプロジェクト概要文を記載）。既存の`tests/unit/engine.test.ts`・
      `tests/unit/stages/index.test.ts`・`tests/unit/stages/poc-01.test.ts`の
      `StageData`フィクスチャにも`description`を追加（型必須化に伴う波及）
- [X] T012 [US2] `src/ui/StageSelectUI.ts`に確認表示モードを追加する。
      ステージカードクリックで選択したステージの`description`・`budget`・
      `getConfig().balance.GLOBAL_RULES.TARGET_PROFIT_RATE`をパーセント表示した
      目標利益率（率のみ）を表示する`data-testid="stage-confirm"`コンテナを
      表示する。「開始する」「もどる」ボタンを追加する
- [X] T013 [US2] `StageSelectUI`に`setOnStart(cb: (stageId: string) => void)`を追加し、
      「開始する」押下時に呼ぶ。「もどる」押下時は一覧表示に戻し
      選択状態をクリアする
- [X] T014 [US2] `src/scenes/StageSelectScene.ts`で`setOnStart`を登録し、
      `this.scene.start("MainScene", { stageId })`を呼ぶ
- [X] T015 [US2] `src/scenes/MainScene.ts`に`init(data: { stageId: string })`を
      追加し、`this.stageId`に保持する。`create()`内の
      `getStage("poc-01")`を`getStage(this.stageId)`に変更する

**Checkpoint**: `npm run test`・`npm run typecheck`が通り、手動でタイトル→
ステージ選択→確認画面→開始→ゲームプレイまで一気通貫で確認できる

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: 全体の整合性確認

- [X] T016 [P] `tests/e2e/title-stageselect.spec.ts`を新規作成し、
      US1・US2のAcceptance Scenariosに対応するE2Eテストを実装する。
      既存の`tests/e2e/{dashboard,card-slot,turn-cycle,preload}.spec.ts`は
      `page.goto("/")`後に直接`MainScene`のUIを待つ実装だったため、新しい
      画面遷移フローを経由するよう更新が必要と判明した。共通の
      `tests/e2e/helpers.ts`（`startGame(page)`関数）を新規作成し、
      各ファイルの`beforeEach`から呼ぶ形に統一した
- [X] T017 `npm run typecheck` でエラー0を確認する
- [X] T018 `npm run test` で既存の単体テストが変更なく全件PASSすることを確認する
      （332件）
- [X] T019 `npm run test:e2e` で全E2EテストPASS（chromium 27件・Mobile Chrome 27件、
      計54件）を確認する
- [X] T020 `npm run lint` (Biome) でエラー0を確認する
- [X] T021 `grep -r "phaser\|document\.\|window\." src/game/types.ts
      src/game/schemas/stageData.ts && echo VIOLATION || echo OK`で
      Phaser/DOM非依存を確認する（OK）

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし
- **US1 (Phase 2)**: Phase 1完了後。MVP
- **US2 (Phase 3)**: Phase 2完了後（`StageSelectScene`・`StageSelectUI`の
  一覧表示部分が前提のため）
- **Polish (Phase 4)**: 全User Story完了後

### Parallel Opportunities

- T003・T004（新規UIクラス2件）は並行実施可能
- T009〜T011（`description`追加3箇所）は並行実施可能

---

## Implementation Strategy

### MVP First (User Story 1 のみ)

1. Phase 1: Setup
2. Phase 2: US1（タイトル→ステージセレクト一覧まで）
3. STOP and VALIDATE: 画面遷移の骨格を確認

### Incremental Delivery

1. Setup → US1 → 検証
2. US2（確認画面＋ゲーム開始）→ 検証
3. Polish
