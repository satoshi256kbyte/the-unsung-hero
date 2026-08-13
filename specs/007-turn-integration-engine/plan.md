# Implementation Plan: ターン統合エンジン（カード効果 × アクティブ効果管理）

**Branch**: `007-turn-integration-engine` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/007-turn-integration-engine/spec.md`

## Summary

Spec-05 の `turn.ts` が `void cards` でスキップしていたカード処理を、Spec-06 で完成した
`applyCards` と組み合わせて実際に動作させる。併せて `effect.ts`（アクティブ効果管理純粋関数）を
新規実装し、effectTick・確率補正という2つの横断機能を提供する。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: Vitest + fast-check（テスト）、Biome（lint/format）

**Storage**: N/A

**Testing**: Vitest + fast-check プロパティテスト

**Target Platform**: Node.js（Vitest実行環境）、Phaser 4（ランタイム呼び出し元）

**Project Type**: game logic library（`src/game/` レイヤー）

**Performance Goals**: N/A（純粋関数・ターン単位）

**Constraints**: Phaser/DOM 非依存、全関数イミュータブル操作

**Scale/Scope**: 2ファイル追加・更新、TurnResult 型拡張

## Constitution Check

| 原則 | 状態 | 備考 |
|------|------|------|
| Architecture Boundary（I） | PASS | effect.ts・turn.ts は src/game/ のみ。Phaser/DOM 非依存 |
| Test Coverage Gates（II） | PASS 予定 | lines/functions ≥ 80% を目標（coverage 100% 想定） |
| Game Balance Invariant（III） | PASS | 確率補正係数 0.5 は既存 constants.ts の設計に整合 |
| Design Knowledge in Graph DB（IV） | PASS | sync-graphdb で ADR 追加予定 |
| Dependency Hygiene（V） | PASS | 新規外部依存なし |

## Key Design Decisions

### 1. TurnResult 型の拡張

`types.ts` の `TurnResult` に 2 フィールドを追加する。

```typescript
export interface TurnResult {
  // 既存フィールド（変更なし）
  events: GameEvent[];
  progressUpdates: ProgressUpdate[];
  memberUpdates: MemberUpdate[];
  costDelta: number;
  isGameOver: boolean;
  gameOverReason: string | null;
  // 追加フィールド
  activeEffectsAdded: CardEffect[];     // applyCards で得た effectsToAdd
  activeEffectsAfterTick: CardEffect[]; // 今ターン有効な全効果を tick した結果
}
```

Phaser Scene は `activeEffectsAfterTick` を次ターンの `state.activeEffects` にセットする。
`activeEffectsAdded` は UI 表示（どの効果が付与されたか）の参照用。

### 2. 今ターン有効なアクティブ効果の合成

手戻りイベント確率補正と tick の対象は
`[...state.activeEffects, ...effectsToAdd]`（前ターン継続 + 今ターン追加）とする。
この合成はターンスコープのローカル変数として持ち、GameState を変更しない。

### 3. EVENT_PROB.STALL の追加

`constants.ts` の `EVENT_PROB` に `STALL: 0.05` を追加する。
`SPEC_UNCLEAR（0.05）` と同値。停滞イベント本体の実装は別 Spec だが、
確率補正関数（`calcEventProbModifier`）はこの値を参照するため今回追加する。

### 4. memberUpdates の統合方針

カード由来の `MemberUpdate[]`（`applyCards` 結果）と
ターン decay 由来の `MemberUpdate[]` を同一配列に結合して TurnResult に返す。
Phaser Scene 側で全デルタを合算適用する。

### 5. processTurn の処理順序

```
1. applyCards(state, cards)          → effectsToAdd, cardMemberUpdates
2. currentEffects = [...state.activeEffects, ...effectsToAdd]
3. 進捗ダイス（各メンバーのアクティブタスク）
4. パラメータ decay + 週末回復       → decayMemberUpdates
5. 手戻りイベント判定（calcEventProbModifier で確率補正）
6. applyEffectTick(currentEffects)   → activeEffectsAfterTick
7. return TurnResult（全フィールド）
```

`memberUpdates = [...cardMemberUpdates, ...decayMemberUpdates]` として統合。

### 6. effect.ts の関数シグネチャ

```typescript
export function applyEffectTick(effects: CardEffect[]): CardEffect[]
export function calcEventProbModifier(
  effects: CardEffect[],
  baseProb: number,
  effectType: EffectType,
): number
```

`calcEventProbModifier` は同 effectType が 1 件以上あれば `baseProb * 0.5` を返す。
重複スタックなし（複数件あっても 0.5 倍のみ）。

## Project Structure

### Documentation (this feature)

```text
specs/007-turn-integration-engine/
├── plan.md          ← このファイル
├── data-model.md    ← Phase 1 出力
├── quickstart.md    ← Phase 1 出力
└── tasks.md         ← /speckit-tasks 出力
```

### Source Code

```text
src/game/
├── types.ts        （UPDATE: TurnResult に activeEffectsAdded / activeEffectsAfterTick 追加）
├── constants.ts    （UPDATE: EVENT_PROB.STALL 追加）
├── effect.ts       （NEW: applyEffectTick / calcEventProbModifier）
└── turn.ts         （UPDATE: void cards → カード統合フロー）

tests/unit/
├── effect.test.ts  （NEW）
└── turn.test.ts    （UPDATE: カード有りターンのテスト追加）
```

## Complexity Tracking

Constitution 違反なし。Complexity Tracking 不要。
