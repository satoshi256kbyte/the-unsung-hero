# Implementation Plan: メンバーパラメータ変動エンジン

**Branch**: `004-member-params-engine` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/004-member-params-engine/spec.md`

## Summary

`src/game/member.ts` に3つの純粋関数を実装する。
`applyTurnDecay` は心・体の自然変動（整数乱数＋クランプ）、
`applyWeekendRecovery` は週末回復（固定加算＋クランプ）、
`applyExperience` は経験値付与とレベルアップ判定（LEVEL_UP_EXP テーブル参照）。
全関数はイミュータブル操作。定数はすべて `constants.ts` から参照する。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: Spec-01実装済みの `src/game/constants.ts`（PARAM_DELTA/MEMBER_PARAMS/EXP/LEVEL_UP_EXP）

**Storage**: N/A

**Testing**: Vitest + fast-check（Node環境）

**Target Platform**: Node.js（テスト）、ブラウザ（ゲーム実行時）

**Project Type**: game-logic library（pure TS）

**Performance Goals**: 1ターン最大6メンバー分の呼び出しが発生しても問題ない軽量計算

**Constraints**: Phaser / DOM API の import 禁止、引数の Member を変更しない

**Scale/Scope**: 3関数・1ファイル

## Constitution Check

| 原則 | 状態 | 備考 |
|------|------|------|
| アーキテクチャ境界（src/game/ はPhaser/DOM非依存） | ✅ PASS | member.ts は pure TS |
| テストゲート（Vitest + fast-check, coverage ≥80%） | ✅ PASS | 境界値 + プロパティテストを実施 |
| ゲームバランス不変条件（数値は constants.ts から） | ✅ PASS | PARAM_DELTA/MEMBER_PARAMS/EXP/LEVEL_UP_EXP を参照 |
| グラフDB（設計決定を Neo4j に同期） | ✅ PASS | 完了後に /sync-graphdb を実行 |
| 依存関係（承認済みライセンスのみ） | ✅ PASS | 新規 npm 依存なし |

## Project Structure

### Documentation (this feature)

```text
specs/004-member-params-engine/
├── plan.md              # This file
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # /speckit-tasks output（未作成）
```

### Source Code

```text
src/game/
├── types.ts             # 既存: Member 型
├── constants.ts         # 既存: PARAM_DELTA, MEMBER_PARAMS, EXP, LEVEL_UP_EXP
└── member.ts            # NEW: applyTurnDecay / applyWeekendRecovery / applyExperience

tests/unit/
└── member.test.ts       # NEW: 境界値テスト + fast-check プロパティテスト
```

## Key Design Decisions

### 整数乱数の生成方法

`applyTurnDecay` では心・体の変動量が「整数」乱数と仕様で定義されている。
`Math.floor(min + (max - min + 1) * Math.random())` で整数乱数を生成する。

### LEVEL_UP_EXP テーブルのルックアップ

`LEVEL_UP_EXP` は `[技レベル下限, 必要経験値]` のペア配列。
現在の技レベルに対応する必要経験値を「下限以下で最大の行」を選択して取得する。
（`balance.ts` の `getSkillFactorRange` と同じパターン）

### 1付与=最大1レベルアップ

1回の `applyExperience` 呼び出しでレベルアップは最大1回。
大量経験値付与で複数レベルアップする仕様は Spec-04 の対象外（Assumptions に記載済み）。
