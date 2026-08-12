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
