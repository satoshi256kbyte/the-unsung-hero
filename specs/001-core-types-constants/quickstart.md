# Quickstart Validation: Core Types and Constants

## 前提条件

- Node.js 20+、npm インストール済み
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

- `balance.test.ts` の全テストケースが PASS
- 技レベル境界値（0, 4, 5, 9, 10, 14, 15, 24, 25, 99）で skill_factor 範囲が仕様通り
- 体の値境界値（0, 29, 30, 49, 50, 69, 70, 100）で health_factor 範囲が仕様通り
- fast-check プロパティテスト: 任意の技レベル・体の値でパニックなし

## ステップ3: 定数の網羅性確認

```bash
# マジックナンバーがsrc/game/以外に残っていないこと（以下は0件であること）
grep -r "0\.08\|0\.05\|0\.04\|0\.03" src/ --include="*.ts" | grep -v constants.ts
```

**期待結果**: 0 件（イベント確率の生値が constants.ts 以外に存在しない）。

## 検証ポイント一覧

| 検証項目 | コマンド | 期待結果 |
|---------|---------|---------|
| 型チェック | `npm run typecheck` | exit 0 |
| テスト全通過 | `npm test` | all pass |
| Phaser依存なし | `grep -r "phaser" src/game/` | 0件 |
| DOM依存なし | `grep -r "document\|window" src/game/` | 0件 |
