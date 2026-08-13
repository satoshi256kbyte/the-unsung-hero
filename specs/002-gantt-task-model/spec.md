# Feature Specification: ガントチャート・タスクモデル

**Feature Branch**: `002-gantt-task-model`

**Created**: 2026-08-12

**Status**: Draft

## User Scenarios & Testing

### User Story 1 - タスクの進捗を更新できる (Priority: P1)

ゲームエンジンが各ターンに「このメンバーがこのタスクをどれだけ進めたか」を
ガントチャートへ反映できる。進捗が100%に達したタスクは自動的に完了状態になる。

**Why this priority**: 進捗更新はゲームの根幹。これがなければターン処理エンジン（Spec-05）が作れない。

**Independent Test**: 進捗0%のタスクに対して進捗量を渡したとき、
タスクの進捗値が正しく加算され、100%超過時に `done` になることを確認できる。

**Acceptance Scenarios**:

1. **Given** 進捗30%のタスク、**When** 進捗量+20%を適用、**Then** 進捗50%・status `active`
2. **Given** 進捗80%のタスク、**When** 進捗量+30%を適用、**Then** 進捗100%・status `done`
3. **Given** 進捗100%のタスク、**When** 進捗量+10%を適用、**Then** 進捗は100%を超えない

---

### User Story 2 - タスクの状態を遷移できる (Priority: P2)

手戻り・停滞・完了などのゲームイベントに応じてタスクの状態（`active` / `stalled` / `done`）を
正しく切り替えられる。状態変化により後続の処理が制御される。

**Why this priority**: 停滞・手戻りはゲームバランスの核心。状態遷移が正確でないと
イベントエンジン（Spec-06）が誤動作する。

**Independent Test**: 各状態への遷移（active→stalled, stalled→active, active→done）を
それぞれ単独で呼び出して、結果を検証できる。

**Acceptance Scenarios**:

1. **Given** `active` タスク、**When** 停滞イベント発生、**Then** status が `stalled`
2. **Given** `stalled` タスク、**When** 停滞解消、**Then** status が `active`
3. **Given** `active` タスク、**When** 手戻りイベント、**Then** 進捗が巻き戻り量だけ減少・status は `active` のまま

---

### User Story 3 - バリアントへ切り替えられる (Priority: P3)

条件付きイベント（仕様追加・リスケなど）の発生時に、あらかじめ用意された
代替ガントチャート（バリアント）へ差し替えられる。
差し替え後は新しいタスク構成・期間でゲームが継続できる。

**Why this priority**: 条件付きイベント（Spec-06）の前提機能。
バリアントなしでも P1/P2 は独立して動く。

**Independent Test**: バリアントIDを指定してガントチャートを差し替えたとき、
指定IDのバリアントのタスク構成が現在のガントに反映されることを確認できる。

**Acceptance Scenarios**:

1. **Given** バリアント `spec-added` を持つステージデータ、
   **When** バリアントID `spec-added` で差し替え要求、
   **Then** ガントのタスク一覧が `spec-added` のものに置き換わる
2. **Given** 存在しないバリアントIDで差し替え要求、
   **Then** 差し替えが行われず元のガントが保持される

---

### Edge Cases

- タスクの依存先がまだ `done` でないとき、そのタスクへの進捗付与はどう扱うか
  （→ 依存未解決タスクへの進捗付与は無視する）
- 進捗量がマイナス値の場合（手戻り）は0未満にクランプする
- バリアントへの切り替え後、すでに完了していたタスクの扱い
  （→ 新バリアントのタスク構成をそのまま適用する。既存の完了状態は引き継がない）

## Requirements

### Functional Requirements

- **FR-001**: システムは、指定タスクの進捗値に進捗量を加算し、0〜100の範囲にクランプしなければならない
- **FR-002**: システムは、タスク進捗が100に達したとき、そのタスクの status を `done` に自動遷移させなければならない
- **FR-003**: システムは、タスクの status を任意の状態（`active` / `stalled` / `done`）に設定できなければならない
- **FR-004**: システムは、手戻りイベント時に「40% − 技 × 1%」の巻き戻し率でタスク進捗を減算し、0未満にクランプしなければならない
- **FR-005**: システムは、ガントチャート全体の完了率（完了タスク数 ÷ 全タスク数）を返せなければならない
- **FR-006**: システムは、指定バリアントIDが存在する場合にガントチャートをそのバリアントへ差し替えられなければならない
- **FR-007**: システムは、指定バリアントIDが存在しない場合は差し替えを行わず現状を維持しなければならない
- **FR-008**: システムは、Phaser および DOM API に一切依存してはならない

### Key Entities

- **GanttChart**: ガントチャート全体。タスク一覧と現在適用中のバリアントIDを保持する
- **GanttTask**: タスク1件。ID・名前・工程・開始ターン・期間・担当メンバー・進捗・状態・依存関係を持つ
- **StageData.ganttVariants**: バリアントIDをキーとした代替ガントチャートのマップ

## Success Criteria

### Measurable Outcomes

- **SC-001**: 全機能関数（進捗更新・状態遷移・完了率計算・バリアント切り替え）の型チェックがエラーゼロで通る
- **SC-002**: 境界値テスト（進捗0/100/超過・手戻り・バリアント存在/不存在）が全件 PASS する
- **SC-003**: fast-check プロパティテストで任意の進捗量・技レベルを入力しても
  パニックせず 0〜100 の範囲内に収まることを確認できる
- **SC-004**: `grep -r "phaser\|document\|window" src/game/gantt.ts` が 0 件

## Assumptions

- GanttTask と GanttChart の型定義は Spec-01 の `src/game/types.ts` で定義済みであることを前提とする
- 手戻り巻き戻し率の計算定数（`REWORK.ROLLBACK_BASE` / `REWORK.ROLLBACK_COEFF`）は
  Spec-01 の `src/game/constants.ts` に定義済みであることを前提とする
- バリアントは `StageData.ganttVariants` として事前定義されており、
  実行時に動的生成はしない（ガントチャートバリエーション設計方針に準拠）
- 依存タスクが未完了の場合の進捗付与については、このSpecではブロックせず無視する
  （依存関係のバリデーションは Spec-05 のターン処理エンジンで制御する）
