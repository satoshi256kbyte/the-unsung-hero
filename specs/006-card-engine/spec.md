# Feature Specification: カード効果エンジン

**Feature Branch**: `006-card-engine`

**Created**: 2026-08-13

**Status**: Draft

## User Scenarios & Testing

### User Story 1 - 確率低減カードが activeEffects に記録される (Priority: P1)

PMがデイリー・レビュー・モニタリングカードを使用すると、対応する確率低減効果が
activeEffects として記録され、次ターン以降の手戻り・停滞確率の計算に利用できる。

**Why this priority**: ゲームの基本戦略（デイリー＋レビュー＋モニタリングの継続）の核心。
turn.ts でこの情報を参照してランダムイベント確率を動的に変えるために必要。

**Independent Test**: デイリー・レビュー・モニタリングをそれぞれ含む cards 配列で
applyCards を呼び出したとき、戻り値の effectsToAdd に対応する effectType が含まれること。

**Acceptance Scenarios**:

1. **Given** デイリーを含む cards 配列、**When** applyCards を呼び出す、
   **Then** effectsToAdd に effectType='task_event_prob_reduced' のエントリが含まれる
2. **Given** レビューを含む cards 配列、**When** applyCards を呼び出す、
   **Then** effectsToAdd に effectType='rework_prob_reduced' のエントリが含まれる
3. **Given** モニタリングを含む cards 配列、**When** applyCards を呼び出す、
   **Then** effectsToAdd に effectType='overreport_prob_reduced' のエントリが含まれる
4. **Given** 空の cards 配列、**When** applyCards を呼び出す、
   **Then** effectsToAdd は空配列、memberUpdates は空配列

---

### User Story 2 - 即時メンバー系カードが memberUpdates として返される (Priority: P2)

PMが個別面談・表彰・計画休カードを使用すると、対象メンバーの心・体が即時に回復する。
回復量は定数ファイルで管理された値を使用する。

**Why this priority**: メンバーの心・体が低下した際の回復手段。US1の確率低減と並んで
ゲームの主要な介入手段であるため P2。

**Independent Test**: 個別面談を含む cards 配列で applyCards を呼び出したとき、
戻り値の memberUpdates に moraleDelta が含まれること。

**Acceptance Scenarios**:

1. **Given** 個別面談を含む cards 配列・メンバーが 1 人以上いる GameState、
   **When** applyCards を呼び出す、
   **Then** memberUpdates[0].moraleDelta === ONE_ON_ONE_MORALE（15）
2. **Given** 表彰を含む cards 配列、**When** applyCards を呼び出す、
   **Then** memberUpdates[0].moraleDelta === COMMENDATION_MORALE（30）
3. **Given** 計画休を含む cards 配列、**When** applyCards を呼び出す、
   **Then** memberUpdates[0].moraleDelta === PLANNED_LEAVE_MORALE（20）かつ
   memberUpdates[0].healthDelta === PLANNED_LEAVE_HEALTH（25）

---

### User Story 3 - 引数の GameState が変化しない (Priority: P3)

applyCards を呼び出した後も、引数として渡した GameState のフィールドが
変化していないことを保証する（イミュータブル操作）。

**Why this priority**: ゲームエンジン全体のイミュータブル原則の一貫性維持。
turn.ts が TurnResult の差分を返すアーキテクチャと整合する。

**Independent Test**: applyCards 呼び出し前後で state.members / state.activeEffects の
参照が変化しないこと。

**Acceptance Scenarios**:

1. **Given** 任意の GameState と cards 配列、**When** applyCards を呼び出す、
   **Then** state.members は変化しない
2. **Given** 任意の GameState と cards 配列、**When** applyCards を呼び出す、
   **Then** state.activeEffects は変化しない

---

### Edge Cases

