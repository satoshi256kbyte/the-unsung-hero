# Quickstart: 条件付きイベントエンジン

## 前提条件

```bash
npm install
npm run typecheck  # tsc --noEmit がエラー0で通過すること
```

## シナリオ A: evaluateCondition — turn 条件

```typescript
import { evaluateCondition } from "./src/game/conditional.js";
// state.turn = 5 のとき
evaluateCondition(state, "turn >= 5");  // → true
evaluateCondition(state, "turn <= 4");  // → false
evaluateCondition(state, "turn == 5");  // → true
```

**期待結果**: それぞれ `true / false / true`

## シナリオ B: evaluateCondition — completion_rate 条件

```typescript
// ガントチャートの完了率が 0.95 のとき
evaluateCondition(state, "completion_rate >= 0.9");  // → true
evaluateCondition(state, "completion_rate < 0.5");   // → false
```

**期待結果**: `true / false`

## シナリオ C: evaluateCondition — メンバー条件

```typescript
// メンバーの士気が [20, 80] のとき
evaluateCondition(state, "any_member_morale < 30");  // → true  (20 < 30)
evaluateCondition(state, "all_members_morale < 30"); // → false (80 >= 30)
evaluateCondition(state, "any_member_health < 50");  // 体力次第
```

## シナリオ D: evaluateCondition — 未知条件

```typescript
evaluateCondition(state, "unknown_condition");  // → false（例外なし）
evaluateCondition(state, "");                   // → false（例外なし）
```

**期待結果**: 必ず `false` が返り、例外がスローされない

## シナリオ E: rollConditionalEvents — 条件成立

```typescript
import { rollConditionalEvents } from "./src/game/conditional.js";

const conditionalEvents: ConditionalEvent[] = [
  {
    id: "evt-01",
    turn: 3,          // ターン3以降に評価される
    condition: "turn >= 3",
    eventType: "ネガティブ",
    params: { category: "デバフ系", targetId: "member-1", moraleDelta: -5 },
  },
];

// state.turn = 3 のとき
const events = rollConditionalEvents(state, conditionalEvents);
// → [{ id: "conditional-3-evt-01", type: "ネガティブ", ... }]
```

**期待結果**: 1件の GameEvent が返る

## シナリオ F: rollConditionalEvents — ターンフィルタ

```typescript
const futureEvent: ConditionalEvent = {
  id: "evt-02",
  turn: 10,         // ターン10以降に評価
  condition: "turn >= 10",
  eventType: "ネガティブ",
  params: {},
};

// state.turn = 3 のとき
const events = rollConditionalEvents(state, [futureEvent]);
// → [] （turn 10 はまだ来ていないのでスキップ）
```

**期待結果**: 空配列

## シナリオ G: processTurn 統合 — 後方互換

```typescript
import { processTurn } from "./src/game/turn.js";

// 第3引数なし → 既存テストがすべてPASS
const result = processTurn(state, ["デイリー"]);

// 空配列を渡しても同じ挙動
const result2 = processTurn(state, ["デイリー"], []);
```

**期待結果**: 既存の206テストがすべて引き続き PASS

## 検証コマンド

```bash
# テスト実行
npm test

# カバレッジ確認
npm run test:coverage

# アーキテクチャ境界チェック（Phaser/DOM import がないこと）
grep -r "phaser\|document\.\|window\." src/game/conditional.ts && echo "VIOLATION" || echo "OK"

# 型チェック
npm run typecheck
```
