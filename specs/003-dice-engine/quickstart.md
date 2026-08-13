# Quickstart: 進捗ダイスエンジン

## 前提条件

- Spec-01 完了済み（`src/game/types.ts`・`src/game/constants.ts`・`src/game/balance.ts` が存在する）
- `npm install` 実行済み

## 検証コマンド

```bash
# 1. 型チェック
npm run typecheck

# 2. テスト実行
npm test tests/unit/dice.test.ts

# 3. Phaser/DOM 依存がないことの確認
grep -r "phaser\|document\|window" src/game/dice.ts; echo "grep exit: $?"
# → 0件ならexit 1（該当なし）が期待値
```

## 期待する結果

```
# typecheck
(エラーなし)

# test
Test Files  1 passed (1)
Tests       N passed (N)

# grep
grep exit: 1   ← 0件 = 依存なし
```

## テスト観点

| 観点 | 確認内容 |
|------|---------|
| 境界値: 技 | 0/4/5/9/10/14/15/24/25/99 の各値で戻り値が正 |
| 境界値: 体 | 0/29/30/49/50/69/70/100 の各値で戻り値が正 |
| プロパティ | 任意の技(0〜99)・体(0〜100) で fast-check が PASS |
| イミュータブル | rollProgress 呼び出し後に元の Member が変化しない |
