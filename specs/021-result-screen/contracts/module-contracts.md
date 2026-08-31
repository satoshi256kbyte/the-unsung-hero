# Contracts: ゲームクリア/失敗のリザルト画面

**Spec**: [spec.md](../spec.md) | **Data Model**: [../data-model.md](../data-model.md) | **Date**: 2026-08-31

本フィーチャーが公開・変更するモジュール契約（型・関数シグネチャ・UI contract）。
外部 API は持たず、ゲームロジック層と UI 層の内部契約が中心。

## 判定ロジック契約（`src/game/result.ts`、新規・純関数）

```typescript
export type GameOutcome = "clear" | "fail";

export interface GameResult {
  readonly outcome: GameOutcome;
  readonly reason: string;        // "全タスク完了" | "納期超過"（GameState.gameOverReason 由来）
  readonly profit: number;        // budget - totalCost
  readonly profitRate: number;    // budget>0 ? profit/budget : 0
  readonly targetProfitRate: number;
  readonly budget: number;
  readonly totalCost: number;
  readonly turn: number;
  readonly completionRate: number; // 0.0–1.0
}

/**
 * GameState から成否判定・利益率を算出する純関数。入力を変更しない。
 * クリア条件: 全タスク完了(reason==="全タスク完了")かつ profitRate >= targetProfitRate。
 * それ以外は "fail"。budget が 0 のとき profitRate は 0（ゼロ除算回避）。
 */
export function evaluateResult(
  state: GameState,
  targetProfitRate: number,
): GameResult;
```

- `src/game/` に置き、Phaser/DOM を import しない（Constitution 原則 I）。
- `state.gameOverReason` が null（ゲーム未終了）で呼ばれることは想定しない。呼び出し側
  （MainScene）は `isGameOver` を確認してから呼ぶ。

## UI 契約（`src/ui/ResultUI.ts`、新規・DOM オーバーレイ）

```typescript
export class ResultUI {
  constructor(root: HTMLElement);
  /** GameResult を描画してリザルト画面を表示する */
  show(result: GameResult): void;
  /** リザルト画面を隠す */
  hide(): void;
  /** 「タイトルへ戻る」押下時のコールバックを登録する */
  setOnBackToTitle(cb: () => void): void;
}
```

UI contract（Playwright 参照用 `data-testid`）:

| 要素 | data-testid | 説明 |
|------|-------------|------|
| リザルト画面ルート | `result-screen` | 表示中のみ可視 |
| 成否判定 | `result-outcome` | "CLEAR" / "FAILED" 等の判定表示 |
| 終了理由 | `result-reason` | 全タスク完了／納期超過 |
| 最終利益率 | `result-profit-rate` | 例: `12.3%` |
| 最終利益 | `result-profit` | 例: `¥1,000,000` |
| 主要数値 | `result-stats` | 目標利益率・予算・総消費コスト・経過ターン・完了率 |
| タイトルへ戻る | `result-back-to-title` | クリックで TitleScene へ |

## Scene 契約（`src/scenes/MainScene.ts`、挙動追加）

```typescript
// confirmTurn 末尾: engine.getState().isGameOver が true なら
//   const result = evaluateResult(state, TARGET_PROFIT_RATE)
//   this.ui.disableConfirm()（多重進行防止）
//   this.result.show(result)
// ResultUI の onBackToTitle: this.result.hide(); this.scene.start("TitleScene")
```

## 互換性契約

- `turn.ts` の終了判定（isGameOver/gameOverReason）と `processTurn` シグネチャは変更しない。
- `engine.ts` のシグネチャは変更しない（getState/processTurn をそのまま使用）。
- `MainGameUI` の既存表示は変更しない。リザルトは別オーバーレイとして追加する。
- 既存の Scene 遷移（Title/StageSelect/Main）は変更しない。Main → Title の戻り導線を追加するのみ。
