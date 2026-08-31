# Quickstart: ゲームクリア/失敗のリザルト画面

**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-08-31

本フィーチャーが正しく動くことを確認する検証手順。実装詳細は tasks.md と実装フェーズで扱う。

## 前提

- `npm install` 済み
- Neo4j は設計参照用（実行時には不要）

## 自動検証

```bash
npx tsc --noEmit          # 型エラー 0
npx vitest run            # result.test.ts を含むユニット全パス
npx vitest run --coverage # src/game カバレッジが基準(lines80/functions80/branches75)以上
npx playwright test       # result.spec.ts を含む E2E 全パス
```

## result.ts ユニット検証の要点（result.test.ts）

`evaluateResult(state, targetProfitRate)` を決定論的に検証する。

- 全タスク完了かつ profitRate ≥ target → outcome "clear"
- 全タスク完了だが profitRate < target → outcome "fail"
- 納期超過（reason="納期超過"）→ 常に "fail"
- budget=0 → profitRate 0（ゼロ除算にならない）
- totalCost > budget → profit 負・profitRate 負・"fail"
- 入力 state を変更しない（純関数）
- completionRate が getCompletionRate と一致

## 手動シナリオ（E2E result.spec.ts）

1. ゲームを開始し、納期到達までターンを確定し続ける。
2. ゲーム終了ターンの確定後、`[data-testid="result-screen"]` が表示される（US1/AC2）。
3. `result-outcome` に成否、`result-reason` に終了理由、`result-profit-rate` に最終利益率、
   `result-profit` に最終利益、`result-stats` に主要数値が表示される（US1・US2）。
4. ゲーム未終了のターンでは `result-screen` が表示されない（US1/AC3・FR-007）。
5. `[data-testid="result-back-to-title"]` をクリックするとタイトル画面へ遷移し、
   再度ゲームを開始できる（US3）。
6. リザルト表示後にターン確定操作をしても二重進行・多重表示しない（Edge Case）。

## 成功基準との対応

- SC-001: 終了時に必ず result-screen が出る（手動2）
- SC-002: 表示利益率が予算・総消費コストからの算出値と一致（ユニット + 手動3）
- SC-003: 成否判定が成否ルールと一致（ユニット全ケース）
- SC-004: タイトルへ戻り再開できる（手動5）
- SC-005: 既存のターン確定・進行・終了判定に回帰なし（既存 E2E/ユニットが継続パス）
