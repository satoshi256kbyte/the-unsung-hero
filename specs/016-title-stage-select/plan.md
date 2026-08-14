# Implementation Plan: タイトル〜ステージセレクト画面遷移

**Branch**: `016-title-stage-select` | **Date**: 2026-08-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/016-title-stage-select/spec.md`

## Summary

`BootScene → PreloadScene → MainScene` の直結を、
`BootScene → PreloadScene → TitleScene → StageSelectScene → MainScene` に拡張する。
`TitleScene`はタイトルロゴ＋スタートボタンのみ。`StageSelectScene`はステージ一覧表示と
確認表示（プロジェクト概要・予算・目標利益率）の2状態を持つ`StageSelectUI`を使う。
`StageData`に`description`フィールドを追加し、確認画面に表示する。
`MainScene`は`init(data: {stageId})`でstageIdのみ受け取り`getStage(stageId)`で
データを取得する形に変更する。

## Technical Context

**Language/Version**: TypeScript 5（strict mode、既存プロジェクト設定を継承）

**Primary Dependencies**: なし（新規依存追加なし。既存のPhaser 4 Scene機構・
Spec-15の`getStage()`/`getConfig()`レジストリを使用）

**Storage**: `public/data/stages/poc-01.json`に`description`フィールドを追加

**Testing**: Playwright E2E（既存パターン踏襲、`tests/e2e/`）。UI層に単体テストは
追加しない（既存の`MainGameUI`等と同じ方針）

**Target Platform**: 既存と同じ（ブラウザ / Vite / Phaser）

**Project Type**: 既存の単一プロジェクト構成を維持

**Performance Goals**: N/A（画面遷移のみ、パフォーマンスに影響する処理はない）

**Constraints**:

- Constitution Principle I（Architecture Boundaries）: `TitleScene`/`StageSelectScene`は
  `src/scenes/`に置き、UIロジック（DOM構築）は`src/ui/`の`TitleUI`/`StageSelectUI`に置く
- 目標利益率はADR-022の方針により`GLOBAL_RULES.TARGET_PROFIT_RATE`（率のみ）を表示し、
  具体的な達成金額を計算・表示してはならない（FR-006）

**Scale/Scope**: 新規Scene 2件（`TitleScene`・`StageSelectScene`）、新規UIクラス2件
（`TitleUI`・`StageSelectUI`）、`MainScene`・`main.ts`の変更、`StageData`型・
`stageDataSchema`・`poc-01.json`への`description`追加、E2E新規1ファイル

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 判定 | 備考 |
|------|------|------|
| I. Architecture Boundaries | PASS | `TitleScene`/`StageSelectScene`（`src/scenes/`）はPhaser Scene層、`TitleUI`/`StageSelectUI`（`src/ui/`）はDOM overlay層。ゲームロジックへの新規追加はなし（`src/game/`は`description`フィールド追加のみ） |
| II. Test Coverage Gates | PASS | UI層は既存方針通りE2Eでカバー。`src/game/**`のカバレッジ対象に変更なし |
| III. Game Balance Invariant | PASS | 数値の変更なし。目標利益率はADR-022方針に従い率のみ参照表示 |
| IV. Design Knowledge in Graph DB | PASS | ADR-024としてすでにNeo4jに反映済み |
| V. Dependency Hygiene | PASS | 新規依存追加なし |

違反なし。Complexity Trackingの記入は不要。

## Project Structure

### Documentation (this feature)

```text
specs/016-title-stage-select/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui-contracts.md
└── tasks.md
```

### Source Code (repository root)

```text
src/scenes/
├── TitleScene.ts          # 新規。TitleUIを使う
├── StageSelectScene.ts     # 新規。StageSelectUIを使う
└── MainScene.ts             # init(data: {stageId}) に変更

src/ui/
├── TitleUI.ts               # 新規
└── StageSelectUI.ts          # 新規。一覧表示/確認表示の2状態

src/game/
├── types.ts                 # StageDataにdescriptionフィールド追加
└── schemas/stageData.ts      # stageDataSchemaにdescriptionフィールド追加

public/data/stages/
└── poc-01.json                # descriptionフィールド追加

src/main.ts                   # scene配列にTitleScene・StageSelectSceneを追加

tests/e2e/
└── title-stageselect.spec.ts  # 新規
```

**Structure Decision**: 既存の3層アーキテクチャ（`src/game/` `src/scenes/` `src/ui/`）を
そのまま踏襲する。`TitleScene`/`StageSelectScene`は`src/scenes/`、対応するDOM overlay UIは
`src/ui/`に置き、Spec-12の`MainScene`+`MainGameUI`と同じ責務分担にする。

## Complexity Tracking

*本Specでは違反なし。記入なし。*
