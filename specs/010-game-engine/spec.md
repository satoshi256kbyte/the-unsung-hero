# Feature Specification: GameEngine（フルターンループ）

**Feature Branch**: `010-game-engine`

**Created**: 2026-08-13

**Status**: Draft

## User Scenarios & Testing

### User Story 1 - ゲームエンジンの初期化（Priority: P1）

プレイヤーがステージを選択すると、そのステージデータからゲームの初期状態が構築される。
初期状態にはメンバー・ガントチャート・予算・納期が正しく設定されている。

**Why this priority**: すべてのターン処理の前提条件。エンジンが初期化できないとゲームが始まらない。

**Independent Test**: ステージデータを渡してエンジンを生成し、`getState()` が正しい初期状態を返すことをテストで確認できる。

**Acceptance Scenarios**:

1. **Given** 有効な StageData, **When** GameEngine を生成する, **Then** `getState().turn` が 1 である
2. **Given** 有効な StageData, **When** GameEngine を生成する, **Then** `getState().members` が `stageData.initialMembers` と一致する
3. **Given** 有効な StageData, **When** GameEngine を生成する, **Then** `getState().gantt` が `stageData.initialGantt` と一致する
4. **Given** 有効な StageData, **When** GameEngine を生成する, **Then** `getState().budget` が `stageData.budget` と一致する
5. **Given** 有効な StageData, **When** GameEngine を生成する, **Then** `isGameOver()` が `false` を返す

---

### User Story 2 - ターン処理の実行（Priority: P1）

プレイヤーがカードを選択してターンを進めると、進捗・メンバー状態・コストが更新され、
結果（イベント・進捗変化・メンバー変化）が返される。

**Why this priority**: ゲームの中核機能。ターンが進まなければゲームが成立しない。

**Independent Test**: 1ターン実行後に `getState()` の値が変化し、TurnResult に正しい情報が含まれることをテストで確認できる。

**Acceptance Scenarios**:

1. **Given** 初期化済みの GameEngine, **When** `processTurn([])` を呼び出す, **Then** TurnResult が返される
2. **Given** 初期化済みの GameEngine, **When** `processTurn([])` を呼び出す, **Then** `getState().turn` が 2 になる
3. **Given** 初期化済みの GameEngine, **When** `processTurn([])` を呼び出す, **Then** `getState().totalCost` が増加する
4. **Given** アクティブタスクがある GameEngine, **When** `processTurn([])` を呼び出す,
   **Then** ガントチャートのタスク進捗が更新される
5. **Given** メンバーがいる GameEngine, **When** `processTurn([])` を呼び出す,
   **Then** メンバーの morale/health が変化する（decay 適用）

---

### User Story 3 - ゲーム終了判定（Priority: P1）

全タスク完了または納期超過でゲームが終了し、以降のターン実行が拒否される。

**Why this priority**: ゲームループの終了条件。これがないとゲームが永遠に続く。

**Independent Test**: 納期を超えたターンで processTurn を呼び出すとゲームオーバーになり、
その後の呼び出しが拒否されることをテストで確認できる。

**Acceptance Scenarios**:

1. **Given** 全タスクが完了した GameEngine, **When** `processTurn([])` を呼び出す,
   **Then** `TurnResult.isGameOver` が `true` で `gameOverReason` が「全タスク完了」
2. **Given** 納期を超過した GameEngine, **When** `processTurn([])` を呼び出す,
   **Then** `TurnResult.isGameOver` が `true` で `gameOverReason` が「納期超過」
3. **Given** ゲームオーバー後の GameEngine, **When** 再度 `processTurn([])` を呼び出す,
   **Then** 例外がスローされる（それ以上ターンが進まない）
4. **Given** 通常進行中の GameEngine, **When** `isGameOver()` を呼び出す,
   **Then** `false` が返る
5. **Given** ゲームオーバー後の GameEngine, **When** `isGameOver()` を呼び出す,
   **Then** `true` が返る

---

### User Story 4 - memberUpdates の集計適用（Priority: P2）

1ターンで同一メンバーに複数の更新（カード効果・自然減退・イベント）が発生した場合、
それらが正しく合算されてメンバー状態に反映される。
パラメータは定められた範囲（最小値・最大値）に収まる。

