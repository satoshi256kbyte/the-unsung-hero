# Data Model: docsガントチャート表記見直し（カレンダー列形式）

本Specはドキュメント表記の変更のみであり、新規のデータ型・スキーマは
導入しない。既存の`public/data/stages/poc-01.json`（`StageData`型、
Spec-15のzodスキーマ `stageDataSchema`）をそのまま参照し、Markdown表として
表現し直すだけである。参照する既存フィールドは以下の通り。

## 参照する既存フィールド（`public/data/stages/poc-01.json`）

| フィールド | 用途 |
| ---------- | ---- |
| `deadline` | ヘッダーテーブルの「締切ターン」欄、およびガントチャート表の列数 |
| `initialCards` | ヘッダーテーブルの「初期カード」欄 |
| `initialGantt.tasks[].id` / `.name` | ガントチャート表の行ラベル |
| `initialGantt.tasks[].startTurn` / `.duration` | 各タスク行のセル（■/・/空欄）の範囲判定 |
| `conditionalEvents[].turn` / `.params.message` / `.condition` | 条件付きイベント表の各列 |

## 導出する値（docs生成時のみ、JSON化・型定義はしない）

- **曜日**: `dayOfWeek(turn) = (turn - 1) % 7`（`src/game/calendar.ts`と同一ロジックを
  表生成時に手動踏襲。0=月, 1=火, 2=水, 3=木, 4=金, 5=土, 6=日）
- **セル値**: タスク`t`・ターン`n`について
  - `startTurn(t) <= n <= startTurn(t) + duration(t) - 1` かつ 平日 → `■`
  - 同条件かつ土日 → `・`
  - それ以外 → 空欄（表示しない）

新規Entity・状態遷移はない。
