# Implementation Plan: PoCステージデータ

**Branch**: `011-poc-stage-data` | **Date**: 2026-08-13 | **Spec**: specs/011-poc-stage-data/spec.md

**Input**: Feature specification from `/specs/011-poc-stage-data/spec.md`

## Summary

`pocStage` という `StageData` 型定数を `src/game/stages/pocStage.ts` に実装する。
メンバー3名・ガントタスク9件・条件付きイベント5件・初期カード3枚を定義し、
`GameEngine` が例外なく初期化できることを Vitest でテストする。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: なし（純粋なデータ定数ファイル）

**Storage**: N/A（インメモリ定数）

**Testing**: Vitest（既存テスト基盤を流用）

**Target Platform**: ブラウザ（Vite バンドル）

**Project Type**: ゲームロジック層のデータ定義モジュール

**Performance Goals**: N/A（静的データ定数）

**Constraints**: `src/game/` 層のみ・Phaser/DOM import 禁止（Constitution 原則 I）

**Scale/Scope**: ファイル2件（本体 + テスト）・型チェックエラー0

## Constitution Check

| Gate | Status | Notes |
|---|---|---|
| Architecture Boundaries | PASS | `src/game/` 配置・Phaser import なし |
| Test Coverage Gates | PASS | ユニットテスト追加でカバレッジ維持 |
| Game Balance Invariant | PASS | 数値はパラメータ仕様準拠・ADR は Neo4j に記録 |
| Design Knowledge in Graph DB | PASS | 設計経緯は sync-graphdb で記録 |
| Dependency Hygiene | PASS | 新規依存なし |

## Project Structure

### Documentation (this feature)

```text
specs/011-poc-stage-data/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks command)
```

### Source Code (repository root)

```text
src/
└── game/
    ├── stages/
    │   └── pocStage.ts   # 新規: StageData 型定数
    ├── types.ts          # 既存: StageData 型定義（変更なし）
    └── engine.ts         # 既存: GameEngine（変更なし）

tests/
└── unit/
    └── stages/
        └── pocStage.test.ts  # 新規: PoCステージ検証テスト
```

**Structure Decision**: 既存 `src/game/` 配下に `stages/` サブディレクトリを新設し、
今後の複数ステージ対応を想定した命名規則を採用する。

## Complexity Tracking

> 特記すべき違反なし
