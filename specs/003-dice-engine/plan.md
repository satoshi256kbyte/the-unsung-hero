# Implementation Plan: 進捗ダイスエンジン

**Branch**: `003-dice-engine` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/003-dice-engine/spec.md`

## Summary

`rollProgress(member: Member): number` を `src/game/dice.ts` に実装する。
計算式: `base × skill_factor × health_factor`。
`base` は `PROGRESS_DICE` 定数から、`skill_factor` / `health_factor` は
既存の `balance.ts` の関数を呼び出して取得する。1ファイル・1関数のシンプルな実装。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: Spec-01実装済みの `src/game/balance.ts`（getSkillFactorRange / getHealthFactor）

**Storage**: N/A

**Testing**: Vitest + fast-check（Node環境）

**Target Platform**: Node.js（テスト）、ブラウザ（ゲーム実行時）

**Project Type**: game-logic library（pure TS）

**Performance Goals**: 1ターンに最大6タスク×6メンバー分の呼び出しが発生しても問題ない軽量計算

**Constraints**: Phaser / DOM API の import 禁止、引数の Member を変更しない

**Scale/Scope**: 1関数・1ファイル

## Constitution Check

| 原則 | 状態 | 備考 |
|------|------|------|
| アーキテクチャ境界（src/game/ はPhaser/DOM非依存） | ✅ PASS | dice.ts は pure TS |
| テストゲート（Vitest + fast-check, coverage ≥80%） | ✅ PASS | 境界値 + プロパティテストを実施 |
| ゲームバランス不変条件（数値は constants.ts から） | ✅ PASS | PROGRESS_DICE / SKILL_FACTOR_TABLE / HEALTH_FACTOR_TABLE を参照 |
| グラフDB（設計決定を Neo4j に同期） | ✅ PASS | 完了後に /sync-graphdb を実行 |
| 依存関係（承認済みライセンスのみ） | ✅ PASS | 新規 npm 依存なし |

## Project Structure

### Documentation (this feature)

```text
specs/003-dice-engine/
├── plan.md              # This file
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # /speckit-tasks output（未作成）
```

### Source Code

```text
src/game/
├── types.ts             # 既存: Member 型
├── constants.ts         # 既存: PROGRESS_DICE, SKILL_FACTOR_TABLE, HEALTH_FACTOR_TABLE
├── balance.ts           # 既存: getSkillFactorRange(), getHealthFactor()
└── dice.ts              # NEW: rollProgress(member) → number

tests/unit/
└── dice.test.ts         # NEW: 境界値テスト + fast-check プロパティテスト
```

**Structure Decision**: `balance.ts` の関数を再利用するため、dice.ts の実装は
`base` の乱数生成と 2 関数の呼び出し・乗算のみ。テーブルロジックを重複させない。

## Key Design Decision

`getSkillFactorRange(skill)` と `getHealthFactor(health)` はすでに `balance.ts` に
実装済み。`dice.ts` はこれらを import して呼び出すだけでよい。
乱数生成は `Math.random()` の線形補間（`min + (max - min) * Math.random()`）を使用する。
