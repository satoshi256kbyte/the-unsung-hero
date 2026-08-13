# Feature Specification: 条件付きイベントエンジン

**Feature Branch**: `009-conditional-event-engine`

**Created**: 2026-08-13

**Status**: Draft

## User Scenarios & Testing

### User Story 1 - 条件式の評価（Priority: P1）

ゲーム状態（GameState）を受け取り、条件式文字列が現在の状態に合致するかを判定する。
判定結果は真偽値として返され、何らかのエラーは発生しない。

**Why this priority**: 条件付きイベント発火の根幹機能。この機能がないと後続の全ユーザーストーリーが成立しない。

**Independent Test**: `evaluateCondition(state, "turn >= 5")` のような呼び出しで
正しい真偽値が返ることをユニットテストで確認できる。

**Acceptance Scenarios**:

1. **Given** ターン数が5のGameState, **When** `"turn >= 5"` を評価, **Then** `true` を返す
2. **Given** ターン数が3のGameState, **When** `"turn >= 5"` を評価, **Then** `false` を返す
3. **Given** 完了率0.95のガントチャートを持つGameState, **When** `"completion_rate >= 0.9"` を評価,
   **Then** `true` を返す
4. **Given** 残予算が50万のGameState, **When** `"budget_remaining <= 500000"` を評価,
   **Then** `true` を返す
5. **Given** メンバーの士気が最低値のGameState, **When** `"any_member_morale < 30"` を評価,
   **Then** `true` を返す
6. **Given** 全メンバーの士気が高いGameState, **When** `"all_members_morale < 30"` を評価,
   **Then** `false` を返す
7. **Given** 任意のGameState, **When** `"unknown_condition"` を評価, **Then** `false` を返す（エラーなし）

---

### User Story 2 - 条件付きイベントの発火（Priority: P1）

ConditionalEvent の配列とGameStateを受け取り、条件が成立したイベントのみをGameEventとして返す。
条件不成立のイベントや、まだ発火すべきでないターンのイベントは除外される。

**Why this priority**: US1の評価ロジックを活用して実際のイベント発火を実現する中核機能。

**Independent Test**: 条件が成立する ConditionalEvent を1件だけ含む配列を渡し、
返却される GameEvent[] に1件含まれることをテストで確認できる。

**Acceptance Scenarios**:

1. **Given** 条件 `"turn >= 3"` のConditionalEventとターン3のGameState,
   **When** `rollConditionalEvents` を呼び出す, **Then** GameEventが1件返る
2. **Given** 条件 `"turn >= 5"` のConditionalEventとターン3のGameState,
   **When** `rollConditionalEvents` を呼び出す, **Then** 空配列が返る
3. **Given** 複数のConditionalEventsで条件成立が2件,
   **When** `rollConditionalEvents` を呼び出す, **Then** GameEventが2件返る
4. **Given** 空の ConditionalEvents 配列,
   **When** `rollConditionalEvents` を呼び出す, **Then** 空配列が返る

---

### User Story 3 - ターン処理との統合（Priority: P2）

`processTurn` が条件付きイベントを受け取り、ランダムイベントと同様に TurnResult.events へ統合する。
呼び出し元が条件付きイベントを渡さない場合は省略可能（デフォルト空配列）。

**Why this priority**: 実際のゲームループで動作させるための統合層。
POC段階では空配列での呼び出しが多いため優先度は P2。

**Independent Test**: `processTurn` に条件成立の ConditionalEvent を渡すと、
返却される `TurnResult.events` にその GameEvent が含まれることをテストで確認できる。

**Acceptance Scenarios**:

1. **Given** 条件が成立するConditionalEventsを持つ `processTurn` 呼び出し,
   **When** ターン処理を実行, **Then** `TurnResult.events` に条件付きイベントが含まれる
2. **Given** `processTurn` を第3引数なしで呼び出す,
   **When** ターン処理を実行, **Then** 既存テストがすべてPASSのまま（後方互換）
3. **Given** 空の conditionalEvents を渡す,
   **When** ターン処理を実行, **Then** ランダムイベントのみが events に含まれる

---

### User Story 4 - イミュータブル操作（Priority: P2）

評価関数・発火関数はいずれも入力の GameState・ConditionalEvent[] を変更せず、
新しいオブジェクトを返す。

**Why this priority**: アーキテクチャ上の不変条件。副作用が混入すると
デバッグや再現テストが困難になる。

