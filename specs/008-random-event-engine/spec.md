# Feature Specification: ランダムイベントエンジン（停滞・手戻り本体）

**Feature Branch**: `008-random-event-engine`

**Created**: 2026-08-13

**Status**: Draft

## User Scenarios & Testing

### User Story 1 - ランダムイベントの判定と返却（Priority: P1）

ゲームエンジンは1ターンの処理中に、プロジェクト状況に応じたランダムイベントを判定し、
発生したイベントの一覧を返す。

**Why this priority**: ゲームの核心となる不確実性の源泉。これなしにはゲームが成立しない。

**Independent Test**: `event.ts` の `rollRandomEvents` を単独で呼び出し、
返却値が GameEvent[] 型であること・各イベントが仕様通りのパラメータを持つことを確認できる。

**Acceptance Scenarios**:

1. **Given** アクティブタスクが存在する GameState と空の activeEffects、
   **When** `rollRandomEvents` を呼び出す、
   **Then** 返却値は GameEvent[] であり、各イベントは id / type / category / targetId /
   params フィールドを持つ。
2. **Given** 5種のイベントを確率100%でシミュレートできる条件、
   **When** 各イベントが発生、
   **Then** stall は対象タスクIDと停滞ターン数（1 または 2）を params に持つ。
   rework は対象タスクIDと巻き戻し量を params に持つ。
   sick / low_motivation / fatigue は対象メンバーIDとパラメータ変化量を params に持つ。
3. **Given** activeEffects に `task_event_prob_reduced` が含まれる状態、
   **When** 大量サンプルで stall 発生率を計測、
   **Then** stall の発生率が通常時（補正なし）の半分程度になる。
4. **Given** アクティブタスクが0件の GameState、
   **When** `rollRandomEvents` を呼び出す、
   **Then** stall イベントと rework イベントは発生しない（タスク系イベントは空リスト）。
5. **Given** メンバーが0人の GameState、
   **When** `rollRandomEvents` を呼び出す、
   **Then** sick / low_motivation / fatigue イベントは発生しない。

---

### User Story 2 - イベントのプログレスマップへの反映（Priority: P2）

発生した手戻り・停滞イベントを、タスク進捗の差分マップ（progressMap）に反映できる。

**Why this priority**: rollRandomEvents の結果を実際の進捗計算に組み込むために必要。

**Independent Test**: `applyEventToProgress` に手戻り/停滞 GameEvent と progressMap を
渡し、正しく更新された新しい Map が返ることを単独テストで確認できる。

**Acceptance Scenarios**:

1. **Given** rework イベント（targetId="t1", params.reworkDelta=-15）と progressMap、
   **When** `applyEventToProgress` を呼び出す、
   **Then** 新しい Map の t1 のデルタが -15 だけ変化する。引数の Map は変化しない。
2. **Given** stall イベント（targetId="t1"）と progressMap、
   **When** `applyEventToProgress` を呼び出す、
   **Then** 新しい Map の t1 のデルタは 0 になる（停滞中は進捗増加なし）。
3. **Given** sick イベント（メンバーイベント）と progressMap、
   **When** `applyEventToProgress` を呼び出す、
   **Then** progressMap は変化しない（メンバーイベントは進捗に影響しない）。

---

### User Story 3 - イベントのメンバーパラメータへの反映（Priority: P2）

発生した sick / low_motivation / fatigue イベントを、メンバーのパラメータに反映できる。

**Why this priority**: イベントがメンバーへ与える影響を計算するために必要。

**Independent Test**: `applyEventToMember` に各イベントと Member を渡し、
パラメータが正しく変化した新しい Member が返ることを単独テストで確認できる。

**Acceptance Scenarios**:

1. **Given** sick イベントとメンバー（morale=100, health=100）、
   **When** `applyEventToMember` を呼び出す、
   **Then** 新しい Member の morale=92、health=90 になる。引数の Member は変化しない。
2. **Given** low_motivation イベントとメンバー（morale=100）、
   **When** `applyEventToMember` を呼び出す、
   **Then** 新しい Member の morale=90 になる。health は変化しない。
3. **Given** fatigue イベントとメンバー（health=10）、
   **When** `applyEventToMember` を呼び出す、
   **Then** 新しい Member の health はクランプされて 0 になる（MIN以下にならない）。
4. **Given** rework イベント（タスクイベント）と Member、
   **When** `applyEventToMember` を呼び出す、
   **Then** Member のパラメータは変化しない（タスクイベントはメンバーに影響しない）。

---

### User Story 4 - processTurn へのイベントエンジン統合（Priority: P1）

`processTurn` が `rollRandomEvents` を呼び出し、イベント結果を TurnResult.events に
格納し、progressMap とメンバーパラメータへ反映する。

**Why this priority**: ゲームループを完成させる最重要統合。MVP の核心。

**Independent Test**: `processTurn` を呼び出し、TurnResult.events が空でない可能性があり、
progressUpdates がイベントの影響を反映していることを確認できる。

**Acceptance Scenarios**:

1. **Given** 通常の GameState（アクティブタスクあり・メンバーあり）、
   **When** `processTurn` を大量サンプルで実行、
   **Then** TurnResult.events に少なくとも1件のランダムイベントが含まれるケースが存在する。
2. **Given** rework イベントが確実に発生する条件（Math.random モック）、
   **When** `processTurn` を実行、
   **Then** TurnResult.progressUpdates にrework相当の差分が反映される。
