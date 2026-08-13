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
| Spec-07 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T020、7フェーズ） |
| Spec-07 | /speckit-implement | 2026-08-13 | — | — | effect.ts + effect.test.ts 新規・turn.ts / turn.test.ts 更新・173テスト全PASS・coverage 100% |
| Spec-08 | /speckit-specify | 2026-08-13 | — | — | ランダムイベントエンジン仕様作成・チェックリスト16項目全PASS |
| Spec-08 | /speckit-plan | 2026-08-13 | — | — | plan.md / data-model.md / quickstart.md 作成 |
| Spec-08 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T019、8フェーズ） |
| Spec-08 | /speckit-implement | 2026-08-13 | — | — | event.ts 新規・turn.ts 更新・206テスト全PASS・coverage 100% |
| Spec-09 | /speckit-specify | 2026-08-13 | — | — | 条件付きイベントエンジン仕様作成・チェックリスト16項目全PASS |
| Spec-09 | /speckit-plan | 2026-08-13 | — | — | plan.md / data-model.md / quickstart.md 作成・KD-1〜5定義 |
| Spec-09 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T015、7フェーズ） |
| Spec-09 | /speckit-implement | 2026-08-13 | — | — | conditional.ts 新規・turn.ts 更新・249テスト全PASS・coverage 100% lines/funcs |
| Spec-10 | /speckit-specify | 2026-08-13 | — | — | GameEngine仕様作成・チェックリスト16項目全PASS |
| Spec-10 | /speckit-plan | 2026-08-13 | — | — | plan.md / data-model.md / quickstart.md 作成・KD-1〜6定義 |
| Spec-10 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T016、6フェーズ） |
| Spec-10 | /speckit-implement | 2026-08-13 | — | — | engine.ts 新規・engine.test.ts 新規・273テスト全PASS・coverage lines/funcs 100% |
| Spec-10 | /sync-graphdb | 2026-08-13 | — | — | ADR-014追加・240ノード |
| Spec-11 | /speckit-specify | 2026-08-13 | — | — | PoCステージデータ仕様作成・チェックリスト16項目全PASS |
| Spec-11 | /sync-graphdb | 2026-08-13 | — | — | pocStage Conceptノード追加・243ノード |

## 累計

| Spec | 合計トークン（概算） |
|------|------------------|
| Spec-01 | — |
| Spec-02（完了） | — |

## 備考

- トークン数はClaude Codeのセッション画面で確認できる
- 入力・出力トークンが確認できない場合は「—」のままでよい
- 1 Spec完了のたびに1行追記する
