# Contracts: ゲーム内ガントチャートUI

**Spec**: [spec.md](../spec.md) | **Data Model**: [../data-model.md](../data-model.md) | **Date**: 2026-08-30

本フィーチャーが公開・変更するインターフェース契約。UI の DOM 契約（E2E 参照用の
`data-testid`）と、ゲームロジックの型・関数シグネチャ契約を定める。

## ゲームロジック契約（`src/game/`）

### `types.ts` GanttTask（拡張）

```typescript
export interface GanttTask {
  id: string;
  name: string;
  phase: string;
  startTurn: number;
  duration: number;
  assignedMemberId: string;
  progress: number;
  status: TaskStatus;
  dependencies: string[];
  actualStartTurn: number | null; // 追加: 実着手ターン（未着手 null）
  actualEndTurn: number | null; // 追加: 実完了ターン（未完了 null）
}
```

### `engine.ts` GameEngine.processTurn（挙動の追加）

シグネチャは不変。挙動として、タスク更新時に実績を記録する。

```typescript
processTurn(cards: { name: CardName; targetId?: string }[]): TurnResult;
// 追加挙動:
// - progress が 0 → 正 に増えたターン T で actualStartTurn が null なら actualStartTurn = T
// - progress が 100 に到達したターン T で actualEndTurn が null なら actualEndTurn = T
```

### 稲妻線算出（純関数、`src/game/gantt.ts` に追加）

```typescript
/** 予定進捗率（%）: 現在ターン currentTurn 時点で予定上あるべき進捗 */
export function plannedRate(task: GanttTask, currentTurn: number): number;

/** 予定に対する乖離（progress - plannedRate）。正=前倒し 負=遅れ */
export function progressDeviation(task: GanttTask, currentTurn: number): number;

/** 実績到達ターン座標（稲妻線の折れ位置） */
export function actualPosition(task: GanttTask): number;
```

これらは `src/game/`（ロジック層）に置き、DOM/Phaser を import しない（Constitution 原則 I）。

## UI 契約（`src/ui/GanttChartUI.ts` 新規）

```typescript
export class GanttChartUI {
  constructor(container: HTMLElement);
  /** 現在の GameState を受けて描画（閲覧専用、状態は変更しない） */
  render(state: GameState): void;
  /** 表示/非表示 */
  show(): void;
  hide(): void;
}
```

### DOM 契約（`data-testid`）

| data-testid | 要素 | 説明 |
| ----------- | ---- | ---- |
| `gantt-screen` | コンテナ | ガントチャート画面全体。show/hide で表示切替 |
| `gantt-turn-header` | 行 | ターン軸の列見出し（ターン1〜deadline） |
| `gantt-turn-col-<turn>` | セル | ターン列見出し。テキストは「N(曜)」形式 |
| `gantt-task-row-<taskId>` | 行グループ | タスク1件（予定行＋実績行を含む） |
| `gantt-planned-row-<taskId>` | 行 | 予定行 |
| `gantt-actual-row-<taskId>` | 行 | 実績行 |
| `gantt-planned-cell-<taskId>-<turn>` | セル | 予定行の各ターンセル（帯の有無） |
| `gantt-actual-cell-<taskId>-<turn>` | セル | 実績行の各ターンセル（帯の有無） |
| `gantt-lightning-line-<taskId>` | 要素 | 当該タスク行の稲妻線（折れ方向を属性で表現） |
| `gantt-task-select-<taskId>` | ボタン/行 | タスク選択操作の対象 |
| `gantt-dep-highlight-<taskId>` | 要素 | 選択タスクの先行タスクとしてハイライトされた表示 |
| `gantt-no-dep-<taskId>` | 要素 | 選択タスクに先行タスクが無いことの表示 |

### 稲妻線の折れ方向表現

`gantt-lightning-line-<taskId>` は折れ方向を属性で公開し、E2E が判定できるようにする。

| 属性値（`data-deviation`） | 意味 |
| ------------------------- | ---- |
| `ahead` | 前倒し（現在ターン列より右に折れる） |
| `behind` | 遅れ（現在ターン列より左に折れる） |
| `ontrack` | 予定どおり（折れなし） |

## `MainGameUI.ts`（変更）

ダッシュボードとガント画面を切り替えるメニューを追加する。

```typescript
// 追加する画面切替メニューの DOM 契約
```

| data-testid | 要素 | 説明 |
| ----------- | ---- | ---- |
| `nav-gantt-btn` | ボタン | ガントチャート画面を開く |
| `nav-dashboard-btn` | ボタン | ダッシュボード（メイン画面）へ戻る |

`MainGameUI` の既存メソッド（`render` / `getPlacedCards` / `setOnConfirm` / `reset`）の
シグネチャは変更しない。

## 互換性契約

- `turn.ts` の `processTurn(state, cards, conditionalEvents?)` のシグネチャは変更しない。
  実績記録は engine 側で行う。
- 既存の `updateTaskProgress` / `setTaskStatus` / `getCompletionRate` / `applyVariant` の
  シグネチャは変更しない（`applyVariant` は実績引き継ぎのため内部挙動を拡張する可能性がある）。
- 既存ステージJSONは実績フィールド未記載でもロード可能（optional + null 補完）。
