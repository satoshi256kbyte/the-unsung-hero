# Data Model: カード効果エンジン

## 入出力エンティティ

### GameState（既存: src/game/types.ts）

applyCards の入力。変更されない。

| フィールド | 型 | 用途 |
|-----------|-----|------|
| members | Member[] | 即時メンバー系カードのターゲット解決に使用（members[0]） |
| activeEffects | CardEffect[] | 読み取り専用（今回は参照しない） |

### CardApplicationResult（NEW: src/game/card.ts でローカル定義）

applyCards の戻り値。呼び出し側が GameState の更新に使う。

```typescript
export interface CardApplicationResult {
  effectsToAdd: CardEffect[];
  memberUpdates: MemberUpdate[];
}
```

### CardEffect（既存: src/game/types.ts）

```typescript
interface CardEffect {
  cardName: CardName;
  targetId: string;   // 'project' または memberId
  effectType: EffectType;
  remainingTurns: number | null;  // null = 手動解除まで継続
}
```

### MemberUpdate（既存: src/game/types.ts）

```typescript
interface MemberUpdate {
  memberId: string;
  moraleDelta: number;
  healthDelta: number;
  skillDelta?: number;
  expDelta?: number;
}
```

## 関数シグネチャ（src/game/card.ts）

```typescript
export function applyCards(state: GameState, cards: CardName[]): CardApplicationResult
```

## カードマッピングテーブル

### グループ A: 確率低減セット系

| CardName | effectType | targetId | remainingTurns | 出力先 |
|----------|------------|----------|----------------|--------|
| デイリー | `task_event_prob_reduced` | `'project'` | `null` | effectsToAdd |
| レビュー | `rework_prob_reduced` | `'project'` | `null` | effectsToAdd |
| モニタリング | `overreport_prob_reduced` | `'project'` | `null` | effectsToAdd |

### グループ B: 即時メンバー系

ターゲット: `state.members[0]`（最小実装）。メンバーが 0 人の場合はスキップ。

| CardName | moraleDelta | healthDelta | 出力先 |
|----------|-------------|-------------|--------|
| 個別面談 | `PARAM_DELTA.ONE_ON_ONE_MORALE` (15) | 0 | memberUpdates |
| 表彰 | `PARAM_DELTA.COMMENDATION_MORALE` (30) | 0 | memberUpdates |
| 計画休 | `PARAM_DELTA.PLANNED_LEAVE_MORALE` (20) | `PARAM_DELTA.PLANNED_LEAVE_HEALTH` (25) | memberUpdates |

### スコープ外

上記 6 種以外の CardName → 無視（エントリを追加しない）

## 処理フロー

```
applyCards(state, cards):
  effectsToAdd = []
  memberUpdates = []

  for each card in cards:
    switch card:
      case 'デイリー':
        effectsToAdd.push({ cardName: card, targetId: 'project',
          effectType: 'task_event_prob_reduced', remainingTurns: null })
      case 'レビュー':
        effectsToAdd.push({ cardName: card, targetId: 'project',
          effectType: 'rework_prob_reduced', remainingTurns: null })
      case 'モニタリング':
        effectsToAdd.push({ cardName: card, targetId: 'project',
          effectType: 'overreport_prob_reduced', remainingTurns: null })
      case '個別面談':
        if state.members.length > 0:
          memberUpdates.push({ memberId: state.members[0].id,
            moraleDelta: PARAM_DELTA.ONE_ON_ONE_MORALE, healthDelta: 0 })
      case '表彰':
        if state.members.length > 0:
          memberUpdates.push({ memberId: state.members[0].id,
            moraleDelta: PARAM_DELTA.COMMENDATION_MORALE, healthDelta: 0 })
      case '計画休':
        if state.members.length > 0:
          memberUpdates.push({ memberId: state.members[0].id,
            moraleDelta: PARAM_DELTA.PLANNED_LEAVE_MORALE,
            healthDelta: PARAM_DELTA.PLANNED_LEAVE_HEALTH })
      default: // スコープ外: 無視

  return { effectsToAdd, memberUpdates }
```

## 依存関係

| モジュール | 使用するもの |
|-----------|-------------|
| types.ts | GameState / CardName / CardEffect / MemberUpdate / EffectType |
| constants.ts | PARAM_DELTA（ONE_ON_ONE_MORALE / COMMENDATION_MORALE / PLANNED_LEAVE_MORALE / PLANNED_LEAVE_HEALTH） |
