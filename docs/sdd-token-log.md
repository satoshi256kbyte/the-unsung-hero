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
| Spec-03 | /speckit-specify | 2026-08-13 | — | — | 進捗ダイスエンジン仕様作成 |
| Spec-03 | /speckit-plan | 2026-08-13 | — | — | plan.md / data-model.md / quickstart.md 作成 |
| Spec-03 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T008） |
| Spec-03 | /speckit-implement | 2026-08-13 | — | — | dice.ts + dice.test.ts 実装・21テスト全PASS |
| Spec-04 | /speckit-specify | 2026-08-13 | — | — | メンバーパラメータ変動エンジン仕様作成 |
| Spec-04 | /speckit-plan | 2026-08-13 | — | — | plan.md / data-model.md / quickstart.md 作成 |
| Spec-04 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T018） |
| Spec-04 | /speckit-implement | 2026-08-13 | — | — | member.ts + member.test.ts 実装・32テスト全PASS・coverage 100% |
| Spec-05 | /speckit-specify | 2026-08-13 | — | — | ターン処理エンジン仕様作成 |
| Spec-05 | /speckit-plan | 2026-08-13 | — | — | plan.md / data-model.md / quickstart.md 作成 |
| Spec-05 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T021） |
| Spec-05 | /speckit-implement | 2026-08-13 | — | — | turn.ts + turn.test.ts 実装・24テスト全PASS・coverage 100% |
| Spec-06 | /speckit-specify | 2026-08-13 | — | — | カード効果エンジン仕様作成・チェックリスト16項目全PASS |
| Spec-06 | /speckit-plan | 2026-08-13 | — | — | plan.md / data-model.md / quickstart.md 作成 |
| Spec-06 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T017） |
| Spec-06 | /speckit-implement | 2026-08-13 | — | — | card.ts + card.test.ts 実装・24テスト全PASS・coverage 100% |
| Spec-07 | /speckit-specify | 2026-08-13 | — | — | ターン統合エンジン仕様作成・チェックリスト16項目全PASS |
| Spec-07 | /speckit-plan | 2026-08-13 | — | — | plan.md / data-model.md / quickstart.md 作成 |

## 累計

| Spec | 合計トークン（概算） |
|------|------------------|
| Spec-01 | — |
| Spec-02（完了） | — |

## 備考

- トークン数はClaude Codeのセッション画面で確認できる
- 入力・出力トークンが確認できない場合は「—」のままでよい
- 1 Spec完了のたびに1行追記する
