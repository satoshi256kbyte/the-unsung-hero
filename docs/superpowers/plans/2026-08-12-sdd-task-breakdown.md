# SDD タスク分割計画

**作成日**: 2026-08-12
**方針**: Spec Kit（specify → plan → tasks → implement）で1 Specずつ実装する。
1 Spec = 純粋TS（`src/game/`）の論理ユニット1つ、または画面1つ。
各Specはフェーズ内で並列実行可能。

---

## フェーズ構成と依存関係

```
Phase 1（コアデータ構造）
  ├── Spec-01: ゲームパラメータ型定義・定数
  └── Spec-02: ガントチャート・タスクモデル

Phase 2（ゲームロジック）← Phase 1 完了後
  ├── Spec-03: 進捗ダイスエンジン
  ├── Spec-04: メンバーパラメータ変動エンジン
  └── Spec-05: ターン処理エンジン（コア）

Phase 3（イベント・カードロジック）← Phase 2 完了後
  ├── Spec-06: ランダムイベントエンジン
  └── Spec-07: カードエフェクトエンジン

Phase 4（ゲームループ・画面）← Phase 3 完了後
  ├── Spec-08: GameEngine（フルターンループ）
  ├── Spec-09: PoCステージデータ
  └── Spec-10: メイン画面UI（DOM overlay + Phaser Scene）
```

---

## Spec 一覧

### Phase 1: コアデータ構造

#### Spec-01: ゲームパラメータ型定義・定数

**目的**: ゲーム全体で使う型・定数を一箇所に集約する。
後続Specすべての基盤。

**スコープ**:

- `src/game/types.ts` — Member, Card, Event, GameState, Gantt 等の型
- `src/game/constants.ts` — バランスパラメータ.md の数値定数すべて
- `src/game/balance.ts` — skill_factor / health_factor テーブル関数

**Specでの指示例**:

```
/speckit-specify
Phaser 4+TypeScriptのSRPGゲームのコアデータ型と定数ファイルを実装する。
docs/03-詳細設計/バランスパラメータ.md の数値をすべて src/game/constants.ts に定義し、
skill_factor・health_factor のルックアップ関数を src/game/balance.ts に実装する。
型定義は src/game/types.ts にまとめる。Phaser非依存のpure TypeScript。
```

---

#### Spec-02: ガントチャート・タスクモデル

**目的**: ガントチャートの構造とタスク進捗の状態管理を実装する。
PoCステージのガントチャートデータ（22ターン・3工程・タスク構成）もここで定義。

**スコープ**:

- `src/game/gantt.ts` — GanttTask, GanttChart 操作関数（進捗更新・完了判定・ガントバリアント切り替え）
- `src/game/stage/poc.ts` — PoCステージの初期ガントチャートデータ（設計6日・実装10日・テスト6日）
- テスト: `src/game/gantt.test.ts`

**Specでの指示例**:

```
/speckit-specify
ウォーターフォール型プロジェクトのガントチャートモデルを実装する。
各タスクは開始ターン・期間・担当メンバー・現在進捗(%）・状態（進行中/停滞/完了）を持つ。
進捗更新・完了判定・ガントバリアント（仕様追加後）の切り替え関数を実装する。
PoCステージ（設計6日/実装10日/テスト6日、タスク8本）のデータを src/game/stage/poc.ts に定義する。
Phaser非依存。Vitest+fast-checkでプロパティテストを含む。
```

---

### Phase 2: ゲームロジック

#### Spec-03: 進捗ダイスエンジン

**目的**: 1ターンの進捗上昇量計算を実装する。
`base × skill_factor × health_factor` の式と確率分布。

**スコープ**:

- `src/game/dice.ts` — rollProgress(member, options?) → number
- プロパティテスト: 技・体の境界値で分布が仕様どおりか検証

**Specでの指示例**:

```
/speckit-specify
進捗ダイスエンジンを実装する。計算式: base(3.0〜7.0の一様乱数) × skill_factor(技) × health_factor(体)。
skill_factor・health_factorのテーブルはdocs/03-詳細設計/バランスパラメータ.md参照。
fast-checkのプロパティテストで技0〜25+・体0〜100の各境界値で上下限が仕様内に収まることを検証する。
Phaser非依存のpure TypeScript。
```

---

#### Spec-04: メンバーパラメータ変動エンジン

**目的**: 心・体・経験値・技の毎ターン変動を実装する。

**スコープ**:

- `src/game/member.ts` — applyTurnDecay, applyWeekendRecovery, applyExperience, tryLevelUp
- プロパティテスト: 心・体が範囲外に出ないこと、技の上限99

**Specでの指示例**:

