# Implementation Plan: ガントチャート・タスクモデル

**Branch**: `002-gantt-task-model` | **Date**: 2026-08-13 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/002-gantt-task-model/spec.md`

## Summary

ガントチャート上のタスク進捗更新・状態遷移・バリアント切り替えを行う pure TypeScript モジュールを実装する。
Spec-01 で定義済みの型（`GanttTask` / `GanttChart`）と定数（`REWORK`）を使い、
外部依存ゼロで `src/game/gantt.ts` 1ファイルに収める。
Vitest + fast-check で境界値・プロパティテストを行い、typecheck + coverage gate を通過させる。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）/ TypeScript 7（tsconfig 互換）

**Primary Dependencies**: `src/game/types.ts`・`src/game/constants.ts`（Spec-01 成果物）のみ

**Storage**: N/A

**Testing**: Vitest + fast-check（プロパティテスト）

**Target Platform**: Browser（Vite ビルド）/ Node.js（Vitest 実行環境）

**Project Type**: ゲームロジックライブラリ（`src/game/` 内の純粋モジュール）

**Performance Goals**: N/A（データ操作のみ、ランタイムパフォーマンス要件なし）

**Constraints**: Phaser・DOM API への依存ゼロ。`tsc --noEmit` エラーゼロ。

**Scale/Scope**: 1ファイル・関数5本程度。テストは `gantt.test.ts` 1ファイル。

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 判定 | 根拠 |
|------|------|------|
| I. Architecture Boundaries | ✅ PASS | `src/game/` に配置、Phaser/DOM import なし |
| II. Test Coverage Gates | ✅ PASS | Vitest プロパティテストを含む |
| III. Game Balance Invariant | ✅ PASS | 手戻り巻き戻し率は `REWORK` 定数を使用（マジックナンバーなし） |
| IV. Design Knowledge in Graph DB | ✅ PASS | ガントチャートバリエーション設計は DB に ADR として記録済み |
| V. Dependency Hygiene | ✅ PASS | 外部 npm パッケージ追加なし |

**Complexity Tracking**: 違反なし。

## Project Structure

### Documentation (this feature)

```text
specs/002-gantt-task-model/
├── plan.md              # This file
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # /speckit-tasks output
```

### Source Code (repository root)

```text
src/
└── game/
    └── gantt.ts          # ガントチャート操作関数群

tests/
└── unit/
    └── gantt.test.ts     # Vitest + fast-check
```

**Structure Decision**: `src/game/` 直下にフラット配置。
types.ts / constants.ts（Spec-01）に依存。Spec-05 のターン処理エンジンから呼び出される。