3. **Given** sick イベントが確実に発生する条件、
   **When** `processTurn` を実行、
   **Then** TurnResult.memberUpdates に sick 相当の morale/health デルタが含まれる。

---

### User Story 5 - イミュータブル操作（Priority: P3）

event.ts の全関数が引数を変更せず、新しい値を返す。

**Why this priority**: 他のゲームロジックモジュールと同じイミュータブル原則を遵守する。

**Independent Test**: 各関数の呼び出し前後で引数の参照・値が変化しないことを
fast-check プロパティテストで確認できる。

**Acceptance Scenarios**:

1. **Given** 任意の effects 配列と GameState、
   **When** `rollRandomEvents` を呼び出す、
   **Then** 引数の GameState と effects は変化しない。
2. **Given** 任意の progressMap と GameEvent、
   **When** `applyEventToProgress` を呼び出す、
   **Then** 引数の Map は変化しない（新しい Map が返る）。
3. **Given** 任意の Member と GameEvent、
   **When** `applyEventToMember` を呼び出す、
   **Then** 引数の Member は変化しない（新しい Member が返る）。

---

## Functional Requirements

### FR1: イベント種別と判定ルール

5種のランダムイベントを独立した確率で判定する。

| イベント | 判定対象 | 基本確率 | 効果 |
|----------|----------|----------|------|
| 停滞（stall） | アクティブタスク1件 | EVENT_PROB.STALL（補正あり） | 停滞ターン1or2 |
| 手戻り（rework） | アクティブタスク1件 | EVENT_PROB.REWORK（補正あり） | 進捗巻き戻し |
| 病気（sick） | メンバー1人 | EVENT_PROB.SICK | morale-8, health-10 |
| 低モチベーション | メンバー1人 | EVENT_PROB.LOW_MOTIVATION | morale-10 |
| 疲弊（fatigue） | メンバー1人 | EVENT_PROB.FATIGUE | health-8 |

### FR2: 確率補正

`calcEventProbModifier`（Spec-07）を使用して確率を補正する。

- stall: `task_event_prob_reduced` が activeEffects に含まれれば確率×0.5
- rework: `rework_prob_reduced` が activeEffects に含まれれば確率×0.5

### FR3: 停滞ターン数の決定

stall イベント発生時、停滞継続ターン数を確率的に決定する。

- STALL.ONE_TURN_PROB（60%）の確率で1ターン停滞
- 残り（40%）で2ターン停滞
- 停滞ターン数は params.stallTurns として GameEvent に格納

### FR4: 手戻り量の計算

rework イベント発生時、`applyRework`（Spec-02）を使用して巻き戻し量を計算する。
対象タスクの assignedMemberId から担当メンバーの skill を参照して計算する。

### FR5: パラメータクランプ

`applyEventToMember` は結果を MEMBER_PARAMS の MIN/MAX でクランプする。

- morale: 0〜150
- health: 0〜100

### FR6: イミュータブル操作

全関数はイミュータブル。引数を変更せず新しい値を返す。

### FR7: Phaser/DOM 非依存

`src/game/event.ts` は Phaser または DOM API を一切インポートしない。

---

## Success Criteria

1. `tests/unit/event.test.ts` の全テストが PASS する
2. `tests/unit/turn.test.ts` のイベント統合テストが PASS する
3. `npx vitest run --coverage` で `src/game/` 全体の lines ≥ 80%、functions ≥ 80%
4. `npx tsc --noEmit` が 0 エラーで終了する
5. `grep -r "phaser\|document\|window" src/game/event.ts` が 0 件

---

## Key Entities

| エンティティ | 説明 |
|------------|------|
| GameEvent | id / type / category / targetId / params を持つイベント記録 |
| GameState | ゲームの現在状態（メンバー・ガントチャート・アクティブ効果） |
| CardEffect | アクティブ効果（確率補正に使用） |
| Member | メンバーのパラメータ（morale / health） |
| progressMap | タスクIDをキーとした進捗デルタの Map |

---

## Scope Boundaries

**含む**:

- 停滞・手戻り・病気・低モチベーション・疲弊の5種のランダムイベント
- event.ts への切り出し（rollRandomEvents / applyEventToProgress / applyEventToMember）
- turn.ts の Step 5 を rollRandomEvents に置き換える統合

**含まない（別Spec）**:

- 条件付きイベント（ConditionalEvent の評価）
- 鼓舞・局所的勝利・残業などのポジティブイベント
- 過大報告・過小報告イベント
- チェックポイント（締め・週次会議）イベント

---

## Dependencies

- `src/game/types.ts` — GameEvent / GameState / Member / CardEffect 型
- `src/game/constants.ts` — EVENT_PROB / STALL / PARAM_DELTA / MEMBER_PARAMS
- `src/game/effect.ts` — calcEventProbModifier（Spec-07）
- `src/game/gantt.ts` — applyRework（Spec-02）

---

## Assumptions

- stall イベントと rework イベントは同一ターンに同一タスクへ重複発生することがある（独立判定）
- タスク系イベント（stall / rework）の対象タスクはアクティブタスクの中から一様ランダム選択
- メンバー系イベント（sick / low_motivation / fatigue）の対象メンバーは一様ランダム選択
- 同一メンバーへの複数メンバーイベント重複発生はありうる（独立判定）
- applyEventToProgress での停滞反映は「そのターンの進捗デルタを0にリセット」として実装
  （すでに progressMap に格納された値を上書きする）