```
/speckit-specify
メンバーパラメータ変動エンジンを実装する。
毎ターン: 心は-3〜+1の一様乱数変動、体は-1〜-3の自然低下。
週末回復（5稼働日ごと）: 心+8/体+12。
経験値: タスク完了時 base_exp(10) × level_factor(max(0.3, 1.0-技×0.04))。
技レベルアップ: 必要経験値テーブルに達したら技+1、経験値リセット。
心の範囲: 0〜150、体: 0〜100、技の上限: 99。
Vitest+fast-checkでパラメータが範囲外に出ないことをプロパティテストする。
```

---

#### Spec-05: ターン処理エンジン（コア）

**目的**: 1ターンの実行シーケンスを実装する。
進捗ダイスロール → パラメータ変動 → 固定イベントチェック の流れ。

**スコープ**:

- `src/game/turn.ts` — executeTurn(state, cardSelections) → TurnResult
- 固定イベント（キックオフ・週次・締め・クロージング）のスケジュール判定
- テスト: 22ターンのフル実行でゲームオーバーにならないスモークテスト

**Specでの指示例**:

```
/speckit-specify
ターン処理エンジン（コア）を実装する。
1ターンの処理順: 1)固定イベント判定, 2)カード効果適用, 3)進捗ダイスロール(各メンバー各タスク),
4)メンバーパラメータ変動, 5)予算超過チェック, 6)ターン終了処理。
固定イベントのスケジュール: キックオフ=turn1, 週次=5の倍数, 締め=各工程最終日, クロージング=turn22。
戻り値TurnResultは進捗更新・発生イベント・ゲームオーバーフラグを含む。
Phaser非依存。
```

---

### Phase 3: イベント・カードロジック

#### Spec-06: ランダムイベントエンジン

**目的**: チェックポイントごとのランダムイベント抽選と効果適用を実装する。

**スコープ**:

- `src/game/events.ts` — rollTaskEvent, rollMemberEvent, rollCheckpointEvent
- 条件付きイベント評価: evaluateConditionalEvents(state, turn) → Event[]
- 確率補正: カード効果 × パラメータ補正（最低確率採用方式）
- テスト: 確率の境界値テスト、条件付きイベントの条件式評価テスト

**Specでの指示例**:

```
/speckit-specify
ランダムイベントエンジンを実装する。
タスクイベント（手戻り8%/停滞5%/ブロッカー4%/環境障害3%/過大報告4%/過小報告3%/報告漏れ3%/ひらめき3%/一発合格2%）。
メンバーイベント（体調不良5%/モチベーション低下6%/疲労蓄積4%/休息3%/地元優勝2%）。
確率補正: カード効果はmin取り、パラメータ補正（×2等）は乗算。
条件付きイベント: poc-ev01〜poc-ev04の条件式（SPI/CPI/cardUsedCount/avgMorale）を評価する関数。
チェックポイント確率（キックオフ60%/週次50%+30%/締め45%or確定/クロージング50%）。
手戻りの巻き戻し率: 40%-(技×1%)。停滞持続: 1ターン60%/2ターン40%。
```

---

#### Spec-07: カードエフェクトエンジン

**目的**: 全カードの効果適用・状態管理を実装する。

**スコープ**:

- `src/game/cards.ts` — applyCard(card, target, state) → GameState
- CardEffect 状態の管理（セット・自動解除・手動解除）
- コスト計算・使用可否チェック
- テスト: 各カードの効果量テスト、状態解除タイミングテスト

**Specでの指示例**:

```
/speckit-specify
カードエフェクトエンジンを実装する。対象カード: デイリー/レビュー/モニタリング/サマライズ/
デイリー中止/雑談/停滞対応/個別面談/教育/ペアプログラミング/表彰/計画休/残業許可/
アサイン/入れ替え/巻取り/進捗ブースト/強制締め/リスケ/メンバー追加/休出/納期交渉/スコープ交渉。
コスト定義はdocs/03-詳細設計/バランスパラメータ.md参照。
状態管理: 即時/セット+自動解除/セット+手動解除の3方式。
1日コスト上限8（残業許可で+2）、合計超過の組み合わせは選択不可。
```

---

### Phase 4: ゲームループ・画面

#### Spec-08: GameEngine（フルターンループ）

**目的**: ゲームの状態機械を実装する。
ターン開始 → カード選択待ち → ターン実行 → 結果反映 → 次ターン。

**スコープ**:

- `src/game/engine.ts` — GameEngine クラス（状態機械）
- startGame / submitCards / getState / getResult
- 勝利・失敗判定（利益率・予算超過・納期）
- 統合テスト: PoCステージを22ターン通しで実行

**Specでの指示例**:

```
/speckit-specify
GameEngineクラスを実装する。ゲーム状態機械として、ターン開始→カード選択待ち→実行→結果反映を管理する。
PoCステージデータを入力として startGame() で初期化。
submitCards(cards[]) でそのターンのカードを受け取り executeTurn を呼び出す。
getState() で現在のゲーム状態を返す。
勝利条件: 全タスク完了かつ利益率≥5%。失敗条件: 予算100%超過または納期未達。
Vitestで22ターン通し実行のスモークテストを作成する。
```

