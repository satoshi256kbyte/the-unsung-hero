# Implementation Plan: ゲームクリア/失敗のリザルト画面

**Branch**: `021-result-screen` | **Date**: 2026-08-31 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/021-result-screen/spec.md`

## Summary

ゲーム終了（全タスク完了または納期到達）時に、成否判定（クリア／失敗）と最終利益・利益率・
成否理由・主要数値を提示する専用リザルト画面を追加する。成否判定は純関数
`src/game/result.ts`（新規、Phaser/DOM 非依存）に `evaluateResult(state)` として実装し、
表示は DOM オーバーレイ `src/ui/ResultUI.ts`（新規、既存 UI と同じパターン）で行う。
`MainScene.confirmTurn` の末尾でゲーム終了を検知したらリザルトを表示し、「タイトルへ戻る」で
`TitleScene` へ遷移する。既存のターン処理・終了判定（turn.ts の isGameOver/gameOverReason）は
変更しない。

技術方針の根拠は [research.md](./research.md)、データ定義は [data-model.md](./data-model.md)、
インターフェースは [contracts/module-contracts.md](./contracts/module-contracts.md)、
検証手順は [quickstart.md](./quickstart.md) を参照。

## Technical Context

**Language/Version**: TypeScript 5（strict）

**Primary Dependencies**: Phaser 4（Scene 遷移）。新規依存なし

**Storage**: なし（リザルトはゲーム状態から算出する派生値。永続化しない）

**Testing**: Vitest + fast-check（result.ts の成否判定・利益率計算の純関数テスト）。
Playwright（リザルト画面の DOM 表示・タイトルへ戻る遷移の E2E）

**Target Platform**: ブラウザ（スマホ横持ち前提）

**Project Type**: 単一プロジェクト（`src/game/` ロジック層 + `src/ui/` DOM 層 + `src/scenes/`）

**Performance Goals**: リザルト算出・表示はターン確定時の処理に体感遅延なく収まる

**Constraints**: Constitution 原則 I（`src/game/` は Phaser/DOM 非依存）。既存の
turn.ts / engine.ts の終了判定・シグネチャは変更しない

**Scale/Scope**: 対象ステージは poc-01。画面1枚（リザルト）と純関数1モジュールの追加

## Constitution Check

*GATE: Phase 0 前に評価し、Phase 1 設計後に再評価する。*

### Phase 0 前評価

- **I. Architecture Boundaries（NON-NEGOTIABLE）**: 成否判定・利益率算出は `src/game/result.ts`
  （純関数、Phaser/DOM 非依存）に置く。表示は `src/ui/ResultUI.ts`（DOM オーバーレイ、
  Playwright から `data-testid` で参照可能）。Scene 遷移は `MainScene` が担う。境界を侵さない。PASS
- **II. Test Coverage Gates（NON-NEGOTIABLE）**: result.ts の純関数（evaluateResult・利益率算出）に
  ユニット・プロパティテストを追加。`src/game/**` の閾値（lines≥80/functions≥80/branches≥75）を
  維持、`tsc --noEmit` 0。ResultUI の表示・遷移は E2E で検証。PASS
- **III. Game Balance Invariant**: 本フィーチャーは成否判定の「基準」に目標利益率
  （既存 `TARGET_PROFIT_RATE`）を用いるが、新規の数値パラメータは導入しない。利益率インバリアント
  （無策で 5% 未満、適切なプレイで 15–25%）の基準値は既存 balance 定義を参照するのみ。
  新たな数値の docs 文書化は不要。PASS
- **IV. Design Knowledge in Graph DB（NON-NEGOTIABLE）**: 本 plan の決定・ADR は
  `after_plan` フックの `/sync-graphdb` で Neo4j に反映する。PASS
- **V. Dependency Hygiene**: 新規依存を追加しない。PASS

Phase 0 前：全項目 PASS。

### Phase 1 後評価

- Phase 1 設計（data-model / contracts / quickstart）を経ても新規依存・境界逸脱はない。
  result.ts は純関数、ResultUI は DOM 描画のみ、MainScene が配線・遷移。turn.ts / engine.ts の
  終了判定・シグネチャは不変。全項目 PASS を維持。

## Project Structure

### Documentation (this feature)

```text
specs/021-result-screen/
├── plan.md              # このファイル
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── module-contracts.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output（/speckit-tasks で作成）
```

### Source Code (repository root)

```text
src/
├── game/
│   └── result.ts        # 新規: evaluateResult(state, targetProfitRate) 純関数（成否判定・利益率算出）
├── ui/
│   └── ResultUI.ts      # 新規: リザルト画面の DOM オーバーレイ（data-testid 付き、タイトルへ戻る）
└── scenes/
    └── MainScene.ts     # confirmTurn 末尾でゲーム終了時に ResultUI を表示、TitleScene へ遷移

tests/
├── unit/
│   └── result.test.ts   # 新規: evaluateResult のユニット・プロパティテスト
└── e2e/
    └── result.spec.ts   # 新規: リザルト表示・タイトルへ戻るの E2E
```

**Structure Decision**: 既存の3層構造を踏襲。成否判定ロジックは `src/game/result.ts`（純関数）に
閉じ、表示は `src/ui/ResultUI.ts`（既存の MainGameUI/StageSelectUI と同じ DOM オーバーレイ流儀、
`data-testid` で E2E 参照可能）、遷移は `MainScene`。turn.ts / engine.ts は不変。

## Complexity Tracking

*憲法違反はない。このセクションは記入不要。*
