# Contracts: 曜日判定・カード対象選択

## `src/game/calendar.ts`が公開する契約

```typescript
export function isWeekend(turn: number): boolean;
export function dayOfWeek(turn: number): 0 | 1 | 2 | 3 | 4 | 5 | 6; // 0=月〜6=日
```

## `src/game/cards/index.ts`が公開する契約（変更点）

```typescript
export interface CardDefinition {
  readonly cost: number;
  readonly requiresTarget?: boolean;
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

既存25種のカードは`applyEffect(state)`のシグネチャのまま変更不要。
`requiresTarget`を持たないカードは`targetId`を無視してよい。

## `src/ui/CardSlot.ts`が公開する契約（変更点）

```typescript
export class CardSlot {
  get targetMemberId(): string | null;
  setTarget(memberId: string): void;
  // place() / remove() は既存のまま。targetMemberIdはremove()でnullに戻る
}
```

## `src/ui/MainGameUI.ts`が公開する契約（変更点）

```typescript
getPlacedCards(): { name: CardName; targetId?: string }[]; // 戻り値の型変更
```

対象選択UIのDOM契約（`data-testid`）:

| data-testid | 要素 | 説明 |
| ----------- | ---- | ---- |
| `target-picker` | コンテナ | 対象選択が必要なカードをスロットに置いた直後に表示 |
| `target-member-<id>` | ボタン | メンバーごとの選択ボタン |

## 互換性契約

- `rollRandomEvents` `applyEventToProgress` `applyEventToMember`等、
  イベント関連の既存シグネチャは変更しない
- `turn.ts`の`processTurn(state, cards, conditionalEvents?)`は引数の数・順序を
  変更しない。ただし`cards`の要素型は`CardName`から`{ name: CardName; targetId?: string }`
  に変わるため、呼び出し元（`MainScene.confirmTurn`）の`getPlacedCards()`結果を
  そのまま渡せるよう合わせて更新する