- cards 配列が空のとき: effectsToAdd と memberUpdates がどちらも空配列を返す
- 即時系カード（個別面談等）でメンバーが 0 人のとき: memberUpdates は空配列を返す（panic しない）
- 同じカードが cards 配列に複数含まれるとき: それぞれ独立してエントリを追加する
- 上記 6 種以外のカード（スコープ外）が含まれるとき: 無視して処理を続行する

## Requirements

### Functional Requirements

- **FR-001**: システムは、カード名の配列を受け取り、各カードの効果を
  effectsToAdd（CardEffect[]）と memberUpdates（MemberUpdate[]）として返さなければならない
- **FR-002**: システムは、デイリーカードを受け取ったとき、
  effectType='task_event_prob_reduced' の CardEffect を effectsToAdd に追加しなければならない
- **FR-003**: システムは、レビューカードを受け取ったとき、
  effectType='rework_prob_reduced' の CardEffect を effectsToAdd に追加しなければならない
- **FR-004**: システムは、モニタリングカードを受け取ったとき、
  effectType='overreport_prob_reduced' の CardEffect を effectsToAdd に追加しなければならない
- **FR-005**: システムは、個別面談カードを受け取ったとき、
  対象メンバーの moraleDelta = ONE_ON_ONE_MORALE の MemberUpdate を返さなければならない
- **FR-006**: システムは、表彰カードを受け取ったとき、
  対象メンバーの moraleDelta = COMMENDATION_MORALE の MemberUpdate を返さなければならない
- **FR-007**: システムは、計画休カードを受け取ったとき、
  対象メンバーの moraleDelta = PLANNED_LEAVE_MORALE かつ healthDelta = PLANNED_LEAVE_HEALTH の
  MemberUpdate を返さなければならない
- **FR-008**: システムは、引数の GameState を変更してはならない（イミュータブル操作）
- **FR-009**: システムは、スコープ外のカードを受け取ったとき、そのカードを無視しなければならない
- **FR-010**: システムは、Phaser および DOM API に一切依存してはならない

### Key Entities

- **CardApplicationResult**: applyCards の戻り値。effectsToAdd（追加するCardEffect一覧）と
  memberUpdates（即時パラメータ変化一覧）の2フィールドを持つ
- **CardEffect**: effectType / targetId / cardName / remainingTurns を持つ効果エンティティ
  （Spec-01 types.ts で定義済み）
- **MemberUpdate**: memberId / moraleDelta / healthDelta を持つパラメータ変化エンティティ
  （Spec-01 types.ts で定義済み）

## Success Criteria

### Measurable Outcomes

- **SC-001**: 全関数の型チェックがエラーゼロで通る
- **SC-002**: 6 種のカードそれぞれについて、正しい effectsToAdd または memberUpdates が
  返されることのテストが全件 PASS する
- **SC-003**: fast-check プロパティテストで任意の合法 GameState・CardName[] を入力しても
  panic しないことを確認できる
- **SC-004**: `grep -r "phaser\|document\|window" src/game/card.ts` が 0 件
- **SC-005**: vitest coverage で lines / functions ≥ 80% を達成する

## Assumptions

- GameState・CardEffect・MemberUpdate・CardName 型は Spec-01 の `src/game/types.ts` で定義済み
- PARAM_DELTA（ONE_ON_ONE_MORALE / COMMENDATION_MORALE / PLANNED_LEAVE_MORALE /
  PLANNED_LEAVE_HEALTH）は Spec-01 の `src/game/constants.ts` で定義済み
- 即時系カードのターゲット解決は今回 `state.members[0]`（最初のメンバー）とする最小実装とし、
  完全な自動解決ルール（最も心が低いメンバー等）は後続 Spec で実装する
- 確率低減カード（グループA）の targetId は 'project'（プロジェクト全体への効果）とする
- 確率低減カードの remainingTurns は null（手動解除まで継続）とする
- cards 配列の順序通りに処理する（先入れ順）
- 同一カードが複数含まれる場合は複数エントリを生成する（重複排除はしない）
- カード効果の削除・自動解除ロジック（remainingTurns のデクリメント等）は別 Spec で実装する