**Why this priority**: Spec-08〜09 のメンバー更新統合ロジックをエンジン層で正しく実装する必要がある。
誤った集計はゲームバランスを崩す。

**Independent Test**: 複数の memberUpdate エントリを持つシナリオで morale/health の変化量が
合計値と一致し、最小値・最大値でクランプされることをテストで確認できる。

**Acceptance Scenarios**:

1. **Given** morale が 100 のメンバーに -30 の変化, **When** ターン処理, **Then** morale が 70 になる
2. **Given** morale が 10 のメンバーに -20 の変化, **When** ターン処理, **Then** morale が最小値でクランプされる
3. **Given** health が 90 のメンバーに +20 の変化, **When** ターン処理, **Then** health が最大値でクランプされる

---

### Edge Cases

- メンバーが0人のステージでターンを実行しても例外が発生しない
- タスクが0件のステージでターンを実行すると即座にゲームオーバーになる可能性がある
- ターン1で納期が1のステージ（deadline = 1）では最初のターンでゲームオーバーになりうる
- conditionalEvents が空のステージでも正常に動作する
- 全タスクが完了した瞬間のターンでゲームオーバーが検出される

## Functional Requirements

1. **初期化**: `GameEngine(stageData)` は StageData から GameState を構築し、turn=1、totalCost=0、
   isGameOver=false の初期状態を設定する
2. **ターン実行**: `processTurn(cards)` はゲームロジック層の `processTurn` を呼び出し、
   その結果をもとに GameState を更新して TurnResult を返す
3. **進捗更新**: TurnResult.progressUpdates をガントチャートに反映し、完了タスクは done、
   デルタが0以下のターンでは stalled に遷移する
4. **メンバー更新**: 同一メンバーへの複数の MemberUpdate を合算し、MEMBER_PARAMS の範囲にクランプして適用する
5. **コスト更新**: totalCost に TurnResult.costDelta を加算する
6. **ターン進行**: 毎ターン後に turn を +1 する
7. **ゲーム終了検出**: TurnResult.isGameOver が true になった時点で GameState の isGameOver を更新し、
   以降の processTurn 呼び出しで例外をスローする
8. **状態取得**: `getState()` は現在の GameState を返す（外部からの変更を防ぐため readonly または
   コピーを返す）
9. **ゲームオーバー確認**: `isGameOver()` は現在の isGameOver を boolean で返す
10. **アーキテクチャ境界**: `src/game/` 内に実装し、Phaser/DOM を一切インポートしない

## Success Criteria

- GameEngine の初期化テストがすべて通過する
- 複数ターン実行シナリオ（5ターン以上）でゲームが正常に進行する
- ゲームオーバー後の processTurn 呼び出しが必ず例外をスローする
- memberUpdates の合算・クランプが正しく適用される（テストで検証）
- 全テスト（既存249件 + 新規テスト）がすべて通過する
- テストカバレッジが lines ≥ 80%、functions ≥ 80% を維持する
- `tsc --noEmit` がエラー0で通過する

## Key Entities

| エンティティ | 説明 |
|-------------|------|
| `GameEngine` | ゲーム全体の状態を管理するクラス |
| `GameState` | ターン・メンバー・ガントチャート・予算等を持つゲーム状態 |
| `StageData` | ステージの初期データ（初期メンバー・ガント・予算・納期・条件付きイベント） |
| `TurnResult` | 1ターンの処理結果（イベント・進捗・メンバー変化・ゲーム終了判定） |

## Dependencies

- Spec-02: ガントチャート・タスクモデル（`updateTaskProgress` / `getCompletionRate`）
- Spec-04: メンバーパラメータ変動エンジン（`MEMBER_PARAMS` 境界値）
- Spec-05〜09: ターン処理エンジン（`processTurn`）

## Assumptions

- `GameState` に `stageConditionalEvents` フィールドを追加するか、
  GameEngine が内部で conditionalEvents を保持して processTurn に渡す
  （本 Spec では GameEngine が stageData.conditionalEvents を内部保持する方式を採用）
- `getState()` は GameState の shallow copy を返す（深いコピーは不要）
- hand（カード手札）は GameEngine では更新しない（Spec-11 で管理）
- 透明性（transparency）・緊張感（tension）は GameEngine では変更しない（将来の Spec で実装）
