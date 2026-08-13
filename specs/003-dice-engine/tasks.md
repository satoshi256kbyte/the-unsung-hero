# Tasks: 進捗ダイスエンジン

**Input**: Design documents from `specs/003-dice-engine/`

**Prerequisites**: plan.md ✅, spec.md ✅, data-model.md ✅, quickstart.md ✅

---

## Phase 1: Setup

**Purpose**: `src/game/dice.ts` と `tests/unit/dice.test.ts` のファイル骨格を確認する

- [x] T001 `src/game/dice.ts` を作成し、`src/game/balance.ts` と `src/game/constants.ts` の
  import 宣言のみを記述して `npm run typecheck` がエラーゼロで通ることを確認する

---

## Phase 2: User Story 1 — メンバーの1ターン進捗量を計算できる (P1)

**Goal**: `rollProgress` を実装し、正の進捗量が返されることを確認する。

**Independent Test**: `npm test` で `dice.test.ts` の US1 テストが全 PASS すること。

- [x] T002 [US1] `rollProgress(member: Member): number` を `src/game/dice.ts` に実装する
  （`base = PROGRESS_DICE` 乱数 × `getSkillFactorRange` 乱数 × `getHealthFactor` 乱数）
- [x] T003 [US1] `tests/unit/dice.test.ts` を作成し `rollProgress` の境界値テストを実装する
  （技の境界値: 0/4/5/9/10/14/15/24/25/99 で戻り値が正数）
- [x] T004 [US1] fast-check プロパティテストを追加する
  （任意の技 0〜99・体 0〜100 で戻り値が正数かつパニックなし）
- [x] T005 [US1] `npm test` を実行して US1 テスト全 PASS を確認する

**Checkpoint**: T005 通過で User Story 1 完了。進捗量計算が型安全・境界値安全な状態。

---

## Phase 3: User Story 2 — 体が低いメンバーは進捗が下振れする (P2)

**Goal**: 体の境界値で `health_factor` の範囲が仕様通りに適用されることを確認する。

**Independent Test**: `npm test` で `dice.test.ts` の US2 テストが全 PASS すること。

- [x] T006 [US2] 体の境界値テストを `dice.test.ts` に追加する
  （体: 0/29/30/49/50/69/70/100 の各境界でテーブルが正しく選択されることを確認）
- [x] T007 [US2] `npm test` を実行して US2 テスト全 PASS を確認する

**Checkpoint**: T007 通過で User Story 2 完了。体による下振れ補正が仕様通り動作する状態。

---

## Phase 4: Polish

- [x] T008 quickstart.md の全検証コマンド（typecheck / test / Phaser依存なし）を
  実行して全項目クリアを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: 即時開始可能
- **Phase 2 (US1)**: Phase 1 完了後
- **Phase 3 (US2)**: Phase 2 完了後（`src/game/dice.ts` が存在する必要がある）
- **Phase 4 (Polish)**: 全フェーズ完了後

### Parallel Opportunities

```
Phase 2:
  T002 (rollProgress 実装) → T003 (境界値テスト) → T004 (fast-check) → T005 (確認)

Phase 3:
  T006 (体境界値テスト追加) → T007 (確認)
```

---

## Implementation Strategy

### MVP (US1 のみ)

1. T001: Setup
2. T002〜T005: `rollProgress` + テスト
3. → **Stop and validate**: Spec-05 が進捗計算を呼び出せる状態

### Full Delivery (全 US)

1. MVP 完了後、T006〜T007 で体の下振れ補正テスト追加
2. T008 で全体検証

---

## Notes

- [USn] ラベル = 対応するユーザーストーリー
- `rollProgress` はイミュータブル操作（Member を変更しない）
- `tsc --noEmit` は各フェーズ末に実行してエラーゼロを確認する
- T003 と T006 は同一ファイル `tests/unit/dice.test.ts` への追記となる
