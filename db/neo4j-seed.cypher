// =============================================================================
// neo4j-seed.cypher
// The Unsung Hero — ナレッジグラフ シードデータ
//
// 生成元: docs/ 配下のMarkdownファイル群
// 投入方法:
//   docker compose exec neo4j cypher-shell -u neo4j -p password \
//     --file /var/lib/neo4j/import/neo4j-seed.cypher
//
// 再生成方法: /sync-graphdb スキルの Phase 1 (generate) を実行
// =============================================================================

// --- 既存データを全削除 ---
MATCH (n) DETACH DELETE n;

// =============================================================================
// ノード: Document
// =============================================================================
MERGE (:Document {name: 'README', path: 'README.md', description: 'プロジェクト概要、ドキュメント構成へのポインタ、開発環境セットアップ'});
MERGE (:Document {name: '要件定義', path: 'docs/01-要件定義/index.md', description: 'ゲーム全体の概要、ステージ構成、勝利/失敗条件、ステージデータの定義'});
MERGE (:Document {name: '基本設計', path: 'docs/02-基本設計/index.md', description: '基本設計のインデックス'});
MERGE (:Document {name: 'ターン制とカード', path: 'docs/02-基本設計/ターン制とカード.md', description: '1日1ターン制、カード使用ルール、PMの理想形行動'});
MERGE (:Document {name: 'メンバー', path: 'docs/02-基本設計/メンバー.md', description: 'メンバーのパラメータ（技・経験値・心・体）、レベルアップ、人数'});
MERGE (:Document {name: '画面構成', path: 'docs/02-基本設計/画面構成.md', description: 'ゲーム画面のレイアウト、ツール（ガント/PERT/EVM/リスクグラフ）、ターン移行ロード画面（用語解説表示）'});
MERGE (:Document {name: '経済モデル', path: 'docs/02-基本設計/経済モデル.md', description: 'コスト体系、利益計算、バッファの仕組み'});
MERGE (:Document {name: 'イベント詳細', path: 'docs/03-詳細設計/イベント.md', description: 'イベントの3分類（固定/条件付き/ランダム）、各イベント表、手戻り・停滞'});
MERGE (:Document {name: 'カード詳細', path: 'docs/03-詳細設計/カード.md', description: 'カードの適用方式、個別カードの効果一覧'});
MERGE (:Document {name: 'ターン処理フロー', path: 'docs/03-詳細設計/ターン処理フロー.md', description: '1ターン14ステップの処理順序、ゲーム全体フロー'});
MERGE (:Document {name: '進捗ダイスと経験値', path: 'docs/03-詳細設計/進捗ダイスと経験値.md', description: '進捗ダイスの計算方法、経験値蓄積とレベルアップ'});
MERGE (:Document {name: 'カード自動解決ルール実装計画', path: 'docs/superpowers/plans/2026-08-10-card-auto-resolution.md', type: 'plan'});
MERGE (:Document {name: '条件付きイベント設計', path: 'docs/superpowers/specs/2026-08-09-conditional-events-design.md', description: '条件付きイベントの設計スペック'});
MERGE (:Document {name: 'カード自動解決ルール設計', path: 'docs/superpowers/specs/2026-08-10-card-auto-resolution-design.md', type: 'spec'});
MERGE (:Document {name: 'カード選択UI設計', path: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md', type: 'spec', summary: 'PMがカードを選ぶ際のドラッグ＆ドロップUI設計。挿入→右方向ドミノ倒しで入れ替えの手間を極限まで減らす'});

// =============================================================================
// ノード: Parameter
// =============================================================================
MERGE (:Parameter {name: '技', min: 0, max: 99, description: 'レベル相当。最大99。高いほど進捗ダイスが計画値付近で高止まりしやすい。経験値蓄積でレベルアップ'});
MERGE (:Parameter {name: '経験値', description: 'タスクをこなすことで蓄積。技が低いほど蓄積が速い。一定値でレベルアップ'});
MERGE (:Parameter {name: '心', min: 0, max: 150, thresholdRule: '低すぎても高すぎてもネガティブイベント発生要因', highEffect: '慢心し注意力が低下する', lowEffect: '不安定になり消極的になる', description: '安定さを示すパラメータ。低すぎても高すぎてもネガティブイベント発生要因'});
MERGE (:Parameter {name: '体', min: 0, max: 100, thresholdRule: '低いとネガティブイベント発生要因（100を超えない）', lowEffect: '疲弊しパフォーマンスが落ちる', description: '技を活かせるかどうかを示すパラメータ。範囲0〜100で100を超えない。低いとネガティブイベント発生要因かつ進捗ダイス下振れ'});
MERGE (:Parameter {name: '予想利益', category: 'KPI', displayFormat: '数値のみ', description: 'プロジェクトの見込み利益額', source: 'docs/02-基本設計/画面構成.md'});
MERGE (:Parameter {name: '予想利益率', category: 'KPI', displayFormat: '数値のみ', description: 'プロジェクトの見込み利益率', source: 'docs/02-基本設計/画面構成.md'});
MERGE (:Parameter {name: '透明性', category: 'KPI', range: '0〜150', initialValue: 100, thresholdRule: '低すぎても高すぎてもネガティブイベント発生要因', highEffect: '情報過多で要点が埋もれる', lowEffect: '情報が隠蔽され判断材料が不足する', description: 'プロジェクト状況の可視化度合い', source: 'docs/02-基本設計/画面構成.md'});
MERGE (:Parameter {name: '緊張感', category: 'KPI', range: '0〜150', initialValue: 100, thresholdRule: '低すぎても高すぎてもネガティブイベント発生要因', highEffect: 'ギスギスし関係が悪化する', lowEffect: '弛緩し危機感が失われる', description: 'チームのテンション/プレッシャー度', source: 'docs/02-基本設計/画面構成.md'});

// =============================================================================
// ノード: EventMechanism
// =============================================================================
MERGE (:EventMechanism {name: '固定イベント', description: 'タイミングが確定しており必ず発生するチェックポイント'});
MERGE (:EventMechanism {name: 'ランダムイベント', description: '毎ターンのリスクグラフ確率に基づく抽選で発生'});
MERGE (:EventMechanism {name: '条件付きイベント', description: 'ステージデータに事前定義。指定ターンに条件を評価し、満たせば発生、満たさなければ永久に消滅'});

// =============================================================================
// ノード: EventCategory
// =============================================================================
MERGE (:EventCategory {name: '進捗ダウン', affectsGantt: true, description: '対象タスクの進捗を下げる/止める。ガントチャート計算に反映あり'});
MERGE (:EventCategory {name: '進捗アップ', affectsGantt: true, description: '対象タスクの進捗を通常より押し上げる。ガントチャート計算に反映あり'});
MERGE (:EventCategory {name: 'メンバー稼働系', affectsGantt: false, description: '対象メンバーの稼働可否・人数変動。ガントチャート計算に直接反映なし'});
MERGE (:EventCategory {name: 'スコープ変化系', affectsGantt: false, description: 'ガントチャート上のタスクが増減する構造変更。条件付きイベントに移行しリスクグラフ軸からは除外'});
MERGE (:EventCategory {name: 'バフ系', affectsGantt: false, description: '確率やパラメータ変化率を一時的に改善する持続効果'});
MERGE (:EventCategory {name: 'デバフ系', affectsGantt: false, description: '確率やパラメータ変化率を一時的に悪化させる持続効果'});

// =============================================================================
// ノード: Event（ランダムイベント）
// =============================================================================
MERGE (:Event {name: '手戻り', type: 'ネガティブ', mechanism: 'ランダム', system: 'タスク', category: '進捗ダウン', description: '完了済タスクの進捗が下がる'});
MERGE (:Event {name: 'ブロッカー発生', type: 'ネガティブ', mechanism: 'ランダム', system: 'タスク', category: '進捗ダウン', description: '対象タスクがブロッカー停滞になる'});
MERGE (:Event {name: '仕様不明確', type: 'ネガティブ', mechanism: 'ランダム', system: 'タスク', category: '進捗ダウン', description: '対象タスクが純粋停滞になる'});
MERGE (:Event {name: '環境障害', type: 'ネガティブ', mechanism: 'ランダム', system: 'タスク', category: '進捗ダウン', description: '対象タスクがブロッカー停滞になる'});
MERGE (:Event {name: '過大報告発覚', type: 'ネガティブ', mechanism: 'ランダム', system: 'タスク', category: '進捗ダウン', description: '対象タスクの進捗が突然後退する。心が低いと発生しやすい'});
MERGE (:Event {name: '過小報告発覚', type: 'ネガティブ', mechanism: 'ランダム', system: 'タスク', category: '進捗アップ', description: '対象タスクの進捗が突然上昇する。心が低いと発生しやすい'});
MERGE (:Event {name: '報告漏れ', type: 'ネガティブ', mechanism: 'ランダム', system: 'タスク', description: '効果は要検討。心が低いと発生しやすい'});
MERGE (:Event {name: '体調不良', type: 'ネガティブ', mechanism: 'ランダム', system: 'メンバー', category: 'メンバー稼働系', description: '対象メンバーがその日稼働できない'});
MERGE (:Event {name: 'モチベーション低下', type: 'ネガティブ', mechanism: 'ランダム', system: 'メンバー', category: 'デバフ系', description: '対象メンバーの心の下降が加速する'});
MERGE (:Event {name: '疲労蓄積', type: 'ネガティブ', mechanism: 'ランダム', system: 'メンバー', category: 'デバフ系', description: '対象メンバーの体の下降が加速する'});
MERGE (:Event {name: 'ひらめき', type: 'ポジティブ', mechanism: 'ランダム', system: 'タスク', category: '進捗アップ', description: '対象タスクの進捗が一時的に伸びやすくなる'});
MERGE (:Event {name: '一発合格', type: 'ポジティブ', mechanism: 'ランダム', system: 'タスク', category: 'バフ系', description: '対象タスクの手戻り発生確率が一時的に下がる'});
MERGE (:Event {name: '休息', type: 'ポジティブ', mechanism: 'ランダム', system: 'メンバー', description: '対象メンバーの心・体が回復する'});
MERGE (:Event {name: '地元優勝', type: 'ポジティブ', mechanism: 'ランダム', system: 'メンバー', description: '対象メンバーの心が回復する'});

// =============================================================================
// ノード: Event（固定イベント）
// =============================================================================
MERGE (:Event {name: 'キックオフ', type: 'ポジティブ', mechanism: '固定', system: 'プロジェクト', timing: 'ステージ開始時', description: '高確率でランダムイベントが発生するチェックポイント'});
MERGE (:Event {name: 'デイリー', type: 'ニュートラル', mechanism: '固定', system: 'プロジェクト', timing: '毎ターン', description: '日々の進行に伴うチェックポイント'});
MERGE (:Event {name: '週次進捗会議', type: 'ニュートラル', mechanism: '固定', system: 'プロジェクト', timing: '5ターンごと', description: '高確率でランダムイベントが発生するチェックポイント'});
MERGE (:Event {name: '締め', type: 'ニュートラル', mechanism: '固定', system: 'プロジェクト', timing: '各工程の終了時', description: '高確率でランダムイベントが発生するチェックポイント。タスク未完了だと締め失敗停滞'});
MERGE (:Event {name: 'クロージング', type: 'ニュートラル', mechanism: '固定', system: 'プロジェクト', timing: 'ステージ終了時', description: '高確率でランダムイベントが発生するチェックポイント'});

// =============================================================================
// ノード: Event（条件付きイベント）
// =============================================================================
MERGE (:Event {name: '追加要望', type: 'ネガティブ', mechanism: '条件付き', system: 'プロジェクト', category: 'スコープ変化系', description: '事前作成データの「仕様追加後ガントチャート」に差し替える。顧客からの追加要望を想定'});
MERGE (:Event {name: '仕様変更', type: 'ネガティブ', mechanism: '条件付き', system: 'プロジェクト', description: '関連するタスクに手戻りが発生する'});
MERGE (:Event {name: '値下げ要求', type: 'ネガティブ', mechanism: '条件付き', system: 'プロジェクト', category: 'デバフ系', description: '予算のバッファが減少する'});
MERGE (:Event {name: '監査対応', type: 'ネガティブ', mechanism: '条件付き', system: 'プロジェクト', category: 'デバフ系', description: 'PM・メンバーのコスト消費が一時的に増加する'});
MERGE (:Event {name: '検収不合格', type: 'ネガティブ', mechanism: '条件付き', system: 'プロジェクト', description: '受入テスト工程の締めが完了しない、または手戻りが発生する'});
MERGE (:Event {name: '離脱', type: 'ネガティブ', mechanism: '条件付き', system: 'メンバー', category: 'メンバー稼働系', description: '対象メンバーがチームから離脱する。メンバーが2人以下の場合は発生しない'});
MERGE (:Event {name: '追加予算承認', type: 'ポジティブ', mechanism: '条件付き', system: 'プロジェクト', category: 'バフ系', description: '予算のバッファが増加する'});
MERGE (:Event {name: '早期検収', type: 'ポジティブ', mechanism: '条件付き', system: 'プロジェクト', description: 'フレーバー的な評価向上'});
MERGE (:Event {name: '応援要員', type: 'ポジティブ', mechanism: '条件付き', system: 'メンバー', category: 'メンバー稼働系', description: '一時的にメンバーが増加する'});

// =============================================================================
// ノード: Card
// =============================================================================
MERGE (:Card {name: 'デイリー', cost: '低', method: 'セット・手動解除', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', description: 'ランダムイベント（手戻り・停滞）の発生確率を下げる。PMの理想形行動'});
MERGE (:Card {name: 'レビュー', cost: '低', method: 'セット・手動解除', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', description: '手戻りの発生確率を下げる。PMの理想形行動'});
MERGE (:Card {name: 'モニタリング', cost: '低', method: 'セット・手動解除', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', description: '検収不合格・過大報告・過小報告・報告漏れの発生確率を下げる。PMの理想形行動'});
MERGE (:Card {name: 'サマライズ', cost: '低', method: 'セット・手動解除', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', description: '締めの発生確率を下げる。PMの理想形行動'});
MERGE (:Card {name: '教育', cost: '中', method: '即時', autoResolutionPattern: '最適割当', autoResolutionRule: '技が最も低いメンバーを対象に、技が最も高いメンバーが教える', description: '対象メンバーの経験値が増加する。両者にトレーニング停滞が発生'});
MERGE (:Card {name: 'ペアプログラミング', cost: '中', method: '即時', autoResolutionPattern: '最適割当', autoResolutionRule: '技が最も低いメンバーを対象に、技が次に高いメンバーとペアを組む', description: '対象メンバーの経験値が増加する。教育より軽め'});
MERGE (:Card {name: '雑談', cost: '低', method: '要検討', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', description: '心の低下率を低減する（回復ではなく減衰緩和）'});
MERGE (:Card {name: '個別面談', cost: '低〜中', method: '即時', autoResolutionPattern: '最弱救済', autoResolutionRule: '心が最も低いメンバーが対象', description: '対象メンバー1人の心を軽度に回復させる'});
MERGE (:Card {name: '表彰', cost: '中', method: '即時', autoResolutionPattern: '最弱救済', autoResolutionRule: '心が最も低いメンバーが対象', description: '対象メンバーの心を大きく回復させる。配布数限定'});
MERGE (:Card {name: '計画休', cost: '中', method: '即時', autoResolutionPattern: '最弱救済', autoResolutionRule: '体が最も低いメンバーが対象', description: '対象メンバー1人の心・体が一定値回復する'});
MERGE (:Card {name: '残業許可', cost: '低', method: 'セット・自動解除', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', description: '全員の1日のコスト上限を引き上げる。1ヶ月間持続'});
MERGE (:Card {name: '休出', cost: '特大', method: 'セット・自動解除', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', description: '週末も進捗・イベント発生が継続。心体低下・ネガティブ確率上昇'});
MERGE (:Card {name: 'リスケ', cost: '中', method: '即時', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', description: '事前作成データの「リスケ後ガントチャート」に差し替える。ガントチャートの構造変更は事前作成データへの差し替えで行う'});
MERGE (:Card {name: '強制締め', cost: '高', method: '即時', autoResolutionPattern: '状況対応', autoResolutionRule: '現在の工程の締めが対象（一意に決まる）', description: '未完了のまま工程の締めを完了させる。手戻り確率が大きく上昇'});
MERGE (:Card {name: '停滞対応', cost: '低', method: '即時', autoResolutionPattern: '状況対応', autoResolutionRule: '停滞中タスクのうち最も遅れているものが対象', description: '対象タスクの停滞を解除する'});
MERGE (:Card {name: '進捗ブースト', cost: '中〜高', method: '要検討', autoResolutionPattern: '状況対応', autoResolutionRule: '計画比で最も遅れているタスクが対象', description: '対象タスクの進捗効率を無理やり上げる。手戻り解消にも使用可'});
MERGE (:Card {name: 'メンバー追加', cost: '高', method: '即時', autoResolutionPattern: '全体効果', autoResolutionRule: '追加メンバーの技は固定値、オンボーディング対象は技が最も高いメンバー', description: 'メンバーを1人追加・補充する（最大6人）。オンボーディング発生'});
MERGE (:Card {name: 'アサイン', cost: '低', applicationType: '即時', autoResolutionPattern: '最適割当', autoResolutionRule: '担当タスクが最も少ないメンバーを新規タスクにアサイン', effect: '担当タスクが最も少ないメンバーを新規タスクにアサインする', source: 'docs/superpowers/specs/2026-08-10-card-auto-resolution-design.md'});
MERGE (:Card {name: '入れ替え', cost: '低', applicationType: '即時', autoResolutionPattern: '最適割当', autoResolutionRule: '進捗最大メンバーの最進捗タスクと、進捗最小メンバーの最低進捗タスクを交換', effect: '進捗最大メンバーの最進捗タスクと、進捗最小メンバーの最低進捗タスクを交換する', source: 'docs/superpowers/specs/2026-08-10-card-auto-resolution-design.md'});
MERGE (:Card {name: '巻取り', cost: '低〜中', applicationType: '即時', autoResolutionPattern: '最適割当', autoResolutionRule: '進捗最大メンバーが、進捗最小メンバーの最低進捗タスクを完全に引き取る', effect: '進捗最大メンバーが、進捗最小メンバーの最低進捗タスクを完全に引き取る', source: 'docs/superpowers/specs/2026-08-10-card-auto-resolution-design.md'});
MERGE (:Card {name: '納期交渉', cost: '特大', applicationType: '即時', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', effect: '顧客と納期延期を交渉する。成功すれば納期延長＋メンバーの心・体回復。延期幅は予算バッファにキャップ', source: 'docs/superpowers/specs/2026-08-10-card-auto-resolution-design.md'});
MERGE (:Card {name: 'スコープ交渉', cost: '特大', applicationType: '即時', autoResolutionPattern: '全体効果', autoResolutionRule: '対象指定なし', effect: '顧客とスコープ削減を交渉する。成功すれば未着手タスクの一部が削除される', source: 'docs/superpowers/specs/2026-08-10-card-auto-resolution-design.md'});

// =============================================================================
// ノード: Rule
// =============================================================================
MERGE (:Rule {name: 'コミットメッセージ規約', description: 'Conventional Commits形式＋日本語。type: feat/fix/docs/refactor/chore/test/style', source: 'CLAUDE.md'});
MERGE (:Rule {name: '犠牲順', description: '押し出し時の犠牲順序：バッファ4→3→2→1→サマライズ→リサーチ→デイリー→レビュー（レビューが最後まで残る）', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#翌日の枠の食われ方'});

// =============================================================================
// ノード: Concept
// =============================================================================
MERGE (:Concept {name: 'カード', description: 'PMの行動手段。メンバーへの指示として機能。1日8コスト上限'});
MERGE (:Concept {name: 'カード枠', description: 'PMのコスト消費の視覚化。1日8枠、左4つが既定枠、右4つがバッファ枠', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#カード枠のレイアウト'});
MERGE (:Concept {name: 'カード枠と状態変化の分離', description: 'カード枠はPMのコスト消費の視覚化、状態変化はメンバーまたはプロジェクトに付与される効果。カード枠から押し出されても付与済み状態は影響を受けない', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#核心概念'});
MERGE (:Concept {name: 'カード枠（常時表示）', description: 'ダッシュボード下部に常時表示される8コスト分のカードスロット。毎ターンのメイン操作エリア', source: 'docs/02-基本設計/画面構成.md'});
MERGE (:Concept {name: 'カード自動解決', description: '全カードの操作を枠に置くだけに統一し、対象メンバー・タスクはカードごとの自動解決ルールで決定する設計方針', source: 'docs/superpowers/specs/2026-08-10-card-auto-resolution-design.md'});
MERGE (:Concept {name: 'ガントチャート', description: 'ステージデータとして事前定義されたタスク構成・依存関係・期間。閲覧専用。仕様追加イベントやリスケカードによる変更は事前作成データへの差し替えで反映する'});
MERGE (:Concept {name: 'ガントチャートバリエーション', description: '仕様追加・リスケ後のガントチャートを事前作成データとして保持する仕組み。実行時にアルゴリズムで計算せず、変更後の状態をステージデータの一部として事前設計し、イベント発生時・カード使用時に対応データへ差し替える', source: 'docs/01-要件定義/index.md#ステージデータ'});
MERGE (:Concept {name: 'ガントチャート画面', description: 'メニューから切替で表示。スケジュールと依存関係の確認用', source: 'docs/02-基本設計/画面構成.md'});
MERGE (:Concept {name: 'ステージ', description: '1/3/6/12ヶ月のプロジェクト期間。レベルデータとして事前設計される独立したゲーム単位'});
MERGE (:Concept {name: 'ステージデータ', description: 'レベルデータ。ガントチャート＋条件付きイベントリスト＋初期メンバー構成＋予算・納期で構成'});
MERGE (:Concept {name: 'ステータスエリア', description: 'メンバーステータス一覧・プロジェクトステータス一覧を表示するエリア。状態変化はここに表示される', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#核心概念'});
MERGE (:Concept {name: 'ターン', description: '1日1ターン制。PMのカード選択→メンバー稼働→イベント→更新の14ステップで進行'});
MERGE (:Concept {name: 'ターン移行ロード画面', description: 'ターン確定〜次ターン開始までの処理待ち時間に表示するロード画面。PM専門用語の解説をランダム表示し、待ち時間を学習機会として活用する', section: 'ターン移行ロード画面', source: 'docs/02-基本設計/画面構成.md'});
MERGE (:Concept {name: 'ダッシュボード', description: 'メイン画面。プロジェクトKPI（6指標: 予想利益・予想利益率・SPI・CPI・透明性・緊張感）を表示。予想利益・予想利益率は数値のみ、SPI・CPI・透明性・緊張感は横棒ゲージ。メンバーステータスも常時表示。スマホ横持ち前提', source: 'docs/02-基本設計/画面構成.md'});
MERGE (:Concept {name: 'トレーニング停滞', description: '教育・ペアプログラミング・オンボーディングで発生。一定期間後自動解除、経験値増加'});
MERGE (:Concept {name: 'ドミノ倒し', description: '挿入位置にカードを入れると右方向に全てシフト。1枠でも複数枠でも同じ挙動。ロック枠は飛ばす', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#ドミノ倒しのルール'});
MERGE (:Concept {name: 'ドラッグ＆ドロップUI', description: '手札からカードをドラッグし枠上にドロップ。ドラッグ中にリアルタイムプレビューアニメーションでドミノ倒しの結果を表示。日跨ぎ時は吹き出しでフィードバック', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#ドラッグ＆ドロップの挙動'});
MERGE (:Concept {name: 'ブロッカー停滞', description: '対象メンバー以外の責任により進捗停止。カード「停滞対応」をブロッカー担当メンバーに使って解消'});
MERGE (:Concept {name: 'リスクグラフ', description: 'ランダムイベントの発生確率をカテゴリ別にレーダーチャートで表示。条件付きイベントは対象外'});
MERGE (:Concept {name: 'リスクグラフ画面', description: 'メニューから切替で表示。リスクレーダーチャート', source: 'docs/02-基本設計/画面構成.md'});
MERGE (:Concept {name: 'ロック状態', description: '日跨ぎカードは占有ターン全てでロック。暗めの色＋ロックアイコン、ドラッグ不可。コスト分のターン経過で自動解放', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#ロック状態'});
MERGE (:Concept {name: '利益', description: '予算−総消費コスト。目標利益を超えればクリア'});
MERGE (:Concept {name: '工程', description: 'ウォーターフォール型。要件定義→設計→開発→テスト→受入テスト（1ヶ月PoCは設計→開発→テストの3工程）'});
MERGE (:Concept {name: '手戻り', description: '完了済タスクの進捗が下がる。担当メンバーの通常の進捗ダイスで再完了を目指す'});
MERGE (:Concept {name: '既定枠自動復帰', description: 'ターン開始時に空き枠へ復帰。復帰順：デイリー→レビュー→リサーチ→サマライズ。左詰め、ロック枠は飛ばす', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#復帰ルール'});
MERGE (:Concept {name: '日跨ぎ', description: 'カードコストが残り枠数を超える場合、超過分が翌日以降の枠を食う。翌日は右端から犠牲順に食われる。UIは吹き出しのみで翌日レーンは表示しない', source: 'docs/superpowers/specs/2026-08-10-card-selection-ui-design.md#日跨ぎの処理'});
MERGE (:Concept {name: '条件付きイベント定義', description: 'ステージデータ内のイベント定義構造。id/turn/condition/event/paramsの5フィールド'});
MERGE (:Concept {name: '条件式パラメータ', description: '条件付きイベントの条件式で参照可能なゲーム内状態'});
MERGE (:Concept {name: '純粋停滞', description: 'メンバー本人の問題により進捗が停止。カード「停滞対応」を本人に使って解消'});
MERGE (:Concept {name: '締め失敗停滞', description: '工程の締めにタスク未完了で突入。後続タスクすべて停止。カード「強制締め」で解消'});
MERGE (:Concept {name: 'EVM', description: 'PV/EV/ACを管理。SPI・CPIを算出しKPI画面に表示'});
MERGE (:Concept {name: 'PERT図', description: 'タスク間の依存関係を表す。ガントチャートのタスクから辿る形で確認'});
MERGE (:Concept {name: 'SPI', category: 'KPI', description: 'Schedule Performance Index。EVM指標。条件式で参照可能'});
MERGE (:Concept {name: 'CPI', category: 'KPI', description: 'Cost Performance Index。EVM指標。条件式で参照可能'});
MERGE (:Concept {name: 'avgMorale', description: 'メンバー全員の心の平均値。条件式で参照可能'});
MERGE (:Concept {name: 'avgHealth', description: 'メンバー全員の体の平均値。条件式で参照可能'});
MERGE (:Concept {name: 'cardUsed', description: '特定カードの使用済み判定。条件式で参照可能'});
MERGE (:Concept {name: 'cardUsedCount', description: '特定カードの使用回数。条件式で参照可能'});
MERGE (:Concept {name: 'taskCompletionRate', description: '全タスクの完了率。条件式で参照可能'});
MERGE (:Concept {name: 'phaseProgress', description: '特定工程の進捗率。条件式で参照可能'});

// =============================================================================
// リレーションシップ: Document → Document
// =============================================================================
MATCH (a:Document {name: '要件定義'}), (b:Document {name: 'ターン制とカード'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: '要件定義'}), (b:Document {name: 'メンバー'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: '要件定義'}), (b:Document {name: 'イベント詳細'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'イベント詳細'}), (b:Document {name: 'カード詳細'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'イベント詳細'}), (b:Document {name: 'ターン処理フロー'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'ターン処理フロー'}), (b:Document {name: 'イベント詳細'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'ターン処理フロー'}), (b:Document {name: '進捗ダイスと経験値'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: '条件付きイベント設計'}), (b:Document {name: 'イベント詳細'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: '条件付きイベント設計'}), (b:Document {name: 'ターン処理フロー'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: '条件付きイベント設計'}), (b:Document {name: '要件定義'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Document {name: 'カード詳細'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Document {name: 'ターン処理フロー'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Document {name: 'ターン制とカード'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Document {name: '画面構成'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'カード自動解決ルール実装計画'}), (b:Document {name: 'カード自動解決ルール設計'}) MERGE (a)-[:IMPLEMENTS]->(b);

// =============================================================================
// リレーションシップ: Document → Concept/Rule/Card
// =============================================================================
MATCH (a:Document {name: '画面構成'}), (b:Concept {name: 'ダッシュボード'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: '画面構成'}), (b:Concept {name: 'カード枠（常時表示）'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: '画面構成'}), (b:Concept {name: 'ガントチャート画面'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: '画面構成'}), (b:Concept {name: 'リスクグラフ画面'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: '画面構成'}), (b:Concept {name: 'ターン移行ロード画面'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Concept {name: 'カード枠'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Concept {name: 'カード枠と状態変化の分離'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Concept {name: 'ステータスエリア'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Concept {name: 'ドミノ倒し'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Concept {name: 'ドラッグ＆ドロップUI'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Concept {name: 'ロック状態'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Concept {name: '既定枠自動復帰'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Concept {name: '日跨ぎ'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード選択UI設計'}), (b:Rule {name: '犠牲順'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Document {name: 'カード自動解決ルール設計'}), (b:Card {name: 'アサイン'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'カード自動解決ルール設計'}), (b:Card {name: 'スコープ交渉'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'カード自動解決ルール設計'}), (b:Card {name: '入れ替え'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'カード自動解決ルール設計'}), (b:Card {name: '巻取り'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'カード自動解決ルール設計'}), (b:Card {name: '納期交渉'}) MERGE (a)-[:DEFINES]->(b);

// =============================================================================
// リレーションシップ: Concept → Concept/Document/Rule/Parameter/EventCategory
// =============================================================================
MATCH (a:Concept {name: 'ステージ'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Concept {name: 'ステージ'}), (b:Concept {name: 'ステージデータ'}) MERGE (a)-[:DEFINED_BY]->(b);
MATCH (a:Concept {name: 'ステージデータ'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Concept {name: 'ステージデータ'}), (b:Concept {name: '条件付きイベント定義'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Concept {name: 'ガントチャート'}), (b:Concept {name: 'ガントチャートバリエーション'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: 'EVM'}), (b:Concept {name: 'SPI'}) MERGE (a)-[:PROVIDES]->(b);
MATCH (a:Concept {name: 'EVM'}), (b:Concept {name: 'CPI'}) MERGE (a)-[:PROVIDES]->(b);
MATCH (a:Concept {name: 'ターン'}), (b:Concept {name: 'カード'}) MERGE (a)-[:STEP_1 {description: 'PMのカード選択確定'}]->(b);
MATCH (a:Concept {name: 'ターン'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:STEP_8 {description: 'ガントチャート/PERT図の更新'}]->(b);
MATCH (a:Concept {name: 'ターン'}), (b:Concept {name: 'EVM'}) MERGE (a)-[:STEP_9 {description: 'コスト集計・EVM更新'}]->(b);
MATCH (a:Concept {name: 'ターン'}), (b:Concept {name: 'リスクグラフ'}) MERGE (a)-[:STEP_10 {description: 'リスクグラフの再計算'}]->(b);
MATCH (a:Concept {name: 'ダッシュボード'}), (b:Concept {name: 'SPI'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'ダッシュボード'}), (b:Concept {name: 'CPI'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'ダッシュボード'}), (b:Parameter {name: '予想利益'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'ダッシュボード'}), (b:Parameter {name: '予想利益率'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'ダッシュボード'}), (b:Parameter {name: '透明性'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'ダッシュボード'}), (b:Parameter {name: '緊張感'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'リスクグラフ'}), (b:EventCategory {name: '進捗ダウン'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'リスクグラフ'}), (b:EventCategory {name: '進捗アップ'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'リスクグラフ'}), (b:EventCategory {name: 'メンバー稼働系'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'リスクグラフ'}), (b:EventCategory {name: 'バフ系'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'リスクグラフ'}), (b:EventCategory {name: 'デバフ系'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'ドラッグ＆ドロップUI'}), (b:Concept {name: 'ドミノ倒し'}) MERGE (a)-[:USES]->(b);
MATCH (a:Concept {name: 'カード枠と状態変化の分離'}), (b:Concept {name: 'ステータスエリア'}) MERGE (a)-[:DISPLAYS]->(b);
MATCH (a:Concept {name: 'ロック状態'}), (b:Concept {name: '既定枠自動復帰'}) MERGE (a)-[:AFFECTS]->(b);
MATCH (a:Concept {name: '既定枠自動復帰'}), (b:Rule {name: '犠牲順'}) MERGE (a)-[:USES]->(b);
MATCH (a:Concept {name: '日跨ぎ'}), (b:Rule {name: '犠牲順'}) MERGE (a)-[:USES]->(b);
MATCH (a:Concept {name: '条件付きイベント定義'}), (b:Concept {name: '条件式パラメータ'}) MERGE (a)-[:USES]->(b);
MATCH (a:Concept {name: '条件式パラメータ'}), (b:Concept {name: 'SPI'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: '条件式パラメータ'}), (b:Concept {name: 'CPI'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: '条件式パラメータ'}), (b:Concept {name: 'avgMorale'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: '条件式パラメータ'}), (b:Concept {name: 'avgHealth'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: '条件式パラメータ'}), (b:Concept {name: 'cardUsed'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: '条件式パラメータ'}), (b:Concept {name: 'cardUsedCount'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: '条件式パラメータ'}), (b:Concept {name: 'taskCompletionRate'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: '条件式パラメータ'}), (b:Concept {name: 'phaseProgress'}) MERGE (a)-[:INCLUDES]->(b);
MATCH (a:Concept {name: 'ターン移行ロード画面'}), (b:Document {name: 'ターン処理フロー'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Concept {name: 'ターン移行ロード画面'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Concept {name: 'ターン移行ロード画面'}), (b:Concept {name: 'EVM'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Concept {name: 'ターン移行ロード画面'}), (b:Concept {name: 'PERT図'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Concept {name: 'ターン移行ロード画面'}), (b:Concept {name: 'SPI'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Concept {name: 'ターン移行ロード画面'}), (b:Concept {name: 'CPI'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Concept {name: 'ターン移行ロード画面'}), (b:Concept {name: 'リスクグラフ'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// リレーションシップ: Parameter → Document/Concept
// =============================================================================
MATCH (a:Parameter {name: '技'}), (b:Document {name: '進捗ダイスと経験値'}) MERGE (a)-[:AFFECTS {how: '高いほど計画値付近で高止まり'}]->(b);
MATCH (a:Parameter {name: '体'}), (b:Document {name: '進捗ダイスと経験値'}) MERGE (a)-[:AFFECTS {how: '低いほど下振れしやすい'}]->(b);
MATCH (a:Parameter {name: '心'}), (b:Concept {name: 'リスクグラフ'}) MERGE (a)-[:INFLUENCES {how: '低いとネガティブイベント発生確率上昇'}]->(b);

// =============================================================================
// リレーションシップ: Event → EventCategory / EventMechanism / Concept
// =============================================================================
// ランダムイベント → EventMechanism
MATCH (a:Event {mechanism: 'ランダム'}), (b:EventMechanism {name: 'ランダムイベント'}) MERGE (a)-[:HAS_MECHANISM]->(b);
// 固定イベント → EventMechanism
MATCH (a:Event {mechanism: '固定'}), (b:EventMechanism {name: '固定イベント'}) MERGE (a)-[:HAS_MECHANISM]->(b);
// 条件付きイベント → EventMechanism
MATCH (a:Event {mechanism: '条件付き'}), (b:EventMechanism {name: '条件付きイベント'}) MERGE (a)-[:HAS_MECHANISM]->(b);
// Event → EventCategory (categoryプロパティが一致するもの)
MATCH (a:Event), (b:EventCategory)
WHERE a.category = b.name
MERGE (a)-[:BELONGS_TO]->(b);
// 追加要望 → ガントチャートバリエーション
MATCH (a:Event {name: '追加要望'}), (b:Concept {name: 'ガントチャートバリエーション'}) MERGE (a)-[:USES]->(b);

// =============================================================================
// リレーションシップ: Card → Event（REDUCES_PROBABILITY）
// =============================================================================
MATCH (a:Card {name: 'デイリー'}), (b:Event {name: '手戻り'}) MERGE (a)-[:REDUCES_PROBABILITY]->(b);
MATCH (a:Card {name: 'デイリー'}), (b:Event {name: '仕様不明確'}) MERGE (a)-[:REDUCES_PROBABILITY]->(b);
MATCH (a:Card {name: 'レビュー'}), (b:Event {name: '手戻り'}) MERGE (a)-[:REDUCES_PROBABILITY]->(b);
MATCH (a:Card {name: 'モニタリング'}), (b:Event {name: '過大報告発覚'}) MERGE (a)-[:REDUCES_PROBABILITY]->(b);
MATCH (a:Card {name: 'モニタリング'}), (b:Event {name: '過小報告発覚'}) MERGE (a)-[:REDUCES_PROBABILITY]->(b);
MATCH (a:Card {name: 'モニタリング'}), (b:Event {name: '報告漏れ'}) MERGE (a)-[:REDUCES_PROBABILITY]->(b);
MATCH (a:Card {name: 'モニタリング'}), (b:Event {name: '検収不合格'}) MERGE (a)-[:REDUCES_PROBABILITY]->(b);
MATCH (a:Card {name: 'サマライズ'}), (b:Event {name: '締め'}) MERGE (a)-[:REDUCES_PROBABILITY]->(b);

// =============================================================================
// リレーションシップ: Card → Event（CONDITION_FOR）
// =============================================================================
MATCH (a:Card {name: 'モニタリング'}), (b:Event {name: '仕様変更'}) MERGE (a)-[:CONDITION_FOR {conditionType: '未使用で発生リスク'}]->(b);
MATCH (a:Card {name: '残業許可'}), (b:Event {name: '離脱'}) MERGE (a)-[:CONDITION_FOR {conditionType: '使用済みで発生リスク'}]->(b);

// =============================================================================
// リレーションシップ: Card → Parameter
// =============================================================================
MATCH (a:Card {name: '教育'}), (b:Parameter {name: '経験値'}) MERGE (a)-[:INCREASES]->(b);
MATCH (a:Card {name: 'ペアプログラミング'}), (b:Parameter {name: '経験値'}) MERGE (a)-[:INCREASES]->(b);
MATCH (a:Card {name: '個別面談'}), (b:Parameter {name: '心'}) MERGE (a)-[:RECOVERS]->(b);
MATCH (a:Card {name: '表彰'}), (b:Parameter {name: '心'}) MERGE (a)-[:RECOVERS]->(b);
MATCH (a:Card {name: '計画休'}), (b:Parameter {name: '心'}) MERGE (a)-[:RECOVERS]->(b);
MATCH (a:Card {name: '計画休'}), (b:Parameter {name: '体'}) MERGE (a)-[:RECOVERS]->(b);
MATCH (a:Card {name: '雑談'}), (b:Parameter {name: '心'}) MERGE (a)-[:REDUCES_DECAY]->(b);

// =============================================================================
// リレーションシップ: Card → Concept（MODIFIES / USES）
// =============================================================================
MATCH (a:Card {name: 'リスケ'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:MODIFIES]->(b);
MATCH (a:Card {name: 'リスケ'}), (b:Concept {name: 'ガントチャートバリエーション'}) MERGE (a)-[:USES]->(b);
// 全カード → カード自動解決
MATCH (a:Card), (b:Concept {name: 'カード自動解決'}) MERGE (a)-[:USES]->(b);

// =============================================================================
// ノード: Document（追加）— SDD関連ドキュメント
// =============================================================================
MERGE (:Document {name: 'バランスパラメータ', path: 'docs/03-詳細設計/バランスパラメータ.md', description: '進捗ダイス計算式・経験値カーブ・心体変動・イベント確率・カードコストの仮値定数'});
MERGE (:Document {name: 'SDDタスクリスト', path: 'docs/sdd-tasks.md', description: 'Spec Kit SDDで実装する10 Spec / 4フェーズのタスクリスト。Spec-01完了済み。'});
MERGE (:Document {name: 'SDD分割計画', path: 'docs/superpowers/plans/2026-08-12-sdd-task-breakdown.md', description: '各SpecのスコープとSpecKitコマンドの指示例', type: 'plan'});
MERGE (:Document {name: '技術スタック', path: 'docs/02-基本設計/技術スタック.md', description: 'Phaser 4/TypeScript/Vite/Biome/Vitest等の技術選定、SDDワークフロー'});
MERGE (:Document {name: 'Spec-01 spec', path: 'specs/001-core-types-constants/spec.md', description: 'コアデータ型定義・定数・balance関数のフィーチャースペック', type: 'spec'});
MERGE (:Document {name: 'プロジェクト憲章', path: '.specify/memory/constitution.md', description: 'アーキテクチャ境界・テストゲート・ゲームバランス不変条件等の開発原則（Spec Kit constitution）'});

// =============================================================================
// ノード: Concept（追加）— SDD・技術スタック関連
// =============================================================================
MERGE (:Concept {name: 'SDD', fullName: 'Spec-Driven Development', description: 'specifyで仕様→計画→タスク→実装の順に進める開発手法'});
MERGE (:Concept {name: 'Spec Kit', description: 'GitHub製のSDD実装支援ツールキット。specify CLIとスキル群を提供する'});
MERGE (:Concept {name: 'アーキテクチャ境界', description: 'src/game/(ロジック), src/scenes/(Phaser描画), src/ui/(DOM overlay)の3層分離'});
MERGE (:Concept {name: 'コアデータ型', description: 'Member/Card/Event/GameState/GanttTask/GanttChart/TurnResult/StageDataの型定義群'});
MERGE (:Concept {name: '定数ファイル', description: 'バランスパラメータ.mdの全数値定数を一箇所に集約したファイル。チューニング時の変更点を最小化する'});
MERGE (:Concept {name: 'balance関数', description: 'skill_factor(技)とhealth_factor(体)の乱数範囲を返す純粋関数'});

// =============================================================================
// ノード: ADR
// =============================================================================
MERGE (:ADR {
  id: 'ADR-001',
  title: 'SDD + Spec Kit を実装手法として採用',
  date: '2026-08-12',
  status: 'accepted',
  context: '実装に入るにあたり、AIエージェントによる大規模コード生成で品質を担保する手法が必要だった。仕様が曖昧なままコード生成すると手戻りが大きくなるリスクがある。',
  decision: 'GitHub製 Spec Kit（specify CLI）を使い、specify→plan→tasks→implementの順でSDDを実施する。各ステップ後に/sync-graphdbでグラフDBを更新することを義務化した。',
  rationale: 'Spec Kitは仕様(what/why)をコード生成前に固定する構造を強制するため、AIエージェントの生成物の品質が安定する。Claude Code向けintegrationが公式サポートされており、.claude/skills/に自動インストールされる。',
  consequences: '各Specの実装前にspecify+planのオーバーヘッドが発生するが、手戻りの削減でトータルは短縮される見込み。Spec Kitの外部ファイルがmarkdownlintに引っかかるため.lintstagedrc.cjsで除外設定が必要だった。'
});
MERGE (:ADR {
  id: 'ADR-002',
  title: 'コアデータ型をPhaser非依存のpure TSで定義',
  date: '2026-08-12',
  status: 'accepted',
  context: 'src/game/をPhaser非依存にするアーキテクチャ境界の原則を具体化する際、型定義の置き場所と依存関係を明確にする必要があった。',
  decision: 'src/game/types.ts・constants.ts・balance.tsをPhaser/DOM非依存のpure TypeScriptとして定義する。Spec-01の実装スコープをこの3ファイルに限定した。',
  rationale: 'ゲームロジックをPhaser非依存にすることでVitestによる高速ユニットテストが可能になる。Phaserのcanvasはヘッドレス環境で扱いにくいため、ロジック層は完全に分離する必要がある。',
  consequences: '型定義がPhaser型と混在しないため、後続SpecでPhaser Scene実装時に明確な境界を維持できる。一方、Phaser独自型（例: Phaser.Math.Vector2）はscenes/側でラップして使う必要がある。'
});
MERGE (:ADR {
  id: 'ADR-003',
  title: 'バランスパラメータを定数ファイルに一括集約',
  date: '2026-08-12',
  status: 'accepted',
  context: 'テストプレイ後のチューニングで多数の数値変更が発生する想定。数値がコード各所に散在するとマジックナンバー問題と修正ミスのリスクがある。',
  decision: 'バランスパラメータ.mdの全数値（進捗ダイス・イベント確率・カードコスト・心体変動量等）をsrc/game/constants.tsに集約する。変更はこのファイルのみで完結する設計にする。',
  rationale: 'チューニングフェーズで頻繁に数値変更が発生するため、変更箇所を最小化することが重要。定数ファイルを単一の真実の源にすることでバランス調整の安全性が高まる。',
  consequences: 'バランスパラメータ.mdとconstants.tsの二重管理が発生する。ドキュメントは設計の意図を説明し、constants.tsが実際の数値の正とする運用で対応する。'
});

// =============================================================================
// リレーションシップ: ADR → Concept/Document (AFFECTS)
// =============================================================================
MATCH (adr:ADR {id: 'ADR-001'}), (n:Concept {name: 'SDD'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-001'}), (n:Concept {name: 'Spec Kit'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-001'}), (n:Document {name: 'プロジェクト憲章'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-002'}), (n:Concept {name: 'アーキテクチャ境界'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-002'}), (n:Concept {name: 'コアデータ型'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-003'}), (n:Concept {name: '定数ファイル'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-003'}), (n:Document {name: 'バランスパラメータ'}) MERGE (adr)-[:AFFECTS]->(n);

// Spec-01 spec document → Concept
MATCH (a:Document {name: 'Spec-01 spec'}), (b:Concept {name: 'コアデータ型'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'Spec-01 spec'}), (b:Concept {name: '定数ファイル'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'Spec-01 spec'}), (b:Concept {name: 'balance関数'}) MERGE (a)-[:DEFINES]->(b);

// =============================================================================
// ノード: Document（追加）— Spec-01 plan artifacts
// =============================================================================
MERGE (:Document {name: 'Spec-01 plan', path: 'specs/001-core-types-constants/plan.md', description: 'コアデータ型定数の実装計画（Technical Context・Constitution Check・ファイル構成）', type: 'plan'});
MERGE (:Document {name: 'Spec-01 data-model', path: 'specs/001-core-types-constants/data-model.md', description: 'コアデータ型の全エンティティ定義・フィールド一覧・依存関係', type: 'data-model'});
MERGE (:Document {name: 'Spec-01 quickstart', path: 'specs/001-core-types-constants/quickstart.md', description: 'Spec-01検証手順（typecheck/test/マジックナンバーチェック）', type: 'quickstart'});

// Spec-01 plan → Concept
MATCH (a:Document {name: 'Spec-01 plan'}), (b:Concept {name: 'アーキテクチャ境界'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-01 plan'}), (b:Concept {name: 'コアデータ型'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-01 plan'}), (b:Concept {name: '定数ファイル'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-01 tasks
// =============================================================================
MERGE (:Document {
  name: 'Spec-01 tasks',
  path: 'specs/001-core-types-constants/tasks.md',
  description: 'Spec-01の実装タスクリスト（T001〜T021・5フェーズ構成。types.ts→constants.ts→balance.tsの依存順で実装）',
  type: 'tasks'
});

// Spec-01 tasks → Concept/Document
MATCH (a:Document {name: 'Spec-01 tasks'}), (b:Concept {name: 'コアデータ型'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-01 tasks'}), (b:Concept {name: '定数ファイル'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-01 tasks'}), (b:Concept {name: 'balance関数'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-01 tasks'}), (b:Document {name: 'Spec-01 plan'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-01 tasks'}), (b:Document {name: 'Spec-01 data-model'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-01 実装ファイル
// =============================================================================
MERGE (:Document {name: 'Spec-01 types.ts', path: 'src/game/types.ts', description: 'ゲーム全体のコアデータ型定義。CardName(26枚)/Member/GanttTask/GanttChart/GameState/TurnResult/StageData等。Phaser/DOM非依存pure TS。', type: 'source'});
MERGE (:Document {name: 'Spec-01 constants.ts', path: 'src/game/constants.ts', description: 'バランスパラメータ.mdの全数値定数を集約。POC_STAGE/MEMBER_PARAMS/EXP/LEVEL_UP_EXP/EVENT_PROB/CARD_COSTS/SKILL_FACTOR_TABLE/HEALTH_FACTOR_TABLE等。', type: 'source'});
MERGE (:Document {name: 'Spec-01 balance.ts', path: 'src/game/balance.ts', description: 'getSkillFactorRange(skill)/getHealthFactor(health)の実装。テーブル参照で[min,max]を返す純粋関数。', type: 'source'});
MERGE (:Document {name: 'Spec-01 balance.test.ts', path: 'tests/unit/balance.test.ts', description: 'Vitest+fast-checkによるbalance関数の境界値テスト(20件)・プロパティテスト。技0〜99・体0〜100の全域でパニックなし確認済み。', type: 'test'});

MATCH (a:Document {name: 'Spec-01 types.ts'}), (b:Concept {name: 'コアデータ型'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'Spec-01 constants.ts'}), (b:Concept {name: '定数ファイル'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'Spec-01 balance.ts'}), (b:Concept {name: 'balance関数'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'Spec-01 constants.ts'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-01 balance.ts'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-01 balance.test.ts'}), (b:Document {name: 'Spec-01 balance.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ADR-004: CARD_COSTSのデイリー中止コストを0として定義
// =============================================================================
MERGE (:ADR {
  id: 'ADR-004',
  title: 'CARD_COSTSに存在しないカードへのコスト定義をゼロとして扱う',
  date: '2026-08-12',
  status: 'accepted',
  context: 'バランスパラメータ.mdの個別コスト確定値リストに「デイリー中止」が含まれていなかったが、CardName union型には含まれる。Record<CardName,number>は全26枚を網羅しなければならない。',
  decision: 'デイリー中止のコストを0として定義し、CARD_COSTSをRecord<CardName,number>として完全に型安全に保つ。',
  rationale: 'TypeScriptのRecord<K,V>は全キーの存在を静的に保証する。未定義のまま残すとtscエラーになるため、論理的に「使用コストなし」を意味する0を採用した。',
  consequences: 'コスト0のカードが存在する設計が明示される。将来コストを変更する場合はconstants.tsの1箇所を修正するだけで済む。'
});
MATCH (adr:ADR {id: 'ADR-004'}), (n:Concept {name: '定数ファイル'}) MERGE (adr)-[:AFFECTS]->(n);

// =============================================================================
// ノード: Document — Spec-02 spec
// =============================================================================
MERGE (:Document {name: 'Spec-02 spec', path: 'specs/002-gantt-task-model/spec.md', description: 'ガントチャート・タスクモデルのフィーチャースペック。進捗更新・状態遷移・バリアント切り替えの3ユーザーストーリー。', type: 'spec'});
MATCH (a:Document {name: 'Spec-02 spec'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'Spec-02 spec'}), (b:Concept {name: 'ガントチャートバリエーション'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 spec'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 spec'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-02 plan artifacts
// =============================================================================
MERGE (:Document {name: 'Spec-02 plan', path: 'specs/002-gantt-task-model/plan.md', description: 'ガントチャート・タスクモデルの実装計画。gantt.ts 1ファイル・関数5本。Spec-01依存。', type: 'plan'});
MERGE (:Document {name: 'Spec-02 data-model', path: 'specs/002-gantt-task-model/data-model.md', description: 'gantt.ts の関数インターフェース定義（updateTaskProgress/setTaskStatus/applyRework/getCompletionRate/applyVariant）', type: 'data-model'});
MERGE (:Document {name: 'Spec-02 quickstart', path: 'specs/002-gantt-task-model/quickstart.md', description: 'Spec-02検証手順（typecheck/test/Phaser依存なし）', type: 'quickstart'});
MATCH (a:Document {name: 'Spec-02 plan'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 plan'}), (b:Concept {name: 'アーキテクチャ境界'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 data-model'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'Spec-02 data-model'}), (b:Concept {name: 'ガントチャートバリエーション'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-02 tasks
// =============================================================================
MERGE (:Document {name: 'Spec-02 tasks', path: 'specs/002-gantt-task-model/tasks.md', description: 'Spec-02実装タスク一覧。T001〜T017、5フェーズ。updateTaskProgress/setTaskStatus/applyRework/getCompletionRate/applyVariant の各関数とVitest+fast-checkテスト。', type: 'tasks'});
MATCH (a:Document {name: 'Spec-02 tasks'}), (b:Document {name: 'Spec-02 spec'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 tasks'}), (b:Document {name: 'Spec-02 plan'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 tasks'}), (b:Document {name: 'Spec-02 data-model'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 tasks'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-02 実装ファイル
// =============================================================================
MERGE (:Document {name: 'Spec-02 gantt.ts', path: 'src/game/gantt.ts', description: 'ガントチャートモデルの純粋関数群。updateTaskProgress/setTaskStatus/applyRework/getCompletionRate/applyVariantの5関数。Phaser/DOM非依存pure TS。全関数イミュータブル操作。', type: 'source'});
MERGE (:Document {name: 'Spec-02 gantt.test.ts', path: 'tests/unit/gantt.test.ts', description: 'Vitest+fast-checkによるgantt.ts全関数のテスト。境界値テスト＋プロパティテスト計25件。全PASS確認済み。', type: 'test'});

MATCH (a:Document {name: 'Spec-02 gantt.ts'}), (b:Concept {name: 'ガントチャート'}) MERGE (a)-[:DEFINES]->(b);
MATCH (a:Document {name: 'Spec-02 gantt.ts'}), (b:Concept {name: 'ガントチャートバリエーション'}) MERGE (a)-[:IMPLEMENTS]->(b);
MATCH (a:Document {name: 'Spec-02 gantt.ts'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 gantt.ts'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-02 gantt.test.ts'}), (b:Document {name: 'Spec-02 gantt.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ADR-005: Spec-02ガントチャートモデルをpure TSイミュータブル関数で実装
// =============================================================================
MERGE (:ADR {
  id: 'ADR-005',
  title: 'Spec-02ガントチャートモデルをpure TSイミュータブル関数で実装',
  date: '2026-08-13',
  status: 'accepted',
  context: 'ガントチャートのタスク進捗更新・状態遷移・バリアント切り替えをゲームエンジンから呼び出せる形で実装する必要があった。Phaserとの結合を避け、Vitestでテスト可能な設計が必要。',
  decision: 'src/game/gantt.tsに5つの純粋関数（updateTaskProgress/setTaskStatus/applyRework/getCompletionRate/applyVariant）を実装。全関数はイミュータブル操作（引数を変更せず新オブジェクトを返す）とした。',
  rationale: 'Phaser非依存・イミュータブル操作により副作用がなく、Vitestによる高速ユニットテストが実現できる。fast-checkプロパティテストで任意入力でもパニックなし・値域保証を確認。',
  consequences: 'Spec-05ターン処理エンジンはこれらの関数を直接呼び出せる。全25テストがPASSし境界値安全性を確認済み。依存タスク未完了時の進捗付与はSpec-05側で制御する方針のため、このSpecでは無視する。'
});
MATCH (adr:ADR {id: 'ADR-005'}), (n:Concept {name: 'ガントチャート'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-005'}), (n:Concept {name: 'アーキテクチャ境界'}) MERGE (adr)-[:AFFECTS]->(n);

// =============================================================================
// ノード: Document — Spec-03 spec
// =============================================================================
MERGE (:Document {name: 'Spec-03 spec', path: 'specs/003-dice-engine/spec.md', description: '進捗ダイスエンジンのフィーチャースペック。rollProgress(member)→number。技・体パラメータによる確率的進捗計算。2ユーザーストーリー。', type: 'spec'});
MATCH (a:Document {name: 'Spec-03 spec'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-03 spec'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-03 plan artifacts
// =============================================================================
MERGE (:Document {name: 'Spec-03 plan', path: 'specs/003-dice-engine/plan.md', description: '進捗ダイスエンジンの実装計画。dice.ts 1ファイル・rollProgress 1関数。balance.ts の既存関数を再利用。Spec-01依存。', type: 'plan'});
MERGE (:Document {name: 'Spec-03 data-model', path: 'specs/003-dice-engine/data-model.md', description: 'rollProgress(member)→number の関数インターフェース定義。内部計算フロー・依存定数・戻り値理論範囲。', type: 'data-model'});
MERGE (:Document {name: 'Spec-03 quickstart', path: 'specs/003-dice-engine/quickstart.md', description: 'Spec-03検証手順（typecheck/test/Phaser依存なし）', type: 'quickstart'});
MATCH (a:Document {name: 'Spec-03 plan'}), (b:Document {name: 'Spec-03 spec'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-03 plan'}), (b:Document {name: 'Spec-01 balance.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-03 data-model'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-03 data-model'}), (b:Document {name: 'Spec-01 balance.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-03 tasks
// =============================================================================
MERGE (:Document {name: 'Spec-03 tasks', path: 'specs/003-dice-engine/tasks.md', description: 'Spec-03実装タスク一覧。T001〜T008、4フェーズ。rollProgress実装・技/体境界値テスト・fast-checkプロパティテスト。', type: 'tasks'});
MATCH (a:Document {name: 'Spec-03 tasks'}), (b:Document {name: 'Spec-03 spec'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-03 tasks'}), (b:Document {name: 'Spec-03 plan'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-03 実装ファイル
// =============================================================================
MERGE (:Document {name: 'Spec-03 dice.ts', path: 'src/game/dice.ts', description: '進捗ダイスエンジン。rollProgress(member)→number。base×skill_factor×health_factor の乗算。Phaser/DOM非依存pure TS。イミュータブル操作。', type: 'source'});
MERGE (:Document {name: 'Spec-03 dice.test.ts', path: 'tests/unit/dice.test.ts', description: 'Vitest+fast-checkによるrollProgress全テスト。技/体境界値テスト＋プロパティテスト計21件。全PASS確認済み。', type: 'test'});
MATCH (a:Document {name: 'Spec-03 dice.ts'}), (b:Document {name: 'Spec-01 balance.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-03 dice.ts'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-03 dice.test.ts'}), (b:Document {name: 'Spec-03 dice.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ADR-006: Spec-03進捗ダイスエンジンでbalance.tsの既存関数を再利用
// =============================================================================
MERGE (:ADR {id: 'ADR-006', title: 'Spec-03進捗ダイスエンジンでbalance.tsの既存関数を再利用', date: '2026-08-13', status: 'accepted', context: '進捗ダイス計算のためskill_factor/health_factorのテーブルルックアップが必要。Spec-01でbalance.tsに同機能が実装済みだった。', decision: 'dice.tsはbalance.tsのgetSkillFactorRange/getHealthFactorをimportして呼び出す。テーブルロジックを再実装しない。', rationale: 'DRY原則。Spec-01でテスト済みの関数を再利用することでdice.tsの実装を最小化し、テスト対象をrollProgressの乗算ロジックのみに絞れる。', consequences: 'dice.tsはbalance.tsに依存する。balance.tsの変更がdice.tsの挙動に影響する。依存関係は単方向で明確。'});
MATCH (adr:ADR {id: 'ADR-006'}), (n:Concept {name: 'アーキテクチャ境界'}) MERGE (adr)-[:AFFECTS]->(n);

// =============================================================================
// ノード: Document — Spec-04 spec
// =============================================================================
MERGE (:Document {name: 'Spec-04 spec', path: 'specs/004-member-params-engine/spec.md', description: 'メンバーパラメータ変動エンジンのフィーチャースペック。applyTurnDecay/applyWeekendRecovery/applyExperienceの3関数。心・体・経験値・技の変動。3ユーザーストーリー。', type: 'spec'});
MATCH (a:Document {name: 'Spec-04 spec'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 spec'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-04 plan artifacts
// =============================================================================
MERGE (:Document {name: 'Spec-04 plan', path: 'specs/004-member-params-engine/plan.md', description: 'メンバーパラメータ変動エンジンの実装計画。member.ts 1ファイル・関数3本。constants.ts直接参照。Spec-01依存。', type: 'plan'});
MERGE (:Document {name: 'Spec-04 data-model', path: 'specs/004-member-params-engine/data-model.md', description: 'Member型・PARAM_DELTA/EXP/LEVEL_UP_EXP定数テーブル・applyTurnDecay/applyWeekendRecovery/applyExperienceの3関数シグネチャと状態遷移。', type: 'data-model'});
MERGE (:Document {name: 'Spec-04 quickstart', path: 'specs/004-member-params-engine/quickstart.md', description: 'Spec-04検証シナリオA〜E（applyTurnDecay境界・下限クランプ・週末上限クランプ・レベルアップ・技上限）', type: 'quickstart'});
MATCH (a:Document {name: 'Spec-04 plan'}), (b:Document {name: 'Spec-04 spec'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 plan'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 data-model'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 data-model'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-04 tasks
// =============================================================================
MERGE (:Document {name: 'Spec-04 tasks', path: 'specs/004-member-params-engine/tasks.md', description: 'Spec-04実装タスク一覧。T001〜T018、6フェーズ。Setup→Foundational→US1(applyTurnDecay)→US2(applyWeekendRecovery)→US3(applyExperience)→Polish。TDD方式。', type: 'tasks'});
MATCH (a:Document {name: 'Spec-04 tasks'}), (b:Document {name: 'Spec-04 spec'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 tasks'}), (b:Document {name: 'Spec-04 plan'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 tasks'}), (b:Document {name: 'Spec-04 data-model'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ADR-007: member.ts は constants.ts の定数を直接参照する
// =============================================================================
MERGE (:ADR {
  id: 'ADR-007',
  title: 'member.ts は constants.ts の PARAM_DELTA/MEMBER_PARAMS/EXP/LEVEL_UP_EXP を直接参照する',
  date: '2026-08-13',
  status: 'accepted',
  context: 'Spec-04 のメンバーパラメータ変動関数が数値定数を必要とする。Spec-01で constants.ts に全定数が定義済み。dice.ts は balance.ts の中間ヘルパー（ADR-006）を使うが、member.ts の LEVEL_UP_EXP ルックアップは dice.ts と重複しない独自ロジックである。',
  decision: 'member.ts は constants.ts から定数を直接 import して使用する。balance.ts のような中間ヘルパー関数は作成しない。LEVEL_UP_EXP ルックアップは member.ts 内のモジュールスコープ関数として実装する。',
  rationale: 'DRY原則の観点では balance.ts への集約も考えられるが、LEVEL_UP_EXP ルックアップは整数テーブル参照という独自パターンで dice.ts と共通化するメリットがない。中間ヘルパーを作ると不要な抽象化になる。',
  consequences: 'member.ts が constants.ts に直接依存する。将来 LEVEL_UP_EXP ルックアップを他モジュールが使う場合は balance.ts への移行を検討する。'
});
MATCH (adr:ADR {id: 'ADR-007'}), (n:Document {name: 'Spec-04 spec'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-007'}), (n:Concept {name: 'アーキテクチャ境界'}) MERGE (adr)-[:AFFECTS]->(n);

// =============================================================================
// ノード: Document — Spec-04 実装ファイル
// =============================================================================
MERGE (:Document {name: 'Spec-04 member.ts', path: 'src/game/member.ts', type: 'source', description: 'メンバーパラメータ変動エンジン。applyTurnDecay/applyWeekendRecovery/applyExperienceの3純粋関数。整数乱数・クランプ・LEVEL_UP_EXPルックアップ。Phaser/DOM非依存pure TS。全関数イミュータブル操作。'});
MERGE (:Document {name: 'Spec-04 member.test.ts', path: 'tests/unit/member.test.ts', type: 'test', description: 'Vitest+fast-checkによるmember.ts全関数のテスト。境界値テスト＋プロパティテスト計32件。全PASS・coverage 100%確認済み。'});

MATCH (a:Document {name: 'Spec-04 member.ts'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 member.ts'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 member.test.ts'}), (b:Document {name: 'Spec-04 member.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-04 spec'}), (b:Document {name: 'Spec-04 member.ts'}) MERGE (a)-[:IMPLEMENTED_BY]->(b);

// =============================================================================
// ノード: Document — Spec-05 spec
// =============================================================================
MERGE (:Document {name: 'Spec-05 spec', path: 'specs/005-turn-engine/spec.md', type: 'spec', description: 'ターン処理エンジンのフィーチャースペック。processTurn(state, cards)→TurnResult。カード適用・進捗ダイス・パラメータ変動・手戻りイベント・ゲームオーバー判定の5グループ処理。3ユーザーストーリー。'});
MATCH (a:Document {name: 'Spec-05 spec'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-05 spec'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-05 spec'}), (b:Document {name: 'Spec-02 gantt.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-05 spec'}), (b:Document {name: 'Spec-03 dice.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-05 spec'}), (b:Document {name: 'Spec-04 member.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-05 plan artifacts
// =============================================================================
MERGE (:Document {name: 'Spec-05 plan', path: 'specs/005-turn-engine/plan.md', type: 'plan', description: 'ターン処理エンジンの実装計画。turn.ts 1ファイル・processTurn 1関数。Spec-02〜04の関数を全て呼び出す統合レイヤー。TurnResult返却・GameState更新は呼び出し側担当。'});
MERGE (:Document {name: 'Spec-05 data-model', path: 'specs/005-turn-engine/data-model.md', type: 'data-model', description: 'GameState/TurnResult/ProgressUpdate/MemberUpdateの入出力エンティティ定義・processTurnの処理フロー・依存モジュール一覧。'});
MERGE (:Document {name: 'Spec-05 quickstart', path: 'specs/005-turn-engine/quickstart.md', type: 'quickstart', description: '検証シナリオA〜D（基本処理・週末回復・全タスク完了・納期超過）・fast-checkプロパティテスト観点。'});
MATCH (a:Document {name: 'Spec-05 spec'}), (b:Document {name: 'Spec-05 plan'}) MERGE (a)-[:HAS_PLAN]->(b);
MATCH (a:Document {name: 'Spec-05 plan'}), (b:Document {name: 'Spec-05 data-model'}) MERGE (a)-[:HAS_DATA_MODEL]->(b);
MATCH (a:Document {name: 'Spec-05 plan'}), (b:Document {name: 'Spec-05 quickstart'}) MERGE (a)-[:HAS_QUICKSTART]->(b);

// =============================================================================
// ノード: Document — Spec-05 tasks
// =============================================================================
MERGE (:Document {name: 'Spec-05 tasks', path: 'specs/005-turn-engine/tasks.md', type: 'tasks', description: 'Spec-05実装タスク一覧。T001〜T021、6フェーズ。Setup→Foundational→US1(進捗ダイス/パラメータ変動/手戻り)→US2(週末回復)→US3(ゲームオーバー判定)→Polish。TDD方式。'});
MATCH (a:Document {name: 'Spec-05 spec'}), (b:Document {name: 'Spec-05 tasks'}) MERGE (a)-[:HAS_TASKS]->(b);

// =============================================================================
// ノード: Document — Spec-05 実装成果物（turn.ts / turn.test.ts）
// =============================================================================
MERGE (:Document {name: 'Spec-05 turn.ts', path: 'src/game/turn.ts', type: 'source', spec: 'Spec-05', status: 'implemented',
  description: 'processTurn(state, cards): TurnResult — 1ターン処理のオーケストレーション純粋関数。進捗ダイス・パラメータ変動・週末回復・手戻りイベント・ゲームオーバー判定。'});
MERGE (:Document {name: 'Spec-05 turn.test.ts', path: 'tests/unit/turn.test.ts', type: 'test', spec: 'Spec-05', status: 'all-pass',
  testCount: 24, coverageLines: 100, coverageFunctions: 100,
  description: '24テスト全PASS。US1基本ターン処理・イミュータブル・手戻り / US2週末回復 / US3ゲームオーバー / fast-checkプロパティ4件。'});
MATCH (a:Document {name: 'Spec-05 spec'}), (b:Document {name: 'Spec-05 turn.ts'}) MERGE (a)-[:IMPLEMENTED_BY]->(b);
MATCH (a:Document {name: 'Spec-05 turn.ts'}), (b:Document {name: 'Spec-05 turn.test.ts'}) MERGE (a)-[:TESTED_BY]->(b);
MATCH (a:Document {name: 'Spec-05 turn.ts'}), (b:Document {name: 'Spec-04 member.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-05 turn.ts'}), (b:Document {name: 'Spec-03 dice.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-05 turn.ts'}), (b:Document {name: 'Spec-02 gantt.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ADR-008: processTurn は TurnResult（差分）を返し GameState 更新は呼び出し側が担う
// =============================================================================
MERGE (:ADR {
  id: 'ADR-008',
  title: 'processTurn は TurnResult（差分）を返し GameState 更新は呼び出し側が担う',
  date: '2026-08-13',
  status: 'accepted',
  context: 'ターン処理エンジン(turn.ts)の戻り値設計。新しいGameStateを返すか、差分(TurnResult)を返すか検討した。',
  decision: 'processTurn(state, cards): TurnResult として差分のみを返す。Phaser Scene が TurnResult を受け取り自分の GameState を更新する。',
  rationale: '差分パターンにより turn.ts が GameState 更新ロジックを持たず純粋な差分計算関数に留まる。テストが容易で、Phaser 側の state 管理と game logic の責務分離が明確になる。',
  consequences: 'Phaser Scene が TurnResult を適用して GameState を更新する責務を持つ。将来の拡張（undo/redo等）も差分ベースなら追いやすい。'
});
MATCH (adr:ADR {id: 'ADR-008'}), (src:Document {name: 'Spec-05 turn.ts'}) MERGE (adr)-[:AFFECTS]->(src);

// =============================================================================
// ノード: Document — Spec-06 spec / checklist
// =============================================================================
MERGE (:Document {name: 'Spec-06 spec', path: 'specs/006-card-engine/spec.md', type: 'spec',
  description: 'カード効果エンジンのフィーチャースペック。applyCards(state, cards): CardApplicationResult。グループA確率低減3種(デイリー/レビュー/モニタリング)+グループB即時メンバー3種(個別面談/表彰/計画休)。3ユーザーストーリー。'});
MERGE (:Document {name: 'Spec-06 checklist', path: 'specs/006-card-engine/checklists/requirements.md', type: 'checklist',
  description: 'Spec-06仕様品質チェックリスト。全16項目PASS。スコープ6種カード明確化、カード削除・自動解除は別Spec分割済み。'});
MATCH (a:Document {name: 'Spec-06 spec'}), (b:Document {name: 'Spec-06 checklist'}) MERGE (a)-[:HAS_CHECKLIST]->(b);
MATCH (a:Document {name: 'Spec-06 spec'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-06 spec'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-06 plan artifacts
// =============================================================================
MERGE (:Document {name: 'Spec-06 plan', path: 'specs/006-card-engine/plan.md', type: 'plan',
  description: 'カード効果エンジンの実装計画。card.ts 1ファイル・applyCards 1関数。グループA確率低減(CardEffect追加)・グループB即時メンバー系(MemberUpdate)。CardApplicationResultはcard.tsローカル型。'});
MERGE (:Document {name: 'Spec-06 data-model', path: 'specs/006-card-engine/data-model.md', type: 'data-model',
  description: 'CardApplicationResult定義・カードマッピングテーブル(6種)・applyCards処理フロー・依存関係。'});
MERGE (:Document {name: 'Spec-06 quickstart', path: 'specs/006-card-engine/quickstart.md', type: 'quickstart',
  description: '検証シナリオA〜E（グループA確率低減・グループB即時・0人panic安全・空配列・イミュータブル）・fast-checkプロパティテスト観点。'});
MATCH (a:Document {name: 'Spec-06 spec'}), (b:Document {name: 'Spec-06 plan'}) MERGE (a)-[:HAS_PLAN]->(b);
MATCH (a:Document {name: 'Spec-06 plan'}), (b:Document {name: 'Spec-06 data-model'}) MERGE (a)-[:HAS_DATA_MODEL]->(b);
MATCH (a:Document {name: 'Spec-06 plan'}), (b:Document {name: 'Spec-06 quickstart'}) MERGE (a)-[:HAS_QUICKSTART]->(b);

// =============================================================================
// ノード: Document — Spec-06 tasks
// =============================================================================
MERGE (:Document {name: 'Spec-06 tasks', path: 'specs/006-card-engine/tasks.md', type: 'tasks',
  description: 'Spec-06実装タスク一覧。T001〜T017、6フェーズ。Setup→Foundational→US1(確率低減3種)→US2(即時メンバー3種)→US3(イミュータブル)→Polish。TDD方式。'});
MATCH (a:Document {name: 'Spec-06 spec'}), (b:Document {name: 'Spec-06 tasks'}) MERGE (a)-[:HAS_TASKS]->(b);

// =============================================================================
// ノード: Document — Spec-06 実装成果物（card.ts / card.test.ts）
// =============================================================================
MERGE (:Document {name: 'Spec-06 card.ts', path: 'src/game/card.ts', type: 'source', spec: 'Spec-06', status: 'implemented',
  description: 'applyCards(state, cards): CardApplicationResult — カード効果適用純粋関数。グループA(デイリー/レビュー/モニタリング)→CardEffect追加、グループB(個別面談/表彰/計画休)→MemberUpdate返却。Phaser/DOM非依存pure TS。'});
MERGE (:Document {name: 'Spec-06 card.test.ts', path: 'tests/unit/card.test.ts', type: 'test', spec: 'Spec-06', status: 'all-pass',
  testCount: 24, coverageLines: 100, coverageFunctions: 100,
  description: '24テスト全PASS。US1確率低減3種 / US2即時メンバー3種 / US3イミュータブル / fast-checkプロパティ4件。coverage 100%。'});
MATCH (a:Document {name: 'Spec-06 spec'}), (b:Document {name: 'Spec-06 card.ts'}) MERGE (a)-[:IMPLEMENTED_BY]->(b);
MATCH (a:Document {name: 'Spec-06 card.ts'}), (b:Document {name: 'Spec-06 card.test.ts'}) MERGE (a)-[:TESTED_BY]->(b);
MATCH (a:Document {name: 'Spec-06 card.ts'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-06 card.ts'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ADR-009: CardApplicationResult は card.ts のローカル export 型とし types.ts に追加しない
// =============================================================================
MERGE (:ADR {
  id: 'ADR-009',
  title: 'CardApplicationResult は card.ts のローカル export 型とし types.ts に追加しない',
  date: '2026-08-13',
  status: 'accepted',
  context: 'applyCards の戻り値型 CardApplicationResult をどこに定義するか検討した。types.ts に追加する案と card.ts ローカル export 案があった。',
  decision: 'CardApplicationResult を card.ts のローカル export インターフェースとして定義する。types.ts には追加しない。',
  rationale: 'types.ts は Phaser Scene を含むプロジェクト全体が参照するコアデータ型のみを置く原則。CardApplicationResult は card.ts ↔ 呼び出し側（turn.ts / Phaser Scene）のインターフェースに留まり、ゲーム全域で共有する型ではない。局所化することで types.ts の肥大化を防ぐ。',
  consequences: 'card.ts を import しない限り CardApplicationResult 型にアクセスできない。呼び出し側は card.ts から直接 import する設計になる。将来より多くのモジュールが利用する場合は types.ts への移行を検討する。'
});
MATCH (adr:ADR {id: 'ADR-009'}), (src:Document {name: 'Spec-06 card.ts'}) MERGE (adr)-[:AFFECTS]->(src);
MATCH (adr:ADR {id: 'ADR-009'}), (n:Document {name: 'Spec-01 types.ts'}) MERGE (adr)-[:AFFECTS]->(n);
MATCH (adr:ADR {id: 'ADR-009'}), (n:Concept {name: 'アーキテクチャ境界'}) MERGE (adr)-[:AFFECTS]->(n);

// =============================================================================
// ノード: Document — Spec-07 spec / checklist
// =============================================================================
MERGE (:Document {name: 'Spec-07 spec', path: 'specs/007-turn-integration-engine/spec.md', type: 'spec',
  description: 'ターン統合エンジンのフィーチャースペック。applyCards→effectsToAdd統合・即時メンバー更新・確率補正・effectTick の4ユーザーストーリー。turn.ts 更新 + effect.ts 新規。'});
MERGE (:Document {name: 'Spec-07 checklist', path: 'specs/007-turn-integration-engine/checklists/requirements.md', type: 'checklist',
  description: 'Spec-07仕様品質チェックリスト。全16項目PASS。スコープ外（停滞ロジック・過大報告・カード枠UI）明記済み。'});
MATCH (a:Document {name: 'Spec-07 spec'}), (b:Document {name: 'Spec-07 checklist'}) MERGE (a)-[:HAS_CHECKLIST]->(b);
MATCH (a:Document {name: 'Spec-07 spec'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-07 spec'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-07 spec'}), (b:Document {name: 'Spec-05 turn.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-07 spec'}), (b:Document {name: 'Spec-06 card.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-07 plan artifacts
// =============================================================================
MERGE (:Document {name: 'Spec-07 plan', path: 'specs/007-turn-integration-engine/plan.md', type: 'plan',
  description: 'ターン統合エンジンの実装計画。TurnResult型拡張・EVENT_PROB.STALL追加・effect.ts新規・turn.ts更新。processTurn処理順序(applyCards→currentEffects合成→dice→decay→rework補正→tick)を定義。'});
MERGE (:Document {name: 'Spec-07 data-model', path: 'specs/007-turn-integration-engine/data-model.md', type: 'data-model',
  description: 'TurnResult型拡張定義・applyEffectTick/calcEventProbModifierシグネチャ・処理フロー・依存関係グラフ。'});
MERGE (:Document {name: 'Spec-07 quickstart', path: 'specs/007-turn-integration-engine/quickstart.md', type: 'quickstart',
  description: '検証シナリオA〜E（デイリー効果追加・確率補正・即時メンバー回復・effectTick除去・calcEventProbModifier）。'});
MATCH (a:Document {name: 'Spec-07 spec'}), (b:Document {name: 'Spec-07 plan'}) MERGE (a)-[:HAS_PLAN]->(b);
MATCH (a:Document {name: 'Spec-07 plan'}), (b:Document {name: 'Spec-07 data-model'}) MERGE (a)-[:HAS_DATA_MODEL]->(b);
MATCH (a:Document {name: 'Spec-07 plan'}), (b:Document {name: 'Spec-07 quickstart'}) MERGE (a)-[:HAS_QUICKSTART]->(b);
MATCH (a:Document {name: 'Spec-07 plan'}), (b:Document {name: 'Spec-05 turn.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-07 plan'}), (b:Document {name: 'Spec-06 card.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-07 plan'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-07 plan'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// ノード: Document — Spec-07 tasks
// =============================================================================
MERGE (:Document {name: 'Spec-07 tasks', path: 'specs/007-turn-integration-engine/tasks.md', type: 'tasks',
  description: 'Spec-07実装タスク一覧。T001〜T020、7フェーズ。Setup→Foundational→US2(applyEffectTick)→US3(calcEventProbModifier)→US1(processTurn統合)→US4(イミュータブル)→Polish。TDD方式。'});
MATCH (a:Document {name: 'Spec-07 spec'}), (b:Document {name: 'Spec-07 tasks'}) MERGE (a)-[:HAS_TASKS]->(b);

// =============================================================================
// Spec-07 implement: effect.ts / effect.test.ts Documents + Concepts + ADR-010
// =============================================================================
MERGE (:Document {name: 'Spec-07 effect.ts', path: 'src/game/effect.ts', spec: 'Spec-07',
  description: 'アクティブ効果管理の純粋関数: applyEffectTick / calcEventProbModifier',
  status: 'implemented'});
MERGE (:Document {name: 'Spec-07 effect.test.ts', path: 'tests/unit/effect.test.ts', spec: 'Spec-07',
  description: 'effect.ts のユニットテスト (18テスト + fast-check 5テスト = 23テスト)',
  status: 'implemented'});
MERGE (:Concept {name: 'applyEffectTick', module: 'effect.ts', spec: 'Spec-07',
  description: 'アクティブ効果のターンtick: null=永続保持, >1=デクリメント, <=1=除去',
  signature: 'applyEffectTick(effects: CardEffect[]): CardEffect[]'});
MERGE (:Concept {name: 'calcEventProbModifier', module: 'effect.ts', spec: 'Spec-07',
  description: '指定effectTypeが含まれればbaseProb×0.5、なければbaseProb（重複スタックなし）',
  signature: 'calcEventProbModifier(effects: CardEffect[], baseProb: number, effectType: EffectType): number'});
MERGE (:Concept {name: 'activeEffectsAdded', module: 'types.ts', spec: 'Spec-07',
  description: 'TurnResult拡張フィールド: 今ターンにカードで追加されたCardEffect[]'});
MERGE (:Concept {name: 'activeEffectsAfterTick', module: 'types.ts', spec: 'Spec-07',
  description: 'TurnResult拡張フィールド: tick後に残存するCardEffect[]（呼び出し側がGameState.activeEffectsを更新する）'});
MERGE (:ADR {
  id: 'ADR-010',
  title: 'effect.ts を turn.ts から分離してアクティブ効果ライフサイクルを管理する',
  date: '2026-08-13',
  status: 'accepted',
  context: 'processTurnはカード効果・イベント確率補正・ターンtickの3つの責務を持ち肥大化するリスクがあった。また applyEffectTick と calcEventProbModifier は純粋関数として単独テスト可能なため分離が有効だった。',
  decision: 'src/game/effect.ts を新規作成し applyEffectTick と calcEventProbModifier を実装。turn.ts はこれをインポートして使用する構成とした。TurnResult型にactiveEffectsAdded/activeEffectsAfterTickを追加し、GameState更新責務を呼び出し側（ADR-008準拠）に委ねる。',
  rationale: '単一責任原則に従い effect.ts を独立させることで、(1) fast-checkプロパティテストを含む独立テストが容易、(2) Phaser/DOM非依存を grep で機械的に保証可能、(3) 将来的なeffectType追加時の変更範囲を最小化できる。',
  consequences: 'effect.tsというファイルが増える分ファイル数は増加するが、turn.tsの責務が明確化されコードの見通しが改善。覚えるべきAPIは2関数のみでシンプル。'
});
MATCH (d:Document {name: 'Spec-07 effect.ts'}), (c:Concept {name: 'applyEffectTick'}) MERGE (d)-[:CONTAINS]->(c);
MATCH (d:Document {name: 'Spec-07 effect.ts'}), (c:Concept {name: 'calcEventProbModifier'}) MERGE (d)-[:CONTAINS]->(c);
MATCH (d:Document {name: 'Spec-07 effect.test.ts'}), (c:Concept {name: 'applyEffectTick'}) MERGE (d)-[:TESTS]->(c);
MATCH (d:Document {name: 'Spec-07 effect.test.ts'}), (c:Concept {name: 'calcEventProbModifier'}) MERGE (d)-[:TESTS]->(c);
MATCH (d:Document {name: 'Spec-05 turn.ts'}), (c:Concept {name: 'applyEffectTick'}) MERGE (d)-[:USES]->(c);
MATCH (d:Document {name: 'Spec-05 turn.ts'}), (c:Concept {name: 'calcEventProbModifier'}) MERGE (d)-[:USES]->(c);
MATCH (d:Document {name: 'Spec-05 turn.ts'}), (c:Concept {name: 'activeEffectsAdded'}) MERGE (d)-[:RETURNS]->(c);
MATCH (d:Document {name: 'Spec-05 turn.ts'}), (c:Concept {name: 'activeEffectsAfterTick'}) MERGE (d)-[:RETURNS]->(c);
MATCH (adr:ADR {id: 'ADR-010'}), (c:Concept {name: 'applyEffectTick'}) MERGE (adr)-[:AFFECTS]->(c);
MATCH (adr:ADR {id: 'ADR-010'}), (c:Concept {name: 'calcEventProbModifier'}) MERGE (adr)-[:AFFECTS]->(c);
MATCH (adr:ADR {id: 'ADR-010'}), (d:Document {name: 'Spec-07 effect.ts'}) MERGE (adr)-[:AFFECTS]->(d);
MATCH (adr:ADR {id: 'ADR-010'}), (prev:ADR {id: 'ADR-008'}) MERGE (adr)-[:EXTENDS]->(prev);
MATCH (spec:Document {name: 'Spec-07 spec'}), (d:Document {name: 'Spec-07 effect.ts'}) MERGE (spec)-[:IMPLEMENTS]->(d);
MATCH (spec:Document {name: 'Spec-07 spec'}), (d:Document {name: 'Spec-07 effect.test.ts'}) MERGE (spec)-[:IMPLEMENTS]->(d);

// =============================================================================
// Spec-08 /speckit-specify: ランダムイベントエンジン仕様
// =============================================================================
MERGE (:Document {name: 'Spec-08 spec', path: 'specs/008-random-event-engine/spec.md', type: 'spec', spec: 'Spec-08',
  description: 'ランダムイベントエンジン仕様。停滞・手戻り・病気・低モチベーション・疲弊の5種。rollRandomEvents/applyEventToProgress/applyEventToMemberの3関数。US1〜US5。',
  status: 'draft'});
MERGE (:Document {name: 'Spec-08 checklist', path: 'specs/008-random-event-engine/checklists/requirements.md', type: 'checklist', spec: 'Spec-08',
  description: 'Spec-08仕様品質チェックリスト。全16項目PASS。スコープ外（条件付きイベント・ポジティブイベント・過大報告・チェックポイント）明記済み。'});
MATCH (a:Document {name: 'Spec-08 spec'}), (b:Document {name: 'Spec-08 checklist'}) MERGE (a)-[:HAS_CHECKLIST]->(b);
MATCH (a:Document {name: 'Spec-08 spec'}), (b:Document {name: 'Spec-01 types.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-08 spec'}), (b:Document {name: 'Spec-01 constants.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-08 spec'}), (b:Document {name: 'Spec-07 effect.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-08 spec'}), (b:Document {name: 'Spec-05 turn.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-08 spec'}), (b:Document {name: 'Spec-02 gantt.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// Spec-08 /speckit-plan: plan / data-model / quickstart
// =============================================================================
MERGE (:Document {name: 'Spec-08 plan', path: 'specs/008-random-event-engine/plan.md', type: 'plan', spec: 'Spec-08',
  description: 'ランダムイベントエンジン実装計画。event.ts新規（rollRandomEvents/applyEventToProgress/applyEventToMember）。turn.ts Step5をrollRandomEventsに置き換え。処理順序KD-1〜KD-5定義。'});
MERGE (:Document {name: 'Spec-08 data-model', path: 'specs/008-random-event-engine/data-model.md', type: 'data-model', spec: 'Spec-08',
  description: '3関数シグネチャ・GameEvent paramsスキーマ（stall/rework/sick/low_motivation/fatigue）・処理フロー・依存関係グラフ。'});
MERGE (:Document {name: 'Spec-08 quickstart', path: 'specs/008-random-event-engine/quickstart.md', type: 'quickstart', spec: 'Spec-08',
  description: '検証シナリオA〜F（stall progressMapリセット・reworkデルタ反映・sickメンバー変化・クランプ・確率補正・processTurn統合）。'});
MATCH (a:Document {name: 'Spec-08 spec'}), (b:Document {name: 'Spec-08 plan'}) MERGE (a)-[:HAS_PLAN]->(b);
MATCH (a:Document {name: 'Spec-08 plan'}), (b:Document {name: 'Spec-08 data-model'}) MERGE (a)-[:HAS_DATA_MODEL]->(b);
MATCH (a:Document {name: 'Spec-08 plan'}), (b:Document {name: 'Spec-08 quickstart'}) MERGE (a)-[:HAS_QUICKSTART]->(b);
MATCH (a:Document {name: 'Spec-08 plan'}), (b:Document {name: 'Spec-05 turn.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-08 plan'}), (b:Document {name: 'Spec-07 effect.ts'}) MERGE (a)-[:REFERENCES]->(b);
MATCH (a:Document {name: 'Spec-08 plan'}), (b:Document {name: 'Spec-02 gantt.ts'}) MERGE (a)-[:REFERENCES]->(b);

// =============================================================================
// Spec-08 /speckit-tasks: tasks
// =============================================================================
MERGE (:Document {name: 'Spec-08 tasks', path: 'specs/008-random-event-engine/tasks.md', type: 'tasks', spec: 'Spec-08',
  description: 'Spec-08実装タスク一覧。T001〜T019、8フェーズ。Setup→Foundational→US2(applyEventToProgress)→US3(applyEventToMember)→US1(rollRandomEvents)→US4(processTurn統合)→US5(イミュータブル)→Polish。TDD方式。'});
MATCH (a:Document {name: 'Spec-08 spec'}), (b:Document {name: 'Spec-08 tasks'}) MERGE (a)-[:HAS_TASKS]->(b);

// =============================================================================
// Spec-08 /speckit-implement: event.ts / event.test.ts + ADR-011
// =============================================================================
MERGE (:Document {name: 'Spec-08 event.ts', path: 'src/game/event.ts', spec: 'Spec-08',
  description: 'ランダムイベントエンジン: rollRandomEvents / applyEventToProgress / applyEventToMember（5種イベント判定）',
  status: 'implemented'});
MERGE (:Document {name: 'Spec-08 event.test.ts', path: 'tests/unit/event.test.ts', spec: 'Spec-08',
  description: 'event.ts のユニットテスト（28テスト + fast-check プロパティテスト）',
  status: 'implemented'});
MERGE (:Concept {name: 'rollRandomEvents', module: 'event.ts', spec: 'Spec-08',
  description: '5種ランダムイベント判定（stall/rework/sick/low_motivation/fatigue）。確率補正はcalcEventProbModifier使用。',
  signature: 'rollRandomEvents(state: GameState, activeEffects: CardEffect[]): GameEvent[]'});
MERGE (:Concept {name: 'applyEventToProgress', module: 'event.ts', spec: 'Spec-08',
  description: 'rework: デルタ加算、stall: 0リセット、その他: そのままコピー。イミュータブル。',
  signature: 'applyEventToProgress(event: GameEvent, progressMap: Map<string, number>): Map<string, number>'});
MERGE (:Concept {name: 'applyEventToMember', module: 'event.ts', spec: 'Spec-08',
  description: 'sick/low_motivation/fatigueをメンバーに適用。MEMBER_PARAMSでクランプ。イミュータブル。',
  signature: 'applyEventToMember(event: GameEvent, member: Member): Member'});
MERGE (:ADR {id: 'ADR-011',
  title: 'event.ts を turn.ts から分離しランダムイベント5種を管理する',
  date: '2026-08-13', status: 'accepted',
  context: 'turn.ts の Step5 は rework のみ簡易実装だった。stall/sick/low_motivation/fatigueの4種を追加するにあたり、イベント判定ロジックを独立モジュールとして切り出す設計を採用した。',
  decision: 'src/game/event.ts を新規作成し rollRandomEvents/applyEventToProgress/applyEventToMember を実装。turn.ts Step5 を完全に削除して rollRandomEvents に統合。eventMemberUpdates を Step7 の memberUpdates 統合に追加。',
  rationale: 'effect.ts（ADR-010）と同様の分離原則。独立テスト・Phaser非依存grep検証・将来イベント追加時の変更範囲最小化のため。applyEventToMemberが差分でなく状態を返すことで、クランプ後の実際の変化量が自動的に正確になる。',
  consequences: 'ファイル数が増えるが責務が明確化。memberUpdatesが最大3種類（card/decay/event）のエントリを持つため呼び出し側での合算が必要。'});
MATCH (d:Document {name: 'Spec-08 event.ts'}), (c:Concept {name: 'rollRandomEvents'}) MERGE (d)-[:CONTAINS]->(c);
MATCH (d:Document {name: 'Spec-08 event.ts'}), (c:Concept {name: 'applyEventToProgress'}) MERGE (d)-[:CONTAINS]->(c);
MATCH (d:Document {name: 'Spec-08 event.ts'}), (c:Concept {name: 'applyEventToMember'}) MERGE (d)-[:CONTAINS]->(c);
MATCH (d:Document {name: 'Spec-08 event.test.ts'}), (c:Concept {name: 'rollRandomEvents'}) MERGE (d)-[:TESTS]->(c);
MATCH (d:Document {name: 'Spec-08 event.test.ts'}), (c:Concept {name: 'applyEventToProgress'}) MERGE (d)-[:TESTS]->(c);
MATCH (d:Document {name: 'Spec-08 event.test.ts'}), (c:Concept {name: 'applyEventToMember'}) MERGE (d)-[:TESTS]->(c);
MATCH (d:Document {name: 'Spec-05 turn.ts'}), (c:Concept {name: 'rollRandomEvents'}) MERGE (d)-[:USES]->(c);
MATCH (adr:ADR {id: 'ADR-011'}), (d:Document {name: 'Spec-08 event.ts'}) MERGE (adr)-[:AFFECTS]->(d);
MATCH (adr:ADR {id: 'ADR-011'}), (prev:ADR {id: 'ADR-010'}) MERGE (adr)-[:EXTENDS]->(prev);

// =============================================================================
// Spec-09 /speckit-specify: 条件付きイベントエンジン
// =============================================================================
MERGE (:Document {name: 'Spec-09 spec.md', path: 'specs/009-conditional-event-engine/spec.md', type: 'spec', spec: 'Spec-09',
  description: '条件付きイベントエンジン仕様。evaluateCondition/rollConditionalEventsの4ユーザーストーリー定義',
  created: '2026-08-13'});
MERGE (:Document {name: 'Spec-09 checklists/requirements.md', path: 'specs/009-conditional-event-engine/checklists/requirements.md', type: 'checklist', spec: 'Spec-09',
  description: '仕様品質チェックリスト 16/16 PASS', created: '2026-08-13'});
MERGE (:Concept {name: 'evaluateCondition', spec: 'Spec-09',
  description: 'GameStateと条件式文字列を受け取りbooleanを返す純粋関数。9種の条件パターンをサポート。未知条件はfalseを返す',
  file: 'src/game/conditional.ts'});
MERGE (:Concept {name: 'rollConditionalEvents', spec: 'Spec-09',
  description: 'ConditionalEvent[]を受け取り条件成立のものだけGameEvent[]に変換して返す純粋関数。turnフィルタあり',
  file: 'src/game/conditional.ts'});
MERGE (:Concept {name: 'ConditionalEvent', spec: 'Spec-09',
  description: 'id/condition/turn/eventフィールドを持つ条件付きイベント定義型。types.tsに追加予定',
  file: 'src/game/types.ts'});
MERGE (:ADR {id: 'ADR-012',
  title: '条件式評価は文字列マッチング方式で実装する',
  date: '2026-08-13', status: 'accepted',
  context: '条件付きイベントエンジンで条件式を評価する手段として、パーサーライブラリ導入か文字列マッチングかの選択が必要だった',
  decision: 'evaluateConditionは文字列マッチング（startsWith/includes）でパターンを判定し、パーサーは使用しない',
  rationale: 'POC段階では9種の固定条件パターンのみ対応すれば十分であり、パーサーは過剰設計になる。文字列マッチングの方がテスタビリティが高く、依存ライブラリも増えない',
  consequences: '将来的に複雑な条件式（AND/OR、ネスト）が必要になった場合は評価戦略の変更が必要。そのタイミングでADRを更新し新実装へ移行する'});
MATCH (adr:ADR {id: 'ADR-012'}), (c:Concept {name: 'evaluateCondition'}) MERGE (adr)-[:AFFECTS]->(c);
MATCH (adr:ADR {id: 'ADR-012'}), (c:Concept {name: 'rollConditionalEvents'}) MERGE (adr)-[:AFFECTS]->(c);
MATCH (spec:Document {name: 'Spec-09 spec.md'}), (c:Concept {name: 'evaluateCondition'}) MERGE (spec)-[:DEFINES]->(c);
MATCH (spec:Document {name: 'Spec-09 spec.md'}), (c:Concept {name: 'rollConditionalEvents'}) MERGE (spec)-[:DEFINES]->(c);
MATCH (spec:Document {name: 'Spec-09 spec.md'}), (c:Concept {name: 'ConditionalEvent'}) MERGE (spec)-[:DEFINES]->(c);

// =============================================================================
// Spec-09 /speckit-plan: plan.md / data-model.md / quickstart.md
// =============================================================================
MERGE (:Document {name: 'Spec-09 plan.md', path: 'specs/009-conditional-event-engine/plan.md', type: 'plan', spec: 'Spec-09',
  description: '条件付きイベントエンジン実装計画。KD-1〜5の設計決定。conditional.ts新規、turn.ts更新',
  created: '2026-08-13'});
MERGE (:Document {name: 'Spec-09 data-model.md', path: 'specs/009-conditional-event-engine/data-model.md', type: 'data-model', spec: 'Spec-09',
  description: '関数シグネチャ・条件式パターン・GameEvent生成スキーマ・processTurnフロー',
  created: '2026-08-13'});
MERGE (:Document {name: 'Spec-09 quickstart.md', path: 'specs/009-conditional-event-engine/quickstart.md', type: 'quickstart', spec: 'Spec-09',
  description: 'A〜Gシナリオの検証ガイド', created: '2026-08-13'});
MATCH (plan:Document {name: 'Spec-09 plan.md'}), (spec:Document {name: 'Spec-09 spec.md'}) MERGE (plan)-[:IMPLEMENTS]->(spec);

// =============================================================================
// Spec-09 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-09 tasks', path: 'specs/009-conditional-event-engine/tasks.md', type: 'tasks', spec: 'Spec-09',
  description: 'Spec-09実装タスク一覧。T001〜T015、7フェーズ。Setup→テスト先行（US1/US2/US4/fast-check）→evaluateCondition実装→rollConditionalEvents実装→processTurn統合→イミュータブル検証→Polish。TDD方式。',
  created: '2026-08-13'});
MATCH (a:Document {name: 'Spec-09 spec.md'}), (b:Document {name: 'Spec-09 tasks'}) MERGE (a)-[:HAS_TASKS]->(b);

// =============================================================================
// Spec-09 /speckit-implement: conditional.ts / conditional.test.ts
// =============================================================================
MERGE (:Document {name: 'Spec-09 conditional.ts', path: 'src/game/conditional.ts', spec: 'Spec-09',
  description: '条件付きイベントエンジン: evaluateCondition（9条件パターン）/ rollConditionalEvents（turnフィルタ+条件評価+GameEvent生成）',
  status: 'implemented'});
MERGE (:Document {name: 'Spec-09 conditional.test.ts', path: 'tests/unit/conditional.test.ts', spec: 'Spec-09',
  description: 'conditional.ts のユニットテスト（39テスト + fast-check プロパティテスト）',
  status: 'implemented'});
MATCH (d:Document {name: 'Spec-09 conditional.ts'}), (c:Concept {name: 'evaluateCondition'}) MERGE (d)-[:CONTAINS]->(c);
MATCH (d:Document {name: 'Spec-09 conditional.ts'}), (c:Concept {name: 'rollConditionalEvents'}) MERGE (d)-[:CONTAINS]->(c);
MATCH (d:Document {name: 'Spec-09 conditional.test.ts'}), (c:Concept {name: 'evaluateCondition'}) MERGE (d)-[:TESTS]->(c);
MATCH (d:Document {name: 'Spec-09 conditional.test.ts'}), (c:Concept {name: 'rollConditionalEvents'}) MERGE (d)-[:TESTS]->(c);
MATCH (turn:Document {name: 'Spec-05 turn.ts'}), (c:Concept {name: 'rollConditionalEvents'}) MERGE (turn)-[:USES]->(c);

// =============================================================================
// Spec-10 /speckit-specify: GameEngine（フルターンループ）
// =============================================================================
MERGE (:Document {name: 'Spec-10 spec.md', path: 'specs/010-game-engine/spec.md', type: 'spec', spec: 'Spec-10',
  description: 'GameEngine（フルターンループ）仕様。初期化・ターン処理・ゲーム終了・memberUpdates集計の4ユーザーストーリー',
  created: '2026-08-13'});
MERGE (:Document {name: 'Spec-10 checklists/requirements.md', path: 'specs/010-game-engine/checklists/requirements.md', type: 'checklist', spec: 'Spec-10',
  description: '仕様品質チェックリスト 16/16 PASS', created: '2026-08-13'});
MERGE (:Concept {name: 'GameEngine', spec: 'Spec-10',
  description: 'ゲーム全体の状態を管理するクラス。初期化・processTurn・getState・isGameOver を提供',
  file: 'src/game/engine.ts'});
MERGE (:ADR {id: 'ADR-013',
  title: 'GameEngine は conditionalEvents を内部保持しターン処理に渡す',
  date: '2026-08-13', status: 'accepted',
  context: 'GameState に stageConditionalEvents を追加するか、GameEngine が内部保持するかを選択する必要があった',
  decision: 'GameEngine コンストラクタで stageData.conditionalEvents を内部保持し、processTurn 呼び出し時に毎回渡す',
  rationale: 'GameState は1ターンの処理状態を表す値オブジェクトであり、ステージ設定データ（conditionalEvents）を混在させるより、GameEngine層で管理する方が責務が明確になる',
  consequences: 'GameState の型は変更不要。GameEngine を経由しない processTurn 呼び出し（テスト等）では引き続き手動で conditionalEvents を渡す'});
MATCH (adr:ADR {id: 'ADR-013'}), (c:Concept {name: 'GameEngine'}) MERGE (adr)-[:AFFECTS]->(c);
MATCH (spec:Document {name: 'Spec-10 spec.md'}), (c:Concept {name: 'GameEngine'}) MERGE (spec)-[:DEFINES]->(c);

// =============================================================================
// Spec-10 /speckit-plan: plan.md / data-model.md / quickstart.md
// =============================================================================
MERGE (:Document {name: 'Spec-10 plan.md', path: 'specs/010-game-engine/plan.md', type: 'plan', spec: 'Spec-10',
  description: 'GameEngine実装計画。KD-1〜6: クラス設計・初期化・progress/member更新・ゲームオーバーガード',
  created: '2026-08-13'});
MERGE (:Document {name: 'Spec-10 data-model.md', path: 'specs/010-game-engine/data-model.md', type: 'data-model', spec: 'Spec-10',
  description: 'GameEngineクラス設計・初期化フロー・processTurnフロー・memberUpdates集計',
  created: '2026-08-13'});
MERGE (:Document {name: 'Spec-10 quickstart.md', path: 'specs/010-game-engine/quickstart.md', type: 'quickstart', spec: 'Spec-10',
  description: 'A〜Eシナリオ: 初期化・1ターン・複数ターン・ゲームオーバーガード・クランプ確認',
  created: '2026-08-13'});
MATCH (plan:Document {name: 'Spec-10 plan.md'}), (spec:Document {name: 'Spec-10 spec.md'}) MERGE (plan)-[:IMPLEMENTS]->(spec);

// =============================================================================
// Spec-10 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-10 tasks', path: 'specs/010-game-engine/tasks.md', type: 'tasks', spec: 'Spec-10',
  description: 'Spec-10実装タスク一覧。T001〜T016、6フェーズ。Setup→テスト先行（US1/US2/US3/US4）→初期化→processTurn→memberUpdates集計→Polish。TDD方式。',
  created: '2026-08-13'});
MATCH (a:Document {name: 'Spec-10 spec.md'}), (b:Document {name: 'Spec-10 tasks'}) MERGE (a)-[:HAS_TASKS]->(b);
MATCH (spec:Document {name: 'Spec-08 spec'}), (d:Document {name: 'Spec-08 event.ts'}) MERGE (spec)-[:IMPLEMENTS]->(d);

// =============================================================================
// Spec-10 /speckit-implement: engine.ts + engine.test.ts
// =============================================================================
MERGE (:Document {name: 'src/game/engine.ts', path: 'src/game/engine.ts', type: 'implementation', spec: 'Spec-10',
  description: 'GameEngineクラス実装。buildInitialState・applyMemberUpdates・processTurn・getState・isGameOverを提供',
  status: 'completed', tests: 24, coverage_lines: 100, coverage_funcs: 100,
  created: '2026-08-13'});
MERGE (:Document {name: 'tests/unit/engine.test.ts', path: 'tests/unit/engine.test.ts', type: 'test', spec: 'Spec-10',
  description: 'GameEngineテスト。US1初期化(8)・US2ターン処理(7)・US3ゲーム終了(5)・US4メンバー集計(4) = 24件全PASS',
  status: 'completed', test_count: 24,
  created: '2026-08-13'});
MATCH (t10tasks:Document {name: 'Spec-10 tasks'}) SET t10tasks.status = 'completed';
MERGE (:Concept {name: 'buildInitialState', description: 'StageDataから初期GameStateを構築するヘルパー関数（engine.ts内部）', file: 'src/game/engine.ts', spec: 'Spec-10'});
MERGE (:Concept {name: 'applyMemberUpdates', description: '同一メンバーのmemberUpdateエントリを合算しclampして適用するヘルパー関数（engine.ts内部）', file: 'src/game/engine.ts', spec: 'Spec-10'});

MATCH (ge:Concept {name: 'GameEngine'}), (d:Document {name: 'src/game/engine.ts'}) MERGE (ge)-[:IMPLEMENTED_IN]->(d);
MATCH (ge:Concept {name: 'GameEngine'}), (t:Document {name: 'tests/unit/engine.test.ts'}) MERGE (ge)-[:TESTED_IN]->(t);
MATCH (spec:Document {name: 'Spec-10 spec.md'}), (d:Document {name: 'src/game/engine.ts'}) MERGE (spec)-[:IMPLEMENTS]->(d);

MERGE (:ADR {id: 'ADR-014',
  title: 'GameEngineのprocessTurnはprogressUpdatesをupdateTaskProgressで適用しstallイベントでsetTaskStatusを呼ぶ',
  date: '2026-08-13', status: 'accepted',
  context: 'GameEngineはprocessTurnCoreの結果（TurnResult）からganttタスクの状態を更新する必要がある。progressUpdatesとstallイベントの両方を処理しなければならない。',
  decision: 'progressUpdates: updateTaskProgress(task, delta)で進捗更新。stallイベント: events配列でe.id.startsWith("stall") && e.targetId===task.idでマッチしsetTaskStatus(task, "stalled")を呼ぶ',
  rationale: '既存のgantt.ts実装（updateTaskProgress・setTaskStatus）を再利用することでロジックの重複を避ける。stallの検出はevent idプレフィックス規約で行い、型を新設せずに済む',
  consequences: 'stall event idが"stall"プレフィックスを持つ規約に依存する。規約変更時はengine.tsも修正が必要'});
MATCH (adr:ADR {id: 'ADR-014'}), (ge:Concept {name: 'GameEngine'}) MERGE (adr)-[:AFFECTS]->(ge);

// =============================================================================
// Spec-11 /speckit-specify: PoCステージデータ仕様
// =============================================================================
MERGE (:Document {name: 'Spec-11 spec.md', path: 'specs/011-poc-stage-data/spec.md', type: 'spec', spec: 'Spec-11',
  description: 'PoCステージデータ仕様。pocStage定数定義・3名メンバー・8〜10タスク・条件付きイベント3〜5件・初期手札2〜3枚',
  status: 'draft', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-11 checklists/requirements.md', path: 'specs/011-poc-stage-data/checklists/requirements.md', type: 'checklist', spec: 'Spec-11',
  description: 'Spec-11仕様チェックリスト。16項目全PASS', status: 'completed', created: '2026-08-13'});
MERGE (:Concept {name: 'pocStage', description: 'PoCステージのStageData定数。budget=500万・deadline=22ターン・メンバー3名・タスク8〜10件・条件付きイベント3〜5件', file: 'src/game/stages/poc.ts', spec: 'Spec-11'});
MATCH (spec:Document {name: 'Spec-11 spec.md'}), (c:Concept {name: 'pocStage'}) MERGE (spec)-[:DEFINES]->(c);

// =============================================================================
// Spec-11 /speckit-plan: PoCステージデータ計画フェーズ
// =============================================================================
MERGE (:Document {name: 'Spec-11 plan.md', path: 'specs/011-poc-stage-data/plan.md', type: 'plan', spec: 'Spec-11',
  description: 'Spec-11実装計画。src/game/stages/pocStage.ts新設。メンバー3名・ガントタスク9件・条件付きイベント5件・初期カード3枚',
  status: 'completed', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-11 research.md', path: 'specs/011-poc-stage-data/research.md', type: 'research', spec: 'Spec-11',
  description: 'evaluateCondition対応9パターン確認。GanttTask初期statusはactive（waitingは型なし）。キャロルskill=6はリテラル定義',
  status: 'completed', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-11 data-model.md', path: 'specs/011-poc-stage-data/data-model.md', type: 'data-model', spec: 'Spec-11',
  description: 'pocStageデータモデル。9タスク(5フェーズ)・5条件付きイベント・initialCards3枚のDAG定義',
  status: 'completed', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-11 quickstart.md', path: 'specs/011-poc-stage-data/quickstart.md', type: 'quickstart', spec: 'Spec-11',
  description: 'Spec-11検証ガイド。vitest/tsc実行手順と4検証シナリオ',
  status: 'completed', created: '2026-08-13'});

MERGE (poc:Concept {name: 'pocStage'})
SET poc.type = 'StageData',
    poc.file = 'src/game/stages/pocStage.ts',
    poc.budget = 5000000,
    poc.deadline = 22,
    poc.memberCount = 3,
    poc.ganttTaskCount = 9,
    poc.conditionalEventCount = 5,
    poc.initialCardCount = 3,
    poc.spec = 'Spec-11';

MERGE (:ADR {id: 'ADR-015',
  title: 'PoCステージデータの構造設計',
  date: '2026-08-13', status: 'accepted',
  context: 'GameEngineに渡す最初のStageData定数が必要。3名体制・22ターン・500万円予算のPoC開発プロジェクトを表現する。',
  decision: 'src/game/stages/pocStage.tsにStageData型定数を実装。アリス(skill=12)・ボブ(skill=8)・キャロル(skill=6)。ガントタスク9件(5フェーズ)。条件付きイベント5件。初期カード(デイリー・レビュー・モニタリング)。',
  rationale: 'stages/サブディレクトリ新設で複数ステージ対応を想定。GanttTask初期statusはactive（waiting型は存在しないため）。キャロルskill値はリテラルで記述（constants.ts肥大化を避ける）。',
  consequences: 'GameEngineが正しく初期化できることをVitestで検証。カバレッジゲートをクリアするためテストファイルも同時作成が必要。'});
MATCH (adr:ADR {id: 'ADR-015'}), (spec:Document {name: 'Spec-11 spec.md'}) MERGE (adr)-[:AFFECTS]->(spec);
MATCH (adr:ADR {id: 'ADR-015'}), (poc:Concept {name: 'pocStage'}) MERGE (adr)-[:AFFECTS]->(poc);
MATCH (ge:Concept {name: 'GameEngine'}), (poc:Concept {name: 'pocStage'}) MERGE (ge)-[:ACCEPTS]->(poc);
MATCH (spec:Document {name: 'Spec-11 plan.md'}), (poc:Concept {name: 'pocStage'}) MERGE (spec)-[:DEFINES]->(poc);

// =============================================================================
// Spec-11 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-11 tasks.md', path: 'specs/011-poc-stage-data/tasks.md', type: 'tasks', spec: 'Spec-11',
  description: 'Spec-11タスク一覧。T001〜T011、5フェーズ。Setup→US1(pocStage実装+テスト)→US2(ガント整合性テスト)→US3(条件付きイベントテスト)→Polish。TDD方式。',
  status: 'pending', created: '2026-08-13'});
MATCH (a:Document {name: 'Spec-11 spec.md'}), (b:Document {name: 'Spec-11 tasks.md'}) MERGE (a)-[:HAS_TASKS]->(b);

// =============================================================================
// Spec-11 /speckit-implement: pocStage.ts + pocStage.test.ts
// =============================================================================
MERGE (:Document {name: 'src/game/stages/pocStage.ts', path: 'src/game/stages/pocStage.ts', type: 'implementation', spec: 'Spec-11',
  description: 'pocStage定数。StageData型準拠。メンバー3名(アリス12/ボブ8/キャロル6)・ガントタスク9件(5フェーズ)・条件付きイベント5件・初期カード3枚',
  status: 'completed', created: '2026-08-13'});
MERGE (:Document {name: 'tests/unit/stages/pocStage.test.ts', path: 'tests/unit/stages/pocStage.test.ts', type: 'test', spec: 'Spec-11',
  description: 'pocStageテスト。US1初期化(9)・US2ガント整合性(5)・US3条件付きイベント(4) = 18件全PASS',
  status: 'completed', test_count: 18, created: '2026-08-13'});
MATCH (t11tasks:Document {name: 'Spec-11 tasks.md'}) SET t11tasks.status = 'completed';

MATCH (poc:Concept {name: 'pocStage'}), (impl:Document {name: 'src/game/stages/pocStage.ts'}) MERGE (poc)-[:IMPLEMENTED_IN]->(impl);
MATCH (poc:Concept {name: 'pocStage'}), (test:Document {name: 'tests/unit/stages/pocStage.test.ts'}) MERGE (poc)-[:TESTED_IN]->(test);
MATCH (spec:Document {name: 'Spec-11 spec.md'}), (impl:Document {name: 'src/game/stages/pocStage.ts'}) MERGE (spec)-[:IMPLEMENTS]->(impl);

// =============================================================================
// Spec-12 /speckit-specify: メイン画面UI仕様
// =============================================================================
MERGE (:Document {name: 'Spec-12 spec.md', path: 'specs/012-main-game-ui/spec.md', type: 'spec', spec: 'Spec-12',
  description: 'メイン画面UI仕様。DOM overlay + Phaser Scene。ダッシュボード・カード枠・ターン移行ロード画面の3ユーザーストーリー',
  status: 'draft', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-12 checklists/requirements.md', path: 'specs/012-main-game-ui/checklists/requirements.md', type: 'checklist', spec: 'Spec-12',
  description: 'Spec-12仕様チェックリスト。16項目全PASS', status: 'completed', created: '2026-08-13'});
MERGE (:Concept {name: 'MainGameUI', description: 'DOM overlay ルートコンポーネント。GameStateを受け取り表示を更新する', layer: 'src/ui/', spec: 'Spec-12'});
MERGE (:Concept {name: 'CardSlot', description: 'カードスロット1枠コンポーネント。カードの配置・除去を管理する', layer: 'src/ui/', spec: 'Spec-12'});
MERGE (:Concept {name: 'LoadingScreen', description: 'ターン移行ロード画面コンポーネント。PM用語テキストを表示する。最低1秒表示', layer: 'src/ui/', spec: 'Spec-12'});
MERGE (:Concept {name: 'MainScene', description: 'Phaser Scene。キャンバス背景とDOM overlayの協調制御を担当', layer: 'src/scenes/', spec: 'Spec-12'});

MATCH (spec:Document {name: 'Spec-12 spec.md'}), (c:Concept {name: 'MainGameUI'}) MERGE (spec)-[:DEFINES]->(c);
MATCH (spec:Document {name: 'Spec-12 spec.md'}), (c:Concept {name: 'CardSlot'}) MERGE (spec)-[:DEFINES]->(c);
MATCH (spec:Document {name: 'Spec-12 spec.md'}), (c:Concept {name: 'LoadingScreen'}) MERGE (spec)-[:DEFINES]->(c);
MATCH (spec:Document {name: 'Spec-12 spec.md'}), (c:Concept {name: 'MainScene'}) MERGE (spec)-[:DEFINES]->(c);
MATCH (spec:Document {name: 'Spec-12 spec.md'}), (poc:Concept {name: 'pocStage'}) MERGE (spec)-[:DEPENDS_ON]->(poc);
MATCH (spec:Document {name: 'Spec-12 spec.md'}), (ge:Concept {name: 'GameEngine'}) MERGE (spec)-[:DEPENDS_ON]->(ge);

// =============================================================================
// Spec-12 /speckit-plan: メイン画面UI計画フェーズ
// =============================================================================
MERGE (:Document {name: 'Spec-12 plan.md', path: 'specs/012-main-game-ui/plan.md', type: 'plan', spec: 'Spec-12',
  description: 'Spec-12実装計画。src/ui/MainGameUI・CardSlot・LoadingScreen + src/scenes/MainScene。Playwright E2E 3ファイル',
  status: 'completed', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-12 research.md', path: 'specs/012-main-game-ui/research.md', type: 'research', spec: 'Spec-12',
  description: 'DOM overlay協調・ドラッグ＆ドロップ・Scene通知パターン・ローディング最低1秒の設計決定',
  status: 'completed', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-12 data-model.md', path: 'specs/012-main-game-ui/data-model.md', type: 'data-model', spec: 'Spec-12',
  description: 'MainGameUI・CardSlot・LoadingScreen・pmTerms・MainSceneのフィールド/メソッド/状態遷移定義',
  status: 'completed', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-12 contracts/ui-contracts.md', path: 'specs/012-main-game-ui/contracts/ui-contracts.md', type: 'contract', spec: 'Spec-12',
  description: 'data-testid一覧・DOM状態コントラクト・E2Eシナリオ概要',
  status: 'completed', created: '2026-08-13'});
MERGE (:Document {name: 'Spec-12 quickstart.md', path: 'specs/012-main-game-ui/quickstart.md', type: 'quickstart', spec: 'Spec-12',
  description: 'Playwright E2E実行手順と3検証シナリオ',
  status: 'completed', created: '2026-08-13'});

MERGE (:ADR {id: 'ADR-016',
  title: 'メイン画面UIのアーキテクチャ設計（DOM overlay + Phaser Scene 協調）',
  date: '2026-08-13', status: 'accepted',
  context: 'Phaser 4のCanvas上にDOM UIを重ねる必要がある。既存のindex.htmlに#ui-overlayが定義済み。Constitution原則IによりPhaser importはsrc/scenes/のみ許可。',
  decision: 'src/ui/は純粋DOM操作のみ（Phaser import禁止）。MainSceneがengineとuiの両方を持ちoverlay.render(state)で通知。ドラッグ＆ドロップはHTML5 drag events。ローディング最低1秒はPromise.all([processTurn(), sleep(1000)])。',
  rationale: '既存のDOM構造を活かし複雑さを最小化。EventEmitter不要でScene→UIの直接メソッド呼び出しがシンプル。Playwright E2EテストがDOM要素として操作できる構造を維持。',
  consequences: 'src/ui/はフレームワーク非依存の純粋TypeScriptクラス。将来Reactへの移行も可能だが現状では不要。'});
MATCH (adr:ADR {id: 'ADR-016'}), (spec:Document {name: 'Spec-12 spec.md'}) MERGE (adr)-[:AFFECTS]->(spec);
MATCH (adr:ADR {id: 'ADR-016'}), (ui:Concept {name: 'MainGameUI'}) MERGE (adr)-[:AFFECTS]->(ui);
MATCH (adr:ADR {id: 'ADR-016'}), (scene:Concept {name: 'MainScene'}) MERGE (adr)-[:AFFECTS]->(scene);

// =============================================================================
// Spec-12 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-12 tasks.md', path: 'specs/012-main-game-ui/tasks.md', type: 'tasks', spec: 'Spec-12',
  description: 'Spec-12タスク一覧。T001〜T028、6フェーズ。Setup→基盤→US1ダッシュボード→US2カード枠→US3ローディング→Polish。E2E 3ファイル。',
  status: 'pending', created: '2026-08-13'});
MATCH (a:Document {name: 'Spec-12 spec.md'}), (b:Document {name: 'Spec-12 tasks.md'}) MERGE (a)-[:HAS_TASKS]->(b);

// =============================================================================
// Spec-12 /speckit-implement: Phase 1 セットアップ（T001-T005）
// =============================================================================
MATCH (n:Document {name: 'Spec-12 tasks.md'}) SET n.status = 'in_progress';

MERGE (pm:Concept {name: 'pmTerms'})
SET pm.type = 'module', pm.file = 'src/ui/pmTerms.ts',
    pm.description = 'PM用語15件の定数配列（EVM, SPI, CPI等）。LoadingScreenが参照する。',
    pm.status = 'implemented', pm.spec = 'Spec-12';

MATCH (ls:Concept {name: 'LoadingScreen'})
SET ls.file = 'src/ui/LoadingScreen.ts',
    ls.description = 'ターン処理中のオーバーレイ。show()でランダムなPM用語を表示、hide()で非表示。data-testid=loading-screen。',
    ls.status = 'implemented';

MATCH (cs:Concept {name: 'CardSlot'})
SET cs.file = 'src/ui/CardSlot.ts',
    cs.description = 'カードスロット1枠。place/remove/markBlocked/clearBlocked。data-testid=card-slot-{index}。',
    cs.status = 'implemented';

MATCH (mgu:Concept {name: 'MainGameUI'})
SET mgu.file = 'src/ui/MainGameUI.ts',
    mgu.description = 'DOM overlay UI全体。header/KPI/メンバー/カードスロット/フッター構成。render(GameState)で更新。src/ui/配下でPhaserをimportしない。',
    mgu.status = 'implemented';

MATCH (ms:Concept {name: 'MainScene'})
SET ms.file = 'src/scenes/MainScene.ts',
    ms.description = 'Phaser.Scene。create()でGameEngine(pocStage)生成・#ui-overlay取得・MainGameUI初期化。confirmTurn()でPromise.all+sleep(1000)のローディング制御。',
    ms.status = 'implemented';

MERGE (:ADR {
  id: 'ADR-017',
  title: 'MainScene を src/scenes/ に置きPhaserをimportする唯一の協調層とする',
  date: '2026-08-13', status: 'accepted',
  context: 'src/ui/ 配下はPhaser非依存が条件（Constitution Principle I）。一方でゲームループはPhaserのシーンライフサイクルに乗る必要がある。',
  decision: 'src/scenes/MainScene.ts がGameEngine + MainGameUIを生成・協調する。src/ui/ はDOMのみ操作し、PhaserをimportしないDOM overlay層とする。',
  rationale: 'UIをPhaser非依存に保つことで単体テストが容易になり、将来的なフレームワーク移行コストも下がる。',
  consequences: 'MainSceneはPhaser依存を集約する。UIの変更はsrc/ui/のみで完結し、src/scenes/への影響を最小化できる。'});

MATCH (adr:ADR {id: 'ADR-017'}), (ms:Concept {name: 'MainScene'}) MERGE (adr)-[:AFFECTS]->(ms);
MATCH (adr:ADR {id: 'ADR-017'}), (mgu:Concept {name: 'MainGameUI'}) MERGE (adr)-[:AFFECTS]->(mgu);
MATCH (ls:Concept {name: 'LoadingScreen'}), (pm:Concept {name: 'pmTerms'}) MERGE (ls)-[:USES]->(pm);
MATCH (mgu:Concept {name: 'MainGameUI'}), (ls:Concept {name: 'LoadingScreen'}) MERGE (mgu)-[:CONTAINS]->(ls);
MATCH (mgu:Concept {name: 'MainGameUI'}), (cs:Concept {name: 'CardSlot'}) MERGE (mgu)-[:CONTAINS]->(cs);
MATCH (ms:Concept {name: 'MainScene'}), (mgu:Concept {name: 'MainGameUI'}) MERGE (ms)-[:USES]->(mgu);
MATCH (ms:Concept {name: 'MainScene'}), (ge:Concept {name: 'GameEngine'}) MERGE (ms)-[:USES]->(ge);

// Spec-12 implement 完了
MATCH (n:Document {name: 'Spec-12 tasks.md'}) SET n.status = 'completed';
MATCH (n:Document {name: 'Spec-12 spec.md'}) SET n.status = 'completed';

// Spec-01〜04 完了ステータス反映（Phase 1-2完了当時は status プロパティ未整備だったため後追い）
MATCH (d:Document)
WHERE d.name STARTS WITH 'Spec-01' OR d.name STARTS WITH 'Spec-02' OR d.name STARTS WITH 'Spec-03' OR d.name STARTS WITH 'Spec-04'
SET d.status = CASE d.type
  WHEN 'source' THEN 'implemented'
  WHEN 'test' THEN 'all-pass'
  ELSE 'completed'
END;

// ADR-018: docs/はNeo4jの一部を人間可読に二重管理するだけであり専有領域ではない
MERGE (:ADR {
  id: 'ADR-018',
  title: 'docs/はNeo4jの一部を人間可読に二重管理するだけであり専有領域ではない',
  date: '2026-08-14',
  status: 'accepted',
  context: 'Constitution Principle IVおよびsync-graphdbスキルの「docs/には数値・一覧・ステージデータ等のみを置く」という記述が、それらの情報がグラフDBには格納されず docs/ にしかない、あるいは docs/ にはその4種類しか書けない、という誤読を招いていた。',
  decision: '設計知識（数値・一覧・ステージデータ・画面構成図を含め）は例外なくすべてNeo4jに格納することを原則とし、docs/はその一部を人間可読な形式で追加的に二重管理しているだけと明記する。AIエージェントはNeo4jのみを参照すれば全体像を把握できる状態を維持する。',
  rationale: 'docs/とグラフDBの役割分担ではなく、グラフDBを唯一の正としたうえでの人間向けの重複配置であることを明確にし、AIがdocs/を正の情報源と誤認するリスクを排除するため。',
  consequences: 'Constitution v1.2.0→v1.2.1（PATCH）。.specify/memory/constitution.mdとdocs/sync-graphdbスキルの該当箇所を修正。今後docs/に何を書くかの判断は「人間に見せたいかどうか」のみで行い、Neo4jへの格納要否とは無関係になる。'
});

// =============================================================================
// Phase 7-8: データ構造リファクタリング / 画面遷移 の設計セッション（brainstorming）
// =============================================================================

MERGE (:Document {name: 'Spec-13 design', path: 'docs/superpowers/specs/2026-08-14-game-data-file-restructure-design.md',
  type: 'design-doc', spec: 'Spec-13',
  description: 'カード・イベント・ステージを1ファイル1定義に再編する設計。src/game/cards|events|stages 配下へ分割し、docs/03-詳細設計 側も同粒度でカード/イベント/ステージのフォルダに分割する（フォルダ・ファイル名は日本語）。',
  status: 'draft', created: '2026-08-14'});

MERGE (:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編', path: 'docs/sdd-tasks.md',
  type: 'spec-entry', spec: 'Spec-13', status: 'planned', created: '2026-08-14'});
MATCH (s13:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編'}), (d:Document {name: 'Spec-13 design'})
MERGE (s13)-[:HAS_DESIGN]->(d);

MERGE (:Document {name: 'Spec-14 design', path: 'docs/superpowers/specs/2026-08-14-title-stageselect-flow-design.md',
  type: 'design-doc', spec: 'Spec-14',
  description: 'BootScene→TitleScene→StageSelectScene→MainSceneの画面遷移設計。ステージ確認画面（プロジェクト概要・予算・目標利益率を表示しYES/NOを問う）の追記が未反映のため更新が必要。',
  status: 'draft', created: '2026-08-14'});

MERGE (:Document {name: 'Spec-14: タイトル〜ステージセレクト画面遷移', path: 'docs/sdd-tasks.md',
  type: 'spec-entry', spec: 'Spec-14', status: 'planned', created: '2026-08-14'});
MATCH (s14:Document {name: 'Spec-14: タイトル〜ステージセレクト画面遷移'}), (d:Document {name: 'Spec-14 design'})
MERGE (s14)-[:HAS_DESIGN]->(d);

MERGE (:Concept {name: 'CardDefinition', description: 'カード1件分のコスト＋効果ロジックをまとめた定義。cards/配下の各ファイルがこの形でexportする（設計のみ、未実装）', file: 'src/game/cards/index.ts', spec: 'Spec-13'});
MERGE (:Concept {name: 'EventDefinition', description: 'ランダムイベント1種のroll関数をまとめた定義。events/配下の各ファイルがこの形でexportする（設計のみ、未実装）', file: 'src/game/events/index.ts', spec: 'Spec-13'});
MERGE (:Concept {name: 'TitleScene', description: 'タイトルロゴ＋スタートボタンのみのScene。押下でStageSelectSceneへ遷移（設計のみ、未実装）', file: 'src/scenes/TitleScene.ts', spec: 'Spec-14'});
MERGE (:Concept {name: 'StageSelectScene', description: 'ステージカード一覧を表示するScene。カード選択で確認画面（プロジェクト概要・予算・目標利益率）を表示し、YESでMainSceneへ遷移（設計のみ、未実装）', file: 'src/scenes/StageSelectScene.ts', spec: 'Spec-14'});

// ADR-019: カード・イベント・ステージのファイル構造再編
MERGE (:ADR {
  id: 'ADR-019',
  title: 'カード・イベント・ステージを1ファイル1定義の構造に再編する',
  date: '2026-08-14',
  status: 'accepted',
  context: 'カードのコスト・効果ロジックはconstants.tsのCARD_COSTSテーブルとcard.tsの1つのswitch文に、ランダムイベントの発生確率・効果ロジックも同様にconstants.tsのEVENT_PROBテーブルとevent.tsの1つのswitch文に集約されていた。ステージもpocStage.tsという「唯一のPoCステージ」であるかのような名前の1ファイルのみだった。カード・イベント・ステージを増やすたびに複数箇所（定義テーブルとswitch文）を編集する必要があり、今後のゲーム設計（バランス調整・コンテンツ追加）の妨げになっていた。',
  decision: 'src/game/cards/・events/・stages/ 配下にカード1種・イベント1種・ステージ1件ごとに1ファイルを置く構造に再編する。各ファイルはデータ定義（コスト・発生確率）と効果ロジックの両方を持つ。cards/index.ts・events/index.ts・stages/index.ts にレジストリを置き、card.ts/event.tsのswitch文を置き換える。CardNameはtypes.tsの明示的なunion型として残し、レジストリ側でsatisfies Record<CardName, CardDefinition>により網羅性をコンパイル時に保証する。ステージファイル名は「タイプ+連番」のフラット命名（例: poc-01.ts）とし、StageData.idも同じ文字列にする。docs/03-詳細設計側もカード/イベント/ステージのフォルダに同粒度で分割するが、フォルダ・ファイル名は日本語にする。条件付きイベントの条件式評価（conditional.ts）とイベントの汎用適用処理（applyEventToProgress/applyEventToMember）はイベント種別に依存しない共通処理のため分割対象外とする。',
  rationale: 'ステージ・カード・イベントを増やす作業を「ファイルを1つ追加するだけ」にし、複数箇所の同時編集による更新漏れを防ぐため。CardNameをレジストリから型導出する案（要ファイル追加のみで完結）も検討したが、カード名の一覧を1箇所で見渡せる明示的unionの可読性と、satisfies活用による同等のコンパイル時網羅性チェックを優先し採用しなかった。ファイル分割によりフォーマット変更時の影響範囲は広がるが、追加のしやすさのメリットが上回ると判断した。未実装のカード19種・イベント10種前後も同じ構造のスタブファイルとして作成し、実装済み分と構造を揃える。',
  consequences: 'card.ts・event.tsは廃止しcards/index.ts・events/index.tsに統合。constants.tsからCARD_COSTS・EVENT_PROBを除去。pocStage.tsはstages/poc-01.tsにリネーム（既存のMainScene.ts等のimport元を要修正）。docs/03-詳細設計/カード.md・イベント.mdは横断的な説明のみを残し個別カード/イベントの内容をカード/・イベント/配下に分割。既存の単体テスト（card.test.ts/event.test.ts）の再編方針は本ADRのスコープ外で別途検討する。'
});
MATCH (adr:ADR {id: 'ADR-019'}), (poc:Concept {name: 'pocStage'}) MERGE (adr)-[:AFFECTS]->(poc);
MATCH (adr:ADR {id: 'ADR-019'}), (re:Concept {name: 'rollRandomEvents'}) MERGE (adr)-[:AFFECTS]->(re);
MATCH (adr:ADR {id: 'ADR-019'}), (cd:Concept {name: 'CardDefinition'}) MERGE (adr)-[:AFFECTS]->(cd);
MATCH (adr:ADR {id: 'ADR-019'}), (ed:Concept {name: 'EventDefinition'}) MERGE (adr)-[:AFFECTS]->(ed);
MATCH (adr:ADR {id: 'ADR-019'}), (d:Document {name: 'Spec-13 design'}) MERGE (adr)-[:AFFECTS]->(d);

// ADR-020: ステージ選択時に確認画面（YES/NO）を挟む
MERGE (:ADR {
  id: 'ADR-020',
  title: 'ステージ選択時にステージ確認画面（プロジェクト概要・予算・目標利益率の表示とYES/NO確認）を挟む',
  date: '2026-08-14',
  status: 'accepted',
  context: '当初はStageSelectSceneでステージカードをクリックした時点で即座にMainSceneへ遷移する設計だったが、ステージ内容（プロジェクト概要・予算・目標利益率＝クリア条件）を事前に確認してからプレイを開始したいという要望があった。',
  decision: 'ステージカードクリック時にMainSceneへ即遷移するのではなく、選択したステージの確認画面（プロジェクト概要・予算・目標利益率を表示し「開始する」「もどる」を選ばせる）を挟む。目標利益率は率のみ表示（例:「目標利益率 5%以上」）し、予算×率の具体金額は表示しない。「開始する」でMainSceneへ遷移、「もどる」でステージ一覧に戻る。これに伴いStageDataにdescription（プロジェクト概要文）フィールドを追加する。',
  rationale: 'プレイヤーがステージの内容を把握したうえで開始できるようにするため。目標金額まで計算表示すると分かりやすさは増すが、利益の定義（予算-コストの厳密な計算式）を先に確定させる必要が生じるため、今回は率表示のみに留めスコープを絞った。',
  consequences: 'StageSelectSceneは一覧表示と確認表示の2状態を持つ（別Sceneには分けない）。StageData（types.ts）にdescription: stringフィールドを追加し、各ステージファイルに文言を設定する必要がある。'
});
MATCH (adr:ADR {id: 'ADR-020'}), (ms:Concept {name: 'MainScene'}) MERGE (adr)-[:AFFECTS]->(ms);
MATCH (adr:ADR {id: 'ADR-020'}), (sss:Concept {name: 'StageSelectScene'}) MERGE (adr)-[:AFFECTS]->(sss);
MATCH (adr:ADR {id: 'ADR-020'}), (d:Document {name: 'Spec-14 design'}) MERGE (adr)-[:AFFECTS]->(d);

// =============================================================================
// Spec-13 /speckit-specify: spec.md
// =============================================================================
MERGE (:Document {name: 'Spec-13 spec.md', path: 'specs/013-card-event-stage-files/spec.md', type: 'spec', spec: 'Spec-13',
  description: 'カード・イベント・ステージのファイル構造再編の仕様。US1カード1ファイル化・US2イベント1ファイル化・US3ステージ命名規則統一・US4docs分割の4ユーザーストーリー。',
  status: 'draft', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-13 checklists/requirements.md', path: 'specs/013-card-event-stage-files/checklists/requirements.md', type: 'checklist', spec: 'Spec-13',
  status: 'completed', created: '2026-08-14'});
MATCH (s13:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編'}), (spec:Document {name: 'Spec-13 spec.md'})
MERGE (s13)-[:HAS_SPEC]->(spec);
MATCH (design:Document {name: 'Spec-13 design'}), (spec:Document {name: 'Spec-13 spec.md'})
MERGE (design)-[:INFORMS]->(spec);

// =============================================================================
// Spec-13 /speckit-plan: plan.md + research.md + data-model.md + contracts + quickstart.md
// =============================================================================
MERGE (:Document {name: 'Spec-13 plan.md', path: 'specs/013-card-event-stage-files/plan.md', type: 'plan', spec: 'Spec-13',
  description: 'Constitution Check全項目PASS。cards/events/stages配下+各index.tsレジストリ、tests/unit/cards|events配下（実装済みは個別ファイル、未実装はstubs.test.tsに集約）。',
  status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-13 research.md', path: 'specs/013-card-event-stage-files/research.md', type: 'research', spec: 'Spec-13', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-13 data-model.md', path: 'specs/013-card-event-stage-files/data-model.md', type: 'data-model', spec: 'Spec-13', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-13 contracts/module-contracts.md', path: 'specs/013-card-event-stage-files/contracts/module-contracts.md', type: 'contracts', spec: 'Spec-13', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-13 quickstart.md', path: 'specs/013-card-event-stage-files/quickstart.md', type: 'quickstart', spec: 'Spec-13', status: 'completed', created: '2026-08-14'});
MATCH (s13:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編'}), (plan:Document {name: 'Spec-13 plan.md'})
MERGE (s13)-[:HAS_PLAN]->(plan);

// ADR-021: CardDefinition/EventDefinitionインターフェース形状とテスト再編方針
MERGE (:ADR {
  id: 'ADR-021',
  title: 'CardDefinition/EventDefinitionのインターフェース形状と既存単体テストの再編方針',
  date: '2026-08-14',
  status: 'accepted',
  context: 'ADR-019でカード・イベントを1ファイル1定義に再編する方針を決めたが、各ファイルが実際にexportするインターフェースの形状と、既存の単体テスト（card.test.ts/event.test.ts）をどう再編するかは未決定だった。',
  decision: 'CardDefinitionは{cost, applyEffect(state)}、EventDefinitionは{roll(state, activeEffects): GameEvent|null}という最小限の形状にする。確率補正が必要なイベントはroll()内部でcalcEventProbModifierを呼び出す（データ形状を無理に共通化しない）。applyEventToProgress/applyEventToMemberはイベント種別に依存しない汎用処理としてevents/index.tsに残す。単体テストは実装済み分（カード6種・イベント5種）をソースと同じ粒度でtests/unit/cards|events配下に分割し、未実装分（カード19種・イベント10種前後）はstubs.test.tsに集約して一括検証する。',
  rationale: 'イベントのroll()を完全にデータ駆動な共通形状に固めると、既存のstall/rework（タスクをランダム選択）とsick等（メンバーをランダム選択）という異なる処理形状の移植が複雑になるため、柔軟性を優先した。未実装カード・イベントを1件ずつテストファイル化すると同型のテストが29件前後増えるだけで保守コストに見合わないため、スタブ検証は集約する。',
  consequences: 'tests/unit/card.test.ts・event.test.tsは廃止しtests/unit/cards/・events/配下に再編。新しいカード・イベントを追加する開発者は、実装ありならcards/<name>.test.tsを追加、実装なしならstubs.test.tsの対象リストに1行追加するだけでよい。'
});
MATCH (adr:ADR {id: 'ADR-021'}), (cd:Concept {name: 'CardDefinition'}) MERGE (adr)-[:AFFECTS]->(cd);
MATCH (adr:ADR {id: 'ADR-021'}), (ed:Concept {name: 'EventDefinition'}) MERGE (adr)-[:AFFECTS]->(ed);
MATCH (adr:ADR {id: 'ADR-021'}), (p:Document {name: 'Spec-13 plan.md'}) MERGE (adr)-[:AFFECTS]->(p);
MATCH (adr:ADR {id: 'ADR-021'}), (prev:ADR {id: 'ADR-019'}) MERGE (adr)-[:REFINES]->(prev);

// =============================================================================
// Spec-13 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-13 tasks.md', path: 'specs/013-card-event-stage-files/tasks.md', type: 'tasks', spec: 'Spec-13',
  description: 'T001〜T054、6フェーズ（Setup→US1カード→US2イベント→US4docs分割→US3ステージ→Polish）。カード実装済み6種・スタブ20種、イベント実装済み5種・スタブ10種を個別ファイル化するタスクを含む。',
  status: 'completed', created: '2026-08-14'});
MATCH (s13:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編'}), (t:Document {name: 'Spec-13 tasks.md'})
MERGE (s13)-[:HAS_TASKS]->(t);
MATCH (plan:Document {name: 'Spec-13 plan.md'}), (t:Document {name: 'Spec-13 tasks.md'})
MERGE (plan)-[:INFORMS]->(t);

// =============================================================================
// Spec-13 /speckit-implement: 完了
// =============================================================================
MATCH (n:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編'}) SET n.status = 'implemented';
MATCH (n:Document {name: 'Spec-13 tasks.md'}) SET n.status = 'completed';

MERGE (:Concept {name: 'CARD_REGISTRY', description: 'カード名からCardDefinitionを引くレジストリ。satisfies Record<CardName, CardDefinition>で網羅性を保証', file: 'src/game/cards/index.ts', spec: 'Spec-13'});
MERGE (:Concept {name: 'EVENT_REGISTRY', description: 'イベントキーからEventDefinitionを引くレジストリ。旧EVENT_PROBのキー名を踏襲', file: 'src/game/events/index.ts', spec: 'Spec-13'});
MERGE (:Concept {name: 'STAGE_REGISTRY', description: 'ステージidからStageDataを引くレジストリ', file: 'src/game/stages/index.ts', spec: 'Spec-13'});
MATCH (cd:Concept {name: 'CardDefinition'}), (reg:Concept {name: 'CARD_REGISTRY'}) MERGE (reg)-[:IMPLEMENTS]->(cd);
MATCH (ed:Concept {name: 'EventDefinition'}), (reg:Concept {name: 'EVENT_REGISTRY'}) MERGE (reg)-[:IMPLEMENTS]->(ed);
MATCH (adr:ADR {id: 'ADR-019'}), (reg:Concept {name: 'CARD_REGISTRY'}) MERGE (adr)-[:AFFECTS]->(reg);
MATCH (adr:ADR {id: 'ADR-019'}), (reg:Concept {name: 'EVENT_REGISTRY'}) MERGE (adr)-[:AFFECTS]->(reg);
MATCH (adr:ADR {id: 'ADR-019'}), (reg:Concept {name: 'STAGE_REGISTRY'}) MERGE (adr)-[:AFFECTS]->(reg);

MATCH (poc:Concept {name: 'pocStage'}) SET poc.file = 'src/game/stages/poc-01.ts', poc.description = 'PoCステージデータ。id="poc-01"。stages/poc-01.tsからexportされ、STAGE_REGISTRYに登録される';

MERGE (:Document {name: 'Spec-13 implement結果', path: 'specs/013-card-event-stage-files/tasks.md',
  type: 'implementation-summary', spec: 'Spec-13',
  description: 'cards/26ファイル+index.ts、events/15ファイル+index.ts、stages/poc-01.ts+index.ts。docs/03-詳細設計/カード26件・イベント23件・ステージ1件（PoCステージ01.md）。card.ts/event.ts/pocStage.ts/CARD_COSTS/EVENT_PROBは削除・統合済み。',
  status: 'completed', tests: 329, coverage_lines: 98.3, coverage_branches: 93.91,
  created: '2026-08-14'});
MATCH (s13:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編'}), (r:Document {name: 'Spec-13 implement結果'})
MERGE (s13)-[:HAS_RESULT]->(r);

// =============================================================================
// SDD外タスク: docs→ソースコード自動生成skill
// =============================================================================
MERGE (:Document {name: 'skill: docs-to-code generator', path: 'docs/sdd-tasks.md',
  type: 'backlog-task', status: 'planned', created: '2026-08-14',
  description: 'docs/03-詳細設計/カード|イベント|ステージ 配下のMarkdownからsrc/game/cards|events|stages 配下のソースコードを生成するClaude Codeスキル。表形式データ（コスト・確率・ガントチャート・条件付きイベント）の変換は大部分プログラム化できる見込み。SDDパイプライン（speckit）は通さない。Spec-13完了後に着手。'});
MATCH (task:Document {name: 'skill: docs-to-code generator'}), (s13:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編'})
MERGE (task)-[:DEPENDS_ON]->(s13);

// =============================================================================
// Spec-13 /speckit-implement 完了
// =============================================================================
MATCH (n:Document {name: 'Spec-13: カード・イベント・ステージのファイル構造再編'}) SET n.status = 'completed';
MATCH (n:Document {name: 'Spec-13 tasks.md'}) SET n.status = 'completed';

MATCH (n:Concept {name: 'CardDefinition'}) SET n.status = 'implemented';
MATCH (n:Concept {name: 'EventDefinition'}) SET n.status = 'implemented';
MATCH (n:Concept {name: 'CARD_REGISTRY'}) SET n.status = 'implemented';
MATCH (n:Concept {name: 'EVENT_REGISTRY'}) SET n.status = 'implemented';
MATCH (n:Concept {name: 'STAGE_REGISTRY'}) SET n.status = 'implemented';
MATCH (a:Concept {name: 'CARD_REGISTRY'}), (b:Concept {name: 'CardDefinition'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (a:Concept {name: 'EVENT_REGISTRY'}), (b:Concept {name: 'EventDefinition'}) MERGE (a)-[:CONTAINS]->(b);
MATCH (impl:Document {name: 'Spec-13 implement結果'}), (c:Concept {name: 'CARD_REGISTRY'}) MERGE (impl)-[:DEFINES]->(c);
MATCH (impl:Document {name: 'Spec-13 implement結果'}), (c:Concept {name: 'EVENT_REGISTRY'}) MERGE (impl)-[:DEFINES]->(c);
MATCH (impl:Document {name: 'Spec-13 implement結果'}), (c:Concept {name: 'STAGE_REGISTRY'}) MERGE (impl)-[:DEFINES]->(c);

MATCH (n:Concept {name: 'pocStage'}) SET n.status = 'superseded';

// =============================================================================
// Phase 9: バランスデータのJSON外部化 の設計セッション（brainstorming）
// =============================================================================

MERGE (:Document {name: 'Spec-15 design', path: 'docs/superpowers/specs/2026-08-14-json-data-externalization-design.md',
  type: 'design-doc', spec: 'Spec-15',
  description: 'カード・イベント・ステージの数値データとconstants.tsの係数テーブルをpublic/data/配下のJSONに外部化。効果ロジックはTSのまま。zodでスキーマ検証、新規PreloadSceneでPhaserのthis.load.jsonにより起動時ロード。docs・グラフDBは係数の意味とJSON参照先のみ記載し具体的な現在値は書かない方針。',
  status: 'draft', created: '2026-08-14'});

MERGE (:Document {name: 'Spec-15: カード・イベント・ステージ・バランス係数のJSON外部化', path: 'docs/sdd-tasks.md',
  type: 'spec-entry', spec: 'Spec-15', status: 'planned', created: '2026-08-14'});
MATCH (s15:Document {name: 'Spec-15: カード・イベント・ステージ・バランス係数のJSON外部化'}), (d:Document {name: 'Spec-15 design'})
MERGE (s15)-[:HAS_DESIGN]->(d);

MERGE (:Concept {name: 'PreloadScene', description: 'BootSceneとTitleSceneの間に挟む新規Scene。カード26+イベント15+ステージ1+バランス1=43件のJSONをPhaserのthis.load.jsonで一括ロードし、zod検証後にレジストリを構築する（設計のみ、未実装）', file: 'src/scenes/PreloadScene.ts', spec: 'Spec-15'});
MERGE (:Concept {name: 'GLOBAL_RULES', description: 'constants.tsのPOC_STAGEを改名。ステージ非依存のグローバルルール（BUFFER_RATIO・TARGET_PROFIT_RATE・DAILY_COST_CAP・OVERTIME_COST_CAP）のみを残す。ステージ固有の重複値（WORKING_DAYS等）は削除（設計のみ、未実装）', file: 'src/game/constants.ts', spec: 'Spec-15'});

// ADR-022: バランスデータのJSON外部化と数値の記載方針
MERGE (:ADR {
  id: 'ADR-022',
  title: 'カード・イベント・ステージ・バランス係数の数値データをJSON外部化し、docs/グラフDBには数値を書かない方針にする',
  date: '2026-08-14',
  status: 'accepted',
  context: 'Spec-13でカード・イベント・ステージは1ファイル1定義のTypeScript構造になったが、数値（コスト・確率・ガントチャート・係数）を変更するたびにTypeScriptのビルド・型チェックを経る必要があり、バランス調整のイテレーションが重い。また、docsやADR/Parameterノードに具体的な数値を書くと、チューニングのたびに複数箇所を更新する必要が生じ、ADR-018で踏んだ更新漏れ・陳腐化と同じ問題を数値データで再発させるリスクがあった。',
  decision: 'カードの`cost`、イベントの基本確率、ステージデータ全体、constants.tsの係数テーブルをpublic/data/配下のJSON（Spec-13のファイル粒度と1:1対応）に外部化する。効果ロジック（applyEffect/roll関数）はTypeScriptのまま残す。zodで起動時にスキーマ検証し、新規PreloadScene（BootScene→TitleScene間）でPhaserのthis.load.jsonにより読み込む。CARD_REGISTRY等はモジュール定数からbuildCardRegistry()等の構築関数に変える。constants.tsのPOC_STAGEはGLOBAL_RULESに改名し、ステージ非依存の4項目のみ残す。docsとグラフDBには係数の意味・計算式の形・JSON参照先のみを記載し、具体的な現在値は書かない。',
  rationale: 'src/game/はConstitution Principle IによりPhaser/DOM非依存のためfetchを持てず、読み込み処理はsrc/scenes/側に置く必要がある。JSON化する層と効果ロジックの層を分けることでSpec-13の1ファイル1定義構造とsatisfiesによる網羅性チェックの安全性を維持しつつ、数値だけを再ビルド不要で編集できるようにする。数値をdocs/グラフDBに重複させないことで、チューニングのたびの更新漏れを構造的に防ぐ。',
  consequences: 'card.tsのCARD_COSTS的な定数はcards/*.tsから外れjson側に移る。constants.tsのPOC_STAGEはGLOBAL_RULESに改名され、WORKING_DAYS等ステージ固有の重複値は削除される（poc-01.tsが唯一の情報源になる）。バランスパラメータ.md・カード/*.md・イベント/*.mdの数値表記は撤去しJSON参照に置き換える。新規依存としてzod（MIT）を追加する。'
});
MATCH (adr:ADR {id: 'ADR-022'}), (adr19:ADR {id: 'ADR-019'}) MERGE (adr)-[:REFINES]->(adr19);
MATCH (adr:ADR {id: 'ADR-022'}), (adr18:ADR {id: 'ADR-018'}) MERGE (adr)-[:REFINES]->(adr18);
MATCH (adr:ADR {id: 'ADR-022'}), (ps:Concept {name: 'PreloadScene'}) MERGE (adr)-[:AFFECTS]->(ps);
MATCH (adr:ADR {id: 'ADR-022'}), (gr:Concept {name: 'GLOBAL_RULES'}) MERGE (adr)-[:AFFECTS]->(gr);
MATCH (adr:ADR {id: 'ADR-022'}), (reg:Concept {name: 'CARD_REGISTRY'}) MERGE (adr)-[:AFFECTS]->(reg);
MATCH (adr:ADR {id: 'ADR-022'}), (reg:Concept {name: 'EVENT_REGISTRY'}) MERGE (adr)-[:AFFECTS]->(reg);
MATCH (adr:ADR {id: 'ADR-022'}), (reg:Concept {name: 'STAGE_REGISTRY'}) MERGE (adr)-[:AFFECTS]->(reg);
MATCH (adr:ADR {id: 'ADR-022'}), (d:Document {name: 'Spec-15 design'}) MERGE (adr)-[:AFFECTS]->(d);

// =============================================================================
// Spec-15 /speckit-specify: spec.md
// =============================================================================
MERGE (:Document {name: 'Spec-15 spec.md', path: 'specs/015-json-data-externalization/spec.md', type: 'spec', spec: 'Spec-15',
  description: 'カード・イベント・ステージ・バランス係数のJSON外部化の仕様。US1バランス調整担当者がビルド不要で数値調整・US2起動時のスキーマ検証・US3docs/グラフDBに数値を残さない方針。',
  status: 'draft', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-15 checklists/requirements.md', path: 'specs/015-json-data-externalization/checklists/requirements.md', type: 'checklist', spec: 'Spec-15',
  status: 'completed', created: '2026-08-14'});
MATCH (s15:Document {name: 'Spec-15: カード・イベント・ステージ・バランス係数のJSON外部化'}), (spec:Document {name: 'Spec-15 spec.md'})
MERGE (s15)-[:HAS_SPEC]->(spec);
MATCH (design:Document {name: 'Spec-15 design'}), (spec:Document {name: 'Spec-15 spec.md'})
MERGE (design)-[:INFORMS]->(spec);

// =============================================================================
// Spec-15 /speckit-plan: plan.md + research.md + data-model.md + contracts + quickstart.md
// =============================================================================
MERGE (:Document {name: 'Spec-15 plan.md', path: 'specs/015-json-data-externalization/plan.md', type: 'plan', spec: 'Spec-15',
  description: 'Constitution Check全項目PASS。JSON読み込みはsrc/scenes/PreloadSceneに置きsrc/game/はgetConfig()経由で参照する設計。zod（MIT）を新規依存として追加。',
  status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-15 research.md', path: 'specs/015-json-data-externalization/research.md', type: 'research', spec: 'Spec-15', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-15 data-model.md', path: 'specs/015-json-data-externalization/data-model.md', type: 'data-model', spec: 'Spec-15', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-15 contracts/json-schema-contracts.md', path: 'specs/015-json-data-externalization/contracts/json-schema-contracts.md', type: 'contracts', spec: 'Spec-15', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-15 quickstart.md', path: 'specs/015-json-data-externalization/quickstart.md', type: 'quickstart', spec: 'Spec-15', status: 'completed', created: '2026-08-14'});
MATCH (s15:Document {name: 'Spec-15: カード・イベント・ステージ・バランス係数のJSON外部化'}), (plan:Document {name: 'Spec-15 plan.md'})
MERGE (s15)-[:HAS_PLAN]->(plan);

MERGE (:Concept {name: 'GameConfig', description: 'PreloadSceneが起動時に一度だけinitGameConfig()で確定させる設定シングルトン。constants.tsの静的importを置き換える（設計のみ、未実装）', file: 'src/game/config.ts', spec: 'Spec-15'});

// ADR-023: constants.tsの静的import参照をGameConfigシングルトンに置き換える
MERGE (:ADR {
  id: 'ADR-023',
  title: 'constants.tsの静的importをGameConfigシングルトン経由の参照に置き換える',
  date: '2026-08-14',
  status: 'accepted',
  context: 'ADR-022でバランス係数をJSON化する方針を決めたが、現状constants.tsは11ファイル（balance.ts/dice.ts/gantt.ts/member.ts/turn.ts/engine.ts/events/index.ts/events/stall.ts/cards/commendation.ts/cards/one-on-one.ts/cards/planned-leave.ts）からモジュールレベルの静的定数として直接importされており、JSON化すると値が起動時にしか手に入らないためこれらの参照方法を変える必要があった。',
  decision: 'src/game/config.tsに設定シングルトンを置く。initGameConfig(data)をPreloadSceneが起動時に1回だけ呼び、以降src/game/内の各関数はgetConfig().balance.Xの形で参照する。各関数のシグネチャ（引数）は変更しない。constants.tsは削除し、型はzodスキーマ（src/game/schemas/balanceConstants.ts）からz.infer<>で導出する唯一の情報源にする。',
  rationale: '完全な依存性注入（全関数の引数にテーブルを渡す）は11ファイル・数十箇所の呼び出しシグネチャ変更を要し本Specの規模に対して過大なため却下。起動時に1回だけ設定される読み取り専用シングルトンは、既存のconstants.tsが持っていた「不変なグローバル値」という性質を大きく損なわずに済む。',
  consequences: 'src/game/config.tsが新規ファイルとして追加される。11ファイルのimport文と参照箇所がgetConfig()経由に変わる。テストはbeforeEachでinitGameConfig(テスト用データ)を呼ぶ必要がある。'
});
MATCH (adr:ADR {id: 'ADR-023'}), (gc:Concept {name: 'GameConfig'}) MERGE (adr)-[:AFFECTS]->(gc);
MATCH (adr:ADR {id: 'ADR-023'}), (p:Document {name: 'Spec-15 plan.md'}) MERGE (adr)-[:AFFECTS]->(p);
MATCH (adr:ADR {id: 'ADR-023'}), (prev:ADR {id: 'ADR-022'}) MERGE (adr)-[:REFINES]->(prev);

// =============================================================================
// Spec-15 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-15 tasks.md', path: 'specs/015-json-data-externalization/tasks.md', type: 'tasks', spec: 'Spec-15',
  description: 'T001〜T044、6フェーズ（Setup→Foundational(zodスキーマ+config.ts)→US1(JSON外部化本体)→US2(検証E2E)→US3(docs整理)→Polish）。BootScene→PreloadScene→MainSceneの順に接続（Spec-14未実装のためTitleScene代わりにMainSceneへ遷移）。',
  status: 'completed', created: '2026-08-14'});
MATCH (s15:Document {name: 'Spec-15: カード・イベント・ステージ・バランス係数のJSON外部化'}), (t:Document {name: 'Spec-15 tasks.md'})
MERGE (s15)-[:HAS_TASKS]->(t);
MATCH (plan:Document {name: 'Spec-15 plan.md'}), (t:Document {name: 'Spec-15 tasks.md'})
MERGE (plan)-[:INFORMS]->(t);

// =============================================================================
// Spec-15 /speckit-implement 完了
// =============================================================================
MATCH (n:Document {name: 'Spec-15: カード・イベント・ステージ・バランス係数のJSON外部化'}) SET n.status = 'implemented';
MATCH (n:Document {name: 'Spec-15 tasks.md'}) SET n.status = 'completed';

MERGE (:Document {name: 'Spec-15 implement結果', path: 'specs/015-json-data-externalization/tasks.md',
  type: 'implementation-summary', spec: 'Spec-15',
  description: 'public/data/配下に43ファイル（カード26・イベント15・ステージ1・バランス1）。zodスキーマ4種、config.tsシングルトン、PreloadScene新規（BootScene→PreloadScene→MainScene）。cards/events/stages/index.tsはinit/getパターンに変更。constants.ts削除、11+1ファイルがgetConfig()経由に移行。docs側はバランスパラメータ.md・カード/*.mdから具体的数値を除去しJSON参照に置換。',
  status: 'completed', tests: 332, e2e_tests: 44, coverage_lines: 94.08, coverage_branches: 89.41, coverage_funcs: 100,
  created: '2026-08-14'});
MATCH (s15:Document {name: 'Spec-15: カード・イベント・ステージ・バランス係数のJSON外部化'}), (r:Document {name: 'Spec-15 implement結果'})
MERGE (s15)-[:HAS_RESULT]->(r);

MATCH (n:Concept {name: 'PreloadScene'}) SET n.status = 'implemented';
MATCH (n:Concept {name: 'GameConfig'}) SET n.status = 'implemented';
MATCH (n:Concept {name: 'GLOBAL_RULES'}) SET n.status = 'implemented';
MATCH (n:Concept {name: 'CARD_REGISTRY'}) SET n.status = 'superseded', n.description = n.description + '（Spec-15でinitCardRegistry()/getCardRegistry()関数に変更）';
MATCH (n:Concept {name: 'EVENT_REGISTRY'}) SET n.status = 'superseded', n.description = n.description + '（Spec-15でinitEventRegistry()/getEventRegistry()関数に変更）';
MATCH (n:Concept {name: 'STAGE_REGISTRY'}) SET n.status = 'superseded', n.description = n.description + '（Spec-15でinitStageRegistry()/getStage()関数に変更）';
MATCH (n:Concept {name: 'pocStage'}) SET n.status = 'superseded', n.description = n.description + '（Spec-15でpoc-01.tsは削除。データはpublic/data/stages/poc-01.jsonに移動）';

// Parameterノードの数値プロパティをjsonPathに置き換える（ADR-022）
MATCH (p:Parameter {name: '技'}) SET p.min = null, p.max = null, p.jsonPath = 'public/data/balance/constants.json の MEMBER_PARAMS.SKILL';
MATCH (p:Parameter {name: '心'}) SET p.min = null, p.max = null, p.jsonPath = 'public/data/balance/constants.json の MEMBER_PARAMS.MORALE';
MATCH (p:Parameter {name: '体'}) SET p.min = null, p.max = null, p.jsonPath = 'public/data/balance/constants.json の MEMBER_PARAMS.HEALTH';
MATCH (p:Parameter {name: '透明性'}) SET p.initialValue = null, p.range = null, p.jsonPath = 'public/data/balance/constants.json の MEMBER_PARAMS.TRANSPARENCY';
MATCH (p:Parameter {name: '緊張感'}) SET p.initialValue = null, p.range = null, p.jsonPath = 'public/data/balance/constants.json の MEMBER_PARAMS.TENSION';
MATCH (p:Parameter {name: '経験値'}) SET p.jsonPath = 'public/data/balance/constants.json の EXP';

// =============================================================================
// Spec-14 設計ドキュメント更新（Spec-13/15後の実コード状態＋ADR-020確認画面を反映）
// =============================================================================
MATCH (d:Document {name: 'Spec-14 design'})
SET d.description = 'BootScene→PreloadScene→TitleScene→StageSelectScene→MainSceneの画面遷移設計。StageSelectUIは一覧表示/確認表示の2状態を持ち、確認表示でプロジェクト概要・予算・目標利益率（GLOBAL_RULES.TARGET_PROFIT_RATE、率のみ）を表示しYES/NOを問う。StageDataにdescriptionフィールドを追加。MainSceneはgetStage(stageId)経由でステージデータを取得する形に変更。';

MERGE (:ADR {
  id: 'ADR-024',
  title: 'Spec-14設計をSpec-13/15後の実コード状態（PreloadScene・getStage()レジストリ）に合わせて更新する',
  date: '2026-08-14',
  status: 'accepted',
  context: 'Spec-14の設計ドキュメントは2026-08-14の会話冒頭（Spec-13/15着手前）に書かれたもので、当時の想定は「BootScene→TitleScene→StageSelectScene→MainScene」かつ「MainSceneはinit(data: {stage: StageData})でStageData本体を直接受け取る」という設計だった。その後Spec-13でステージがpoc-01.tsに、Spec-15でPreloadScene＋getStage()レジストリ方式に変わり、実際のScene構成・データ受け渡し方法が設計ドキュメントと食い違っていた。また、会話の中盤で決まったステージ確認画面（ADR-020: プロジェクト概要・予算・目標利益率を表示しYES/NOを問う）もまだ設計ドキュメントに反映されていなかった。',
  decision: '設計ドキュメントを実際のコード状態に合わせて全面更新した。Scene遷移をBootScene→PreloadScene→TitleScene→StageSelectScene→MainSceneに修正。MainSceneはinit(data: {stageId: string})でidのみを受け取りgetStage(stageId)でStageDataを取得する形に変更（StageData本体のScene間受け渡しは行わない）。StageDataにdescriptionフィールドを追加し、stageDataSchema（Spec-15のzodスキーマ）・poc-01.jsonにも反映する。ADR-020の確認画面仕様（プロジェクト概要・予算・目標利益率の表示、率のみで具体金額は非表示）をStageSelectUIの2状態設計として明記した。',
  rationale: '設計ドキュメントが実装と食い違ったまま/speckit-specifyに進むと、仕様書生成時に誤った前提（古いScene構成）が混入するため、着手前に実コード状態との整合を取る必要があった。',
  consequences: 'Spec-14の実装ではStageData型定義・zodスキーマ・poc-01.jsonの3箇所にdescriptionフィールドを追加する作業が発生する（Spec-15のJSON外部化後のフローに従う）。'
});
MATCH (adr:ADR {id: 'ADR-024'}), (d:Document {name: 'Spec-14 design'}) MERGE (adr)-[:AFFECTS]->(d);
MATCH (adr:ADR {id: 'ADR-024'}), (prev:ADR {id: 'ADR-020'}) MERGE (adr)-[:REFINES]->(prev);
MATCH (adr:ADR {id: 'ADR-024'}), (ps:Concept {name: 'PreloadScene'}) MERGE (adr)-[:AFFECTS]->(ps);
MATCH (adr:ADR {id: 'ADR-024'}), (sr:Concept {name: 'STAGE_REGISTRY'}) MERGE (adr)-[:AFFECTS]->(sr);

// =============================================================================
// Spec-14 /speckit-specify: spec.md
// =============================================================================
MERGE (:Document {name: 'Spec-14 spec.md', path: 'specs/016-title-stage-select/spec.md', type: 'spec', spec: 'Spec-14',
  description: 'タイトル〜ステージセレクト画面遷移の仕様。US1タイトルからのゲーム開始・US2ステージ確認画面（プロジェクト概要・予算・目標利益率を率のみ表示、YES/NO）。FR9件・SC3件。',
  status: 'draft', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-14 checklists/requirements.md', path: 'specs/016-title-stage-select/checklists/requirements.md', type: 'checklist', spec: 'Spec-14',
  status: 'completed', created: '2026-08-14'});
MATCH (s14:Document {name: 'Spec-14: タイトル〜ステージセレクト画面遷移'}), (spec:Document {name: 'Spec-14 spec.md'})
MERGE (s14)-[:HAS_SPEC]->(spec);
MATCH (design:Document {name: 'Spec-14 design'}), (spec:Document {name: 'Spec-14 spec.md'})
MERGE (design)-[:INFORMS]->(spec);

// =============================================================================
// Spec-14 /speckit-plan: plan.md + research.md + data-model.md + contracts + quickstart.md
// =============================================================================
MERGE (:Document {name: 'Spec-14 plan.md', path: 'specs/016-title-stage-select/plan.md', type: 'plan', spec: 'Spec-14',
  description: 'Constitution Check全項目PASS。TitleScene/StageSelectSceneをsrc/scenes/に、TitleUI/StageSelectUIをsrc/ui/に追加。MainSceneはinit(data:{stageId})に変更。StageDataにdescription追加（types.ts/stageDataSchema/poc-01.jsonの3箇所）。',
  status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-14 research.md', path: 'specs/016-title-stage-select/research.md', type: 'research', spec: 'Spec-14', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-14 data-model.md', path: 'specs/016-title-stage-select/data-model.md', type: 'data-model', spec: 'Spec-14', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-14 contracts/ui-contracts.md', path: 'specs/016-title-stage-select/contracts/ui-contracts.md', type: 'contracts', spec: 'Spec-14', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-14 quickstart.md', path: 'specs/016-title-stage-select/quickstart.md', type: 'quickstart', spec: 'Spec-14', status: 'completed', created: '2026-08-14'});
MATCH (s14:Document {name: 'Spec-14: タイトル〜ステージセレクト画面遷移'}), (plan:Document {name: 'Spec-14 plan.md'})
MERGE (s14)-[:HAS_PLAN]->(plan);

MATCH (n:Concept {name: 'TitleScene'}) SET n.status = 'planned';
MATCH (n:Concept {name: 'StageSelectScene'}) SET n.status = 'planned';

// =============================================================================
// Spec-14 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-14 tasks.md', path: 'specs/016-title-stage-select/tasks.md', type: 'tasks', spec: 'Spec-14',
  description: 'T001〜T021、4フェーズ（Setup→US1タイトル+一覧→US2確認画面+ゲーム開始→Polish）。',
  status: 'completed', created: '2026-08-14'});
MATCH (s14:Document {name: 'Spec-14: タイトル〜ステージセレクト画面遷移'}), (t:Document {name: 'Spec-14 tasks.md'})
MERGE (s14)-[:HAS_TASKS]->(t);
MATCH (plan:Document {name: 'Spec-14 plan.md'}), (t:Document {name: 'Spec-14 tasks.md'})
MERGE (plan)-[:INFORMS]->(t);

// =============================================================================
// Spec-14 /speckit-implement 完了
// =============================================================================
MATCH (n:Document {name: 'Spec-14: タイトル〜ステージセレクト画面遷移'}) SET n.status = 'implemented';
MATCH (n:Document {name: 'Spec-14 tasks.md'}) SET n.status = 'completed';
MATCH (n:Concept {name: 'TitleScene'}) SET n.status = 'implemented';
MATCH (n:Concept {name: 'StageSelectScene'}) SET n.status = 'implemented';

MERGE (:Document {name: 'Spec-14 implement結果', path: 'specs/016-title-stage-select/tasks.md',
  type: 'implementation-summary', spec: 'Spec-14',
  description: 'TitleScene/StageSelectScene新規（src/scenes/）、TitleUI/StageSelectUI新規（src/ui/）。StageDataにdescription追加（types.ts/stageDataSchema/poc-01.json）。MainSceneはinit(data:{stageId})経由でgetStage()解決に変更。既存E2E4ファイルを新遷移フロー対応に更新（tests/e2e/helpers.tsのstartGame()を共通化）。',
  status: 'completed', tests: 332, e2e_tests: 54, coverage_lines: 94.08, coverage_branches: 89.41, coverage_funcs: 100,
  created: '2026-08-14'});
MATCH (s14:Document {name: 'Spec-14: タイトル〜ステージセレクト画面遷移'}), (r:Document {name: 'Spec-14 implement結果'})
MERGE (s14)-[:HAS_RESULT]->(r);

// =============================================================================
// Phase 10: 週モデル変更 の設計セッション（brainstorming）
// =============================================================================

MERGE (:Document {name: 'Spec-16 design', path: 'docs/superpowers/specs/2026-08-14-week-model-redesign.md',
  type: 'design-doc', spec: 'Spec-16',
  description: 'ターン＝暦日（月曜始まり・7ターン周期）への変更。turn.tsの進捗ダイス土日スキップ・週末回復判定変更。休出（土）・休出（日）カード新規（1枚=メンバー1人分、効果はその週だけ）。カードに対象メンバーを指定できる仕組み（CardDefinitionにtargetId引数追加）とCardSlot/MainGameUIへの対象選択UIを新規追加。PoCステージのdeadline再校正（約30〜31ターン）。',
  status: 'draft', created: '2026-08-14'});

MERGE (:Document {name: 'Spec-16: 週モデル変更', path: 'docs/sdd-tasks.md',
  type: 'spec-entry', spec: 'Spec-16', status: 'planned', created: '2026-08-14'});
MATCH (s16:Document {name: 'Spec-16: 週モデル変更'}), (d:Document {name: 'Spec-16 design'})
MERGE (s16)-[:HAS_DESIGN]->(d);

MERGE (:Document {name: 'Spec-17: docsガントチャート表記見直し', path: 'docs/sdd-tasks.md',
  type: 'spec-entry', spec: 'Spec-17', status: 'planned', created: '2026-08-14',
  description: 'docs/03-詳細設計/ステージ配下のガントチャート表記を、日付列（ターン+暦日）が並ぶカレンダー形式に見直す。Spec-16（週モデル変更）に依存。'});
MERGE (:Document {name: 'Spec-18: ゲーム内ガントチャートUI', path: 'docs/sdd-tasks.md',
  type: 'spec-entry', spec: 'Spec-18', status: 'planned', created: '2026-08-14',
  description: 'ゲーム内に予定/実績2行＋稲妻線を持つガントチャート表示UIを新規実装する。Spec-16・Spec-17に依存。'});
MATCH (s16:Document {name: 'Spec-16: 週モデル変更'}), (s17:Document {name: 'Spec-17: docsガントチャート表記見直し'}) MERGE (s17)-[:DEPENDS_ON]->(s16);
MATCH (s16:Document {name: 'Spec-16: 週モデル変更'}), (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}) MERGE (s18)-[:DEPENDS_ON]->(s16);
MATCH (s17:Document {name: 'Spec-17: docsガントチャート表記見直し'}), (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}) MERGE (s18)-[:DEPENDS_ON]->(s17);

MERGE (:Concept {name: 'isWeekend', description: '曜日判定ヘルパー。ターン番号から月曜始まり7ターン周期で土日を判定する（設計のみ、未実装）', file: 'src/game/calendar.ts', spec: 'Spec-16'});
MERGE (:Concept {name: 'HolidayWorkSat', description: '休出（土）カード。1枚=メンバー1人分。対象は使用時にプレイヤーが選択（設計のみ、未実装）', file: 'src/game/cards/holiday-work-sat.ts', spec: 'Spec-16'});
MERGE (:Concept {name: 'HolidayWorkSun', description: '休出（日）カード。1枚=メンバー1人分。対象は使用時にプレイヤーが選択（設計のみ、未実装）', file: 'src/game/cards/holiday-work-sun.ts', spec: 'Spec-16'});

// ADR-025: ターン＝暦日への変更と休出カードの対象選択UI導入
MERGE (:ADR {
  id: 'ADR-025',
  title: 'ターン＝暦日（7ターン周期）に変更し、休出カードに対象選択UIを導入する',
  date: '2026-08-14',
  status: 'accepted',
  context: 'docs/03-詳細設計/ステージのガントチャート表記を一般的なガントチャート（日付列・土日非表示）に見直す作業がきっかけで、現状のturn.tsが「5ターン=1週間、土日はターンを消費しない」前提（進捗ダイスは全ターンで無条件に実行、週末回復はturn%5==0で判定）であることが判明した。一方、休出カードは「土日を稼働ターンに変換する」という設計意図（メンバー.mdに記載）があり、土日がターン番号を持たない前提とは矛盾していた。また、ターン処理フロー.mdに書かれた固定イベント判定（キックオフ・週次進捗会議・締め・クロージング）は実装が存在しないことも判明した。',
  decision: 'ターン＝暦日（土日もターン番号を持つ）とし、週の起点を月曜とする（ターン1=月曜、6=土、7=日）。画面表示は「ターン」ではなく「◯日目」と表現する。turn.tsの進捗ダイスは土日をスキップし（休出の対象になっている場合を除く）、週末回復の判定を7ターン周期の実際の週境界に基づく判定に変更する。休出は土日で別カード「休出（土）」「休出（日）」とし、1枚=メンバー1人分、効果は使用した週だけとする。休出の対象メンバーはプレイヤーが使用時に選択できるようにする（既存のどのカードにも対象選択の仕組みがなかったため、CardDefinitionにtargetId引数を追加し、CardSlot/MainGameUIに対象選択UIを新規実装する）。既存の個別面談・表彰・計画休（state.members[0]固定）は今回リトロフィットしない。PoCステージの締切は実働日数（22日相当）を維持するため約30〜31ターンに再校正する（具体値はテストプレイ後のバランス調整）。固定イベント判定の実装は本Specのスコープ外とする。',
  rationale: '休出カードの設計意図（土日を稼働可能にする）を成立させるには土日がターンとして存在する必要があるため。対象選択の仕組みは休出カード専用の使い捨て実装にせず、CardDefinitionインターフェースレベルで汎用的に追加することで将来の対象指定カードにも再利用できるようにした。既存カードのリトロフィットは本Specの目的（週モデル整合性の確保）に対して余分なスコープ拡大となるため見送った。',
  consequences: 'turn.ts・cards/index.ts・CardSlot.ts・MainGameUI.ts・types.ts（CardName）・poc-01.json・関連docsの広範な変更が必要になる。既存のturn.test.ts等は新しい週モデルに合わせて更新が必要。固定イベント（キックオフ等）は引き続き未実装のまま残る。'
});
MATCH (adr:ADR {id: 'ADR-025'}), (iw:Concept {name: 'isWeekend'}) MERGE (adr)-[:AFFECTS]->(iw);
MATCH (adr:ADR {id: 'ADR-025'}), (hs:Concept {name: 'HolidayWorkSat'}) MERGE (adr)-[:AFFECTS]->(hs);
MATCH (adr:ADR {id: 'ADR-025'}), (hu:Concept {name: 'HolidayWorkSun'}) MERGE (adr)-[:AFFECTS]->(hu);
MATCH (adr:ADR {id: 'ADR-025'}), (d:Document {name: 'Spec-16 design'}) MERGE (adr)-[:AFFECTS]->(d);

// =============================================================================
// Spec-16 /speckit-specify: spec.md
// =============================================================================
MERGE (:Document {name: 'Spec-16 spec.md', path: 'specs/017-week-model-redesign/spec.md', type: 'spec', spec: 'Spec-16',
  description: '週モデル変更の仕様。US1土日は通常稼働しない・US2休日出勤カードで対象選択。FR9件・SC4件。',
  status: 'draft', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-16 checklists/requirements.md', path: 'specs/017-week-model-redesign/checklists/requirements.md', type: 'checklist', spec: 'Spec-16',
  status: 'completed', created: '2026-08-14'});
MATCH (s16:Document {name: 'Spec-16: 週モデル変更'}), (spec:Document {name: 'Spec-16 spec.md'})
MERGE (s16)-[:HAS_SPEC]->(spec);
MATCH (design:Document {name: 'Spec-16 design'}), (spec:Document {name: 'Spec-16 spec.md'})
MERGE (design)-[:INFORMS]->(spec);

// =============================================================================
// Spec-16 /speckit-plan: plan.md + research.md + data-model.md + contracts + quickstart.md
// =============================================================================
MERGE (:Document {name: 'Spec-16 plan.md', path: 'specs/017-week-model-redesign/plan.md', type: 'plan', spec: 'Spec-16',
  description: 'Constitution Check全項目PASS。calendar.ts新規、turn.ts変更、休出（土）/（日）カード（コスト暫定2）、対象選択UI、poc-01.jsonの締切を22→30ターンに再校正。',
  status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-16 research.md', path: 'specs/017-week-model-redesign/research.md', type: 'research', spec: 'Spec-16', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-16 data-model.md', path: 'specs/017-week-model-redesign/data-model.md', type: 'data-model', spec: 'Spec-16', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-16 contracts/calendar-and-targeting-contracts.md', path: 'specs/017-week-model-redesign/contracts/calendar-and-targeting-contracts.md', type: 'contracts', spec: 'Spec-16', status: 'completed', created: '2026-08-14'});
MERGE (:Document {name: 'Spec-16 quickstart.md', path: 'specs/017-week-model-redesign/quickstart.md', type: 'quickstart', spec: 'Spec-16', status: 'completed', created: '2026-08-14'});
MATCH (s16:Document {name: 'Spec-16: 週モデル変更'}), (plan:Document {name: 'Spec-16 plan.md'})
MERGE (s16)-[:HAS_PLAN]->(plan);

// =============================================================================
// Spec-16 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-16 tasks.md', path: 'specs/017-week-model-redesign/tasks.md', type: 'tasks', spec: 'Spec-16',
  description: 'T001〜T034、5フェーズ（Setup→Foundational(calendar.ts+対象選択基盤)→US1+US2統合実装(週末スキップ+休出カード+対象選択UI)→docs更新→Polish）。',
  status: 'completed', created: '2026-08-14'});
MATCH (s16:Document {name: 'Spec-16: 週モデル変更'}), (t:Document {name: 'Spec-16 tasks.md'})
MERGE (s16)-[:HAS_TASKS]->(t);
MATCH (plan:Document {name: 'Spec-16 plan.md'}), (t:Document {name: 'Spec-16 tasks.md'})
MERGE (plan)-[:INFORMS]->(t);

// =============================================================================
// Spec-16 /speckit-implement 完了
// =============================================================================
MATCH (n:Document {name: 'Spec-16: 週モデル変更'}) SET n.status = 'implemented';
MATCH (n:Document {name: 'Spec-16 tasks.md'}) SET n.status = 'completed';

MERGE (:Document {name: 'Spec-16 implement結果', path: 'specs/017-week-model-redesign/tasks.md',
  type: 'implementation-summary', spec: 'Spec-16',
  description: 'src/game/calendar.tsを新規追加（dayOfWeek/isWeekend、月曜起点7ターン周期）。休出カードを休出（土）/休出（日）の2枚（各cost=2、1枚=メンバー1人分）に分割し、CardDefinitionにrequiresTarget?/applyEffect(state, targetId?)を追加。applyCards/processTurnのシグネチャを CardName[] から {name: CardName; targetId?: string}[] に変更。CardSlot.tsに対象メンバー保持、MainGameUI.tsに対象選択オーバーレイ（data-testid=target-picker）を新規実装。turn.tsの進捗ダイスは土日をスキップ（対象になっている場合を除く）、週末回復をturn%7===0に変更。ヘッダー表示を「ターンN」から「N日目」に変更。poc-01.jsonのdeadlineを22→30、conditionalEventsのターン番号を再校正、initialCardsに休出2種を追加（手札の再抽選機構が存在しないため静的追加が必要だった＝Spec-19で解消予定）。',
  status: 'completed', tests: 358, e2e_tests: 29, coverage_lines: 94.37, coverage_branches: 90.52, coverage_funcs: 100,
  created: '2026-08-14'});
MATCH (s16:Document {name: 'Spec-16: 週モデル変更'}), (r:Document {name: 'Spec-16 implement結果'})
MERGE (s16)-[:HAS_RESULT]->(r);

MATCH (n:Concept {name: 'isWeekend'}) SET n.status = 'implemented', n.description = '曜日判定ヘルパー。ターン番号から月曜始まり7ターン周期で土日を判定する';
MATCH (n:Concept {name: 'HolidayWorkSat'}) SET n.status = 'implemented', n.description = '休出（土）カード。1枚=メンバー1人分。対象は使用時にプレイヤーが選択する（CardSlot.setTarget/MainGameUIのtarget-pickerオーバーレイ経由）';
MATCH (n:Concept {name: 'HolidayWorkSun'}) SET n.status = 'implemented', n.description = '休出（日）カード。1枚=メンバー1人分。対象は使用時にプレイヤーが選択する（CardSlot.setTarget/MainGameUIのtarget-pickerオーバーレイ経由）';

// ADR-026: 手札の静的性（再抽選機構の不在）の発見と暫定対応
MERGE (:ADR {
  id: 'ADR-026',
  title: 'カード再抽選機構が存在しないためinitialCardsへの静的追加で暫定対応し、恒久対応はSpec-19にバックログ化する',
  date: '2026-08-14',
  status: 'accepted',
  context: 'Spec-16実装中、state.handはGameEngine構築時にstageData.initialCardsから一度だけ設定され、以降ターン経過やイベントで再抽選・補充される仕組みが存在しないことが判明した。休出（土）（日）カードをpoc-01.jsonのinitialCardsに追加しない限り、これらのカードはプレイヤーが永久に入手できず機能として到達不能になる。',
  decision: '当面の対応としてpoc-01.jsonのinitialCardsに休出（土）（日）を追加し、既存の静的手札の枠内で到達可能にする。カードを手札に組み込む（ドロー・補充）機能そのものの実装はSpec-16のスコープ外とし、docs/sdd-tasks.mdにSpec-19としてバックログ化する。',
  rationale: 'Spec-16の目的は週モデル整合性の確保であり、手札管理機構の新規設計・実装まで含めるとスコープが大きく膨らむ。initialCardsへの追加は既存の仕組みの範囲内での最小限の修正であり、機能的な到達可能性を確保する上で必須の対応（スコープ拡大ではなく基本的な動作保証）と判断した。',
  consequences: '当面、ステージ定義者は新規カードを必ずinitialCardsに含める必要がある（手動運用でカバー）。Spec-19実装後はこの制約が解消される見込み。'
});
MATCH (adr:ADR {id: 'ADR-026'}), (hs:Concept {name: 'HolidayWorkSat'}) MERGE (adr)-[:AFFECTS]->(hs);
MATCH (adr:ADR {id: 'ADR-026'}), (hu:Concept {name: 'HolidayWorkSun'}) MERGE (adr)-[:AFFECTS]->(hu);

MERGE (:Document {name: 'Spec-19: カード選択・手札への組み込み機能', path: 'docs/sdd-tasks.md', type: 'spec-entry', spec: 'Spec-19',
  description: '現状state.handはステージ開始時の固定配列で、ターン経過による再抽選・補充の仕組みが存在しない。Spec-16で追加した休出カード等、initialCardsに含めない限り到達不能になる制約を解消するためのバックログSpec（未着手）。',
  status: 'backlog', created: '2026-08-14'});
MATCH (adr:ADR {id: 'ADR-026'}), (s19:Document {name: 'Spec-19: カード選択・手札への組み込み機能'}) MERGE (adr)-[:AFFECTS]->(s19);

// =============================================================================
// Spec-17 /speckit-specify: spec.md（brainstorming skillのbounded pathで
// この会話内で設計合意。docs/superpowers/specs/への設計ドキュメントは作成せず、
// 会話内合意を直接spec.mdに反映した）
// =============================================================================
MERGE (:Document {name: 'Spec-17 spec.md', path: 'specs/018-gantt-calendar-notation/spec.md', type: 'spec', spec: 'Spec-17',
  description: 'docsガントチャート表記見直しの仕様。US1カレンダー列形式で一望・US2ヘッダー/条件付きイベントの実データ整合。FR11件・SC3件。1枚の表、列見出しは「ターン番号(曜日)」形式、セルは■(平日稼働)/・(土日で期間内だが非稼働)/空欄(期間外)の3値。',
  status: 'draft', created: '2026-08-16'});
MERGE (:Document {name: 'Spec-17 checklists/requirements.md', path: 'specs/018-gantt-calendar-notation/checklists/requirements.md', type: 'checklist', spec: 'Spec-17',
  status: 'completed', created: '2026-08-16'});
MATCH (s17:Document {name: 'Spec-17: docsガントチャート表記見直し'}), (spec:Document {name: 'Spec-17 spec.md'})
MERGE (s17)-[:HAS_SPEC]->(spec);

// =============================================================================
// Spec-17 /speckit-plan: plan.md + research.md + data-model.md + quickstart.md
// （contracts/なし。外部インターフェースを持たない純粋なdocs編集のため）
// =============================================================================
MERGE (:Document {name: 'Spec-17 plan.md', path: 'specs/018-gantt-calendar-notation/plan.md', type: 'plan', spec: 'Spec-17',
  description: 'Constitution Check全項目PASS（src/変更なし、テスト・バランス影響なし）。docs/03-詳細設計/ステージ/PoCステージ01.mdのみを対象とする純粋なMarkdown編集。',
  status: 'completed', created: '2026-08-16'});
MERGE (:Document {name: 'Spec-17 research.md', path: 'specs/018-gantt-calendar-notation/research.md', type: 'research', spec: 'Spec-17', status: 'completed', created: '2026-08-16'});
MERGE (:Document {name: 'Spec-17 data-model.md', path: 'specs/018-gantt-calendar-notation/data-model.md', type: 'data-model', spec: 'Spec-17', status: 'completed', created: '2026-08-16'});
MERGE (:Document {name: 'Spec-17 quickstart.md', path: 'specs/018-gantt-calendar-notation/quickstart.md', type: 'quickstart', spec: 'Spec-17', status: 'completed', created: '2026-08-16'});
MATCH (s17:Document {name: 'Spec-17: docsガントチャート表記見直し'}), (plan:Document {name: 'Spec-17 plan.md'})
MERGE (s17)-[:HAS_PLAN]->(plan);
MATCH (spec:Document {name: 'Spec-17 spec.md'}), (plan:Document {name: 'Spec-17 plan.md'})
MERGE (spec)-[:INFORMS]->(plan);

// =============================================================================
// Spec-17 /speckit-tasks: tasks.md
// =============================================================================
MERGE (:Document {name: 'Spec-17 tasks.md', path: 'specs/018-gantt-calendar-notation/tasks.md', type: 'tasks', spec: 'Spec-17',
  description: 'T001〜T012、5フェーズ（Setup→Foundational(曜日列見出し算出)→US1(ガントチャート表のカレンダー列形式化)→US2(ヘッダー/条件付きイベントの実データ整合)→Polish）。',
  status: 'completed', created: '2026-08-16'});
MATCH (s17:Document {name: 'Spec-17: docsガントチャート表記見直し'}), (t:Document {name: 'Spec-17 tasks.md'})
MERGE (s17)-[:HAS_TASKS]->(t);
MATCH (plan:Document {name: 'Spec-17 plan.md'}), (t:Document {name: 'Spec-17 tasks.md'})
MERGE (plan)-[:INFORMS]->(t);

// =============================================================================
// Spec-17 /speckit-implement 完了
// =============================================================================
MATCH (n:Document {name: 'Spec-17: docsガントチャート表記見直し'}) SET n.status = 'implemented';
MATCH (n:Document {name: 'Spec-17 tasks.md'}) SET n.status = 'completed';

MERGE (:Document {name: 'Spec-17 implement結果', path: 'specs/018-gantt-calendar-notation/tasks.md',
  type: 'implementation-summary', spec: 'Spec-17',
  description: 'docs/03-詳細設計/ステージ/PoCステージ01.mdを全面更新。ガントチャート表を1枚・31列（タスク列+ターン1〜30列、列見出し「ターン番号(曜日)」形式）に書き換え、セルを■(平日稼働)/・(期間内だが土日で非稼働)/空欄(期間外)の3値で表現。ヘッダーテーブルの締切ターン(22→30)・初期カード(休出（土）（日）追加)・パス参照(src/game/stages/poc-01.ts→public/data/stages/poc-01.json)、条件付きイベント表のターン番号(5,12,16,22,24)をSpec-16後の実データに整合。Spec-13以降docsが未更新のまま乖離していた点を解消。src/配下のコード変更なし。',
  status: 'completed', created: '2026-08-16'});
MATCH (s17:Document {name: 'Spec-17: docsガントチャート表記見直し'}), (r:Document {name: 'Spec-17 implement結果'})
MERGE (s17)-[:HAS_RESULT]->(r);

MATCH (n:Concept {name: 'ガントチャート'})
SET n.description = coalesce(n.description, '') + '（Spec-17でdocs表記をカレンダー列形式に変更。列見出し「ターン番号(曜日)」、セルは■(平日稼働)/・(土日で非稼働)/空欄(期間外)の3値。実装は docs/03-詳細設計/ステージ/PoCステージ01.md）';

// =============================================================================
// セッションチェックポイント（2026-08-16）: Spec-16・17完了、Spec-18は未着手のまま中断
// =============================================================================
MATCH (n:Document {name: 'Spec-18: ゲーム内ガントチャートUI'})
SET n.status = 'planned',
    n.next_action = 'brainstorming skillのarchitectural pathで設計から開始する（新規UIサブシステムのため）。着手条件（Spec-16・17の実装・コミット完了）は満たしている。',
    n.checkpoint_date = '2026-08-16';

// =============================================================================
// Spec-18 /speckit-specify（2026-08-30）: ゲーム内ガントチャートUIの仕様確定
// ディレクトリは specs/019-in-game-gantt-ui/、グラフDB上は Spec-18（番号ずれは既存慣習を踏襲）
// =============================================================================

// spec-entry ノードの更新: planned → specified、description を Q1=B 確定内容に更新
MATCH (n:Document {name: 'Spec-18: ゲーム内ガントチャートUI'})
SET n.status = 'specified',
    n.description = 'ゲーム内に予定/実績2行＋稲妻線＋タスク選択による依存（先行タスク）のPERT的表示を持つガントチャート画面を新規実装する。Spec-16・Spec-17に依存。',
    n.next_action = '/speckit-plan で技術方針を確定する。稲妻線の折れ量算出方式・リスケ時の実績連続性の扱いを plan で決定する。',
    n.checkpoint_date = '2026-08-30';

// spec.md ノード
MERGE (:Document {name: 'Spec-18 spec.md', path: 'specs/019-in-game-gantt-ui/spec.md', type: 'spec', spec: 'Spec-18',
  description: 'ゲーム内ガントチャートUIの仕様。US1予定/実績2行＋稲妻線(P1)、US2実績(着手・完了ターン)確認(P2)、US3依存タスクのPERT的表示(P3)。FR13件・SC5件。閲覧専用。実績フィールド(着手・完了ターン)を新規保持。Out of Scopeにpert/EVM/リスク独立ビュー・直接編集・将来予測外挿を明記。',
  status: 'draft', created: '2026-08-30'});

// checklist ノード
MERGE (:Document {name: 'Spec-18 checklists/requirements.md', path: 'specs/019-in-game-gantt-ui/checklists/requirements.md', type: 'checklist', spec: 'Spec-18',
  description: '仕様品質チェックリスト。Content Quality・Requirement Completeness・Feature Readiness の全項目PASS。NEEDS CLARIFICATIONマーカー0件。',
  status: 'completed', created: '2026-08-30'});

MATCH (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}), (spec:Document {name: 'Spec-18 spec.md'})
MERGE (s18)-[:HAS_SPEC]->(spec);
MATCH (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}), (cl:Document {name: 'Spec-18 checklists/requirements.md'})
MERGE (s18)-[:HAS_CHECKLIST]->(cl);

// ADR-027: ゲーム内ガントチャートUIのスコープと実績データ保持方式
MERGE (:ADR {
  id: 'ADR-027',
  title: 'ゲーム内ガントチャートUIのスコープと実績データ保持方式',
  date: '2026-08-30',
  status: 'accepted',
  context: 'Spec-18は新規UIサブシステム。予定/実績2行＋稲妻線が中核だが、(a)依存タスク（PERT的情報）表示を含めるか、(b)実績（着手・完了ターン）をどう保持するか、(c)ディレクトリ番号とグラフDB Spec番号のずれ、の3点が未確定だった。現状のGanttTaskはstartTurn/duration/progress/statusのみを持ち実績を記録する仕組みがない。画面構成.mdは「PERT図は独立ビューを持たず、ガントのタスクから依存をたどる」方針。',
  decision: 'Q1=B: ガントチャート画面のスコープに「予定/実績2行＋稲妻線」に加えて「タスク選択による依存（先行タスク）のPERT的表示」を含める（画面構成.mdの方針を完全充足）。Q2=B: GanttTaskに実績フィールド（実際の着手ターン・完了ターン）を新たに記録・保持する。progressからの導出のみに頼らず着手/完了の時期を明示的に持つ。Q3=A: ディレクトリは019、グラフDB上はSpec-18として管理する（既存の番号ずれ慣習を踏襲）。',
  rationale: '依存表示は画面構成の既存方針（独立PERTビューを持たない）を満たすため同一画面に統合するのが自然で、別Specに切り出すと画面へ二度手を入れることになる。実績フィールドの明示保持は、稲妻線（予定対実績のずれ）と実績行（着手〜完了の帯）を正確に描くにはprogressだけでは情報不足（いつ着手したかはprogressから復元できない）なため。番号ずれは既にSpec-16/17で発生済みで、揃え直すと過去分との一貫性が崩れるため踏襲する。',
  consequences: 'planフェーズでGanttTask（types.ts）への実績フィールド追加、turn.ts/engine.tsでの着手・完了ターン記録、ガントチャート画面（src/ui/配下）の新規実装、MainGameUIからの画面切替導線が必要になる。稲妻線の折れ量の厳密な算出方式（進捗率ベース/残作業ベース）とリスケによる予定差し替え時の実績連続性はplanで確定する。依存表示を含めたことでUS3(P3)分のスコープが増える。'
});
MATCH (adr:ADR {id: 'ADR-027'}), (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}) MERGE (adr)-[:AFFECTS]->(s18);
MATCH (adr:ADR {id: 'ADR-027'}), (spec:Document {name: 'Spec-18 spec.md'}) MERGE (adr)-[:AFFECTS]->(spec);

// =============================================================================
// Spec-18 /speckit-plan（2026-08-30）: ゲーム内ガントチャートUIの技術方針確定
// =============================================================================

// spec-entry ノードの更新: specified → planned（Spec Kit上のplan完了）
MATCH (n:Document {name: 'Spec-18: ゲーム内ガントチャートUI'})
SET n.status = 'planned',
    n.next_action = '/speckit-tasks でタスク分解する。',
    n.checkpoint_date = '2026-08-30';

// plan 成果物ノード
MERGE (:Document {name: 'Spec-18 plan.md', path: 'specs/019-in-game-gantt-ui/plan.md', type: 'plan', spec: 'Spec-18',
  description: 'ゲーム内ガントチャートUIの実装計画。Constitution Check（Phase0前/Phase1後）全項目PASS。GanttTaskに実績2フィールド追加、engine.processTurnで実績記録、gantt.tsに稲妻線算出純関数追加、src/ui/GanttChartUI.ts新規（DOM overlay）、MainGameUIに画面切替メニュー追加。数値バランス不変。',
  status: 'completed', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-18 research.md', path: 'specs/019-in-game-gantt-ui/research.md', type: 'research', spec: 'Spec-18',
  description: '6つのDecision: 実績フィールド追加、engine実績記録、進捗率ベース稲妻線、id基準リスケ実績引き継ぎ、DOM overlay画面切替、ターン軸全描画+横スクロール。',
  status: 'completed', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-18 data-model.md', path: 'specs/019-in-game-gantt-ui/data-model.md', type: 'data-model', spec: 'Spec-18',
  description: 'GanttTaskにactualStartTurn/actualEndTurn(number|null)追加。検証ルール・状態遷移・派生データ(稲妻線/帯範囲)・リスケ引き継ぎ・影響範囲。',
  status: 'completed', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-18 contracts/ui-and-module-contracts.md', path: 'specs/019-in-game-gantt-ui/contracts/ui-and-module-contracts.md', type: 'contracts', spec: 'Spec-18',
  description: 'GanttTask拡張、engine.processTurn挙動、gantt.ts純関数(plannedRate/progressDeviation/actualPosition)、GanttChartUIクラス契約、data-testid一覧、MainGameUIのnav-gantt-btn/nav-dashboard-btn、互換性契約。',
  status: 'completed', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-18 quickstart.md', path: 'specs/019-in-game-gantt-ui/quickstart.md', type: 'quickstart', spec: 'Spec-18',
  description: '自動検証(vitest/tsc/playwright)+手動5シナリオ(画面切替/稲妻線遅れ前倒し/実績帯/依存ハイライト/スクロール)。',
  status: 'completed', created: '2026-08-30'});

MATCH (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}), (plan:Document {name: 'Spec-18 plan.md'})
MERGE (s18)-[:HAS_PLAN]->(plan);

// ADR-028: ゲーム内ガントチャートUIの技術方針
MERGE (:ADR {
  id: 'ADR-028',
  title: 'ゲーム内ガントチャートUIの技術方針（実績データ・稲妻線算出・DOM overlay）',
  date: '2026-08-30',
  status: 'accepted',
  context: 'Spec-18 planで(1)実績（着手・完了ターン）の保持方法、(2)実績記録タイミング、(3)稲妻線の折れ量算出方式、(4)リスケ時の実績連続性、(5)ガント画面の実装方式を確定する必要があった。現状GanttTaskはstartTurn/duration/progress/statusのみで実績を持たず、MainGameUIはDOM overlay方式だが画面切替メニュー未実装。turn.tsは純粋関数でstateを変更せず、engine.tsがstateを確定する。',
  decision: '(1)GanttTaskにactualStartTurn:number|null / actualEndTurn:number|null を追加（未着手/未完了はnull）。(2)実績記録はGameEngine.processTurn内のタスク更新時。progressが0→正に増えたターンでactualStartTurn=state.turn、progress100到達ターンでactualEndTurn=state.turn。turn.tsの純粋関数シグネチャは不変。(3)稲妻線は進捗率ベース: plannedRate=clamp((T-startTurn+1)/duration,0,1)*100、deviation=progress-plannedRate、実績到達ターン=startTurn-1+duration*(progress/100)。gantt.tsにplannedRate/progressDeviation/actualPositionの純関数追加。(4)リスケ(ganttVariants差し替え)時はtask idをキーに実績を引き継ぐ。(5)ガント画面はDOM overlay方式のGanttChartUIをsrc/ui/に新規実装(Phaser非使用)、MainGameUIにnav-gantt-btn/nav-dashboard-btnを追加しトグル。閲覧専用。ステージJSONの実績フィールドはoptionalでnull補完。',
  rationale: 'progressだけでは着手ターンを復元できず実績表示に不足するため明示保持。実績確定はstateを持つengineの責務で、turn.tsの既存契約(Spec-16で維持と明記)を崩さない。進捗率ベースの稲妻線は既存フィールドだけで算出でき将来予測(Out of Scope)に踏み込まない。DOM overlayは既存UIと一貫しConstitution原則I(canvasはE2E不透明、DOMでE2E可能)を満たす。',
  consequences: 'types.ts/engine.ts/gantt.ts/schemas/stageData.tsの変更、src/ui/GanttChartUI.ts新規、MainGameUI.tsとMainScene.tsの画面切替配線。既存ステージJSONは変更不要。数値バランスは不変。依存表示(US3/P3)分の実装が加わる。E2E参照点としてgantt-screen/gantt-turn-col-<turn>/gantt-planned-row/gantt-actual-row/gantt-lightning-line-<id>(data-deviation=ahead|behind|ontrack)/gantt-dep-highlight-<id>/nav-gantt-btn/nav-dashboard-btnを公開。'
});
MATCH (adr:ADR {id: 'ADR-028'}), (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}) MERGE (adr)-[:AFFECTS]->(s18);
MATCH (adr:ADR {id: 'ADR-028'}), (plan:Document {name: 'Spec-18 plan.md'}) MERGE (adr)-[:AFFECTS]->(plan);
MATCH (adr:ADR {id: 'ADR-028'}), (c:Concept {name: 'ガントチャート'}) MERGE (adr)-[:AFFECTS]->(c);

// =============================================================================
// Spec-18 /speckit-tasks（2026-08-30）: タスク分解
// =============================================================================

// spec-entry ノードの next_action 更新（status は planned のまま）
MATCH (n:Document {name: 'Spec-18: ゲーム内ガントチャートUI'})
SET n.next_action = '/speckit-implement で T001〜T029 を実装する。',
    n.checkpoint_date = '2026-08-30';

// tasks.md ノード
MERGE (:Document {name: 'Spec-18 tasks.md', path: 'specs/019-in-game-gantt-ui/tasks.md', type: 'tasks', spec: 'Spec-18',
  description: 'タスク分解（T001〜T029、6フェーズ）。Phase1 Setup(既存データ/契約確認)、Phase2 Foundational(GanttTask実績フィールド・schema・engine実績記録・gantt.ts稲妻線純関数・リスケ引き継ぎ＋各テスト)、Phase3 US1(P1/MVP: GanttChartUI新規・予定/実績2行・稲妻線・MainGameUIメニュー・MainScene配線＋E2E)、Phase4 US2(P2: 実績行3状態＋E2E)、Phase5 US3(P3: 依存ハイライト＋E2E)、Phase6 Polish(スクロール・型/カバレッジ/lint/quickstart)。テスト必須(Constitution II)。',
  status: 'completed', created: '2026-08-30'});
MATCH (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}), (t:Document {name: 'Spec-18 tasks.md'})
MERGE (s18)-[:HAS_TASKS]->(t);

// =============================================================================
// Spec-18 /speckit-implement（2026-08-30）: ゲーム内ガントチャートUI 実装完了
// =============================================================================

// spec-entry ノードを implemented に更新
MATCH (n:Document {name: 'Spec-18: ゲーム内ガントチャートUI'})
SET n.status = 'implemented',
    n.next_action = '実装完了。コミットは人手で行う。',
    n.checkpoint_date = '2026-08-30';

// 実装結果ノード
MERGE (:Document {name: 'Spec-18 implement結果', path: 'specs/019-in-game-gantt-ui/tasks.md',
  type: 'implementation-summary', spec: 'Spec-18',
  description: 'T001〜T029全完了。GanttTaskにactualStartTurn/actualEndTurn追加(types.ts/schemas/stageData.tsでoptional null補完)、engine.processTurnで実績記録(progress増加で着手ターン、100到達で完了ターン)、gantt.tsにplannedRate/progressDeviation/actualPosition追加・applyVariantをid基準の実績引き継ぎに拡張。src/ui/GanttChartUI.ts新規(DOM overlay、予定行/実績行/稲妻線data-deviation/ターン軸曜日/依存パネル/スクロール)、MainGameUIにnav-gantt-btn、MainSceneで画面切替配線。ユニット17件+E2E24件(chromium/Mobile Chrome)追加。tsc 0、src/gameカバレッジlines99.48%/funcs100%/branches93.33%、全ユニット375件・全E2E82件PASS、biome/markdownlint 0。数値バランス不変。',
  status: 'completed', created: '2026-08-30'});
MATCH (s18:Document {name: 'Spec-18: ゲーム内ガントチャートUI'}), (r:Document {name: 'Spec-18 implement結果'})
MERGE (s18)-[:HAS_RESULT]->(r);

// GanttChartUI Concept
MERGE (:Concept {name: 'GanttChartUI', description: 'ゲーム内ガントチャート画面(DOM overlay、閲覧専用)。予定行/実績行の2行、現在ターンの稲妻線(予定対実績の遅れ・前倒し)、タスク選択による先行タスクのハイライト表示。Spec-18で実装。', file: 'src/ui/GanttChartUI.ts', spec: 'Spec-18'});
MATCH (adr:ADR {id: 'ADR-028'}), (g:Concept {name: 'GanttChartUI'}) MERGE (adr)-[:AFFECTS]->(g);

// ガントチャート Concept にゲーム内UI実装を追記
MATCH (n:Concept {name: 'ガントチャート'})
SET n.description = coalesce(n.description, '') + '（Spec-18でゲーム内UI GanttChartUIを実装。予定/実績2行・稲妻線・依存表示、閲覧専用のDOM overlay。実績はGanttTask.actualStartTurn/actualEndTurnで保持）';

// =============================================================================
// Spec-19 /speckit-specify（2026-08-30）: カード選択・手札への組み込み機能の仕様確定
// ディレクトリは specs/020-card-selection-hand/、グラフDB上は Spec-19（番号ずれは既存慣習）
// =============================================================================

// spec-entry ノードの更新: backlog → specified
MATCH (n:Document {name: 'Spec-19: カード選択・手札への組み込み機能'})
SET n.status = 'specified',
    n.next_action = '/speckit-plan で技術方針を確定する。手札上限・初期枚数・poc-01プール内容・乱数方式・重複配布可否・ADR-026暫定対応の置き換えを plan で決定する。',
    n.checkpoint_date = '2026-08-30';

// spec.md / checklist ノード
MERGE (:Document {name: 'Spec-19 spec.md', path: 'specs/020-card-selection-hand/spec.md', type: 'spec', spec: 'Spec-19',
  description: 'カード選択・手札への組み込み機能の仕様。US1毎ターン手札補充(P1)、US2ステージ配布プールで出現制御(P2)、US3配布回数上限カード(P3)。FR11件・SC5件。手札を固定配列からプール補充方式に変更。Out of Scopeにデッキビルド・能動ドロー・レアリティを明記。',
  status: 'draft', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-19 checklists/requirements.md', path: 'specs/020-card-selection-hand/checklists/requirements.md', type: 'checklist', spec: 'Spec-19',
  description: '仕様品質チェックリスト。全項目PASS。NEEDS CLARIFICATIONマーカー0件。',
  status: 'completed', created: '2026-08-30'});

MATCH (s19:Document {name: 'Spec-19: カード選択・手札への組み込み機能'}), (spec:Document {name: 'Spec-19 spec.md'})
MERGE (s19)-[:HAS_SPEC]->(spec);
MATCH (s19:Document {name: 'Spec-19: カード選択・手札への組み込み機能'}), (cl:Document {name: 'Spec-19 checklists/requirements.md'})
MERGE (s19)-[:HAS_CHECKLIST]->(cl);

// ADR-029: 手札をステージ配布プールからのターン補充方式にする（配布回数上限つき）
MERGE (:ADR {
  id: 'ADR-029',
  title: '手札をステージ配布プールからのターン補充方式にする（配布回数上限つき）',
  date: '2026-08-30',
  status: 'accepted',
  context: 'ADR-026で「state.handはinitialCards固定で補充機構がなく、initialCardsに含めないカードは到達不能」という制約が判明し、暫定対応(休出カードをinitialCardsへ静的追加)のうえ恒久対応をSpec-19にバックログ化していた。基本設計「ターン制とカード.md」には既に「ステージ開始時に一定数配布＋ターンごとにランダム配布」「ステージ中1回しか配布されないカードもある」という方針が記載されている。',
  decision: 'Q1=A ステージごとに配布プール(配布され得るカード集合＋出やすさの重み)を定義しそこからランダム配布。Q2=A 毎ターン開始時に手札を手札上限まで補充(不足分をプールから引く、上限超過なし)。Q3=A カードに「ステージ中の配布回数上限」を任意で持たせ、上限到達で配布対象から除外。配布可能カードが尽きたら補充せず手札を現状維持(エラーにしない)。',
  rationale: '基本設計の既定方針(開始時＋ターンごとのランダム配布、1回限りカードあり)を最も素直に満たす。プール方式はステージごとの難易度・テーマ設計と利益率インバリアント(Constitution III)の調整を可能にする。全27カードからの一律ランダム(案B)は設計自由度が低く却下。デッキビルド(案C)はスコープ過大で却下(Out of Scope)。',
  consequences: 'ステージデータ(poc-01.json等)に配布プール定義(カード・重み・配布回数上限)と手札上限・初期枚数の追加が必要。GameStateに配布回数の記録を持たせ、ターン処理に補充ステップを追加する。既存のinitialCardsによる静的手札は配布プール経由に置き換わる想定(移行方法はplan)。手札上限・初期枚数の具体値、poc-01プール内容、乱数方式、重複配布可否はplanで確定。'
});
MATCH (adr:ADR {id: 'ADR-029'}), (s19:Document {name: 'Spec-19: カード選択・手札への組み込み機能'}) MERGE (adr)-[:AFFECTS]->(s19);
MATCH (adr:ADR {id: 'ADR-029'}), (spec:Document {name: 'Spec-19 spec.md'}) MERGE (adr)-[:AFFECTS]->(spec);
MATCH (adr:ADR {id: 'ADR-029'}), (prev:ADR {id: 'ADR-026'}) MERGE (adr)-[:SUPERSEDES]->(prev);

// =============================================================================
// Spec-19 /speckit-plan（2026-08-30）: カード選択・手札への組み込み機能の技術方針確定
// =============================================================================

// spec-entry ノードの更新: specified → planned
MATCH (n:Document {name: 'Spec-19: カード選択・手札への組み込み機能'})
SET n.status = 'planned',
    n.next_action = '/speckit-tasks でタスク分解する。',
    n.checkpoint_date = '2026-08-30';

// plan 成果物ノード
MERGE (:Document {name: 'Spec-19 plan.md', path: 'specs/020-card-selection-hand/plan.md', type: 'plan', spec: 'Spec-19',
  description: 'カード選択・手札への組み込み機能の実装計画。Constitution Check(Phase0前/Phase1後)全項目PASS(原則IIIは配布数値をdocs/03-詳細設計に文書化する運用で充足)。StageDataにcardPool/handLimit、GameStateにdrawCounts追加、src/game/deck.ts新規(純関数)、engine.processTurnに補充ステップ、poc-01.jsonにプール定義。turn.ts純関数不変。UI変更なし。',
  status: 'completed', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-19 research.md', path: 'specs/020-card-selection-hand/research.md', type: 'research', spec: 'Spec-19',
  description: '7つのDecision: cardPoolデータ構造/handLimit・initialCards据え置き/engine補充ステップ+deck.ts純関数/drawCounts記録/initialCards移行(休出はプールへ)/重複配布許可/Math.random踏襲+rng注入テスト。',
  status: 'completed', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-19 data-model.md', path: 'specs/020-card-selection-hand/data-model.md', type: 'data-model', spec: 'Spec-19',
  description: 'StageDataにcardPool(CardPoolEntry[])・handLimit、GameStateにdrawCounts追加。CardPoolEntry(name/weight/maxDraws?)。検証ルール・状態遷移・影響範囲。',
  status: 'completed', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-19 contracts/module-contracts.md', path: 'specs/020-card-selection-hand/contracts/module-contracts.md', type: 'contracts', spec: 'Spec-19',
  description: '型契約(CardPoolEntry/StageData/GameState拡張)、deck.tsの純関数eligibleEntries/drawCards(rng注入可)、engine挙動、zodスキーマ、互換性契約(turn.ts・applyCards・UI不変)。',
  status: 'completed', created: '2026-08-30'});
MERGE (:Document {name: 'Spec-19 quickstart.md', path: 'specs/020-card-selection-hand/quickstart.md', type: 'quickstart', spec: 'Spec-19',
  description: '自動検証(vitest/tsc/playwright)+deck.tsユニット要点+手動5シナリオ(手札補充/プール制御/配布回数上限/到達可能性/回帰)。',
  status: 'completed', created: '2026-08-30'});

MATCH (s19:Document {name: 'Spec-19: カード選択・手札への組み込み機能'}), (plan:Document {name: 'Spec-19 plan.md'})
MERGE (s19)-[:HAS_PLAN]->(plan);

// =============================================================================
// Spec-19 /speckit-tasks（2026-08-31）: カード選択・手札への組み込み機能のタスク分解
// =============================================================================

// spec-entry ノードの更新: planned → tasks-generated
MATCH (n:Document {name: 'Spec-19: カード選択・手札への組み込み機能'})
SET n.status = 'tasks-generated',
    n.next_action = '/speckit-implement で実装する（MVP=US1から）。',
    n.checkpoint_date = '2026-08-31';

// tasks.md ノード
MERGE (:Document {name: 'Spec-19 tasks.md', path: 'specs/020-card-selection-hand/tasks.md', type: 'tasks', spec: 'Spec-19',
  description: 'タスク分解（T001〜T022、6フェーズ）。Phase1 Setup(既存types/テスト構成確認)、Phase2 Foundational(types.tsにCardPoolEntry/StageData拡張/GameState.drawCounts、stageData.ts zodスキーマ)、Phase3 US1(P1/MVP: deck.ts drawCards純関数・engine buildInitialState/processTurn補充+各テスト)、Phase4 US2(P2: 重み付き抽選・プール内限定・poc-01.json cardPool/handLimit+統計テスト)、Phase5 US3(P3: eligibleEntriesでmaxDraws除外+テスト)、Phase6 Polish(docs/03-詳細設計に配布数値文書化(原則III)・ADR-026恒久化・回帰・tsc/カバレッジ・quickstart検証)。テスト必須(Constitution II)。',
  status: 'completed', created: '2026-08-31'});
MATCH (s19:Document {name: 'Spec-19: カード選択・手札への組み込み機能'}), (t:Document {name: 'Spec-19 tasks.md'})
MERGE (s19)-[:HAS_TASKS]->(t);

// =============================================================================
// Spec-19 /speckit-implement（2026-08-31）: カード選択・手札への組み込み機能の実装完了
// =============================================================================

// spec-entry ノードの更新: tasks-generated → implemented
MATCH (n:Document {name: 'Spec-19: カード選択・手札への組み込み機能'})
SET n.status = 'implemented',
    n.next_action = 'なし（実装完了。ユニット396件・E2E82件パス、tsc 0エラー、src/game カバレッジ基準クリア）。',
    n.checkpoint_date = '2026-08-31';

// 実装成果物ノード
MERGE (:Document {name: 'Spec-19 deck.ts', path: 'src/game/deck.ts', type: 'source', spec: 'Spec-19',
  description: '新規。純関数 eligibleEntries(maxDraws未到達エントリ抽出)・drawCards(手札をhandLimitまで重み付き抽選で補充、rng注入可、プール外を配らない、配布可能が尽きたら打ち切り)。Phaser/DOM非依存。',
  status: 'implemented', created: '2026-08-31'});
MERGE (:Document {name: 'Spec-19 deck.test.ts', path: 'tests/unit/deck.test.ts', type: 'test', spec: 'Spec-19',
  description: 'US1基本補充・US2プール制御と重み(fast-check)・US3配布回数上限(eligibleEntries/maxDraws)のユニット/プロパティテスト。決定論rng注入。全パス。',
  status: 'all-pass', created: '2026-08-31'});
MERGE (:Document {name: 'Spec-19 engine.ts(変更)', path: 'src/game/engine.ts', type: 'source', spec: 'Spec-19',
  description: 'buildInitialStateでdrawCountsをinitialCardsから初期化。GameEngineがcardPool/handLimit/rngを保持。processTurn末尾でゲーム継続時のみdrawCardsによりhandLimitまで補充。turn.tsシグネチャ不変。',
  status: 'implemented', created: '2026-08-31'});
MERGE (:Document {name: 'Spec-19 implement結果', path: 'specs/020-card-selection-hand/tasks.md', type: 'implementation-summary', spec: 'Spec-19',
  description: 'T001〜T022全完了。types.ts(CardPoolEntry/StageData.cardPool・handLimit/GameState.drawCounts)、schemas/stageData.ts(cardPool既定[]・handLimit既定initialCards長、後方互換)、deck.ts新規、engine.ts補充ステップ、poc-01.json(cardPool全27種・handLimit=8)。docs/03-詳細設計/ステージ/PoCステージ01.mdに配布数値を文書化(原則III)。検証: tsc 0、ユニット396パス、E2E82パス、src/gameカバレッジ lines94.4/branches89.4/funcs99.3で基準(80/75/80)クリア。',
  status: 'completed', created: '2026-08-31'});

MATCH (s19:Document {name: 'Spec-19: カード選択・手札への組み込み機能'}), (d:Document {name: 'Spec-19 implement結果'})
MERGE (s19)-[:HAS_IMPLEMENTATION]->(d);

// ADR-030: 休出（土）はE2E安定のため initialCards にも残し入手経路を二重化する
MERGE (adr:ADR {id: 'ADR-030'})
SET adr.title = '休出（土）はE2E安定のため初期カードにも残し、プールと二重化する',
    adr.date = '2026-08-31',
    adr.status = 'accepted',
    adr.context = 'Spec-19でADR-026の暫定対応(休出をinitialCardsへ静的追加)をcardPool経由に恒久化する方針だったが、requiresTargetを持つカードは休出（土）（日）のみで、対象選択UIのE2E(tests/e2e/target-picker.spec.ts, Spec-16)が初期手札に休出（土）が存在することに依存している。補充はランダムのためE2Eで確実に休出を手札へ出すのが困難。',
    adr.decision = 'poc-01のinitialCardsに休出（土）を1枚残し、cardPoolにも休出（土）（日）を含める(入手経路の二重化)。休出（日）はプール経由のみ。initialCardsは4枚(デイリー・レビュー・モニタリング・休出（土）)、handLimit=8。',
    adr.rationale = '案1(初期カードに休出（土）を残す)を採用。E2Eの安定性を保ちつつSpec-19のプール化(SC-001到達可能性)も両立する。案2(E2Eを補充後取得に書き換え)は乱数依存で不安定になるため却下。',
    adr.consequences = '休出（土）は初期手札に固定される点でADR-026の暫定対応の一部が残存するが、cardPoolにも含むため配布仕組みの検証は成立する。将来requiresTargetカードが増えればE2Eを別カードへ移し初期カードから外せる。';
MATCH (adr:ADR {id: 'ADR-030'}), (prev:ADR {id: 'ADR-026'}) MERGE (adr)-[:SUPERSEDES]->(prev);
MATCH (adr:ADR {id: 'ADR-030'}), (s19:Document {name: 'Spec-19: カード選択・手札への組み込み機能'}) MERGE (adr)-[:AFFECTS]->(s19);

// =============================================================================
// Spec-19 /speckit-analyze（2026-08-31）: 整合性分析（読み取り専用）とremediation
// =============================================================================

// spec-entry に analyze 結果を記録（status は implemented を維持）
MATCH (n:Document {name: 'Spec-19: カード選択・手札への組み込み機能'})
SET n.analyze_result = 'CRITICAL 0件。FRカバレッジ100%(FR11/SC5、全FRに1タスク以上)。Constitution技術ゲート(原則I境界/II閾値/III数値docs化/IVグラフDB)全遵守。指摘: C1=token log未記録(HIGH,是正済)、I1=tasks T015記述と案1実装の差分(MEDIUM,research.md追記とADR-030で是正済)。unmapped task 0、duplication 0、ambiguity 1(LOW解消済)。',
    n.analyze_date = '2026-08-31';

// =============================================================================
// Spec-20 /speckit-specify（2026-08-31）: ゲームクリア/失敗のリザルト画面
// ディレクトリは specs/021-result-screen/、グラフDB上は Spec-20（番号ずれは既存慣習）
// =============================================================================

MERGE (:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面', path: 'docs/sdd-tasks.md', type: 'spec-entry', spec: 'Spec-20',
  description: 'ゲーム終了(全タスク完了/納期到達)時に成否判定(クリア/失敗)と最終利益・利益率・成否理由・主要数値を提示する専用リザルト画面。US1成否と利益率提示(P1)・US2成否理由と内訳(P2)・US3タイトルへ戻る導線(P3)。FR11件・SC5件・Out of Scope明記。成否ルール=最終利益率が目標利益率以上かつ納期内完遂でクリア。',
  status: 'specified', created: '2026-08-31'});

MERGE (:Document {name: 'Spec-20 spec.md', path: 'specs/021-result-screen/spec.md', type: 'spec', spec: 'Spec-20',
  description: 'リザルト画面の仕様。ゲーム終了時にリザルト表示(FR-001)、成否判定明示(FR-002)、成否ルール=利益率≥目標かつ納期内完遂でクリア(FR-003)、最終利益・利益率表示(FR-004)、成否理由(FR-005)、主要数値(FR-006)、非終了時は非表示(FR-007)、タイトルへ戻る導線(FR-008)、ゼロ除算回避(FR-009)、同時成立時の優先(FR-010)、既存挙動不破壊(FR-011)。',
  status: 'draft', created: '2026-08-31'});

MERGE (:Document {name: 'Spec-20 checklists/requirements.md', path: 'specs/021-result-screen/checklists/requirements.md', type: 'checklist', spec: 'Spec-20',
  description: '仕様品質チェックリスト。Content Quality/Requirement Completeness/Feature Readiness 全項目PASS。NEEDS CLARIFICATION 0。',
  status: 'completed', created: '2026-08-31'});

MATCH (s20:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'}), (spec:Document {name: 'Spec-20 spec.md'})
MERGE (s20)-[:HAS_SPEC]->(spec);
MATCH (s20:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'}), (cl:Document {name: 'Spec-20 checklists/requirements.md'})
MERGE (s20)-[:HAS_CHECKLIST]->(cl);

// =============================================================================
// Spec-20 /speckit-plan（2026-08-31）: リザルト画面の技術方針確定
// =============================================================================

// spec-entry 更新: specified → planned
MATCH (n:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'})
SET n.status = 'planned',
    n.next_action = '/speckit-tasks でタスク分解する。',
    n.checkpoint_date = '2026-08-31';

MERGE (:Document {name: 'Spec-20 plan.md', path: 'specs/021-result-screen/plan.md', type: 'plan', spec: 'Spec-20',
  description: 'リザルト画面の実装計画。Constitution Check(Phase0前/Phase1後)全項目PASS。成否判定は src/game/result.ts(新規純関数 evaluateResult)、表示は src/ui/ResultUI.ts(新規DOMオーバーレイ、data-testid付き)、MainScene.confirmTurn末尾で終了検知しResultUI表示・TitleSceneへ遷移。turn.ts/engine.tsの終了判定・シグネチャ不変。新規依存なし・新規数値なし(目標利益率は既存TARGET_PROFIT_RATE参照)。',
  status: 'completed', created: '2026-08-31'});
MERGE (:Document {name: 'Spec-20 research.md', path: 'specs/021-result-screen/research.md', type: 'research', spec: 'Spec-20',
  description: '6つのDecision: 成否ルール(全タスク完了かつ利益率≥目標でclear)/利益率算出(既存踏襲・ゼロ除算回避)/純関数+DOMオーバーレイ方式/表示タイミングとTitle遷移・確定無効化/主要数値の取得元(getCompletionRate等)/同時成立は全タスク完了優先。',
  status: 'completed', created: '2026-08-31'});
MERGE (:Document {name: 'Spec-20 data-model.md', path: 'specs/021-result-screen/data-model.md', type: 'data-model', spec: 'Spec-20',
  description: 'GameResult(outcome/reason/profit/profitRate/targetProfitRate/budget/totalCost/turn/completionRate、派生値・保存しない)。判定ルール・検証ルール(ゼロ除算回避・純関数)・影響範囲。',
  status: 'completed', created: '2026-08-31'});
MERGE (:Document {name: 'Spec-20 contracts/module-contracts.md', path: 'specs/021-result-screen/contracts/module-contracts.md', type: 'contracts', spec: 'Spec-20',
  description: 'GameResult/GameOutcome型、evaluateResult(state,targetProfitRate)純関数、ResultUI(show/hide/setOnBackToTitle)、UI contract(data-testid: result-screen/outcome/reason/profit-rate/profit/stats/back-to-title)、MainScene挙動、互換性契約(turn/engine/MainGameUI/Scene遷移不変)。',
  status: 'completed', created: '2026-08-31'});
MERGE (:Document {name: 'Spec-20 quickstart.md', path: 'specs/021-result-screen/quickstart.md', type: 'quickstart', spec: 'Spec-20',
  description: '自動検証(tsc/vitest/coverage/playwright)+result.tsユニット要点+手動6シナリオ(終了時表示/成否・数値/未終了時非表示/タイトルへ戻る/多重進行なし)+SC対応。',
  status: 'completed', created: '2026-08-31'});

MATCH (s20:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'}), (plan:Document {name: 'Spec-20 plan.md'}) MERGE (s20)-[:HAS_PLAN]->(plan);

// ADR-031: リザルト成否判定は純関数result.tsに置きDOMオーバーレイで表示する
MERGE (adr:ADR {id: 'ADR-031'})
SET adr.title = 'リザルトの成否判定を純関数result.tsに分離しDOMオーバーレイで表示する',
    adr.date = '2026-08-31', adr.status = 'accepted',
    adr.context = 'ゲーム終了判定(isGameOver/gameOverReason)は既存だが、成否(クリア/失敗)と最終利益率の提示画面が無い。判定ロジックをどこに置くか、リザルトをPhaser SceneとDOMオーバーレイのどちらで作るかを決める必要があった。',
    adr.decision = '成否判定と利益率算出をsrc/game/result.tsのevaluateResult(state,targetProfitRate)純関数に置く。クリア条件は全タスク完了(reason=全タスク完了)かつprofitRate≥targetProfitRate、それ以外はfail。表示はsrc/ui/ResultUI.ts(DOMオーバーレイ、data-testid付き)。MainScene.confirmTurn末尾で終了検知しResultUI表示、タイトルへ戻るでTitleScene遷移、終了後は確定無効化。',
    adr.rationale = 'Constitution原則I(src/gameはPhaser/DOM非依存)に従い判定を純関数化して決定論テスト可能にする。既存の情報表示画面(MainGameUI/StageSelectUI)が全てDOMオーバーレイでPlaywright参照性が高いため合わせる。目標利益率は既存TARGET_PROFIT_RATEを参照し新規数値を導入しない(原則III)。turn.ts/engine.tsの終了判定は不変で回帰リスクを抑える。',
    adr.consequences = 'リザルトは派生値で状態を持たないため永続化・スコア等は別途必要なら拡張。Phaser Sceneではないため演出は限定的だがテスト容易性を優先。';
MATCH (adr:ADR {id: 'ADR-031'}), (s20:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'}) MERGE (adr)-[:AFFECTS]->(s20);

// =============================================================================
// Spec-20 /speckit-tasks（2026-08-31）: リザルト画面のタスク分解
// =============================================================================

MATCH (n:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'})
SET n.status = 'tasks-generated', n.next_action = '/speckit-implement で実装する（MVP=US1から）。', n.checkpoint_date = '2026-08-31';

MERGE (:Document {name: 'Spec-20 tasks.md', path: 'specs/021-result-screen/tasks.md', type: 'tasks', spec: 'Spec-20',
  description: 'タスク分解(T001〜T015、6フェーズ)。Phase1 Setup(既存終了判定/利益率/getCompletionRate/UI流儀確認)、Phase2 Foundational(result.tsにGameOutcome/GameResult型)、Phase3 US1(P1/MVP: evaluateResult純関数・ResultUI基本表示・MainScene配線+ユニット/E2E)、Phase4 US2(P2: 成否理由result-reason・内訳result-stats+ユニット)、Phase5 US3(P3: result-back-to-title・TitleScene遷移・確定無効化+E2E)、Phase6 Polish(回帰・tsc/カバレッジ・quickstart)。テスト必須(Constitution II)。turn/engine不変。',
  status: 'completed', created: '2026-08-31'});
MATCH (s20:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'}), (t:Document {name: 'Spec-20 tasks.md'}) MERGE (s20)-[:HAS_TASKS]->(t);

// =============================================================================
// Spec-20 /speckit-implement（2026-09-01）: リザルト画面の実装完了
// =============================================================================

MATCH (n:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'})
SET n.status = 'implemented',
    n.next_action = 'なし（実装完了。ユニット407件・E2E88件パス、tsc 0、src/gameカバレッジ基準クリア）。',
    n.checkpoint_date = '2026-09-01';

MERGE (:Document {name: 'Spec-20 result.ts', path: 'src/game/result.ts', type: 'source', spec: 'Spec-20',
  description: '新規。GameOutcome/GameResult型とevaluateResult(state,targetProfitRate)純関数。profit=budget−totalCost、profitRate=budget>0?profit/budget:0(ゼロ除算回避)、outcome=(reason=="全タスク完了"&&profitRate>=target)?"clear":"fail"、completionRate=getCompletionRate。Phaser/DOM非依存。',
  status: 'implemented', created: '2026-09-01'});
MERGE (:Document {name: 'Spec-20 result.test.ts', path: 'tests/unit/result.test.ts', type: 'test', spec: 'Spec-20',
  description: 'US1成否と利益率・US2理由と内訳・プロパティテスト(fast-check)。全11件パス。',
  status: 'all-pass', created: '2026-09-01'});
MERGE (:Document {name: 'Spec-20 ResultUI.ts', path: 'src/ui/ResultUI.ts', type: 'source', spec: 'Spec-20',
  description: '新規。DOMオーバーレイ。show(result)/hide()/setOnBackToTitle()。data-testid: result-screen/outcome/reason/profit-rate/profit/stats/back-to-title。成否・利益率・理由・主要数値・タイトルへ戻るを描画。',
  status: 'implemented', created: '2026-09-01'});
MERGE (:Document {name: 'Spec-20 result.spec.ts', path: 'tests/e2e/result.spec.ts', type: 'test', spec: 'Spec-20',
  description: 'E2E。未終了時非表示・ゲーム終了後のリザルト表示(成否/利益率/理由/内訳)・タイトルへ戻り再開。全6件パス。',
  status: 'all-pass', created: '2026-09-01'});
MERGE (:Document {name: 'Spec-20 MainScene.ts(変更)', path: 'src/scenes/MainScene.ts', type: 'source', spec: 'Spec-20',
  description: 'confirmTurn末尾でisGameOver時にevaluateResult(state,TARGET_PROFIT_RATE)を算出しResultUI表示・確定ボタン無効化(多重進行防止)。ResultUIのonBackToTitleでTitleSceneへ遷移。MainGameUIにsetConfirmEnabled追加。',
  status: 'implemented', created: '2026-09-01'});
MERGE (:Document {name: 'Spec-20 implement結果', path: 'specs/021-result-screen/tasks.md', type: 'implementation-summary', spec: 'Spec-20',
  description: 'T001〜T015全完了。result.ts新規(evaluateResult純関数)、ResultUI.ts新規(DOMオーバーレイ)、MainScene配線(終了検知→表示→Title遷移・確定無効化)、MainGameUI.setConfirmEnabled追加。turn.ts/engine.ts不変。検証: tsc0・ユニット407パス・E2E88パス・result.tsカバレッジ100/87.5/100/100・全体94.5/89.3/99.3で基準クリア・biome/markdownlint 0。engine.test.tsの一部はMath.random順序依存でフルスイート時に稀にフレーキー(本Spec非起因)。',
  status: 'completed', created: '2026-09-01'});

MATCH (s20:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'}), (d:Document {name: 'Spec-20 implement結果'}) MERGE (s20)-[:HAS_IMPLEMENTATION]->(d);

// =============================================================================
// Spec-20 /speckit-analyze（2026-09-01）: 整合性分析（読み取り専用）
// =============================================================================

MATCH (n:Document {name: 'Spec-20: ゲームクリア/失敗のリザルト画面'})
SET n.analyze_result = 'CRITICAL 0件。FRカバレッジ100%(FR11/SC5)。Constitution全原則遵守(I境界/IIテストゲート/III数値なし/IVグラフDB/V依存)。指摘はLOWのみ(A1成否表示文言はspec非規定・実装裁量、N1日英対応一貫、C1 token log analyze行追記)。unmapped0/duplication0。',
    n.analyze_date = '2026-09-01';
