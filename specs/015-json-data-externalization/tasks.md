# Tasks: カード・イベント・ステージ・バランス係数のJSON外部化

**Input**: Design documents from `specs/015-json-data-externalization/`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並行実行可（異なるファイル、依存なし）
- **[Story]**: 対応ユーザーストーリー（US1〜US3）

**注記**: `TitleScene`/`StageSelectScene`（Spec-14）は本Spec時点で未実装のため、
`PreloadScene`は`BootScene`→`PreloadScene`→`MainScene`の順に接続する。
Spec-14実装時に`MainScene`の位置に`TitleScene`が入る形に差し替える。

---

## Phase 1: Setup

**Purpose**: 依存追加とディレクトリ雛形の作成

- [X] T001 `npm install zod` で依存を追加する（MITライセンス、`npm run license:check`対象に含まれることを確認）
- [X] T002 `public/data/cards/` `events/` `stages/` `balance/` ディレクトリを作成する
- [X] T003 `src/game/schemas/` ディレクトリを作成する

---

## Phase 2: Foundational（全User Storyの前提）

**Purpose**: zodスキーマと設定シングルトンは全ストーリーが依存する基盤

**⚠️ CRITICAL**: このフェーズ完了までUser Story側の実装は着手できない

- [X] T004 [P] `src/game/schemas/cardData.ts` を作成する
      （`{ cost: number.int().nonnegative() }`）
- [X] T005 [P] `src/game/schemas/eventData.ts` を作成する
      （`{ baseProb: number.min(0).max(1) }` ＋ 派生確率キーを`catchall`で許容）
- [X] T006 [P] `src/game/schemas/stageData.ts` を作成する（既存`StageData`と同型）
- [X] T007 [P] `src/game/schemas/balanceConstants.ts` を作成する
      （`MEMBER_PARAMS`・`PROGRESS_DICE`・`EXP`・`LEVEL_UP_EXP`・`PARAM_DELTA`・
      `THRESHOLDS`・`REWORK`・`STALL`・`CHECKPOINT_PROB`・`SKILL_FACTOR_TABLE`・
      `HEALTH_FACTOR_TABLE`・`GLOBAL_RULES`の各キーを既存`constants.ts`から転記した形状で定義
      （`REWORK`はplan策定時に見落としていたため追加））
- [X] T008 `src/game/config.ts` を作成する（`GameConfig`インターフェース、
      `initGameConfig(data)`・`getConfig()`。未初期化時の`getConfig()`は例外を投げる）

**Checkpoint**: `npm run typecheck` がここまででエラー0（スキーマ・configのみ追加した段階）

---

## Phase 3: User Story 1 - バランス調整担当者がビルド不要で数値調整できる (Priority: P1) 🎯 MVP

**Goal**: カード・イベント・ステージ・バランス係数の数値をJSON化し、起動時に
読み込んでレジストリを構築する

**Independent Test**: `public/data/cards/daily.json`の`cost`を書き換えて
ブラウザをリロードするだけで（再ビルドなしに）変更が反映される

### Implementation for User Story 1

- [X] T009 [P] [US1] 既存26カードのコスト値を`public/data/cards/<name>.json`
      （Spec-13の`cards/*.ts`と同じファイル名）に転記する
- [X] T010 [P] [US1] 既存15イベントの基本確率（派生確率含む）を
      `public/data/events/<name>.json` に転記する
- [X] T011 [P] [US1] `poc-01.ts`のStageDataを`public/data/stages/poc-01.json`に転記する
      （転記後、参照元がなくなった`poc-01.ts`自体は削除。データ内容はJSONと完全一致を確認済み）
- [X] T012 [P] [US1] `constants.ts`の各テーブルを`public/data/balance/constants.json`に
      転記する。`POC_STAGE`は`GLOBAL_RULES`に改名し、`poc-01.json`と重複する
      項目（`WORKING_DAYS`・`MEMBER_COUNT`等）は削除し、ステージ非依存の4項目
      （`BUFFER_RATIO`・`TARGET_PROFIT_RATE`・`DAILY_COST_CAP`・`OVERTIME_COST_CAP`）
      のみ残す（`REWORK`テーブルはplan時点で見落としていたため追加で含めた）
- [X] T013 [US1] `src/game/cards/index.ts`の`CARD_REGISTRY`定数を
      `initCardRegistry(costData)`/`getCardRegistry()`関数に変更する
      （`applyCards`のシグネチャは不変。当初計画の`buildCardRegistry()`ではなく
      `config.ts`と同じinit/getパターンに統一）
- [X] T014 [US1] `src/game/events/index.ts`の`EVENT_REGISTRY`定数を
      `initEventRegistry(probData)`/`getEventRegistry()`関数に変更する
      （`rollRandomEvents`等のシグネチャは不変）
