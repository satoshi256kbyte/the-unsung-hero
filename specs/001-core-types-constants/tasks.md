# Tasks: Core Types and Constants

**Input**: Design documents from `specs/001-core-types-constants/`

**Prerequisites**: plan.md ✅, spec.md ✅, data-model.md ✅, quickstart.md ✅

---

## Phase 1: Setup

**Purpose**: src/game/ ディレクトリの作成と tsconfig のパスエイリアス確認

- [x] T001 src/game/ ディレクトリを作成し、tsconfig.json の `@game` エイリアスが `src/game` を指していることを確認する

---

## Phase 2: User Story 1 — 後続モジュールが型安全なデータを扱える (P1)

**Goal**: Member/Card/Event/GameState/GanttTask/GanttChart/TurnResult/StageData/ConditionalEvent
など全エンティティの TypeScript 型を定義し、tsc --noEmit がエラーゼロで通る。

**Independent Test**: `npm run typecheck` がエラーゼロで完了すること。

- [x] T002 [P] [US1] CardName union 型と CardApplicationMode / TargetType / EffectType / EventType / EventCategory 列挙型を
  src/game/types.ts に定義する（data-model.md の CardName 全26枚を含む）
- [x] T003 [P] [US1] Member / CardEffect / ProgressUpdate / MemberUpdate 型を src/game/types.ts に定義する
  （data-model.md の Member・CardEffect 参照）
- [x] T004 [P] [US1] GanttTask / GanttChart 型を src/game/types.ts に定義する（data-model.md の GanttTask・GanttChart 参照）
- [x] T005 [US1] GameEvent / ConditionalEvent / TurnResult 型を src/game/types.ts に定義する（T002〜T004 完了後）
- [x] T006 [US1] GameState / StageData 型を src/game/types.ts に定義する（T002〜T005 完了後）
- [x] T007 [US1] `npm run typecheck` を実行してエラーゼロを確認する

**Checkpoint**: T007 通過で User Story 1 完了。型定義が後続 Spec の基盤として使える状態。

---

## Phase 3: User Story 2 — バランスパラメータ変更が一箇所で完結する (P2)

**Goal**: docs/03-詳細設計/バランスパラメータ.md の全数値定数を src/game/constants.ts に定義する。

**Independent Test**: `grep -r "0\.08\|0\.05\|0\.04\|0\.03" src/ --include="*.ts" | grep -v constants.ts`
が 0 件であること（マジックナンバーなし）。

- [x] T008 [P] [US2] PoCステージ基本情報定数（稼働日数・工程期間・チェックポイント回数・
  バッファ比率・目標利益率）を src/game/constants.ts に定義する
- [x] T009 [P] [US2] メンバーパラメータ範囲定数（心/体/技/経験値の min・max・初期値）と
  週末回復量・心体自然変動幅を src/game/constants.ts に定義する
- [x] T010 [P] [US2] ランダムイベント発生確率定数（タスクイベント7種・メンバーイベント5種の
  基本確率とカード使用時の確率）を src/game/constants.ts に定義する
- [x] T011 [P] [US2] カードコスト定数 CARD_COSTS: Record\<CardName, number\> を
  src/game/constants.ts に定義する（バランスパラメータ.md 「6. カードのコスト確定値」参照）
- [x] T012 [P] [US2] チェックポイント確率定数（キックオフ/週次/締め/クロージング）と
  手戻り巻き戻し計算定数を src/game/constants.ts に定義する
- [x] T013 [P] [US2] レベルアップ必要経験値テーブル LEVEL_UP_EXP と
  経験値計算定数（base_exp・level_factor 係数）を src/game/constants.ts に定義する
- [x] T014 [US2] ネガティブイベント発生閾値定数（心/体/透明性/緊張感の低/高閾値）と
  各イベントによる心体変動量定数を src/game/constants.ts に定義する（T008〜T013 完了後）
- [x] T015 [US2] `npm run typecheck` を実行してエラーゼロを確認し、
  quickstart.md のマジックナンバーチェックコマンドで 0 件であることを確認する

**Checkpoint**: T015 通過で User Story 2 完了。数値変更が constants.ts 1 ファイルで完結する状態。

---

## Phase 4: User Story 3 — 技・体の補正値が正しく計算される (P3)

**Goal**: getSkillFactorRange(skill) / getHealthFactor(health) を実装し、
バランスパラメータ.md のテーブルと境界値で一致することを Vitest + fast-check で検証する。

**Independent Test**: `npm test` で balance.test.ts の全テストケースが PASS すること。

- [x] T016 [US3] skill_factor テーブル定数（技レベル帯ごとの [min, max] 配列）を
  src/game/constants.ts に追加し、getSkillFactorRange(skill: number): [number, number]
  関数を src/game/balance.ts に実装する
- [x] T017 [US3] health_factor テーブル定数（体の値帯ごとの [min, max] 配列）を
  src/game/constants.ts に追加し、getHealthFactor(health: number): [number, number]
  関数を src/game/balance.ts に実装する
- [x] T018 [US3] src/game/balance.test.ts を作成し、Vitest で境界値テストを実装する
  （技レベル: 0/4/5/9/10/14/15/24/25/99 の各値で仕様通りの範囲を返すこと）
- [x] T019 [US3] fast-check プロパティテストを src/game/balance.test.ts に追加する
  （任意の技レベル 0〜99・体 0〜100 で関数がパニックせず [min, max] 形式を返すこと）
- [x] T020 [US3] `npm test` を実行して全テスト PASS を確認する

**Checkpoint**: T020 通過で User Story 3 完了。balance 関数の正確さが自動検証された状態。

---

## Phase 5: Polish

- [x] T021 quickstart.md の全検証コマンド（typecheck / test / Phaser依存なし / DOM依存なし）を実行して全項目クリアを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: 即時開始可能
- **Phase 2 (US1)**: Phase 1 完了後。T002〜T004 は並列実行可。T005〜T007 は T002〜T004 完了後
- **Phase 3 (US2)**: Phase 2 完了後（types.ts の CardName 型が必要）。T008〜T013 は並列実行可
- **Phase 4 (US3)**: Phase 3 の T008〜T013 完了後（定数ファイルへの追記が必要）
- **Phase 5 (Polish)**: 全フェーズ完了後

### Parallel Opportunities

```
# Phase 2 で並列実行できるタスク
T002 (CardName等列挙型)
T003 (Member/CardEffect等)
T004 (GanttTask/GanttChart)
  ↓ 完了後
T005 (GameEvent/ConditionalEvent/TurnResult)
  ↓ 完了後
T006 (GameState/StageData)

# Phase 3 で並列実行できるタスク
T008 (PoC基本情報)
T009 (パラメータ範囲・変動)
T010 (イベント確率)
T011 (カードコスト)
T012 (チェックポイント確率・手戻り)
T013 (経験値テーブル)
  ↓ 完了後
T014 (閾値・変動量)
```

---

## Implementation Strategy

### MVP (US1 のみ)

1. T001: Setup
2. T002〜T006: 型定義
3. T007: typecheck 確認
4. → **Stop and validate**: 後続 Spec が import できる型定義が完成

### Full Delivery (全 US)

1. MVP 完了後、T008〜T015 で定数定義
2. T016〜T020 で balance 関数実装・テスト
3. T021 で全体検証

---

## Notes

- [P] タスク = ファイルが異なり依存なし、並列実行可
- [USn] ラベル = 対応するユーザーストーリー
- `tsc --noEmit` は各フェーズの最後に実行して型エラーがないことを確認する
- Phaser / DOM への import が混入していないことを各フェーズ完了時にチェックする
