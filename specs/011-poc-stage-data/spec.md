# Feature Specification: PoCステージデータ

**Feature Branch**: `011-poc-stage-data`

**Created**: 2026-08-13

**Status**: Draft

**Input**: User description: "PoCステージデータを実装する。GameEngine に渡す最初のステージデータ定義。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - PoCステージで GameEngine を初期化できる (Priority: P1)

プレイヤーが PoCステージを選択したとき、
GameEngine に `pocStage` を渡すことで正しい初期状態（メンバー3名・ガントタスク群・予算・納期）が
構築される。

**Why this priority**: ゲームを動かすために最初に必要なステージデータ。
これがなければ他の全機能が動作しない。

**Independent Test**: `new GameEngine(pocStage)` が例外なく生成でき、
`getState()` が期待する初期値を返すことを確認できる。

**Acceptance Scenarios**:

1. **Given** `pocStage` が正しく定義されている、**When** `new GameEngine(pocStage)` を呼ぶ、
   **Then** `getState().turn === 1`、`getState().members.length === 3`、
   `getState().budget === 5_000_000`、`getState().deadline === 22` が成立する
2. **Given** pocStage が初期化済み、**When** `getState().gantt.tasks` を参照する、
   **Then** 8〜10個のタスクが存在しすべての `status` が `'active'` または `'waiting'` である
3. **Given** pocStage が初期化済み、**When** `getState().hand` を参照する、
   **Then** 2〜3枚の有効な CardName が含まれる

---

### User Story 2 - ガントチャートタスクが PoC の工程を正しく表現する (Priority: P2)

PoC開発プロジェクトの標準工程（要件定義→設計→実装→テスト→リリース準備）が
タスクとして定義されており、依存関係・担当メンバー・開始ターン・期間が
22ターン以内に収まっている。

**Why this priority**: ゲームプレイの基盤となる工程定義。
正しい工程が定義されることでゲームバランスが成立する。

**Independent Test**: 全タスクの `startTurn + duration` が `deadline(22)` 以下であること、
依存関係が循環しないことをテストで検証できる。

**Acceptance Scenarios**:

1. **Given** ガントタスク一覧、**When** 各タスクの `startTurn + duration` を確認する、
   **Then** すべてのタスクが `deadline(22)` 以内に完了できる計画である
2. **Given** ガントタスク一覧、**When** 依存関係グラフを走査する、
   **Then** 循環依存が存在しない
3. **Given** ガントタスク一覧、**When** 担当メンバーIDを確認する、
   **Then** すべての assignedMemberId が `initialMembers` のいずれかと一致する

---

### User Story 3 - 条件付きイベントが適切な条件で発火する (Priority: P3)

定義された3〜5件の条件付きイベントが、
`evaluateCondition` によって正しく評価される条件式を持っており、
ゲーム進行中に適切なタイミングで発火する。

**Why this priority**: ゲームの難易度バランスを担う機能。
P1・P2が安定した後にテストできる。

**Independent Test**: 各 `conditionalEvents[i].condition` が
`evaluateCondition` の受け付けるパターン（Spec-09定義）と一致することを
文字列レベルで検証できる。

**Acceptance Scenarios**:

1. **Given** pocStage の conditionalEvents、**When** 各 condition 文字列を確認する、
   **Then** すべての条件式が `evaluateCondition` の9パターンのいずれかにマッチする
2. **Given** `turn >= N` 条件のイベント、**When** ターンNに達した GameState を渡す、
   **Then** `evaluateCondition` が `true` を返す
3. **Given** GameEngine で22ターン進行する、**When** 条件が成立するターンを迎える、
   **Then** `TurnResult.events` に条件付きイベント由来のイベントが含まれる

---

### Edge Cases

- メンバーIDが `assignedMemberId` に存在しない場合、タスク進捗計算が失敗しないか
- `startTurn` が 1 より小さいタスクが定義された場合のガード
- `initialCards` に無効な CardName が含まれた場合（型チェックで防止）
- 条件付きイベントの `turn` フィールドが `deadline` を超えている場合は発火しない

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `pocStage` は `StageData` 型に完全に準拠したオブジェクトでなければならない
- **FR-002**: `initialMembers` にはアリス（skill=12）・ボブ（skill=8）・キャロル（skill=6）の3名が含まれなければならない
- **FR-003**: `budget` は 5,000,000（500万円）、`deadline` は 22（ターン）でなければならない
- **FR-004**: `initialGantt.tasks` は PoC工程の8〜10タスクを含み、全タスクが deadline 以内に収まる計画でなければならない
- **FR-005**: すべてのタスクの `assignedMemberId` は `initialMembers` のいずれかの `id` と一致しなければならない
- **FR-006**: `conditionalEvents` は3〜5件定義し、各条件式は `evaluateCondition` が評価できる文字列でなければならない
- **FR-007**: `initialCards` は2〜3枚の有効な `CardName` でなければならない
- **FR-008**: ガントタスクの依存関係（`dependencies`）は循環しないこと
- **FR-009**: すべての `startTurn` は1以上の整数であること
- **FR-010**: `ganttVariants` は空オブジェクト `{}` であること（バリアントは今回スコープ外）

### Key Entities

- **pocStage**: `StageData` 型の定数オブジェクト。ゲームの初期状態を完全に定義する
- **GanttTask（PoC工程）**: 要件定義・設計・実装・テスト・リリース準備の各フェーズのタスク群
- **ConditionalEvent（PoC向け）**: 進捗率・ターン数・予算残高・メンバー状態に反応するイベント定義

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `new GameEngine(pocStage)` が例外なく生成でき、初期値が仕様と一致する（全テストPASS）
- **SC-002**: ガントタスク全件の `startTurn + duration <= deadline` が成立する
- **SC-003**: 依存関係グラフに循環が存在しない
- **SC-004**: 条件付きイベント全件の条件式が `evaluateCondition` の受け付けるパターンに一致する
- **SC-005**: GameEngine で22ターンを超えずにゲームが進行完了できる（統合テストで確認）
- **SC-006**: TypeScriptの型チェックがエラー0で通過する

## Assumptions

- `evaluateCondition` は Spec-09で実装済みの9パターンの文字列マッチングを使用する
- `GameEngine` は Spec-10で実装済みのクラスを使用する
- バリアント機能（ganttVariants）は本Specのスコープ外であり空オブジェクトで問題ない
- タスクの `progress` の初期値は0、`status` の初期値は `'active'`
- PoC工程の詳細なタスク分割は、22ターン・3名体制・予算500万円に収まる現実的な規模とする
- E2Eテスト（Playwright）はスコープ外（ロジックのみ検証）