**Independent Test**: 呼び出し前後で元の GameState が同一オブジェクトのまま変化していない
ことをテストで確認できる。

**Acceptance Scenarios**:

1. **Given** evaluateCondition 呼び出し前の GameState スナップショット,
   **When** evaluateCondition を呼び出す, **Then** GameState は変更されていない
2. **Given** rollConditionalEvents 呼び出し前の ConditionalEvent[] スナップショット,
   **When** rollConditionalEvents を呼び出す, **Then** 元の配列は変更されていない

---

### Edge Cases

- `evaluateCondition` に空文字列を渡した場合は `false` を返す（エラーをスローしない）
- メンバーが0人のGameStateで `any_member_morale < N` を評価した場合は `false` を返す
- メンバーが0人のGameStateで `all_members_morale < N` を評価した場合は `true` を返す
  （`Array.every` の空配列の仕様に従う）
- ConditionalEvent の `turn` が現在ターンより大きい場合は評価をスキップし発火しない
- 同一ターンに複数の条件付きイベントが成立した場合、すべて発火する

## Functional Requirements

1. **条件式評価**: `evaluateCondition(state, condition)` は GameState と文字列を受け取り、
   boolean を返す純粋関数として動作する
2. **対応条件式**: 9種類の条件パターン
   （completion_rate 2種、turn 3種、budget_remaining 1種、member 系 3種）をサポートする
3. **未知条件のフォールバック**: 未定義の条件式は `false` を返す（例外をスローしない）
4. **条件付きイベント発火**: `rollConditionalEvents(state, conditionalEvents)` は
   条件成立のイベントのみを GameEvent[] に変換して返す
5. **ターン早期フィルタ**: ConditionalEvent の turn が現在ターンより大きい場合は評価しない
6. **イベントID生成**: 生成する GameEvent の id は
   `conditional-${state.turn}-${conditionalEvent.id}` とする
7. **processTurn 統合**: `processTurn` の第3引数に
   `conditionalEvents?: ConditionalEvent[]` を追加し省略時は空配列として扱う
8. **後方互換**: 既存の `processTurn(state, cards)` 呼び出しは変更なく動作する
9. **イミュータブル操作**: すべての関数は入力を変更せず新しい値を返す
10. **アーキテクチャ境界**: `src/game/` 内に実装し、Phaser/DOM を一切インポートしない

## Success Criteria

- 条件式の全パターン（9種）のユニットテストがすべて通過する
- 未知条件式を渡した際に例外が発生せず `false` が返る
- `rollConditionalEvents` の単体テストがすべて通過し、条件成立・不成立の両パターンをカバーする
- `processTurn` の既存テスト（206件）がすべて引き続き通過する
- テストカバレッジが lines ≥ 80%、functions ≥ 80% を維持する
- `tsc --noEmit` がエラー0で通過する
- Biome lint がエラー0で通過する
- `src/game/conditional.ts` が Phaser/DOM を一切インポートしていないことを grep で確認できる

## Key Entities

| エンティティ | 説明 |
|-------------|------|
| `evaluateCondition` | GameState と条件式文字列を受け取り boolean を返す純粋関数 |
| `rollConditionalEvents` | GameState と ConditionalEvent[] から GameEvent[] を生成する純粋関数 |
| `ConditionalEvent` | `id`, `condition`, `turn`, `event` フィールドを持つデータ型（types.ts に定義） |
| `GameEvent` | ランダムイベントと共通の型。条件付きイベントも同じ型に変換されて統合される |
| `GameState` | ターン、メンバー、ガントチャート、予算等を持つゲーム状態 |

## Dependencies

- Spec-02: ガントチャート・タスクモデル（`getCompletionRate` を使用）
- Spec-05: ターン処理エンジン（`processTurn` を更新）
- Spec-08: ランダムイベントエンジン（`TurnResult.events` への統合方式を踏襲）

## Assumptions

- `ConditionalEvent` 型は `src/game/types.ts` に追加する（`id: string`, `condition: string`,
  `turn: number`, `event: Omit<GameEvent, 'id'>` フィールドを持つ）
- `state.budget` と `state.totalCost` は GameState に既存のフィールドとして存在する
- `budget_remaining` は `state.budget - state.totalCost` として計算する
- POC 段階では条件付きイベントは空配列で運用し、Spec-11（PoCステージデータ）で実データが投入される
- 条件式のパーサーは使用せず、文字列マッチング（startsWith / includes）で判定する
