# Research: PoCステージデータ

Phase 0 output for Spec-11

## evaluateCondition の対応パターン

`src/game/conditional.ts` を精読した結果、以下の6パターンが対応している。

| パターン | 例 |
|---|---|
| `turn >= N` | `turn >= 10` |
| `turn <= N` | `turn <= 5` |
| `turn == N` | `turn == 15` |
| `completion_rate >= N` | `completion_rate >= 0.8` |
| `completion_rate < N` | `completion_rate < 0.5` |
| `budget_remaining <= N` | `budget_remaining <= 500000` |
| `any_member_morale < N` | `any_member_morale < 60` |
| `any_member_health < N` | `any_member_health < 50` |
| `all_members_morale < N` | `all_members_morale < 80` |

- Decision: 条件付きイベントの condition 文字列はこの9パターンから選択する
- Rationale: spec.md FR-006 および既存実装との整合性を保つため
- Alternatives considered: 新パターン追加は Spec-09 改修が必要なためスコープ外

## GanttTask の初期 status

`src/game/types.ts` より `TaskStatus = "active" | "stalled" | "done"`。
PoC では全タスクの初期 status を `'active'` とする（`'waiting'` は型定義に存在しない）。
spec.md の Acceptance Scenario に `'waiting'` と記載があるが、
型定義に合わせ `'active'` で統一する（依存タスクも同様）。

- Decision: 全 GanttTask の初期 status は `'active'`
- Rationale: 型定義に `'waiting'` が存在しないため
- Alternatives considered: waiting 状態の追加は Spec-12 以降のスコープとする

## 3名目メンバー（キャロル）の skill 値

spec.md FR-002 に「キャロル（skill=6）」と明記されている。
constants.ts には `SKILL.INITIAL_A: 10, INITIAL_B: 8` のみ定義されており、
キャロル分の定数追加は不要（pocStage.ts にリテラルで記述する）。

- Decision: キャロルの skill を 6 とし、pocStage.ts にリテラルで定義
- Rationale: 定数は汎用パラメータ向けであり、キャロル固有値は stage データに直書きが適切
- Alternatives considered: constants.ts への追加は不要（定数肥大化を避ける）
