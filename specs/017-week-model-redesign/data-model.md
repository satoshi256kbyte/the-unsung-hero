# Data Model: 週モデル変更（ターン＝暦日・7ターン周期）

## CardName（既存、変更点のみ）

`"休出"`を削除し、`"休出（土）"` `"休出（日）"`を追加する。

## CardEffect（既存、新しい`effectType`値）

| `effectType` | 説明 |
| ------------- | ---- |
| `holiday_work_sat` | 休出（土）の効果。`targetId`=対象メンバーid。該当週の土曜まで有効 |
| `holiday_work_sun` | 休出（日）の効果。`targetId`=対象メンバーid。該当週の日曜まで有効 |

## CardDefinition（既存、変更点のみ）

```typescript
export interface CardDefinition {
  readonly cost: number;
  readonly requiresTarget?: boolean; // 新規。trueならUI側で対象選択を要求する
  applyEffect(
    state: GameState,
    targetId?: string, // 新規。対象メンバーid（対象選択カードのみ使用）
  ): { effectsToAdd: CardEffect[]; memberUpdates: MemberUpdate[] };
}
```

## StageData（変更点のみ）

`public/data/stages/poc-01.json`の以下の値を新しい週モデルに合わせて更新する。

| フィールド | 旧値 | 新値 |
| ---------- | ---- | ---- |
| `deadline` | 22 | 30 |
| `conditionalEvents[].turn` | 5, 10, 12, 16, 18 | 5, 12, 16, 22, 24 |

## CardSlot / MainGameUIの内部状態（新規、実装詳細）

| 状態 | 説明 |
| ---- | ---- |
| `CardSlot.targetMemberId: string \| null` | 対象選択カードが置かれた枠の、選択済み対象メンバーid |
| `MainGameUI`の対象選択オーバーレイ表示状態 | 対象選択待ちのスロットがある間、一覧をオーバーレイ表示する |

`getPlacedCards()`の戻り値を`CardName[]`から
`{ name: CardName; targetId?: string }[]`に変更する。

## 曜日インデックス

| ターン % 7 の結果（`(turn-1) % 7`） | 曜日 |
| ------------------------------------ | ---- |
| 0 | 月 |
| 1 | 火 |
| 2 | 水 |
| 3 | 木 |
| 4 | 金 |
| 5 | 土 |
| 6 | 日 |
