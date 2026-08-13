# Implementation Plan: カード効果エンジン

**Branch**: `006-card-engine` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/006-card-engine/spec.md`

## Summary

`src/game/card.ts` に `applyCards(state, cards): CardApplicationResult` を実装する。
デイリー・レビュー・モニタリング（確率低減セット系）と
個別面談・表彰・計画休（即時メンバー系）の計 6 種のカードを処理し、
`effectsToAdd`（CardEffect[]）と `memberUpdates`（MemberUpdate[]）の差分を返す。
Spec-01 で定義済みの型・定数のみに依存し、GameState を変更しない。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: Spec-01 の types.ts / constants.ts のみ

**Storage**: N/A

**Testing**: Vitest + fast-check（Node 環境）

**Target Platform**: Node.js（テスト）、ブラウザ（ゲーム実行時）

**Project Type**: game-logic library（pure TS）

**Performance Goals**: 1 ターン処理の一部として呼ばれる。cards は最大 8 枚程度。パフォーマンス制約なし。

**Constraints**: Phaser / DOM API の import 禁止、引数の GameState を変更しない

**Scale/Scope**: 1 関数・1 ファイル

## Constitution Check

| 原則 | 状態 | 備考 |
|------|------|------|
| アーキテクチャ境界（src/game/ はPhaser/DOM非依存） | ✅ PASS | card.ts は pure TS |
| テストゲート（Vitest + fast-check, coverage ≥80%） | ✅ PASS | 境界値 + プロパティテストを実施 |
| ゲームバランス不変条件（数値は constants.ts から） | ✅ PASS | PARAM_DELTA を参照 |
| グラフDB（設計決定を Neo4j に同期） | ✅ PASS | 完了後に /sync-graphdb を実行 |
| 依存関係（承認済みライセンスのみ） | ✅ PASS | 新規 npm 依存なし |

## Project Structure

### Documentation (this feature)

```text
specs/006-card-engine/
├── plan.md              # This file
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # /speckit-tasks output（未作成）
```

### Source Code

```text
src/game/
├── types.ts             # 既存: GameState / CardEffect / MemberUpdate / CardName 型
├── constants.ts         # 既存: PARAM_DELTA（ONE_ON_ONE_MORALE 等）
└── card.ts              # NEW: applyCards

tests/unit/
└── card.test.ts         # NEW: 境界値テスト + fast-check プロパティテスト
```

## Key Design Decisions

### CardApplicationResult はローカル型として card.ts に定義する

`CardApplicationResult` は `applyCards` の戻り値専用の型。
types.ts には追加しない（types.ts は Phaser Scene からも参照されるため、
game-logic の実装詳細を追加したくない）。
card.ts の先頭で `export interface CardApplicationResult { ... }` として定義する。

### グループ A: 確率低減セット系の CardEffect 設計

| カード | effectType | targetId | remainingTurns |
|--------|------------|----------|----------------|
| デイリー | `task_event_prob_reduced` | `'project'` | `null` |
| レビュー | `rework_prob_reduced` | `'project'` | `null` |
| モニタリング | `overreport_prob_reduced` | `'project'` | `null` |

- `targetId = 'project'` はプロジェクト全体への効果を示す慣例（types.ts コメント参照）
- `remainingTurns = null` = 手動解除まで継続
- 同じカードが複数含まれる場合は複数エントリを生成する（重複排除はしない）

### グループ B: 即時メンバー系のターゲット解決

今回は最小実装として `state.members[0]` を対象とする。
メンバーが 0 人の場合は memberUpdates に何も追加しない（パニックしない）。
完全な自動解決ルール（最も心が低いメンバーを選ぶ等）は後続 Spec で実装する。

| カード | moraleDelta | healthDelta |
|--------|-------------|-------------|
| 個別面談 | ONE_ON_ONE_MORALE (15) | 0 |
| 表彰 | COMMENDATION_MORALE (30) | 0 |
| 計画休 | PLANNED_LEAVE_MORALE (20) | PLANNED_LEAVE_HEALTH (25) |

### スコープ外カードの扱い

上記 6 種以外のカードは switch 文のデフォルトケースでスキップ（無視）する。
エラーは発生させない。

### turn.ts との統合は今回のスコープ外

Spec-06 は `card.ts` の実装と単体テストのみを対象とする。
`turn.ts` の `void cards` を `applyCards` に置き換える統合は別 Spec とする。