- [X] T015 [US1] `src/game/stages/index.ts`の`STAGE_REGISTRY`定数を
      `initStageRegistry(dataMap)`/`getStage(id)`関数に変更する
- [X] T016 [US1] `src/scenes/PreloadScene.ts`を新規作成する。`preload()`で
      43ファイルをPhaserの`this.load.json(key, path)`でロードし、
      `create()`でzodスキーマ検証（`.parse()`未捕捉、US2のfail-fast要件通り）→
      `initGameConfig()`・`initCardRegistry()`・`initEventRegistry()`・
      `initStageRegistry()`を呼んで`MainScene`へ遷移する
- [X] T017 [US1] `src/scenes/BootScene.ts`の遷移先を`PreloadScene`に変更する
- [X] T018 [US1] `src/scenes/MainScene.ts`を`getStage()`経由でステージデータを
      取得するように変更する
- [X] T019 [P] [US1] `src/game/balance.ts`の`getSkillFactorRange`/`getHealthFactor`を
      `getConfig().balance.SKILL_FACTOR_TABLE`等の参照に変更する
- [X] T020 [P] [US1] `src/game/dice.ts`の`constants.ts`参照を`getConfig()`経由に変更する
- [X] T021 [P] [US1] `src/game/gantt.ts`の`constants.ts`参照を`getConfig()`経由に変更する
- [X] T022 [P] [US1] `src/game/member.ts`の`constants.ts`参照を`getConfig()`経由に変更する
- [X] T023 [P] [US1] `src/game/turn.ts`の`constants.ts`参照（`POC_STAGE.DAILY_COST_CAP`等）を
      `getConfig().balance.GLOBAL_RULES`経由に変更する
- [X] T024 [P] [US1] `src/game/engine.ts`の`constants.ts`参照を`getConfig()`経由に変更する
- [X] T025 [P] [US1] `src/game/events/index.ts`・`events/stall.ts`の`constants.ts`参照を
      `getConfig()`経由に変更する
- [X] T026 [P] [US1] `src/game/cards/commendation.ts`・`one-on-one.ts`・`planned-leave.ts`の
      `constants.ts`参照（`PARAM_DELTA`）を`getConfig()`経由に変更する
      （`src/ui/MainGameUI.ts`の`CARD_REGISTRY`直接参照も同様の理由でスコープに含め`getCardRegistry()`に変更）
- [X] T027 [US1] `src/game/constants.ts`を削除する
- [X] T028 [US1] 既存の単体テストで初期化が必要な箇所に対応。
      `tests/unit/testConfig.ts`（旧constants.ts相当のテスト用フィクスチャ）と
      `tests/unit/setup.ts`を新規作成し、`vitest.config.ts`の`setupFiles`に登録することで
      全テストに`initGameConfig`等を自動適用（個別ファイル編集を回避）。
      `tests/unit/stages/poc-01.test.ts`は削除された`poc-01.ts`の代わりにフィクスチャを
      インライン化。新規`tests/unit/stages/index.test.ts`を追加（`stages/index.ts`の
      カバレッジ確保）

**Checkpoint**: `npm run test` が全件PASSし、`npm run dev`でゲームが起動し
`public/data/cards/daily.json`の編集がリロードだけで反映されることを確認する

---

## Phase 4: User Story 2 - 開発者がJSONの入力ミスを起動時に検知できる (Priority: P2)

**Goal**: 不正なJSON（必須フィールド欠落・型不一致・範囲外の値）で起動しようとした
場合に、起動時の検証で確実に検知される

**Independent Test**: いずれかのJSONの必須フィールドを欠落させた状態で起動し、
ゲームが開始されずエラーになることを確認する

### Tests for User Story 2

- [X] T029 [P] [US2] `tests/e2e/preload.spec.ts`を新規作成し、正常系
      （全JSON正常→`PreloadScene`を経てゲームが開始される）を検証する
- [X] T030 [P] [US2] `preload.spec.ts`に異常系を追加する。当初案の「実ファイルを
      一時的に書き換える」方式は、`fullyParallel`で並列実行される他のE2Eテスト
      ファイル（同じ開発サーバーを共有）とレースコンディションを起こすことが判明
      したため、`page.route()`によるネットワークインターセプトのみで不正なJSONを
      返す方式に変更（ディスク上のファイルには一切触れない）

**Checkpoint**: `npm run test:e2e`でT029・T030がPASSすること
（T016のPreloadScene実装はPhase 3で完了済みのため、本Phaseはテストのみ）

---

