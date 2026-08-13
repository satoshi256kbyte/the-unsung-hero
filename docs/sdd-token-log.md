# SDD トークン使用量ログ

Spec Kitコマンドごとのトークン消費を記録する。
各Specの完了後に手動で記録する（またはセッション終了時にまとめて記録する）。

## 記録フォーマット

| Spec | コマンド | 日付 | 入力トークン | 出力トークン | 備考 |
|------|---------|------|------------|------------|------|
| Spec-01 | /speckit-specify | 2026-08-12 | — | — | constitution作成含む |
| Spec-01 | /sync-graphdb | 2026-08-12 | — | — | ADR-001〜003追加 |
| Spec-02 | /speckit-specify | 2026-08-12 | — | — | ガントチャート・タスクモデル仕様作成 |
| Spec-02 | /speckit-plan | 2026-08-12 | — | — | plan.md / data-model.md / quickstart.md 作成 |
| Spec-02 | /speckit-tasks | 2026-08-12 | — | — | tasks.md 作成（T001〜T017） |
| Spec-02 | /speckit-implement | 2026-08-13 | — | — | gantt.ts + gantt.test.ts 実装・25テスト全PASS |
| Spec-02 | /sync-graphdb | 2026-08-13 | — | — | gantt.ts/test.ts追加・ADR-005追加 |

## 累計

| Spec | 合計トークン（概算） |
|------|------------------|
| Spec-01 | — |
| Spec-02（完了） | — |

## 備考

- トークン数はClaude Codeのセッション画面で確認できる
- 入力・出力トークンが確認できない場合は「—」のままでよい
- 1 Spec完了のたびに1行追記する
