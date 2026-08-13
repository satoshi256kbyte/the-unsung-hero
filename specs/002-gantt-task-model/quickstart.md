# Quickstart Validation: ガントチャート・タスクモデル

## 前提条件

- Spec-01（`src/game/types.ts` / `src/game/constants.ts`）が実装済み
- `npm install` 完了済み

## ステップ1: 型チェック

```bash
npm run typecheck
```

**期待結果**: エラーゼロで終了。

## ステップ2: ユニット・プロパティテスト

```bash
npm test
```

**期待結果**:

- `gantt.test.ts` の全テストケースが PASS
- 進捗境界値（0 / 100 / 超過・マイナス）で正しくクランプされる
- 手戻り境界値（技 0 / 10 / 99）で巻き戻し率が仕様通り
- fast-check: 任意の delta・技レベルでパニックなし
- バリアント存在/不存在で正しく分岐する

## ステップ3: 依存関係チェック

```bash
grep -r "phaser\|document\|window" src/game/gantt.ts
```

**期待結果**: 0件（Phaser / DOM への依存なし）。

## 検証ポイント一覧

| 検証項目 | コマンド | 期待結果 |
|---------|---------|---------|
| 型チェック | `npm run typecheck` | exit 0 |
| テスト全通過 | `npm test` | all pass |
| Phaser依存なし | `grep -r "phaser" src/game/gantt.ts` | 0件 |
| DOM依存なし | `grep -r "document\|window" src/game/gantt.ts` | 0件 |
