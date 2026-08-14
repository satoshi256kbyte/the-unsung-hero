# Data Model: タイトル〜ステージセレクト画面遷移

## StageData（既存、変更点のみ）

| フィールド | 変更内容 |
| ---------- | -------- |
| `description` | 新規追加。`string`型。ステージ確認画面に表示するプロジェクト概要文 |

その他の既存フィールド（`id` `name` `budget` `deadline` `initialMembers`
`initialGantt` `ganttVariants` `conditionalEvents` `initialCards`）は変更しない。

`src/game/schemas/stageData.ts`の`stageDataSchema`にも同じ`description: z.string()`を
追加し、`public/data/stages/poc-01.json`に実際の説明文を追記する。

## StageSelectUIの内部状態（新規、実装詳細）

コード上の型ではなくUIクラス内部の状態のみ。永続化しない。

| 状態 | 説明 |
| ---- | ---- |
| `mode: "list" \| "confirm"` | 一覧表示か確認表示かを切り替える |
| `selectedStageId: string \| null` | 確認表示中に選択されているステージid |

## Scene間データ受け渡し

| 遷移 | 渡すデータ |
| ---- | ---------- |
| `TitleScene` → `StageSelectScene` | なし |
| `StageSelectScene` → `MainScene` | `{ stageId: string }` |

## 状態遷移図（画面レベル）

```text
[TitleScene]
  --(スタート)--> [StageSelectScene: list]
                    --(ステージ選択)--> [StageSelectScene: confirm]
                    <--(もどる)--
                    --(開始する)--> [MainScene]
```
