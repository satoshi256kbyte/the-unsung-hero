# Quickstart: バランスデータのJSON外部化

## 前提

- `npm install`済み（`zod`を新規追加後は再実行）

## リファクタリング結果の検証

```bash
npm run typecheck
npm run test
```

- `typecheck`がエラーゼロで終了すること
- 既存の単体テスト（`src/game/`内の関数は引数不変のため変更不要）が全件PASSすること

## ビルド不要でのチューニング反映の確認（手動確認）

1. 開発サーバーを起動する（`npm run dev`）
2. `public/data/cards/daily.json`の`cost`を書き換えて保存する
3. ブラウザをリロードし、デイリーカードのコスト表示が変更後の値になることを確認する
4. `npm run build`を一切実行していないことを確認する

## 起動時検証（異常系）の確認

1. `public/data/cards/daily.json`の`cost`フィールドを削除する
2. ゲームを起動し、コンソールにzodのバリデーションエラーが出て
   ゲームが開始されないことを確認する
3. `daily.json`を元に戻す

## E2E検証

```bash
npm run test:e2e
```

`PreloadScene`の正常系（起動後にTitleSceneへ遷移する）・異常系（不正JSON時に
起動が失敗する）のシナリオがPASSすることを確認する。

## docs記載方針の確認

```bash
grep -n "%\|円\|[0-9]" "docs/03-詳細設計/バランスパラメータ.md"
```

計算式中の数値（例:`skill_factor`テーブルの閾値説明文中の数字）を除き、
「現在のチューニング値」に相当する記載が残っていないことを目視で確認する。
