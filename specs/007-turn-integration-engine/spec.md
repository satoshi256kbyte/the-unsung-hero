# Feature Specification: ターン統合エンジン（カード効果 × アクティブ効果管理）

**Feature Branch**: `007-turn-integration-engine`

**Created**: 2026-08-13

**Status**: Draft

**Input**: User description: "ターン統合エンジン（カード効果 × アクティブ効果管理）を実装する"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - カード効果がターン処理に適用される (Priority: P1)

PMがターンにカードを使用すると、そのカード効果が当ターンのイベント確率計算やメンバーパラメータに
即時反映される。デイリー・レビュー・モニタリングを置くことで手戻りや停滞の確率が下がり、
個別面談・表彰・計画休でメンバーの心・体が即時回復する。

**Why this priority**: Spec-05 の `void cards` プレースホルダーを実際に動かすことが
このSpecの最大の目的であり、ゲームの中心的なループを完成させる。

**Independent Test**: カードありのターンを実行し、TurnResult の内容（進捗更新・メンバー更新・
アクティブ効果変化）が cards なしのターンと異なることを確認することで単独テスト可能。

**Acceptance Scenarios**:

1. **Given** デイリーカードを含む cards でターン処理を行う,
   **When** processTurn を呼び出す,
   **Then** TurnResult の activeEffectsAdded に task_event_prob_reduced 効果が含まれる
2. **Given** 個別面談カードを含む cards でターン処理を行う,
   **When** processTurn を呼び出す,
   **Then** TurnResult の memberUpdates に対象メンバーの moraleDelta が含まれる
3. **Given** レビューカードなしでターン処理を行う,
   **When** 手戻りイベント発生確率を評価する,
   **Then** EVENT_PROB.REWORK がそのまま使用される
4. **Given** レビューカードありでターン処理を行う,
   **When** 手戻りイベント発生確率を評価する,
   **Then** EVENT_PROB.REWORK × 0.5 が使用される

---

### User Story 2 - アクティブ効果が tick でライフサイクル管理される (Priority: P2)

ターン終了時に、有効期限付き（remainingTurns > 0）のアクティブ効果は残りターン数が1減算され、
0になった効果は自動除去される。永続効果（remainingTurns = null）はターンを跨いで継続する。

**Why this priority**: 効果の蓄積による意図しないバフが発生しないためのライフサイクル管理が必要。
カード枠設計（永続効果と期限付き効果の分離）を実装するための基盤となる。

**Independent Test**: remainingTurns が 1 の効果を持つ GameState でターン処理を実行し、
TurnResult の activeEffectsAfterTick からその効果が除去されていることを確認できる。

**Acceptance Scenarios**:

1. **Given** remainingTurns=1 の CardEffect を持つ GameState,
   **When** applyEffectTick を呼び出す,
   **Then** その効果は結果リストから除去される
2. **Given** remainingTurns=3 の CardEffect を持つ GameState,
   **When** applyEffectTick を呼び出す,
   **Then** 結果リストに remainingTurns=2 の同効果が含まれる
3. **Given** remainingTurns=null の CardEffect を持つ GameState,
   **When** applyEffectTick を呼び出す,
   **Then** 効果は除去されず remainingTurns=null のまま保持される
4. **Given** 複数の効果が混在する GameState,
   **When** applyEffectTick を呼び出す,
   **Then** null 効果は保持、期限切れ効果は除去、残存効果はデクリメントされる

---

### User Story 3 - アクティブ効果による確率補正が正しく機能する (Priority: P2)

activeEffects の内容に応じてイベント発生確率が補正される。
rework_prob_reduced 効果があれば手戻り確率が半減し、
task_event_prob_reduced 効果があれば停滞確率が半減する。
効果がなければ基本確率がそのまま使われる。

**Why this priority**: カードを置く戦略的意義（確率低減）がゲームプレイに実際に影響するために必要。
US1 と同時に実装されるが、確率補正単体のテストを分離して記述することで品質を保証する。

**Independent Test**: calcEventProbModifier 関数を直接呼び出し、
効果あり/なしで期待通りの確率値が返ることを確認できる。

**Acceptance Scenarios**:

1. **Given** rework_prob_reduced 効果が activeEffects にある,
   **When** 手戻りイベント確率を計算する,
   **Then** 基本確率の 0.5 倍の値が返る
2. **Given** rework_prob_reduced 効果が activeEffects にない,
   **When** 手戻りイベント確率を計算する,
   **Then** 基本確率がそのまま返る
3. **Given** task_event_prob_reduced 効果が activeEffects にある,
   **When** 停滞イベント確率を計算する,
   **Then** 基本確率の 0.5 倍の値が返る
