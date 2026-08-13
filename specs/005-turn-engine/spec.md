# Feature Specification: ターン処理エンジン

**Feature Branch**: `005-turn-engine`

**Created**: 2026-08-13

**Status**: Draft

## User Scenarios & Testing

### User Story 1 - 1ターンの基本処理が実行される (Priority: P1)

ゲームエンジンが1ターン分の処理を一括して実行できる。
カード効果の適用、メンバーの進捗ダイス、パラメータ変動がまとめて処理され、
結果（進捗変化・パラメータ変化）が呼び出し元に返される。

**Why this priority**: ゲームループの中核。これなしでは1ターンも進行できない。

**Independent Test**: processTurn を1回呼び出したとき、戻り値の TurnResult に
progressUpdates・memberUpdates が含まれ、ターン数が1進んでいることを確認できる。

**Acceptance Scenarios**:

1. **Given** 初期 GameState（ターン1・メンバー2人・タスク複数）、**When** processTurn を呼び出す、
   **Then** TurnResult.progressUpdates に各メンバー担当タスクの進捗変化量が含まれる
2. **Given** 同じ GameState、**When** processTurn を呼び出す、
   **Then** TurnResult.memberUpdates に全メンバーの心・体変化量が含まれる
3. **Given** 同じ GameState、**When** processTurn を呼び出す、
   **Then** 引数の GameState は変化しない（イミュータブル操作）

---

### User Story 2 - 5ターンごとに週末回復が適用される (Priority: P2)

5ターン（5稼働日＝1週間）ごとに自動的に週末回復が適用される。
プレイヤーは何もしなくても毎週末メンバーの心・体が回復する。

**Why this priority**: 長期プレイのバランス維持に必要。週末回復なしでは22ターンで体がゼロになる。

**Independent Test**: ターン5で processTurn を呼び出したとき、
TurnResult.memberUpdates の health 変化量が通常より大きいことを確認できる
（HEALTH_NATURAL_MIN〜HEALTH_NATURAL_MAX の通常減衰 + WEEKEND_HEALTH_RECOVERY の回復）。

**Acceptance Scenarios**:

1. **Given** turn=5 の GameState、**When** processTurn を呼び出す、
   **Then** TurnResult.memberUpdates に週末回復量（心+8、体+12）が通常変動に加算された値が含まれる
2. **Given** turn=4 の GameState（週末前）、**When** processTurn を呼び出す、
   **Then** 週末回復は適用されない

---

### User Story 3 - ゲームオーバー条件が判定される (Priority: P3)

全タスク完了または納期超過でゲームオーバーが検出される。
ゲームエンジンはターン終了時に終了条件を評価し、結果を呼び出し元に伝える。

**Why this priority**: ゲームの勝敗判定の基盤。Spec-05の完結に必要。

**Independent Test**: 全タスク完了の GameState で processTurn を呼び出したとき、
TurnResult.isGameOver が true になることを確認できる。

**Acceptance Scenarios**:

1. **Given** 全タスクが完了済みの GameState、**When** processTurn を呼び出す、
   **Then** TurnResult.isGameOver = true、TurnResult.gameOverReason が設定される
2. **Given** turn が deadline を超える GameState、**When** processTurn を呼び出す、
   **Then** TurnResult.isGameOver = true、TurnResult.gameOverReason に納期超過が設定される
3. **Given** 進行中の GameState（タスク未完了・turn < deadline）、
   **When** processTurn を呼び出す、**Then** TurnResult.isGameOver = false

---

### Edge Cases

- 担当メンバーが存在しないタスクへの進捗付与は行わない
- 全メンバーの心・体がすでに 0 でも panicしない（クランプにより 0 以上を保つ）
- 手戻りイベントが発生しても進捗が負にならない（0 にクランプ）
- cards 引数が空配列でも正常に動作する

## Requirements

### Functional Requirements

- **FR-001**: システムは、1ターンの処理（カード適用・進捗ダイス・パラメータ変動・イベント判定・終了条件評価）を
  1回の関数呼び出しで実行しなければならない
- **FR-002**: システムは、各メンバーの担当タスクに rollProgress の結果を進捗として反映しなければならない
- **FR-003**: システムは、毎ターン applyTurnDecay を全メンバーに適用しなければならない
- **FR-004**: システムは、5ターンごとに applyWeekendRecovery を全メンバーに適用しなければならない
- **FR-005**: システムは、EVENT_PROB.REWORK の確率で手戻りイベントを発生させ、
  ランダムな1タスクに applyRework を適用しなければならない
- **FR-006**: システムは、全タスクの完了率が 100% に達したとき isGameOver = true を返さなければならない
- **FR-007**: システムは、現在ターンが deadline を超えたとき isGameOver = true を返さなければならない
- **FR-008**: システムは、引数の GameState を変更してはならない（イミュータブル操作）
- **FR-009**: システムは、Phaser および DOM API に一切依存してはならない

### Key Entities

- **GameState**: 現在のゲーム全状態（ターン数・メンバー・ガントチャート・予算・activeEffects等）
- **TurnResult**: 1ターンの処理結果（progressUpdates・memberUpdates・events・costDelta・isGameOver等）
- **CardName**: 使用するカード名の配列（今回はactiveEffectsへの追加のみ）

## Success Criteria

### Measurable Outcomes

- **SC-001**: 全関数の型チェックがエラーゼロで通る
- **SC-002**: 1ターン処理の結果として progressUpdates・memberUpdates が返されることを確認できる
- **SC-003**: ゲームオーバー条件（全タスク完了・納期超過）のテストが全件 PASS する
- **SC-004**: fast-check プロパティテストで任意の合法 GameState を入力しても panicしないことを確認できる
- **SC-005**: `grep -r "phaser\|document\|window" src/game/turn.ts` が 0 件

## Assumptions

- GameState・TurnResult 型は Spec-01 の `src/game/types.ts` で定義済みであることを前提とする
- gantt.ts（Spec-02）・dice.ts（Spec-03）・member.ts（Spec-04）が実装済みであることを前提とする
- cards 引数は今回 activeEffects への追加処理のみ（カード効果の完全実装は別 Spec で行う）
- メンバー担当タスクの解決は「タスクの assignedMemberId とメンバー id の一致」で行う
- 手戻りイベントの対象タスクは activeな（status='active'）タスクからランダムに選択する
- コスト計算（costDelta）は今回「1ターン = POC_STAGE.DAILY_COST_CAP × メンバー数」の固定値とする
