# Implementation Plan: 条件付きイベントエンジン

**Branch**: `009-conditional-event-engine` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

## Summary

`src/game/conditional.ts` を新規作成し、GameState を受け取って条件式文字列を評価する
`evaluateCondition` と、条件成立の ConditionalEvent を GameEvent に変換する
`rollConditionalEvents` を実装する。
合わせて `processTurn` の第3引数に `conditionalEvents?: ConditionalEvent[]` を追加し、
ランダムイベントと同じ統合パイプラインへ組み込む。

## Technical Context

**Language/Version**: TypeScript 5 (strict mode)

**Primary Dependencies**: Vitest + fast-check（テスト）

**Storage**: N/A（pure in-memory 操作）

**Testing**: Vitest + fast-check

**Target Platform**: Node.js（Vitest 実行環境）、ブラウザ（Vite バンドル後）

**Project Type**: ゲームロジック ライブラリ（Phaser/DOM 非依存）

**Performance Goals**: 単体ターン処理 < 1ms（既存制約に準じる）

**Constraints**: Phaser/DOM インポート禁止（アーキテクチャ境界）

**Scale/Scope**: conditional.ts 〜60行、conditional.test.ts 〜150行

## Constitution Check

| 原則 | 状態 | 備考 |
|------|------|------|
| Architecture Boundaries | PASS | src/game/ 内に実装、Phaser/DOM 非依存 |
| Test Coverage Gates | PASS | lines/functions ≥ 80% 維持必須 |
| Game Balance Invariant | N/A | 確率を持たない決定論的関数のため対象外 |
| Design Knowledge in Graph DB | PASS | after_specify フック済み（ADR-012 追加済み） |
| Dependency Hygiene | PASS | 新規依存なし |

## Key Decisions

### KD-1: ConditionalEvent 型は types.ts の既存定義を使用

types.ts に `ConditionalEvent` が既に定義されている:

```typescript
interface ConditionalEvent {
  id: string;
  turn: number;          // 条件評価ターン
  condition: string;     // 条件式文字列
  eventType: EventType;  // GameEvent.type に対応
  params: Record<string, unknown>; // category/targetId/etc.
}
```

`rollConditionalEvents` は ConditionalEvent → GameEvent に変換する際、
`params` から `category`・`targetId` を取り出して GameEvent を構築する。

### KD-2: 条件式文字列のパターン定義

`evaluateCondition` は以下9パターンを正規表現でマッチングする:

| 条件式パターン | 評価内容 |
|--------------|---------|
| `completion_rate >= N` | `getCompletionRate(state.gantt) >= N` |
| `completion_rate < N` | `getCompletionRate(state.gantt) < N` |
| `turn >= N` | `state.turn >= N` |
| `turn <= N` | `state.turn <= N` |
| `turn == N` | `state.turn === N` |
| `budget_remaining <= N` | `(state.budget - state.totalCost) <= N` |
| `any_member_morale < N` | `state.members.some(m => m.morale < N)` |
| `any_member_health < N` | `state.members.some(m => m.health < N)` |
| `all_members_morale < N` | `state.members.every(m => m.morale < N)` |

未知パターンは `false` を返す（例外なし）。

### KD-3: rollConditionalEvents のフィルタリング順序

1. `conditionalEvent.turn > state.turn` → スキップ（まだ発火しない）
2. `evaluateCondition(state, conditionalEvent.condition)` が `false` → スキップ
3. 両方パスしたら GameEvent を生成して返す

生成する GameEvent の id: `conditional-${state.turn}-${conditionalEvent.id}`

### KD-4: processTurn シグネチャ変更

```typescript
// before
export function processTurn(state: GameState, cards: CardName[]): TurnResult

// after
export function processTurn(
  state: GameState,
  cards: CardName[],
  conditionalEvents?: ConditionalEvent[]
): TurnResult
```

Step 5 の後に Step 5.5 として `rollConditionalEvents` を呼び出し、
結果を `events.push(...)` で統合する。
既存の呼び出しはデフォルト値（空配列）で後方互換を維持。

### KD-5: GameEvent 生成時の category / targetId 取得

ConditionalEvent.params に `category` や `targetId` が含まれうる:

```typescript
const event: GameEvent = {
  id: `conditional-${state.turn}-${ce.id}`,
  type: ce.eventType,
  category: (ce.params.category as EventCategory | undefined) ?? null,
  targetId: (ce.params.targetId as string | undefined) ?? null,
  params: ce.params,
};
```

## Project Structure

### Documentation (this feature)

```text
specs/009-conditional-event-engine/
├── plan.md              # This file
├── data-model.md        # 関数シグネチャ・フロー定義
├── quickstart.md        # 検証シナリオ
└── tasks.md             # /speckit-tasks コマンド出力
```

### Source Code

```text
src/game/
├── conditional.ts       # NEW: evaluateCondition / rollConditionalEvents
├── types.ts             # ConditionalEvent 型は既に定義済み（変更不要）
└── turn.ts              # processTurn シグネチャ更新・Step5.5 追加

tests/unit/
├── conditional.test.ts  # NEW: 単体テスト + fast-check プロパティテスト
└── turn.test.ts         # 条件付きイベント統合テスト追加
```
