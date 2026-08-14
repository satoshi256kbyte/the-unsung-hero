# Implementation Plan: カード・イベント・ステージ・バランス係数のJSON外部化

**Branch**: `015-json-data-externalization` | **Date**: 2026-08-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/015-json-data-externalization/spec.md`

## Summary

カードのコスト・イベントの基本発生確率・ステージデータ・`constants.ts`の係数テーブルを
`public/data/`配下のJSONファイルへ外部化する。効果ロジック（`applyEffect`/`roll`関数）は
TypeScriptのまま維持する。新規`PreloadScene`（`BootScene`→`TitleScene`間）でPhaserの
`this.load.json`により起動時に全JSONを読み込み、zodでスキーマ検証してからレジストリを
構築する。設計ドキュメント・グラフDBの`Parameter`ノードは数値の現在値を持たず、
JSONファイルへの参照のみを持つ形に改める。

## Technical Context

**Language/Version**: TypeScript 5（strict mode、既存プロジェクト設定を継承）

**Primary Dependencies**: 新規に`zod`（MIT、v4系）を追加。それ以外は既存の
`src/game/types.ts`の型定義・Phaserの`LoaderPlugin`（`this.load.json`）を使用

**Storage**: `public/data/`配下のJSONファイル（Viteが素通しで配信、ビルド後は
`dist/data/`にコピーされる）

**Testing**: Vitest + fast-check（既存の単体テストは変更不要）。Playwright E2Eで
`PreloadScene`の正常系・異常系（不正JSON時の起動失敗）を検証

**Target Platform**: 既存と同じ（ブラウザ / Vite）。JSONは`public/`配下のためVite
ビルドの影響を受けず、デプロイ後に直接編集しても次回ロード時に反映される

**Project Type**: 既存の単一プロジェクト構成を維持

**Performance Goals**: 起動時に43件のJSONを並行ロードする。Phaserの`LoaderPlugin`は
複数ファイルの並行ダウンロードをネイティブにサポートするため、追加の最適化は不要

**Constraints**:

- Constitution Principle I（Architecture Boundaries）: `src/game/`はPhaser/DOM非依存。
  fetch/JSON読み込みは`src/scenes/`側（`PreloadScene`）に置く
- 本Spec FR-007: 効果ロジック自体は変更しない
- 本Spec FR-008/FR-009: docs・グラフDBに数値の現在値を残さない

**Scale/Scope**: JSONファイル43件（カード26＋イベント15＋ステージ1＋バランス1）、
zodスキーマ4種、`PreloadScene`新規1件、`cards/events/stages/index.ts`の
構築関数化（3ファイル）、`constants.ts`の`POC_STAGE`→`GLOBAL_RULES`改名、
docs側3ファイル（バランスパラメータ.md・カード/*・イベント/*）の数値記述除去

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 判定 | 備考 |
|------|------|------|
| I. Architecture Boundaries | PASS | JSON読み込み（fetch相当のPhaser LoaderPlugin）は`src/scenes/PreloadScene.ts`に置き、`src/game/`は構築済みデータを受け取る純粋関数のまま維持する |
| II. Test Coverage Gates | PASS | `src/game/`の関数は同期・純粋のまま変更しないため既存カバレッジを維持。`PreloadScene`はE2Eで検証（Vitestのカバレッジ対象は`src/game/**`のみのため直接の影響なし） |
| III. Game Balance Invariant | PASS | 数値自体は変更しない（配置場所の変更のみ）。docsの記述方針変更はFR-008で本Specのスコープに含む |
| IV. Design Knowledge in Graph DB | PASS | ADR-022としてすでにNeo4jに反映済み。各speckitステップ後も`/sync-graphdb`を継続する |
| V. Dependency Hygiene | PASS | 新規依存`zod`はMITライセンスで承認済みリストに適合。`npm audit`・ライセンスチェックの対象に加わる |

違反なし。Complexity Trackingの記入は不要。

## Project Structure

### Documentation (this feature)

```text
specs/015-json-data-externalization/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md         # Phase 1 output
├── contracts/
│   └── json-schema-contracts.md
└── tasks.md              # Phase 2 output (/speckit-tasks - not created here)
```

### Source Code (repository root)

```text
public/data/
├── cards/<name>.json          # 26ファイル、{ cost: number }
├── events/<name>.json          # 15ファイル、{ baseProb: number, ...派生確率 }
├── stages/poc-01.json           # StageData相当
└── balance/constants.json       # 係数テーブル一式（GLOBAL_RULES含む）

src/game/
├── schemas/
│   ├── cardData.ts              # zodスキーマ
│   ├── eventData.ts
│   ├── stageData.ts
│   └── balanceConstants.ts
├── cards/index.ts                # buildCardRegistry(costData) に変更
├── events/index.ts                # buildEventRegistry(probData) に変更
├── stages/index.ts                 # buildStageRegistry(stageDataJson) に変更
└── constants.ts                    # POC_STAGE → GLOBAL_RULES改名、係数はJSONへ移動後は
                                     # 型定義のみ残すか、完全に削除しJSONを直接使う

src/scenes/
└── PreloadScene.ts                 # 新規。BootScene→TitleScene間。
                                     # 43件のJSONロード＋zod検証＋レジストリ構築

docs/03-詳細設計/
├── バランスパラメータ.md            # 数値列を削除、計算式・意味・JSON参照先を残す
├── カード/*.md                       # コスト数値表記をJSON参照に置き換え
└── イベント/*.md                     # 確率数値表記をJSON参照に置き換え
```

**Structure Decision**: 既存の3層アーキテクチャ（`src/game/` `src/scenes/` `src/ui/`）を
維持する。JSON読み込みは境界の原則に従い`src/scenes/`（`PreloadScene`）に置き、
`src/game/`は「データを受け取ってレジストリを構築する関数」を追加する形で対応する。
JSON実体は`public/data/`にSpec-13のファイル粒度と1:1対応させて配置する。

## Complexity Tracking

*本Specでは違反なし。記入なし。*
