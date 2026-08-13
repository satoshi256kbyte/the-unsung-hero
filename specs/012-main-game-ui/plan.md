# Implementation Plan: メイン画面UI

**Branch**: `012-main-game-ui` | **Date**: 2026-08-13 | **Spec**: specs/012-main-game-ui/spec.md

**Input**: Feature specification from `/specs/012-main-game-ui/spec.md`

## Summary

`src/ui/` 配下に DOM overlay コンポーネント群（MainGameUI・CardSlot・LoadingScreen）を実装し、
`src/scenes/MainScene.ts` で Phaser Scene と協調させる。
`pocStage` + `GameEngine` を使ってゲームループを動かし、Playwright E2E テストで検証する。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: Phaser 4、Vite、Playwright（E2E）

**Storage**: N/A（インメモリ `GameState`）

**Testing**: Playwright E2E（DOM overlay 操作）

**Target Platform**: ブラウザ（スマホ横持ち 960×540 相当、Vite dev server）

**Project Type**: ブラウザゲーム（DOM overlay + Phaser Canvas）

**Performance Goals**: ターン確定からロード画面表示まで体感遅延なし

**Constraints**:

- `src/ui/` は Phaser・DOM API 直接参照禁止（Constitution 原則 I）
- `src/scenes/` のみが Phaser を import 可
- `src/ui/` の DOM 要素は Playwright で操作可能であること（Constitution 原則 I）

**Scale/Scope**: ファイル数 6〜8件（UI コンポーネント × 4 + Scene × 1 + E2E テスト × 2〜3）

## Constitution Check

| Gate | Status | Notes |
|---|---|---|
| Architecture Boundaries | PASS | UI は `src/ui/`、Scene は `src/scenes/`、ロジックは `src/game/`（変更なし） |
| Test Coverage Gates | PASS | E2E テストは Playwright。`src/game/` カバレッジは既存テストが維持 |
| Game Balance Invariant | N/A | 表示層のみ。ロジック変更なし |
| Design Knowledge in Graph DB | PASS | 設計経緯は sync-graphdb で記録 |
| Dependency Hygiene | PASS | 新規 npm 依存なし（Playwright は既存） |

## Project Structure

### Documentation (this feature)

```text
specs/012-main-game-ui/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks command)
```

### Source Code (repository root)

```text
src/
├── ui/
│   ├── MainGameUI.ts        # 新規: DOM overlay ルート。GameState を受け取り描画
│   ├── CardSlot.ts          # 新規: カードスロット1枠コンポーネント
│   ├── LoadingScreen.ts     # 新規: ターン移行ロード画面
│   └── pmTerms.ts           # 新規: PM用語プール定数（10〜20件）
├── scenes/
│   ├── BootScene.ts         # 既存（変更なし）
│   └── MainScene.ts         # 新規: Phaser Scene + DOM overlay 協調
└── main.ts                  # 既存（MainScene 追加のみ）

tests/
└── e2e/
    ├── dashboard.spec.ts    # 新規: US1 ダッシュボード表示 E2E
    ├── card-slot.spec.ts    # 新規: US2 カード枠操作 E2E
    └── turn-cycle.spec.ts   # 新規: US3 ターン確定・ロード画面 E2E
```

**Structure Decision**: Constitution 原則 I に従い `src/ui/`・`src/scenes/`・`src/game/` の
3層を厳守。`src/game/` は今 Spec では変更しない。

## Complexity Tracking

> 特記すべき違反なし
