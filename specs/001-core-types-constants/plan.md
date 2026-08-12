# Implementation Plan: Core Types and Constants

**Branch**: `001-core-types-constants` | **Date**: 2026-08-12 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-core-types-constants/spec.md`

## Summary

ゲーム全体で使うコアデータ型・バランス定数・補正係数関数を pure TypeScript で実装する。
Phaser / DOM に一切依存せず、後続 Spec（Spec-02〜Spec-10）すべての型安全な基盤を提供する。
3ファイル構成: `src/game/types.ts`（型定義）、`src/game/constants.ts`（数値定数）、
`src/game/balance.ts`（skill_factor / health_factor 関数）。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: なし（pure TypeScript、外部ライブラリ不使用）

**Storage**: N/A

**Testing**: Vitest + fast-check（プロパティテスト）

**Target Platform**: Browser（Vite でビルド）、Node.js（Vitest 実行環境）

**Project Type**: ゲームロジックライブラリ（src/game/ 内の純粋モジュール）

**Performance Goals**: N/A（データ定義のみ、ランタイムパフォーマンス要件なし）

**Constraints**: Phaser・DOM API への依存ゼロ。`tsc --noEmit` エラーゼロ。

**Scale/Scope**: 3ファイル・型定義 + 定数 + 2関数。テストは balance.ts のプロパティテストのみ。

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 判定 | 根拠 |
|------|------|------|
| I. Architecture Boundaries | ✅ PASS | src/game/ に配置、Phaser/DOM import なし |
| II. Test Coverage Gates | ✅ PASS | balance.ts に Vitest プロパティテストを含む |
| III. Game Balance Invariant | ✅ PASS | バランスパラメータ.md の仮値をそのまま定数化 |
| IV. Design Knowledge in Graph DB | ✅ PASS | ADR-002/003 がグラフDBに記録済み |
| V. Dependency Hygiene | ✅ PASS | 外部依存なし |

**Complexity Tracking**: 違反なし。

## Project Structure

### Documentation (this feature)

```text
specs/001-core-types-constants/
├── plan.md              # This file
├── research.md          # Phase 0（不要のため省略）
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # /speckit-tasks output
```

### Source Code (repository root)

```text
src/
└── game/
    ├── types.ts          # 型定義（Member, Card, Event, GameState, GanttTask 等）
    ├── constants.ts      # バランス数値定数（バランスパラメータ.md の全数値）
    └── balance.ts        # skill_factor / health_factor 関数 + テスト

tests/
└── unit/
    └── balance.test.ts   # Vitest + fast-check プロパティテスト
```

**Structure Decision**: `src/game/` 直下にフラット配置。
types → constants → balance の依存順（constants は types に依存、balance は constants と types に依存）。
