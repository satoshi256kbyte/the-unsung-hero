# Research: ゲームクリア/失敗のリザルト画面

**Spec**: [spec.md](./spec.md) | **Date**: 2026-08-31

spec.md の Assumptions で plan に先送りした論点（成否判定ルールの細部、利益率算出、
リザルトの実装方式、画面遷移、表示する主要数値の取得元）をここで解決する。

## 前提となる既存実装の把握

- ゲーム終了判定は `turn.ts` の `processTurn` が行い、`isGameOver`（allDone || deadlineExceeded）と
  `gameOverReason`（"全タスク完了" / "納期超過"）を `TurnResult` で返す。`engine.processTurn` が
  state を確定し `state.isGameOver` / `state.gameOverReason` に反映する。
- 利益・利益率は `MainGameUI` で `profit = state.budget - state.totalCost`、
  `profitRate = profit / state.budget`（予算 0 は "0.0"% にフォールバック）として算出・表示済み。
- 目標利益率は balance 定義 `GLOBAL_RULES.TARGET_PROFIT_RATE`（現行 0.05）。`StageSelectUI` が
  確認画面で率のみ表示している。
- タスク完了率は `gantt.ts` の `getCompletionRate(gantt)` で取得できる。
- 画面は DOM オーバーレイ（`src/ui/*UI.ts`、`#ui-overlay` 配下、`data-testid` 付き）で構成され、
  `src/scenes/*Scene.ts` が `this.scene.start("...")` で遷移する。Scene 構成は
  Boot → Preload → Title → StageSelect → Main。

## Decision 1: 成否判定ルール

**Decision**: クリア条件は「全タスク完了（納期内完遂）かつ 最終利益率 ≥ 目標利益率」。
それ以外（納期超過による終了、または全タスク完了でも利益率が目標未満）は失敗とする。

- 終了理由は既存の `gameOverReason`（"全タスク完了" / "納期超過"）を用いる。
- 成否は `outcome: "clear" | "fail"` として返す。

**Rationale**: spec FR-003 と、グラフDBの「利益＝予算−総消費コスト。目標利益を超えればクリア」
および Constitution III（目標利益率で成否を測る）に一致する。納期超過は全タスク未完了を含意し、
プロジェクト失敗として扱うのが自然。

**Alternatives considered**:

- 利益率を問わず全タスク完了なら常にクリア: Constitution III の「利益率で成否を測る」に反し、
  無策プレイでもクリアになりうるため却下。

## Decision 2: 利益・利益率の算出

**Decision**: `profit = budget - totalCost`、`profitRate = budget > 0 ? profit / budget : 0`。
既存 `MainGameUI` の算出式を踏襲し、予算 0 のゼロ除算は 0 にフォールバックする（FR-009）。

**Rationale**: 表示の一貫性（ダッシュボードとリザルトで同じ値）。FR-004 / FR-009 を満たす。

## Decision 3: 実装方式（純関数 + DOM オーバーレイ）

**Decision**: 成否判定・数値算出を `src/game/result.ts`（新規・純関数）に
`evaluateResult(state, targetProfitRate)` として実装し、`GameResult` を返す。表示は
`src/ui/ResultUI.ts`（新規・DOM オーバーレイ、`data-testid` 付き）が `GameResult` を描画する。

**Rationale**: Constitution 原則 I（`src/game/` は Phaser/DOM 非依存）。判定ロジックを純関数に
分離することで決定論的にユニットテストでき、表示は E2E で検証できる。既存 UI と同じ流儀。

**Alternatives considered**:

- 判定を UI 内で実施: ロジックが DOM 層に漏れ、テストしづらく原則 I に反するため却下。
- Phaser Scene としてリザルトを描画: 既存の情報表示画面は全て DOM オーバーレイであり、
  Playwright 参照性・実装一貫性のため DOM オーバーレイに合わせる。

## Decision 4: 表示タイミングと画面遷移

**Decision**: `MainScene.confirmTurn` の末尾で `engine.getState().isGameOver` が true になったら、
`evaluateResult` の結果を `ResultUI` に渡して表示する。リザルトの「タイトルへ戻る」で
`this.scene.start("TitleScene")` に遷移し、ResultUI を隠す。

- ゲーム終了後はターン確定ボタンを無効化し、リザルトが多重表示・二重進行しないようにする
  （FR-011、Edge Case）。engine は終了後の processTurn で例外を投げる既存挙動があるため、
  UI 側で確定を止める。

**Rationale**: 終了検知は engine が state を確定した直後が確実。遷移は既存の Scene 遷移に載せる。

## Decision 5: 表示する主要数値の取得元

**Decision**: `GameResult` に成否（outcome）、終了理由（reason）、利益（profit）、利益率
（profitRate）、目標利益率（targetProfitRate）、予算（budget）、総消費コスト（totalCost）、
経過ターン（turn）、タスク完了率（completionRate）を含める。completionRate は
`getCompletionRate(state.gantt)` で算出する。

**Rationale**: spec FR-006 の主要数値を漏れなく提示するため。すべて state と既存ヘルパーから
算出でき、新規の状態保持は不要。

## Decision 6: 同時成立時の優先順位

**Decision**: 全タスク完了と納期到達が同一ターンで同時成立した場合は「全タスク完了（納期内完遂）」を
優先する（FR-010）。既存 turn.ts も allDone を先に評価し gameOverReason="全タスク完了" とするため、
その挙動をそのまま採用する。

**Rationale**: 既存の終了判定ロジックと一致し、追加分岐が不要。納期最終日にすべて完了した場合は
成功として扱うのが自然。

## 未解決事項

なし。リザルト画面のレイアウト・文言・演出は実装フェーズ（tasks）で確定する
（本 research で提示する情報項目と成否ルールに沿って表示する）。