## Phase 5: User Story 3 - 設計ドキュメント・グラフDBの利用者が古い数値に惑わされない (Priority: P3)

**Goal**: docsとグラフDBから係数・コスト・確率の具体的な現在値を削除し、
JSON参照先のみを記載する

**Independent Test**: `バランスパラメータ.md`・`カード/*.md`・`イベント/*.md`に
具体的な現在値が残っていないことを確認する

- [X] T031 [P] [US3] `docs/03-詳細設計/バランスパラメータ.md`の数値列を削除し、
      計算式・意味・対応する`public/data/balance/constants.json`のキーへの
      参照を残す（セクション9〜11のシミュレーション考察・調整優先度は係数表ではなく
      分析的な記述であり具体的な例示数値を残す判断とした）
- [X] T032 [P] [US3] `docs/03-詳細設計/カード/*.md`（26件）のコスト数値表記を
      `public/data/cards/<name>.json`への参照に置き換える
- [X] T033 [P] [US3] `docs/03-詳細設計/イベント/*.md`（23件）を確認。
      いずれも具体的な確率値を記載していなかったため変更なし
- [X] T034 [US3] `npx markdownlint-cli2`で分割後の全ファイルがエラーゼロで通ることを確認する
- [X] T035 [US3] グラフDBの`Parameter`ノードの数値プロパティを削除し、
      `jsonPath`プロパティ（対応するJSONファイルパス）に置き換える

**Checkpoint**: `grep`で`バランスパラメータ.md`等に具体的な現在値が
残っていないことを目視確認する

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 全体の整合性確認

- [X] T036 `npm run typecheck` でエラー0を確認する
- [X] T037 `npm run test` で全テストPASSを確認する（332件全PASS）
- [X] T038 `npm run test:coverage` でカバレッジ lines/functions ≥ 80%,
      branches ≥ 75%（`src/game/**`）を確認する（実測: lines 94.08%, functions 100%,
      branches 89.41%）
- [X] T039 `npm run test:e2e` で全E2EテストPASSを確認する（chromium 22件・
      Mobile Chrome 22件、計44件全PASS。過程で2件のバグを発見・修正:
      (1) `MainGameUI.ts`で技ラベルと技の値に同じ`data-testid`が重複していた
      既存バグ（Spec-15とは無関係、`member-alice-skill`が値を表示しない不具合）、
      (2) `preload.spec.ts`の異常系テストが実ファイルを書き換える設計だと
      並列実行される他のE2Eファイルとレースする問題（`page.route()`による
      ネットワークインターセプト方式に変更して解消）
- [X] T040 `grep -r "phaser\|document\.\|window\." src/game/config.ts src/game/schemas
      && echo VIOLATION || echo OK` でPhaser/DOM非依存を確認する（OK）
- [X] T041 `npm run lint` (Biome) でエラー0を確認する
- [X] T042 `npm audit --audit-level=high` と `npm run license:check` で
      新規依存`zod`に問題がないことを確認する（0 vulnerabilities、zod MIT確認）
- [X] T043 `grep -rl "constants\.js\"" src` が0件であることを確認する
      （旧`constants.ts`参照の残存チェック、0件）
- [X] T044 `quickstart.md`の手動確認手順を実施する（JSONの`cost`値を書き換え、
      再ビルドなしに開発サーバーが変更後の値を配信することを確認）

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし、即開始可能
- **Foundational (Phase 2)**: Phase 1完了後。全User Storyをブロックする
- **US1 (Phase 3)**: Phase 2完了後。本Specの中核（MVP）
- **US2 (Phase 4)**: Phase 3完了後（`PreloadScene`の実体が必要なため、
  US1の実装完了に依存する。他ストーリーとは独立してテストのみ追加する）
- **US3 (Phase 5)**: Phase 2完了後。US1・US2とは独立（docsのみのため並行実施可）
- **Polish (Phase 6)**: 全User Story完了後

### Parallel Opportunities

- Phase 2のT004〜T007（スキーマ4種）は並行実施可能
- Phase 3のT009〜T012（JSON転記4種）・T019〜T026（constants.ts参照元8ファイル）は並行実施可能
- Phase 5（US3、docs分割）はPhase 2完了後ならPhase 3・4と並行実施可能

---

## Implementation Strategy

### MVP First (User Story 1 のみ)

1. Phase 1〜2: Setup・Foundational
2. Phase 3: US1（JSON外部化本体）
3. STOP and VALIDATE: `npm run dev`でJSON編集→リロードのみで反映されることを確認

### Incremental Delivery

1. Setup + Foundational → 基盤完成
2. US1 → 検証（MVP）
3. US2（検証テスト追加）→ 検証
4. US3（docs整理）→ 検証
5. Polish
