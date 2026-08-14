# Implementation Plan: カード・イベント・ステージのファイル構造再編

**Branch**: `013-card-event-stage-files` | **Date**: 2026-08-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/013-card-event-stage-files/spec.md`

## Summary

カードのコスト・効果ロジック（現状 `constants.ts` の `CARD_COSTS` ＋ `card.ts` の1つの
switch文）とランダムイベントの発生確率・効果ロジック（現状 `constants.ts` の `EVENT_PROB` ＋
`event.ts` の1つのswitch文）を、カード1種・イベント1種ごとに1ファイルへ再編する。
ステージも「タイプ-連番」形式（`poc-01`）にリネームし、`stages/index.ts` にレジストリを置く。
併せて `docs/03-詳細設計/カード.md` `イベント.md` を同粒度で分割し、
新規に `docs/03-詳細設計/ステージ/PoCステージ01.md` を作成する。
既存のゲームロジックの外部挙動（`processTurn` 等の入出力）は変更しない、純粋な構造再編。

## Technical Context

**Language/Version**: TypeScript 5（strict mode、既存プロジェクト設定を継承）

**Primary Dependencies**: なし（新規依存追加なし。既存の `src/game/types.ts` の型定義のみ使用）

**Storage**: N/A

**Testing**: Vitest + fast-check（既存）。Playwright E2Eは対象外（画面・DOM変更を伴わない
純粋な内部リファクタリングのため）

**Target Platform**: 既存と同じ（ブラウザ / Vite）。本Specは `src/game/` 配下のみに影響し
プラットフォーム依存は生じない

**Project Type**: 既存の単一プロジェクト構成を維持

**Performance Goals**: N/A（実行時の計算内容は変更しないため、既存のパフォーマンス特性を維持）

**Constraints**:

- Constitution Principle I（Architecture Boundaries）: `src/game/cards|events|stages` は
  Phaser / DOM に依存してはならない
- 本Spec FR-012: 既存のゲームロジックの外部から見た振る舞いを変更してはならない

**Scale/Scope**: カード25ファイル＋レジストリ、イベント約15ファイル＋レジストリ、
ステージ1ファイルのリネーム＋レジストリ、`docs/` 側カード約26ファイル・イベント約23ファイル・
ステージ1ファイル（新規）

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 判定 | 備考 |
|------|------|------|
| I. Architecture Boundaries | PASS | `cards/` `events/` `stages/` は全て `src/game/` 配下の純粋ロジックであり、Phaser/DOM importを持たない設計 |
| II. Test Coverage Gates | PASS | 既存のカバレッジ基準（lines/functions≥80%, branches≥75%、`src/game/**`対象）を本リファクタリング後も維持する。テストは移動・分割するが実質的なテスト内容は既存を踏襲 |
| III. Game Balance Invariant | PASS | 数値パラメータ自体は変更しない（移動のみ）。`docs/03-詳細設計/` 側のドキュメント分割はFR-013〜017で本Specのスコープに含めている |
| IV. Design Knowledge in Graph DB | PASS | 設計判断はADR-019としてすでにNeo4jに反映済み。各speckitステップ後も`/sync-graphdb`を継続する |
| V. Dependency Hygiene | PASS | 新規依存追加なし |

違反なし。Complexity Trackingの記入は不要。

## Project Structure

### Documentation (this feature)

```text
specs/013-card-event-stage-files/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md         # Phase 1 output
├── contracts/
│   └── module-contracts.md
└── tasks.md              # Phase 2 output (/speckit-tasks - not created here)
```

### Source Code (repository root)

```text
src/game/
├── cards/
│   ├── daily.ts, review.ts, monitoring.ts, ... （25ファイル）
│   └── index.ts          # CARD_REGISTRY（satisfies Record<CardName, CardDefinition>）＋applyCards
├── events/
│   ├── stall.ts, rework.ts, sick.ts, ... （約15ファイル）
│   └── index.ts          # EVENT_REGISTRY＋rollRandomEvents＋汎用適用処理（applyEventToProgress等）
├── stages/
│   ├── poc-01.ts          # 旧pocStage.ts
│   └── index.ts           # STAGE_REGISTRY（id → StageData）
├── conditional.ts         # 変更なし（条件式評価の共通エンジン）
└── constants.ts            # カード・イベント固有値（CARD_COSTS・EVENT_PROB）を除去

tests/unit/
├── cards/
│   ├── daily.test.ts, review.test.ts, ...（実装済み6種、個別ファイル）
│   └── stubs.test.ts       # 未実装19種を一括検証
├── events/
│   ├── stall.test.ts, rework.test.ts, ...（実装済み5種、個別ファイル）
│   └── stubs.test.ts       # 未実装イベントを一括検証
└── stages/
    └── poc-01.test.ts       # 旧engine.test.ts等が参照していたステージデータの検証を移す場合はここ

docs/03-詳細設計/
├── カード.md（横断的説明のみ）
├── カード/デイリー.md 等（約26件）
├── イベント.md（横断的説明のみ）
├── イベント/追加要望.md 等（約23件）
└── ステージ/PoCステージ01.md（新規）
```

**Structure Decision**: 既存の単一プロジェクト構成（`src/game/` `src/scenes/` `src/ui/`
の3層アーキテクチャ、Constitution Principle I）を維持し、`src/game/` 配下に
`cards/` `events/` `stages/` のサブディレクトリを新設する。テストも同じ粒度で
`tests/unit/cards/` `tests/unit/events/` に分割する。`docs/03-詳細設計/` 配下に
日本語名の `カード/` `イベント/` `ステージ/` フォルダを新設する。

## Complexity Tracking

*本Specでは違反なし。記入なし。*
