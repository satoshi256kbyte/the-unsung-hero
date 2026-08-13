# Quickstart: ランダムイベントエンジン 検証シナリオ

## Prerequisites

```bash
docker compose up -d   # Neo4j (不要な場合はスキップ)
npx vitest run tests/unit/event.test.ts
npx vitest run tests/unit/turn.test.ts
```

## シナリオ A: stall イベントが発生し progressMap がリセットされる

```typescript
// Math.random を mock して確率100%に設定
vi.spyOn(Math, 'random').mockReturnValue(0); // < STALL(0.05) かつ stallTurns=1

const state = makeState(); // アクティブタスク t1 を持つ GameState
const events = rollRandomEvents(state, []);

const stallEvent = events.find(e => e.id.startsWith('stall'));
// stallEvent.params.stallTurns === 1

const progressMap = new Map([['t1', 5]]);
const updated = applyEventToProgress(stallEvent, progressMap);
// updated.get('t1') === 0  ← リセット
// progressMap.get('t1') === 5  ← 変化なし（イミュータブル）
```

## シナリオ B: rework イベントが発生し progressMap に負のデルタが反映される

```typescript
// Math.random mock: rework 発生（0.05 < x < 0.13 を狙う）
const events = rollRandomEvents(state, []);
const reworkEvent = events.find(e => e.id.startsWith('rework'));
// reworkEvent.params.reworkDelta < 0

const progressMap = new Map([['t1', 0]]);
const updated = applyEventToProgress(reworkEvent, progressMap);
// updated.get('t1') === reworkEvent.params.reworkDelta (負値)
```

## シナリオ C: sick イベントがメンバーパラメータを変化させる

```typescript
const sickEvent: GameEvent = {
  id: 'sick-1-m1', type: 'ネガティブ', category: 'デバフ系',
  targetId: 'm1', params: { moraleDelta: -8, healthDelta: -10 }
};
const member = { id: 'm1', name: 'Alice', skill: 10, exp: 0, morale: 100, health: 100 };
const updated = applyEventToMember(sickEvent, member);
// updated.morale === 92
// updated.health === 90
// member.morale === 100  ← 変化なし
```

## シナリオ D: パラメータクランプ（health が 0 を下回らない）

```typescript
const fatigueEvent: GameEvent = {
  id: 'fatigue-1-m1', type: 'ネガティブ', category: 'デバフ系',
  targetId: 'm1', params: { healthDelta: -8 }
};
const member = { ..., health: 5 };
const updated = applyEventToMember(fatigueEvent, member);
// updated.health === 0  ← クランプ
```

## シナリオ E: rework_prob_reduced 効果で確率が半減する

```typescript
const effectsWithReduction: CardEffect[] = [{
  cardName: 'レビュー', targetId: 'project',
  effectType: 'rework_prob_reduced', remainingTurns: 3
}];

// 大量サンプルで rework 発生率を比較
const rateWithout = measureReworkRate(state, [], 10000);   // ~ 0.08
const rateWith    = measureReworkRate(state, effectsWithReduction, 10000); // ~ 0.04
// rateWith ≈ rateWithout * 0.5
```

## シナリオ F: processTurn に sick イベントが統合される

```typescript
// Math.random mock で sick が確実に発生する条件
const result = processTurn(state, []);
// result.events.some(e => e.id.startsWith('sick')) === true
// result.memberUpdates.some(u => u.moraleDelta <= -8) === true
```
