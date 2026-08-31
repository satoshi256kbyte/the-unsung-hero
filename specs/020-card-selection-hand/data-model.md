# Data Model: カード選択・手札への組み込み機能

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md) | **Date**: 2026-08-30

## エンティティ変更

### StageData（既存を拡張）

`src/game/types.ts` の `StageData` と `schemas/stageData.ts` に配布プール・手札上限を追加する。

| フィールド | 型 | 説明 | 追加/既存 |
|-----------|-----|------|----------|
| initialCards | CardName[] | 初期配布カード | 既存 |
| cardPool | CardPoolEntry[] | 配布プール（配布され得るカードと重み・回数上限） | 追加 |
| handLimit | number | 手札上限枚数 | 追加 |

### CardPoolEntry（新規）

| フィールド | 型 | 説明 |
|-----------|-----|------|
| name | CardName | 配布対象カード名 |
| weight | number | 出やすさ（相対重み、正の数） |
| maxDraws | number \| undefined | ステージ中の配布回数上限（省略時は無制限） |

### GameState（既存を拡張）

| フィールド | 型 | 説明 | 追加/既存 |
|-----------|-----|------|----------|
| hand | CardName[] | 現在の手札 | 既存 |
| drawCounts | Record<string, number> | カード名→累計配布回数 | 追加 |

## 検証ルール

- `weight` は正の数（0 以下は配布対象にならない、またはスキーマで min>0 を要求）。
- `maxDraws` は省略可。指定時は 1 以上の整数。
- `handLimit` は 1 以上。`initialCards.length <= handLimit` をステージ定義で整合させる
  （満たさない場合は初期配布を handLimit までに丸める、または検証で警告）。
- 既存ステージ JSON は cardPool/handLimit 未記載の可能性があるため、スキーマ上は
  cardPool を既定 `[]`、handLimit を既定値（例: initialCards.length）で補完する。

## 状態遷移（配布回数と手札）

```text
ステージ開始
  hand = initialCards（handLimit 以下）
  drawCounts = initialCards の各カードを +1 した集計
       │  ターン確定 → 次ターン開始
       ▼
補充ステップ（handLimit に満たない場合）
  配布可能カード = cardPool のうち drawCounts[name] < maxDraws（または maxDraws 無し）
  不足分 = handLimit - hand.length
  重み付き抽選で不足分を配布（配布可能が尽きたら打ち切り）
  配布したカードを hand に追加し drawCounts を加算
```

## 派生・補助（保存しない）

補充ロジックは純関数として算出する（`src/game/deck.ts` 新規）。

- `eligibleEntries(pool, drawCounts)`: maxDraws 未到達のプールエントリ集合
- `drawCards(pool, drawCounts, hand, handLimit, rng)`: 補充後の hand と drawCounts を返す

## 影響範囲

| ファイル | 変更内容 |
|---------|---------|
| `src/game/types.ts` | StageData に cardPool/handLimit、GameState に drawCounts、CardPoolEntry 型を追加 |
| `src/game/schemas/stageData.ts` | cardPool/handLimit のスキーマ追加（既定値補完） |
| `src/game/deck.ts` | 新規。eligibleEntries / drawCards（重み付き抽選・上限除外の純関数、rng 注入可） |
| `src/game/engine.ts` | buildInitialState で drawCounts 初期化、processTurn に補充ステップ追加 |
| `public/data/stages/poc-01.json` | cardPool・handLimit を追加、initialCards を再構成（休出はプールへ） |
