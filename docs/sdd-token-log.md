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
| Spec-11 | /speckit-plan | 2026-08-13 | — | — | plan.md / research.md / data-model.md / quickstart.md 作成・ADR-015追加 |
| Spec-11 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T011、5フェーズ） |
| Spec-11 | /speckit-implement | 2026-08-13 | — | — | pocStage.ts 新規・pocStage.test.ts 新規・291テスト全PASS・coverage lines/funcs 100% |
| Spec-12 | /speckit-specify | 2026-08-13 | — | — | メイン画面UI仕様作成・チェックリスト16項目全PASS |
| Spec-12 | /sync-graphdb | 2026-08-13 | — | — | MainGameUI/CardSlot/LoadingScreen/MainScene Conceptノード追加 |
| Spec-12 | /speckit-plan | 2026-08-13 | — | — | plan.md / research.md / data-model.md / contracts/ / quickstart.md 作成・ADR-016追加 |
| Spec-12 | /speckit-tasks | 2026-08-13 | — | — | tasks.md 作成（T001〜T028、6フェーズ） |
| Spec-12 | /speckit-implement | 2026-08-13 | — | — | src/ui/ 4ファイル・MainScene・BootScene遷移・E2E 3ファイル・291ユニットテスト全PASS・型エラーゼロ・Phaser境界OK |
| Spec-13 | /speckit-specify | 2026-08-14 | — | — | カード・イベント・ステージのファイル構造再編。US1〜4・FR17件・SC6件を定義 |
| Spec-13 | /speckit-plan | 2026-08-14 | — | — | plan.md/research.md/data-model.md/contracts/quickstart.md作成。Constitution Check全項目PASS |
| Spec-13 | /speckit-tasks | 2026-08-14 | — | — | tasks.md作成（T001〜T054、6フェーズ、US1〜US4） |
| Spec-13 | /speckit-implement | 2026-08-14 | — | — | T001〜T054全完了。cards/26+events/15+stages/1ファイル+各index.ts、docs側カード26/イベント23/ステージ1、全329テストPASS・型エラー0・カバレッジ lines98.3%/branches93.91% |
| Spec-15 | /speckit-specify | 2026-08-14 | — | — | カード・イベント・ステージ・バランス係数のJSON外部化。US1〜3・FR9件・SC5件を定義 |
| Spec-15 | /speckit-plan | 2026-08-14 | — | — | plan.md/research.md/data-model.md/contracts/quickstart.md作成。Constitution Check全項目PASS。constants.ts11箇所の参照元をconfig.tsシングルトンに変更する設計を決定 |
| Spec-15 | /speckit-tasks | 2026-08-14 | — | — | tasks.md作成（T001〜T044、6フェーズ、US1〜US3） |
| Spec-15 | /speckit-implement | 2026-08-14 | — | — | T001〜T044全完了。JSON43件+zodスキーマ4種+config.ts+PreloadScene新規、constants.ts削除・11+1ファイルgetConfig()移行、docs数値記載除去、グラフDB Parameterノードjsonpath化。332ユニットテスト+E2E44件全PASS・型エラー0・カバレッジlines94.08%/branches89.41%。副次的にMainGameUI.tsの既存data-testid重複バグを発見・修正 |
| Spec-14 | /speckit-specify | 2026-08-14 | — | — | タイトル〜ステージセレクト画面遷移。US1〜2・FR9件・SC3件を定義（設計ドキュメントをSpec-13/15後の実コード状態に合わせて更新した上で仕様化） |
| Spec-14 | /speckit-plan | 2026-08-14 | — | — | plan.md/research.md/data-model.md/contracts/quickstart.md作成。Constitution Check全項目PASS |
| Spec-14 | /speckit-tasks | 2026-08-14 | — | — | tasks.md作成（T001〜T021、4フェーズ、US1〜US2） |
| Spec-14 | /speckit-implement | 2026-08-14 | — | — | T001〜T021全完了。TitleScene/StageSelectScene新規、TitleUI/StageSelectUI新規、StageDataにdescription追加、MainSceneはstageId経由に変更。既存E2E4ファイルを新遷移フロー対応に更新（共通helpers.ts追加）。332ユニットテスト+E2E54件（chromium/Mobile Chrome）全PASS・型エラー0・カバレッジlines94.08%/branches89.41% |
| Spec-16 | /speckit-specify | 2026-08-14 | — | — | 週モデル変更（ターン＝暦日・7ターン周期・休出カード・対象選択UI）。US1〜2・FR9件・SC4件を定義 |
| Spec-16 | /speckit-plan | 2026-08-14 | — | — | plan.md/research.md/data-model.md/contracts/quickstart.md作成。Constitution Check全項目PASS。締切を22→30ターン、条件付きイベントのターン番号を再校正 |
| Spec-16 | /speckit-tasks | 2026-08-14 | — | — | tasks.md作成（T001〜T034、5フェーズ、US1+US2統合実装） |
| Spec-16 | /speckit-implement | 2026-08-14 | — | — | T001〜T034全完了。calendar.ts新規（dayOfWeek/isWeekend）、休出カードを（土）（日）2種に分割し対象選択UI（target-picker）を新規実装、applyCards/processTurnのシグネチャを`{name,targetId?}[]`へ変更、週末回復をturn%7へ変更、ヘッダー表記を「ターンN」→「N日目」に変更。358ユニットテスト+E2E29件（chromium）全PASS・型エラー0・lint 0・カバレッジlines94.37%/branches90.52%/functions100%。手札への静的追加が必要だった制約（カード再抽選機構が未実装）はSpec-19としてバックログ化 |
| Spec-17 | /speckit-specify | 2026-08-16 | — | — | docsガントチャート表記見直し（カレンダー列形式）。brainstorming skillのbounded pathで会話内合意した設計をそのままspec.mdへ反映。US1カレンダー列形式で一望・US2実データ整合。FR11件・SC3件を定義 |
| Spec-17 | /speckit-plan | 2026-08-16 | — | — | plan.md/research.md/data-model.md/quickstart.md作成。Constitution Check全項目PASS（src/変更なしのため）。contracts/は対象外（外部インターフェースなし） |
| Spec-17 | /speckit-tasks | 2026-08-16 | — | — | tasks.md作成（T001〜T012、5フェーズ、US1+US2） |
| Spec-17 | /speckit-implement | 2026-08-16 | — | — | T001〜T012全完了。`docs/03-詳細設計/ステージ/PoCステージ01.md`を全面更新。ガントチャート表を1枚・31列（タスク列+ターン1〜30列、見出し「ターン番号(曜日)」形式）に書き換え、セルを■(平日稼働)/・(土日で非稼働)/空欄(期間外)の3値化。ヘッダーテーブル（締切22→30、初期カードに休出2種追加、パス参照をpublic/data/stages/poc-01.jsonに修正）と条件付きイベント表のターン番号（5,12,16,22,24）をSpec-16後の実データに整合。markdownlintエラー0（作業中に自作ファイルのMD013/MD036指摘を修正） |

## 累計

| Spec | 合計トークン（概算） |
|------|------------------|
| Spec-01 | — |
| Spec-02（完了） | — |

## 備考

- トークン数はClaude Codeのセッション画面で確認できる
- 入力・出力トークンが確認できない場合は「—」のままでよい
- 1 Spec完了のたびに1行追記する
