# Data Model: ゲーム内ガントチャートUI

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md) | **Date**: 2026-08-30

## エンティティ変更

### GanttTask（既存を拡張）

`src/game/types.ts` の `GanttTask` に実績フィールドを2つ追加する。

| フィールド | 型 | 説明 | 追加/既存 |
|-----------|-----|------|----------|
| id | string | タスク識別子 | 既存 |
| name | string | タスク名 | 既存 |
| phase | string | フェーズ名 | 既存 |
| startTurn | number | 計画開始ターン（1-indexed） | 既存 |
| duration | number | 計画期間（ターン数） | 既存 |
| assignedMemberId | string | 担当メンバー | 既存 |
| progress | number | 現在進捗 0.0–100.0 | 既存 |
| status | TaskStatus | active / stalled / done | 既存 |
| dependencies | string[] | 先行タスク id の配列 | 既存 |
| actualStartTurn | number \| null | 実際に着手したターン。未着手は null | 追加 |
| actualEndTurn | number \| null | 実際に完了したターン。未完了は null | 追加 |

### 検証ルール

- `actualStartTurn` は着手前は null。一度設定されたら以後変更しない。
- `actualEndTurn` は完了前は null。`actualStartTurn` が null のまま `actualEndTurn` が
  設定されることはない（着手なしに完了はない）。
- `actualEndTurn` が非 null のとき `actualStartTurn <= actualEndTurn` でなければならない。
- 既存のステージJSON（`public/data/stages/poc-01.json`）は実績フィールドを持たないため、
  ステージデータのスキーマ上は省略可能とし、ロード時に既定値 null を補完する。

### 状態遷移（実績の確定）

```text
未着手 (actualStartTurn=null, actualEndTurn=null)
   │  そのターンで progress が 0 → 正 に増加
   ▼
着手済み・進行中 (actualStartTurn=T1, actualEndTurn=null)
   │  progress が 100 に到達
   ▼
完了 (actualStartTurn=T1, actualEndTurn=T2)   ※ T1 <= T2
```

- 記録は `GameEngine.processTurn`（`src/game/engine.ts`）内のタスク更新時に行う。
  更新前の `state.turn` を T として用いる。
- `stalled`（停滞）は progress が増えないため `actualStartTurn` は変化しない。

## 派生データ（保存しない・描画時に算出）

ガント画面が `GameState` から描画のたびに算出する。永続化しない。

### 稲妻線の折れ量（タスクごと）

- `plannedRate = clamp((T - startTurn + 1) / duration, 0, 1) * 100`（T=現在ターン）
- `deviation = progress - plannedRate`（正=前倒し、負=遅れ、0=予定どおり）
- 実績到達ターン座標 `actualPos = startTurn - 1 + duration * (progress / 100)`
- 稲妻線は現在ターン列 T を基準に、`actualPos` との差を水平オフセットとして各タスク行で折る。

### 予定行・実績行の帯範囲（タスクごと）

| 行 | 開始ターン | 終了ターン |
|----|-----------|-----------|
| 予定行 | startTurn | startTurn + duration - 1 |
| 実績行 | actualStartTurn（null なら描画なし） | actualEndTurn（null かつ進行中なら現在ターン T） |

## リスケ（予定差し替え）時の扱い

- `ganttVariants` による差し替えで予定（startTurn/duration）が変わっても、同一 id のタスクの
  `actualStartTurn` / `actualEndTurn` は引き継ぐ（research.md Decision 4）。
- 差し替えで消えた id の実績は破棄、新規 id は実績 null。

## 影響範囲

| ファイル | 変更内容 |
|---------|---------|
| `src/game/types.ts` | GanttTask に actualStartTurn / actualEndTurn を追加 |
| `src/game/schemas/stageData.ts` | ganttTaskSchema に2フィールドを optional で追加、既定 null 補完 |
| `src/game/engine.ts` | processTurn のタスク更新時に実績を記録 |
| `src/game/gantt.ts` | 実績付きでリスケ差し替えする際の id ベース引き継ぎ（必要なら補助関数） |
| `public/data/stages/poc-01.json` | 変更不要（optional のため。省略時 null 補完） |
