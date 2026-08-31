# Data Model: ゲームクリア/失敗のリザルト画面

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md) | **Date**: 2026-08-31

## エンティティ

### GameResult（新規・派生値、保存しない）

ゲーム終了時に `GameState` から算出するリザルト情報。`src/game/result.ts` の `evaluateResult` が返す。

| フィールド | 型 | 説明 |
|-----------|-----|------|
| outcome | "clear" \| "fail" | 成否判定 |
| reason | "全タスク完了" \| "納期超過" | 終了理由（既存 gameOverReason 由来） |
| profit | number | 最終利益（budget − totalCost） |
| profitRate | number | 最終利益率（budget>0 なら profit/budget、else 0） |
| targetProfitRate | number | 目標利益率（判定基準、balance 定義値） |
| budget | number | 予算 |
| totalCost | number | 総消費コスト |
| turn | number | 経過ターン（終了時点） |
| completionRate | number | タスク完了率 0.0–1.0（getCompletionRate 由来） |

## 判定ルール

```text
allDone       = reason === "全タスク完了"（= 納期内に全タスク完了）
profitMet     = profitRate >= targetProfitRate
outcome       = (allDone && profitMet) ? "clear" : "fail"
```

- 納期超過（reason === "納期超過"）は allDone=false のため常に "fail"。
- 全タスク完了でも profitRate が目標未満なら "fail"。
- 同時成立時は既存 turn.ts が "全タスク完了" を優先（reason に反映済み）。

## 検証ルール

- `profitRate` は budget が 0 のときゼロ除算にせず 0 とする（FR-009）。
- `profit` は負値を取りうる（totalCost > budget）。その場合 profitRate も負で "fail"。
- `evaluateResult` は入力 state を変更しない純関数。

## 影響範囲

| ファイル | 変更内容 |
|---------|---------|
| `src/game/result.ts` | 新規。`GameResult` 型と `evaluateResult(state, targetProfitRate)` 純関数 |
| `src/ui/ResultUI.ts` | 新規。GameResult を DOM 描画（data-testid 付き）、タイトルへ戻るコールバック |
| `src/scenes/MainScene.ts` | confirmTurn 末尾で終了検知時に ResultUI 表示、TitleScene へ遷移、確定ボタン無効化 |

## 既存資産との関係（変更しない）

- `GameState`（turn/budget/totalCost/gantt/isGameOver/gameOverReason）: 読み取りのみ
- `turn.ts` の終了判定（isGameOver/gameOverReason）: 変更しない
- `gantt.ts` の `getCompletionRate`: 再利用
- balance 定義 `GLOBAL_RULES.TARGET_PROFIT_RATE`: 判定基準として参照
