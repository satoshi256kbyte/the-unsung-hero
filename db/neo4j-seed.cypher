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
MATCH (spec:Document {name: 'Spec-08 spec'}), (d:Document {name: 'Spec-08 event.ts'}) MERGE (spec)-[:IMPLEMENTS]->(d);
