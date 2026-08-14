# Quickstart: カード・イベント・ステージのファイル構造再編

## 前提

- `npm install` 済み

## リファクタリング結果の検証

```bash
npm run typecheck
npm run test
```

- `typecheck` がエラーゼロで終了すること
- 既存の単体テスト（分割後は `tests/unit/cards/**` `tests/unit/events/**`
  `tests/unit/stages/**` 含む）が全件PASSすること

## 挙動が変わっていないことの確認（回帰確認）

```bash
npm run test -- tests/unit/engine.test.ts tests/unit/turn.test.ts
```

`GameEngine` / `processTurn` を経由する既存テストが全件PASSすれば、
カード・イベント・ステージの再配置が外部挙動に影響していないことを確認できる。

## 「1ファイル追加だけで完結する」ことの手動確認

1. `src/game/cards/` に新規カードファイルを1つ追加する（例: `雑談.ts`）
2. `cards/index.ts` のレジストリに1行importと登録を追加する
3. 既存のカードファイル・`constants.ts`・`card.ts` 相当の統合先を
   一切編集していないことを確認する
4. `npm run typecheck` がエラーゼロで通ることを確認する

同様の手順をイベント（`src/game/events/`）・ステージ（`src/game/stages/`）でも
確認できる。

## ドキュメント分割の確認

```bash
npx markdownlint-cli2 'docs/03-詳細設計/**/*.md'
```

- `docs/03-詳細設計/カード/` `イベント/` 配下のファイル数が、それぞれ
  約26件・約23件であることを確認する
- `docs/03-詳細設計/ステージ/PoCステージ01.md` の冒頭に
  `ステージID: poc-01` の記載があることを確認する