---

#### Spec-09: PoCステージデータ

**目的**: PoCステージの完全なステージデータを定義する。
ガントチャートバリアント（仕様追加後・リスケ後）と条件付きイベントリスト。

**スコープ**:

- `src/game/stage/poc-gantt.ts` — 初期ガントチャート + バリアント定義
- `src/game/stage/poc-events.ts` — poc-ev01〜poc-ev04の条件付きイベント
- `src/game/stage/poc-cards.ts` — 初期配布カードセット

**Specでの指示例**:

```
/speckit-specify
PoCステージ（1ヶ月/22ターン/2人/3工程）の完全なステージデータを実装する。
ガントチャート: 設計フェーズ6日(タスク2本), 実装フェーズ10日(タスク4本), テストフェーズ6日(タスク2本)。
仕様追加バリアント（poc-ev01発火後）: 実装フェーズにタスク1本追加。
条件付きイベント: poc-ev01(turn8), poc-ev02(turn12), poc-ev03(turn16), poc-ev04(turn19)。
初期配布カード: デイリー/レビュー/モニタリング/サマライズ各1枚 + ランダム4枚。
```

---

#### Spec-10: メイン画面UI

**目的**: ゲームの主画面を実装する。
Phaser 4 Scene（背景・ガントチャート表示）+ DOM overlay（カード選択UI）。

**スコープ**:

- `src/scenes/GameScene.ts` — Phaser 4 Scene（ガントチャート・パラメータ表示）
- `src/ui/CardSelectionPanel.ts` — DOM overlay カード選択UI
- `src/ui/MemberStatusPanel.ts` — DOM overlay メンバーステータス表示
- `src/ui/EventLogPanel.ts` — DOM overlay イベントログ
- Playwright E2Eテスト: カード選択→ターン実行の基本フロー

**Specでの指示例**:

```
/speckit-specify
PoCステージのメイン画面を実装する。
Phaser3 GameSceneにガントチャート（タスクバー・進捗・ターン数）と
メンバーパラメータ（技/心/体）を描画する。
カード選択UIはDOMオーバーレイとして実装し（PlaywrightのE2Eテスト対象）、
使用可能カードの表示・コスト表示・上限チェック・確定ボタンを含む。
GameEngineと接続し、カード確定でsubmitCards()を呼び出してターンを進める。
Playwright E2Eテスト: カード選択→ターン実行→ガントチャート更新の確認。
```

---

## 実行順序まとめ

| フェーズ | Spec | 並列実行 | 前提 |
| -------- | ---- | -------- | ---- |
| Phase 1 | Spec-01, Spec-02 | 可 | なし |
| Phase 2 | Spec-03, Spec-04 | 可 | Phase 1 完了 |
| Phase 2 | Spec-05 | — | Spec-03, 04 完了 |
| Phase 3 | Spec-06, Spec-07 | 可 | Phase 2 完了 |
| Phase 4 | Spec-08, Spec-09 | 可 | Phase 3 完了 |
| Phase 4 | Spec-10 | — | Spec-08, 09 完了 |

---

## 各Specのターゲットファイル一覧

| Spec | 作成ファイル |
| ---- | ------------ |
| Spec-01 | src/game/types.ts, src/game/constants.ts, src/game/balance.ts |
| Spec-02 | src/game/gantt.ts, src/game/stage/poc.ts, src/game/gantt.test.ts |
| Spec-03 | src/game/dice.ts, src/game/dice.test.ts |
| Spec-04 | src/game/member.ts, src/game/member.test.ts |
| Spec-05 | src/game/turn.ts, src/game/turn.test.ts |
| Spec-06 | src/game/events.ts, src/game/events.test.ts |
| Spec-07 | src/game/cards.ts, src/game/cards.test.ts |
| Spec-08 | src/game/engine.ts, src/game/engine.test.ts |
| Spec-09 | src/game/stage/poc-gantt.ts, src/game/stage/poc-events.ts, src/game/stage/poc-cards.ts |
| Spec-10 | src/scenes/GameScene.ts, src/ui/CardSelectionPanel.ts, src/ui/MemberStatusPanel.ts, src/ui/EventLogPanel.ts, tests/e2e/game.spec.ts |

---

## SDD実行手順

各Specに対して以下の順で実行する。

1. `/speckit-specify` — 機能要件・受入条件を定義
2. `/speckit-plan` — 実装計画（ファイル構成・アーキテクチャ判断）
3. `/speckit-tasks` — タスクリスト生成
4. `/speckit-implement` — 実装実行
5. pre-pushでtypecheck + coverage + audit を通過させてpush
