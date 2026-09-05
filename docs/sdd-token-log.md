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
| Spec-18 | /speckit-specify | 2026-08-30 | — | — | ゲーム内ガントチャートUI。Q1=B(予定/実績2行＋稲妻線＋依存タスクのPERT的表示)・Q2=B(実績＝着手/完了ターンを新規保持)・Q3=A(ディレクトリ019/グラフDBはSpec-18)を確定。US1稲妻線(P1)・US2実績確認(P2)・US3依存表示(P3)、FR13件・SC5件・Out of Scope明記。品質チェックリスト全項目PASS・markdownlint 0。specs/019-in-game-gantt-ui/に作成 |
| Spec-18 | /sync-graphdb | 2026-08-30 | — | — | Spec-18ノードをplanned→specifiedに更新、spec.md/checklistノード追加(HAS_SPEC/HAS_CHECKLIST)、ADR-027追加。346ノード/449リレーション |
| Spec-18 | /speckit-plan | 2026-08-30 | — | — | plan.md/research.md/data-model.md/contracts/quickstart.md作成。Constitution Check（Phase0前/Phase1後）全項目PASS。GanttTaskにactualStartTurn/actualEndTurn追加、engine.processTurnで実績記録、gantt.tsに稲妻線算出純関数(plannedRate/progressDeviation/actualPosition)、src/ui/GanttChartUI.ts新規(DOM overlay)、MainGameUIに画面切替(nav-gantt-btn/nav-dashboard-btn)。数値バランス不変。markdownlint 0 |
| Spec-18 | /sync-graphdb | 2026-08-30 | — | — | Spec-18ノードをspecified→plannedに更新、plan成果物5ノード追加(HAS_PLAN)、ADR-028追加。352ノード/453リレーション |
| Spec-18 | /speckit-tasks | 2026-08-30 | — | — | tasks.md作成（T001〜T029、6フェーズ、US1〜US3）。Phase1 Setup/Phase2 Foundational(実績フィールド・schema・engine実績記録・稲妻線純関数・リスケ引き継ぎ＋テスト)/Phase3 US1(P1/MVP)/Phase4 US2(P2)/Phase5 US3(P3)/Phase6 Polish。テスト必須(Constitution II)。markdownlint 0 |
| Spec-18 | /sync-graphdb | 2026-08-30 | — | — | Spec-18のnext_action更新、tasks.mdノード追加(HAS_TASKS)。353ノード/454リレーション |
| Spec-18 | /speckit-implement | 2026-08-30 | — | — | T001〜T029全完了。GanttTaskにactualStartTurn/actualEndTurn追加、engine.processTurnで実績記録、gantt.tsに稲妻線算出純関数(plannedRate/progressDeviation/actualPosition)・applyVariant実績引き継ぎ、src/ui/GanttChartUI.ts新規(DOM overlay: 予定/実績2行・稲妻線data-deviation・ターン軸曜日・依存パネル・スクロール)、MainGameUIにnav-gantt-btn、MainScene配線。ユニット17件+E2E24件追加。tsc 0、src/gameカバレッジlines99.48%/funcs100%/branches93.33%、全ユニット375件・全E2E82件PASS、biome/markdownlint 0。数値バランス不変 |
| Spec-18 | /sync-graphdb | 2026-08-30 | — | — | Spec-18ノードをimplementedに更新、implement結果ノード追加(HAS_RESULT)、GanttChartUI Concept追加。355ノード/456リレーション |
| Spec-19 | /speckit-specify | 2026-08-30 | — | — | カード選択・手札への組み込み機能。Q1=A(ステージ配布プール)・Q2=A(毎ターン手札上限まで補充)・Q3=A(配布回数上限属性)を確定。US1補充(P1)・US2プール制御(P2)・US3配布回数上限(P3)、FR11件・SC5件・Out of Scope明記。品質チェックリスト全項目PASS・markdownlint 0。specs/020-card-selection-hand/に作成 |
| Spec-19 | /sync-graphdb | 2026-08-30 | — | — | Spec-19ノードをbacklog→specifiedに更新、spec.md/checklistノード追加(HAS_SPEC/HAS_CHECKLIST)、ADR-029追加(ADR-026をSUPERSEDES)。358ノード/461リレーション |
| Spec-19 | /speckit-plan | 2026-08-30 | — | — | plan.md/research.md/data-model.md/contracts/quickstart.md作成。Constitution Check(Phase0前/Phase1後)全項目PASS(原則IIIは配布数値をdocs/03-詳細設計に文書化する運用で充足)。StageDataにcardPool/handLimit、GameStateにdrawCounts、src/game/deck.ts新規(純関数eligibleEntries/drawCards、rng注入)、engine.processTurnに補充ステップ、poc-01.jsonにプール定義。turn.ts純関数不変・UI変更なし。markdownlint 0 |
| Spec-19 | /sync-graphdb | 2026-08-30 | — | — | Spec-19ノードをspecified→plannedに更新、plan成果物5ノード追加(HAS_PLAN)。363ノード/462リレーション |
| Spec-19 | /speckit-tasks | 2026-08-31 | — | — | tasks.md作成(T001〜T022、6フェーズ)。US1補充(P1/MVP)・US2プール制御と重み(P2)・US3配布回数上限(P3)。テスト必須(Constitution II)。全FRにタスク対応・チェックリスト形式準拠。markdownlint 0 |
| Spec-19 | /sync-graphdb | 2026-08-31 | — | — | Spec-19ノードをplanned→tasks-generatedに更新、tasks.mdノード追加(HAS_TASKS) |
| Spec-19 | /speckit-implement | 2026-08-31 | — | — | T001〜T022全完了。types(CardPoolEntry/StageData.cardPool・handLimit/GameState.drawCounts)、schemas/stageData.ts(既定値補完で後方互換)、deck.ts新規(eligibleEntries/drawCards)、engine補充ステップ、poc-01.json(cardPool全27種・handLimit8)、docsに配布数値文書化(原則III)。案1採用で休出（土）はinitialCards併存(ADR-030)。検証: tsc 0・ユニット396パス・E2E82パス・src/gameカバレッジlines94.4/branches89.4/funcs99.3で基準クリア・biome/markdownlint 0 |
| Spec-19 | /sync-graphdb | 2026-08-31 | — | — | Spec-19ノードをtasks-generated→implementedに更新、実装成果物ノード+implement結果(HAS_IMPLEMENTATION)追加、ADR-030追加(ADR-026をSUPERSEDES) |
| Spec-19 | /speckit-analyze | 2026-08-31 | — | — | 整合性分析(読み取り専用)。CRITICAL 0件、FRカバレッジ100%、Constitution技術ゲート全遵守。指摘: C1(token log未記録・HIGH)、I1(T015記述と案1実装の差分・MEDIUM)。両者を本セッションで是正 |
| Spec-19 | /speckit-converge | 2026-08-31 | — | — | 収束評価。missing/partial/contradicts/unrequested 全0件で✅Converged。tasks.mdはappend-only契約に従い未変更(git diff差分0)。after_convergeフックは未登録かつConstitution上sync不要でskip |
| Spec-20 | /speckit-specify | 2026-08-31 | — | — | ゲームクリア/失敗のリザルト画面。US1成否と利益率提示(P1)・US2成否理由と内訳(P2)・US3タイトルへ戻る(P3)、FR11件・SC5件・Out of Scope明記。成否ルール=最終利益率≥目標利益率かつ納期内完遂でクリア。品質チェックリスト全項目PASS・markdownlint 0。specs/021-result-screen/に作成 |
| Spec-20 | /sync-graphdb | 2026-08-31 | — | — | Spec-20 spec-entryノード(specified)、spec.md/checklistノード追加(HAS_SPEC/HAS_CHECKLIST) |
| Spec-20 | /speckit-plan | 2026-08-31 | — | — | plan.md/research.md/data-model.md/contracts/quickstart.md作成。Constitution Check全項目PASS。成否判定はsrc/game/result.ts(純関数evaluateResult)、表示はsrc/ui/ResultUI.ts(DOMオーバーレイ)、MainScene末尾で終了検知しResultUI表示・TitleScene遷移。turn.ts/engine.ts不変・新規依存/数値なし。markdownlint 0 |
| Spec-20 | /sync-graphdb | 2026-08-31 | — | — | Spec-20ノードをspecified→plannedに更新、plan成果物5ノード追加(HAS_PLAN)、ADR-031追加(成否判定を純関数result.tsに分離・DOMオーバーレイ表示) |
| Spec-20 | /speckit-tasks | 2026-08-31 | — | — | tasks.md作成(T001〜T015、6フェーズ)。US1成否と利益率提示(P1/MVP)・US2成否理由と内訳(P2)・US3タイトルへ戻る(P3)。テスト必須(Constitution II、Vitest+Playwright)。全FRにタスク対応・チェックリスト形式準拠。turn/engine不変。markdownlint 0 |
| Spec-20 | /sync-graphdb | 2026-08-31 | — | — | Spec-20ノードをplanned→tasks-generatedに更新、tasks.mdノード追加(HAS_TASKS) |
| Spec-20 | /speckit-implement | 2026-09-01 | — | — | T001〜T015全完了。result.ts新規(evaluateResult純関数)、ResultUI.ts新規(DOMオーバーレイ、data-testid付き)、MainScene配線(終了検知→ResultUI表示→TitleScene遷移・確定無効化)、MainGameUI.setConfirmEnabled追加。turn.ts/engine.ts不変。検証: tsc0・ユニット407パス・E2E88パス・result.tsカバレッジ100/87.5/100/100・全体94.5/89.3/99.3で基準クリア・biome/markdownlint 0 |
| Spec-20 | /sync-graphdb | 2026-09-01 | — | — | Spec-20ノードをtasks-generated→implementedに更新、実装成果物ノード(result.ts/result.test.ts/ResultUI.ts/result.spec.ts/MainScene変更)+implement結果(HAS_IMPLEMENTATION)追加 |
| Spec-20 | /speckit-analyze | 2026-09-01 | — | — | 整合性分析(読み取り専用)。CRITICAL 0件、FRカバレッジ100%、Constitution全原則遵守。指摘はLOWのみ(成否表示文言・日英対応・token log追記)。是正必須事項なし |
| Spec-20 | /speckit-converge | 2026-09-01 | — | — | 収束評価。missing/partial/contradicts/unrequested 全0件で✅Converged。tasks.mdはappend-only契約に従い未変更(git diff差分0)。after_convergeフックは未登録かつConstitution上sync不要でskip |

## 累計

| Spec | 合計トークン（概算） |
|------|------------------|
| Spec-01 | — |
| Spec-02（完了） | — |

## 備考

- トークン数はClaude Codeのセッション画面で確認できる
- 入力・出力トークンが確認できない場合は「—」のままでよい
- 1 Spec完了のたびに1行追記する
