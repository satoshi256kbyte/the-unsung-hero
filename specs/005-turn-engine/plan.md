# Implementation Plan: ターン処理エンジン

**Branch**: `005-turn-engine` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/005-turn-engine/spec.md`

## Summary

`src/game/turn.ts` に1ターンの処理を orchestrate する純粋関数 `processTurn` を実装する。
Spec-02〜04 で実装済みの `gantt.ts`・`dice.ts`・`member.ts` の関数を呼び出し、
進捗更新・パラメータ変動・手戻りイベント・ゲームオーバー判定をまとめて実行し、
TurnResult として返す。GameState の更新は呼び出し側（Phaser Scene）が担う。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: Spec-01〜04 の実装済みモジュール
（types.ts / constants.ts / gantt.ts / dice.ts / member.ts）

**Storage**: N/A

**Testing**: Vitest + fast-check（Node環境）

**Target Platform**: Node.js（テスト）、ブラウザ（ゲーム実行時）

**Project Type**: game-logic library（pure TS）

**Performance Goals**: 1ターン処理が数ms以内（メンバー最大6人でも問題なし）

**Constraints**: Phaser / DOM API の import 禁止、引数の GameState を変更しない

**Scale/Scope**: 1関数・1ファイル

## Constitution Check

| 原則 | 状態 | 備考 |
|------|------|------|
| アーキテクチャ境界（src/game/ はPhaser/DOM非依存） | ✅ PASS | turn.ts は pure TS |
| テストゲート（Vitest + fast-check, coverage ≥80%） | ✅ PASS | 境界値 + プロパティテストを実施 |
| ゲームバランス不変条件（数値は constants.ts から） | ✅ PASS | EVENT_PROB/POC_STAGE を参照 |
| グラフDB（設計決定を Neo4j に同期） | ✅ PASS | 完了後に /sync-graphdb を実行 |
| 依存関係（承認済みライセンスのみ） | ✅ PASS | 新規 npm 依存なし |

## Project Structure

### Documentation (this feature)

```text
specs/005-turn-engine/
├── plan.md              # This file
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # /speckit-tasks output（未作成）
```

### Source Code

```text
src/game/
├── types.ts             # 既存: GameState / TurnResult / CardName 型
├── constants.ts         # 既存: EVENT_PROB / POC_STAGE
├── gantt.ts             # 既存: updateTaskProgress / applyRework / getCompletionRate
├── dice.ts              # 既存: rollProgress
├── member.ts            # 既存: applyTurnDecay / applyWeekendRecovery
└── turn.ts              # NEW: processTurn

tests/unit/
└── turn.test.ts         # NEW: 境界値テスト + fast-check プロパティテスト
```

## Key Design Decisions

### TurnResult を返し、GameState の更新は呼び出し側が担う

`processTurn` は `TurnResult`（差分）を返す。新しい `GameState` は返さない。
Phaser Scene が TurnResult を受け取り、自分の GameState を更新する責務を持つ。
これにより turn.ts は GameState の更新ロジックを持たず、純粋な差分計算関数に留まる。

### 進捗ダイスの担当タスク解決

`GanttTask.assignedMemberId` とメンバーの `id` が一致するタスクが対象。
`status === 'active'` のタスクのみ進捗を付与する（stalled・done は除外）。

### 手戻りイベントのターゲット選択

`status === 'active'` のタスクの中からランダムに1件選択して `applyRework` を適用する。
active タスクが0件の場合は手戻りイベントを発生させない。

### コスト計算

今フェーズでは `POC_STAGE.DAILY_COST_CAP × members.length` の固定値。
将来 残業許可カードの効果（OVERTIME_COST_CAP への切り替え）は Spec 以降で実装する。

### 週末判定

`turn % 5 === 0`（turn は processTurn 呼び出し時点の値、インクリメント前）で週末判定する。
