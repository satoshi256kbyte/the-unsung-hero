# Implementation Plan: ゲーム内ガントチャートUI

**Branch**: `019-in-game-gantt-ui` | **Date**: 2026-08-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/019-in-game-gantt-ui/spec.md`

## Summary

ゲーム内に、各タスクの予定行・実績行の2行と現在ターンの稲妻線を持つガントチャート画面を
新規実装する。あわせてタスク選択で先行タスク（依存）をたどれるようにし（独立PERTビューは持たない）、
メイン画面のメニューからダッシュボードとガント画面を切り替えられるようにする。
実績（着手・完了ターン）を表現するため `GanttTask` に `actualStartTurn` / `actualEndTurn` を追加し、
`GameEngine.processTurn` のタスク更新時に記録する。稲妻線・実績帯は保存せず、描画時に
`GameState` から算出する。閲覧専用であり、スケジュールの直接編集手段は提供しない。

技術方針の根拠は [research.md](./research.md)、データ定義は [data-model.md](./data-model.md)、
インターフェースは [contracts/ui-and-module-contracts.md](./contracts/ui-and-module-contracts.md)、
検証手順は [quickstart.md](./quickstart.md) を参照。

## Technical Context

**Language/Version**: TypeScript 5（strict）

**Primary Dependencies**: Phaser 4（Scene管理）、DOM（ガント画面は DOM overlay で構築）。
ガント画面自体は Phaser canvas を使わず、既存 UI（MainGameUI/CardSlot）と同じ DOM overlay 方式

**Storage**: N/A（ゲーム状態はメモリ上の `GameState`。実績はステージJSONで optional）

**Testing**: Vitest + fast-check（`src/game/` のロジック：実績記録・稲妻線算出）、
Playwright（`src/ui/` の DOM 検証：予定/実績行・稲妻線・依存ハイライト・画面切替）

**Target Platform**: ブラウザ（スマートフォン横持ち前提の画面領域）

**Project Type**: 単一プロジェクト（既存リポジトリ。`src/game/` ロジック層 + `src/ui/` DOM層 +
`src/scenes/` Phaser層）

**Performance Goals**: ガント画面の描画・再描画がターン確定後の状態反映に体感遅延なく追随する
（60fps 前提の UI 遷移を阻害しない）

**Constraints**: Constitution 原則 I（`src/game/` は Phaser/DOM を import しない、`src/ui/` は
DOM 要素として E2E から参照可能）。`turn.ts` の純粋関数シグネチャは変更しない

**Scale/Scope**: 対象ステージは poc-01（9タスク・deadline 30）。列はターン1〜deadline を全描画

## Constitution Check

*GATE: Phase 0 前に評価し、Phase 1 設計後に再評価する。*

### Phase 0 前評価

- **I. Architecture Boundaries（NON-NEGOTIABLE）**: ガント画面は `src/ui/GanttChartUI.ts`
  として DOM overlay 方式で実装し、Phaser を import しない。稲妻線算出などのロジックは
  `src/game/gantt.ts`（Phaser/DOM 非依存）に純関数で置く。実績記録は `src/game/engine.ts` に置く。
  全表示要素に `data-testid` を付与し E2E から参照可能にする。PASS
- **II. Test Coverage Gates（NON-NEGOTIABLE）**: 実績記録（engine）と稲妻線算出（gantt.ts）に
  ユニット/プロパティテストを追加し、`src/game/**` の閾値（lines≥80/functions≥80/branches≥75）を
  維持する。UI は Playwright E2E で検証する。`tsc --noEmit` 0 を維持。PASS
- **III. Game Balance Invariant**: 本フィーチャーは表示専用で数値バランス・確率・コストを
  変更しない。実績フィールド追加は表示のためのメタデータであり、進捗ダイスやイベント確率に
  影響しない。PASS
- **IV. Design Knowledge in Graph DB（NON-NEGOTIABLE）**: 本 plan の決定と ADR は
  `after_plan` フックの `/sync-graphdb` で Neo4j に反映する。PASS
- **V. Dependency Hygiene**: 新規依存を追加しない（既存の Phaser/DOM/テスト基盤のみ）。PASS

Phase 0 前：全項目 PASS。違反なし。

### Phase 1 後評価

- Phase 1 の設計（data-model / contracts / quickstart）を経ても新規依存・アーキテクチャ境界の
  逸脱は発生しない。`src/game/` に追加する純関数（plannedRate/progressDeviation/actualPosition）は
  Phaser/DOM 非依存。`GanttChartUI` は DOM のみ。`turn.ts` の純粋関数シグネチャは不変で、実績記録は
  state を持つ engine 側に閉じる。全項目 PASS を維持。違反なし（Complexity Tracking 記入不要）。

## Project Structure

### Documentation (this feature)

```text
specs/019-in-game-gantt-ui/
├── plan.md              # このファイル
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── ui-and-module-contracts.md  # Phase 1 output
├── checklists/
│   └── requirements.md  # /speckit-specify output
└── tasks.md             # Phase 2 output（/speckit-tasks で作成）
```

### Source Code (repository root)

```text
src/
├── game/
│   ├── types.ts         # GanttTask に actualStartTurn / actualEndTurn を追加
│   ├── engine.ts        # processTurn のタスク更新時に実績を記録
│   ├── gantt.ts         # plannedRate / progressDeviation / actualPosition を追加
│   │                    #   + リスケ差し替え時の id ベース実績引き継ぎ
│   └── schemas/
│       └── stageData.ts # ganttTaskSchema に実績2フィールドを optional 追加（null 補完）
├── ui/
│   ├── GanttChartUI.ts  # 新規: ガントチャート画面（DOM overlay、閲覧専用）
│   └── MainGameUI.ts    # メニュー（nav-gantt-btn / nav-dashboard-btn）で画面切替を追加
└── scenes/
    └── MainScene.ts     # GanttChartUI の生成と MainGameUI との表示切替の配線

tests/
├── e2e/
│   └── gantt.spec.ts    # 新規: ガント画面の DOM・稲妻線・依存・画面切替の E2E
└── （unit）              # gantt.ts / engine.ts のユニット・プロパティテストを既存ファイルに追加
```

**Structure Decision**: 既存の3層構造（`src/game/` ロジック、`src/ui/` DOM、`src/scenes/`
Phaser）をそのまま用いる。ガント画面は既存 UI と同じ DOM overlay 方式で `src/ui/` に新規追加し、
`MainScene` で MainGameUI と切り替える。ロジック（実績記録・稲妻線算出）は `src/game/` に置く。

## Complexity Tracking

*本 Spec に憲法違反はないため、このセクションは記入不要。*