4. **Given** 複数の同種効果が activeEffects にある,
   **When** 確率補正を計算する,
   **Then** 効果は 1 つとして扱い 0.5 倍のみ適用される（重複スタックなし）

---

### User Story 4 - イミュータブル操作・引数不変 (Priority: P3)

effect.ts の全関数は引数の GameState・CardEffect[] を変更せず、
新しいオブジェクト・配列を返す。turn.ts も同様に processTurn の引数 state を変更しない。

**Why this priority**: イミュータブル設計はテスト容易性と Phaser Scene との責務分離を保証する
Constitution の非交渉原則。全 Spec 共通の品質ゲート。

**Independent Test**: applyEffectTick 呼び出し後に元の effects 配列参照が変化していないことを
確認するテストで単独検証できる。

**Acceptance Scenarios**:

1. **Given** activeEffects リストを持つ GameState,
   **When** applyEffectTick を呼び出す,
   **Then** 引数に渡した元の effects 配列の参照・値が変化しない
2. **Given** cards を含む processTurn 呼び出し,
   **When** processTurn を実行する,
   **Then** 引数 state の activeEffects・members が変化しない

---

### Edge Cases

- activeEffects が空配列のとき calcEventProbModifier は基本確率をそのまま返す
- cards が空配列のとき effectsToAdd・memberUpdates が空の TurnResult が返る
- remainingTurns が 0 の効果は tick で即除去される（デクリメント前に除去）
- 全メンバーが 0 人のとき memberUpdates の即時適用でパニックしない
- 複数の rework_prob_reduced 効果が重複していても確率は 0.5 倍のみ（スタックしない）

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: processTurn は applyCards を呼び出し CardApplicationResult を得ること
- **FR-002**: effectsToAdd は TurnResult に含めて返すこと（GameState を直接更新しない）
- **FR-003**: memberUpdates（カード由来）はターンの進捗計算より前に適用した morale/health
  デルタとして TurnResult に統合されること
- **FR-004**: 手戻りイベント発生判定に rework_prob_reduced 効果による確率補正を適用すること
- **FR-005**: applyEffectTick は remainingTurns > 0 の効果を -1 デクリメントし、
  0 になった効果を除去した新配列を返すこと
- **FR-006**: applyEffectTick は remainingTurns = null の効果を除去せず保持すること
- **FR-007**: calcEventProbModifier は指定 effectType が activeEffects に 1 件以上あれば
  baseProb × 0.5 を返し、なければ baseProb をそのまま返すこと
- **FR-008**: 確率補正は重複スタックしないこと（同 effectType が複数あっても 0.5 倍のみ）
- **FR-009**: effect.ts の全関数はイミュータブル操作（引数変更なし）であること
- **FR-010**: processTurn は引数 state を変更しないこと（既存 ADR-008 の継続）

### Key Entities

- **CardEffect**: cardName / targetId / effectType / remainingTurns（null = 永続）を持つ効果記録
- **CardApplicationResult**: effectsToAdd（CardEffect[]）と memberUpdates（MemberUpdate[]）の差分
- **TurnResult（拡張）**: 既存フィールドに加え activeEffectsAdded / activeEffectsAfterTick を追加

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: カードありのターン処理と cards=[] のターン処理で TurnResult の内容が
  確率的に異なることを決定論的テストで確認できること
- **SC-002**: effect.ts の全関数が Vitest + fast-check プロパティテストで
  任意入力に対してパニックなし・イミュータブル・値域保証を満たすこと
- **SC-003**: テストカバレッジ lines ≥ 80%・functions ≥ 80%（Constitution ゲート）
- **SC-004**: `grep -r "phaser|document|window" src/game/effect.ts` が 0 件
  （Architecture Boundary ゲート）
- **SC-005**: TurnResult の型変更後も `tsc --noEmit` が 0 エラーで通過すること

## Assumptions

- TurnResult 型に activeEffectsAdded と activeEffectsAfterTick フィールドを追加する
  （types.ts を更新する）
- constants.ts に EVENT_PROB.STALL が未定義の場合は追加する（停滞確率の基本値）
- remainingTurns = null は「永続効果（除去不要）」を意味する設計とする（Spec-06 の決定を継承）
- カード由来の memberUpdates とターン decay の memberUpdates は TurnResult に統合して返す
  （Phaser Scene 側で合算適用する）
- 停滞イベントの発生ロジック自体（純粋停滞・ブロッカー停滞）は別 Spec で実装する。
  今回は確率補正計算関数（calcEventProbModifier）の実装のみ
