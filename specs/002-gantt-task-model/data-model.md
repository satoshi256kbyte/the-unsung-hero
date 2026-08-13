# Data Model: ガントチャート・タスクモデル

## 既存エンティティ（Spec-01 定義済み・再利用）

### GanttTask（`src/game/types.ts`）

| フィールド | 型 | 説明 |
|-----------|-----|------|
| id | string | タスク識別子 |
| name | string | タスク名 |
| phase | string | 所属工程（'設計' / '実装' / 'テスト' 等） |
| startTurn | number | 開始ターン（1-indexed） |
| duration | number | 計画期間（ターン数） |
| assignedMemberId | string | 担当メンバーID |
| progress | number | 現在進捗（0.0〜100.0） |
| status | TaskStatus | タスク状態（'active' / 'stalled' / 'done'） |
| dependencies | string[] | 先行タスクID一覧 |

### GanttChart（`src/game/types.ts`）

| フィールド | 型 | 説明 |
|-----------|-----|------|
| tasks | GanttTask[] | タスク一覧 |
| variantId | string \| null | 適用中バリアントID（null = デフォルト） |

---

## 新規関数インターフェース（`src/game/gantt.ts`）

### updateTaskProgress

```
updateTaskProgress(task: GanttTask, delta: number): GanttTask
```

| 引数/戻り値 | 型 | 説明 |
|------------|-----|------|
| task | GanttTask | 更新対象タスク（イミュータブル操作） |
| delta | number | 進捗変化量（%単位、正負両方） |
| 戻り値 | GanttTask | 更新後の新しいタスクオブジェクト |

- `progress` を `clamp(task.progress + delta, 0, 100)` で更新
- `progress === 100` になった場合 `status` を `done` に遷移

### setTaskStatus

```
setTaskStatus(task: GanttTask, status: TaskStatus): GanttTask
```

| 引数/戻り値 | 型 | 説明 |
|------------|-----|------|
| task | GanttTask | 更新対象タスク |
| status | TaskStatus | 新しい状態 |
| 戻り値 | GanttTask | 更新後の新しいタスクオブジェクト |

### applyRework

```
applyRework(task: GanttTask, skill: number): GanttTask
```

| 引数/戻り値 | 型 | 説明 |
|------------|-----|------|
| task | GanttTask | 手戻り対象タスク |
| skill | number | 担当メンバーの技レベル |
| 戻り値 | GanttTask | 進捗が巻き戻された新しいタスクオブジェクト |

- 巻き戻し率 = `REWORK.ROLLBACK_BASE − skill × REWORK.ROLLBACK_COEFF`
- `progress` を `clamp(task.progress − task.progress × 巻き戻し率, 0, 100)` で更新
- `status` は `active` のまま

### getCompletionRate

```
getCompletionRate(gantt: GanttChart): number
```

| 引数/戻り値 | 型 | 説明 |
|------------|-----|------|
| gantt | GanttChart | ガントチャート |
| 戻り値 | number | 完了率（0.0〜1.0）。タスクが0件の場合は 0.0 |

- `gantt.tasks` 中 `status === 'done'` のタスク数 ÷ 全タスク数

### applyVariant

```
applyVariant(gantt: GanttChart, variantId: string, variants: Record<string, GanttChart>): GanttChart
```

| 引数/戻り値 | 型 | 説明 |
|------------|-----|------|
| gantt | GanttChart | 現在のガントチャート |
| variantId | string | 適用するバリアントID |
| variants | Record\<string, GanttChart\> | 利用可能なバリアント一覧（StageData.ganttVariants） |
| 戻り値 | GanttChart | 差し替え後のガントチャート。IDが存在しない場合は元の gantt を返す |

---

## 依存関係

```
src/game/gantt.ts
  └── 依存: src/game/types.ts（GanttTask, GanttChart, TaskStatus）
  └── 依存: src/game/constants.ts（REWORK.ROLLBACK_BASE, REWORK.ROLLBACK_COEFF）

tests/unit/gantt.test.ts
  └── 依存: src/game/gantt.ts
```
