# Data Model: ターン統合エンジン

## 型変更: TurnResult（types.ts 拡張）

```typescript
export interface TurnResult {
  events: GameEvent[];
  progressUpdates: ProgressUpdate[];
  memberUpdates: MemberUpdate[];   // カード由来 + decay 由来を統合
  costDelta: number;
  isGameOver: boolean;
  gameOverReason: string | null;
  activeEffectsAdded: CardEffect[];      // NEW: applyCards で付与された効果
  activeEffectsAfterTick: CardEffect[];  // NEW: tick 後の有効効果一覧
}
```

Phaser Scene は次ターン開始時に `state.activeEffects = result.activeEffectsAfterTick` をセット。

## 定数追加: EVENT_PROB.STALL（constants.ts）

```typescript
export const EVENT_PROB = {
  // ... 既存 ...
  STALL: 0.05,   // NEW: 停滞イベント基本確率（停滞本体実装は別Spec）
} as const;
```

## 新規関数: effect.ts

### applyEffectTick

```typescript
function applyEffectTick(effects: CardEffect[]): CardEffect[]
```

| 条件 | 処理 |
|------|------|
| remainingTurns === null | そのまま保持（永続効果） |
| remainingTurns > 1 | remainingTurns - 1 にして保持 |
| remainingTurns === 1 | 除去（0になるため） |
| remainingTurns === 0 | 除去（既に期限切れ） |

引数配列を変更せず新配列を返す。

### calcEventProbModifier

```typescript
function calcEventProbModifier(
  effects: CardEffect[],
  baseProb: number,
  effectType: EffectType,
): number
```

| 条件 | 戻り値 |
|------|--------|
| 対象 effectType が 1 件以上ある | `baseProb * 0.5` |
| 対象 effectType が 0 件 | `baseProb`（変更なし） |

重複スタックなし（同 effectType が複数あっても 0.5 倍のみ）。

## 更新関数: processTurn（turn.ts）

処理フロー（順序が意味を持つ）:

```
入力: state: GameState, cards: CardName[]

Step 1: applyCards(state, cards)
  → effectsToAdd: CardEffect[]
  → cardMemberUpdates: MemberUpdate[]

Step 2: currentEffects = [...state.activeEffects, ...effectsToAdd]

Step 3: 進捗ダイス（各メンバーのアクティブタスク）
  → progressMap: Map<taskId, delta>

Step 4: パラメータ decay + 週末回復（state.members ループ）
  → decayMemberUpdates: MemberUpdate[]

Step 5: 手戻りイベント判定
  reworkProb = calcEventProbModifier(currentEffects, EVENT_PROB.REWORK, 'rework_prob_reduced')
  if Math.random() < reworkProb → rework イベント生成 + progressMap 更新

Step 6: applyEffectTick(currentEffects)
  → activeEffectsAfterTick: CardEffect[]

Step 7: 仮想ガント → ゲームオーバー判定

Step 8: return TurnResult {
  events, progressUpdates, memberUpdates（card + decay 統合）,
  costDelta, isGameOver, gameOverReason,
  activeEffectsAdded: effectsToAdd,
  activeEffectsAfterTick
}
```

## 依存関係グラフ

```
effect.ts
  ← types.ts (CardEffect, EffectType)

turn.ts (更新)
  ← effect.ts (applyEffectTick, calcEventProbModifier)
  ← card.ts   (applyCards)
  ← member.ts (applyTurnDecay, applyWeekendRecovery)
  ← dice.ts   (rollProgress)
  ← gantt.ts  (updateTaskProgress, getCompletionRate, applyRework)
  ← constants.ts (EVENT_PROB.REWORK, EVENT_PROB.STALL, POC_STAGE)
  ← types.ts  (GameState, TurnResult, CardEffect, ...)
```
