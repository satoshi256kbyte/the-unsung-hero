# 週モデル変更（ターン＝暦日・7ターン周期）設計

## 概要

`docs/03-詳細設計/ステージ/*.md`のガントチャート表記を一般的なガントチャート（日付列・
土日非表示・予定/実績・稲妻線）に見直す計画の第1段階。土台となる「ターンと曜日の対応」を
現状の「5ターン=1週間（土日はターンを消費しない）」から「ターン＝暦日（土日もターンとして
存在し、7ターンで1週間）」に変更する。

休日出勤カードで土日を稼働ターンに変換する仕様である以上、土日がターン番号を
持たないと整合しないため、この変更が必要になる。

## 現状分析

- `turn.ts`は`state.turn % 5 === 0`で週末回復を判定し、進捗ダイス（`rollProgress`）は
  ステップ3で全メンバー・全ターンに対し無条件に実行される（土日でも進捗が進む）
- `ターン処理フロー.md`に書かれた14ステップのうち、固定イベント判定
  （キックオフ・週次進捗会議・締め・クロージング）は実装が存在しない
  （`CHECKPOINT_PROB`定数のみでロジックなし）。本Specのスコープ外として現状維持する
- `休出`カードはSpec-13時点でスタブ（効果なし）のまま
- カードの対象メンバー選択は、個別面談・表彰・計画休いずれも`state.members[0]`固定。
  プレイヤーが対象を選ぶ仕組みは存在しない

## 決定事項

1. ターン＝暦日。週の起点は月曜（ターン1=月曜、5=金曜、6=土、7=日、8=翌週月曜…）
2. 画面表示は「ターン」ではなく「◯日目」と表現する
3. PoCステージの締切は実働日数（22日相当）を維持するため増やす
   （土日を挟む分、約30〜31ターンに再校正。具体的な値はテストプレイ後のバランス調整）
4. 休出は土日で別カード「休出（土）」「休出（日）」とする
5. 休出は1枚＝メンバー1人分。効果は使用したその週だけ
6. 休出の対象メンバーは使用時にプレイヤーが選択する（新規の対象選択UIが必要）
7. 既存の個別面談・表彰・計画休（`state.members[0]`固定）は今回リトロフィットしない
   （対象選択の仕組みが使えるようにはなるが、既存カードの挙動変更は本Specのスコープ外）

## 曜日判定

```typescript
// src/game/calendar.ts（新規）
export function isWeekend(turn: number): boolean {
  const dayOfWeek = (turn - 1) % 7; // 0=月, 1=火, ..., 5=土, 6=日
  return dayOfWeek === 5 || dayOfWeek === 6;
}

export function dayNumber(turn: number): number {
  return turn; // 画面表示用。「turn」をそのまま「◯日目」として使う
}
```

## `turn.ts`の変更

- ステップ3（進捗ダイス）: `isWeekend(state.turn)`かつ、その週の休出効果が
  対象メンバーに適用されていない場合はダイスをスキップする
  （タスクは進捗せず、タスクの`status`はactiveのまま据え置き）
- 週末回復の判定: `state.turn % 5 === 0`から、実際の週境界
  （`dayOfWeek(state.turn) === 6`＝日曜終了時、または次の月曜開始時）に基づく判定に変更する

## 休出（土）・休出（日）カード

- `CardName`ユニオンに`"休出（土）"` `"休出（日）"`を追加し、既存の`"休出"`を置き換える
- Spec-13のファイル構造に従い`src/game/cards/holiday-work-sat.ts` /
  `holiday-work-sun.ts`として実装（既存の`holiday-work.ts`は削除）
- 効果: 使用した週の該当曜日（土または日）について、指定した対象メンバーの
  進捗ダイス・稼働イベント判定を「稼働扱い」にする1回限りの効果
  （`CardEffect`として`activeEffects`に積み、対象週の該当ターンが過ぎたら
  `applyEffectTick`で自然消滅する）
- 使用コストは既存の`休出`（コスト6）を踏襲するか、1人分になったことを踏まえて
  バランス調整する（テストプレイ後）

## 対象選択の仕組み（新規）

現状カードは`applyEffect(state: GameState)`で対象を固定的に決めている。
休出カードのために、対象を外部から渡せるようにする。

```typescript
// src/game/cards/index.ts
export interface CardDefinition {
  readonly cost: number;
  readonly requiresTarget?: boolean; // trueならUI側で対象選択を要求する
  applyEffect(
    state: GameState,
    targetId?: string,
  ): { effectsToAdd: CardEffect[]; memberUpdates: MemberUpdate[] };
}

export function applyCards(
  state: GameState,
  cards: { name: CardName; targetId?: string }[],
): CardApplicationResult;
```

既存25種のカードは`applyEffect(state)`のシグネチャのまま変更不要
（TypeScriptの構造的部分型により、引数の少ない関数は互換性を保つ）。

### UI側（`src/ui/CardSlot.ts` / `src/ui/MainGameUI.ts`）

- `CardSlot`に`targetMemberId: string | null`フィールドを追加
- `requiresTarget`なカードがスロットに置かれたとき、対象選択オーバーレイ
  （`data-testid="target-picker"`、メンバーごとに`data-testid="target-member-<id>"`
  ボタン）を表示し、選択されるまでスロットは未確定状態にする
- `getPlacedCards()`の戻り値を`CardName[]`から`{name: CardName; targetId?: string}[]`に変更する

## PoCステージデータの再校正

- `public/data/stages/poc-01.json`の`deadline`を約30〜31に変更する
  （具体的な値・`conditionalEvents`のターン番号の再校正はテストプレイ後の
  バランス調整として別途行う。本Specでは「土日を挟んでも実働日数が変わらない」
  という整合性の確保を優先し、暫定値を設定する）

## 影響を受ける既存ファイル

- `src/game/turn.ts`（進捗ダイスの土日スキップ、週末回復判定）
- `src/game/member.ts`（`applyWeekendRecovery`の呼び出し条件は`turn.ts`側で変更）
- `src/game/cards/index.ts`（`CardDefinition`インターフェース、`applyCards`シグネチャ）
- `src/game/cards/holiday-work.ts`（削除、2ファイルに置き換え）
- `src/game/types.ts`（`CardName`ユニオンの変更）
- `src/game/schemas/cardData.ts`（変更なし、コスト形状は同じ）
- `src/ui/CardSlot.ts` `src/ui/MainGameUI.ts`（対象選択UI追加）
- `public/data/cards/`（`holiday-work.json`を`holiday-work-sat.json` /
  `holiday-work-sun.json`に置き換え）
- `public/data/stages/poc-01.json`（`deadline`再校正）
- `docs/03-詳細設計/カード/休出.md`（2ファイルに分割）
- `docs/03-詳細設計/バランスパラメータ.md`（「5稼働日ごと」等の記述を7ターン周期に更新）

## テスト方針

- `src/game/calendar.ts`の`isWeekend`は単体テストで全曜日パターンを検証する
- `turn.ts`の土日スキップ・週末回復タイミングの変更は既存の`turn.test.ts`に
  影響するため、既存テストを新しい週モデルに合わせて更新する
- 休出（土）・休出（日）カードは他の実装済みカードと同様に個別テストファイルを作成する
- 対象選択UIはPlaywright E2Eで検証する（既存のカード配置UIパターンに準拠）
