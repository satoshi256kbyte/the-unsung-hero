# Tasks: 週モデル変更（ターン＝暦日・7ターン周期）

**Input**: Design documents from `specs/017-week-model-redesign/`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並行実行可（異なるファイル、依存なし）
- **[Story]**: 対応ユーザーストーリー（US1〜US2）

**注記**: US1（土日は通常稼働しない）とUS2（休日出勤カードで対象選択）は
休出カードを介して密結合している（US1の「休出使用時は進捗が発生する」という
受け入れ基準の検証には、US2の対象選択の仕組みが実際に動く必要がある）。
そのため実装フェーズは統合するが、タスクには元のストーリーラベルを付与する。

---

## Phase 1: Setup

**Purpose**: 既存実装の再確認

- [X] T001 `src/game/turn.ts`のステップ3（進捗ダイス）・ステップ4（週末回復判定）の
      現在の実装を確認する
- [X] T002 `src/game/cards/index.ts`の`CardDefinition`・`applyCards`の現在の
      シグネチャを確認する

---

## Phase 2: Foundational（全User Storyの前提）

**Purpose**: 曜日判定と対象選択の基盤

**⚠️ CRITICAL**: このフェーズ完了までUser Story側の実装は着手できない

- [X] T003 [P] `src/game/calendar.ts`を新規作成する。`isWeekend(turn: number): boolean`
      （`(turn-1)%7`が5または6なら true）と`dayOfWeek(turn: number)`を実装する
- [X] T004 [P] `src/game/types.ts`の`CardName`ユニオンから`"休出"`を削除し、
      `"休出（土）"` `"休出（日）"`を追加する（`EffectType`にも
      `holiday_work_sat`/`holiday_work_sun`を追加）
- [X] T005 `src/game/cards/index.ts`の`CardDefinition`に`requiresTarget?: boolean`を、
      `applyEffect`に`targetId?: string`引数を追加する。`applyCards`の引数を
      `cards: CardName[]`から`cards: { name: CardName; targetId?: string }[]`に変更する
      （既存25種のカードファイルは`applyEffect(state)`のまま変更不要）
- [X] T006 `src/ui/CardSlot.ts`に`targetMemberId: string | null`フィールドと
      `setTarget(memberId: string): void`を追加する。`remove()`で`null`に戻す

**Checkpoint**: `npm run typecheck`がここまででエラー0

---

## Phase 3: 週末スキップ・休出カード・対象選択UI（US1 + US2 統合実装）

**Goal**: 土日は休日出勤カードで対象指定されたメンバー以外は進捗が発生せず、
休日出勤（土）／（日）カードは対象メンバーを選んで使用できる

**Independent Test**: 土曜にカードなしでターンを進めると進捗が発生しない
（US1）。休日出勤（土）カードを対象メンバーを選んで使うと、そのメンバーの
タスクだけ土曜に進捗する（US1+US2の組み合わせ）

### Implementation

- [X] T007 [US2] `public/data/cards/holiday-work.json`を削除し、
      `holiday-work-sat.json` `holiday-work-sun.json`を新規作成する
      （`{"cost": 2}`、コストは暫定値）
- [X] T008 [P] [US2] `src/game/cards/holiday-work-sat.ts`を新規作成する。
      `requiresTarget: true`、`applyEffect(state, targetId)`で
      `effectType: "holiday_work_sat"`の`CardEffect`（`targetId`に指定された
      メンバーid、`remainingTurns`は次の土曜までの残数）を返す
- [X] T009 [P] [US2] `src/game/cards/holiday-work-sun.ts`を同様に新規作成する
      （`effectType: "holiday_work_sun"`）
- [X] T010 [US2] 旧`src/game/cards/holiday-work.ts`を削除する
- [X] T011 [US2] `src/game/cards/index.ts`のレジストリを更新し、
      `holiday-work-sat.ts` `holiday-work-sun.ts`を登録する
      （旧`holiday-work.ts`の登録を削除）
- [X] T012 [US1] `src/game/turn.ts`のステップ3（進捗ダイス）を変更する。
      `isWeekend(state.turn)`が true の場合、対象メンバーに
      `holiday_work_sat`（土曜の場合）または`holiday_work_sun`（日曜の場合）の
      `CardEffect`が`currentEffects`に存在しない限り、そのメンバーのタスクの
      進捗ダイスをスキップする
- [X] T013 [US1] `src/game/turn.ts`のステップ4（週末回復判定）を
      `state.turn % 5 === 0`から`state.turn % 7 === 0`（日曜終了時点）に変更する
- [X] T014 [US1] `src/game/turn.ts`の`processTurn`の`cards`引数の型を
      `CardName[]`から`{ name: CardName; targetId?: string }[]`に変更する
      （`applyCards`呼び出しにそのまま渡す。`GameEngine.processTurn`（engine.ts）も
      同様に変更が必要と判明したため合わせて対応）
- [X] T015 [US2] `src/ui/MainGameUI.ts`に対象選択オーバーレイ
      （`data-testid="target-picker"`、メンバーごとの
      `data-testid="target-member-<id>"`ボタン）を追加する。
      `requiresTarget`なカードがスロットに置かれたとき表示し、選択で
      `CardSlot.setTarget()`を呼ぶ
- [X] T016 [US2] `MainGameUI.getPlacedCards()`の戻り値を`CardName[]`から
      `PlacedCard[]`（`{ name: CardName; targetId?: string }[]`）に変更する
- [X] T017 [US2] `src/scenes/MainScene.ts`の`confirmTurn`を`PlacedCard[]`を
      受け取る形に変更する
- [X] T018 [P] [US1] `public/data/stages/poc-01.json`の`deadline`を22から30に、
      `conditionalEvents[].turn`を対応表（research.md参照: 5→5, 10→12, 12→16,
      16→22, 18→24）に沿って更新する
- [X] T019 [P] [US1] 画面上の「ターン」表記（`MainGameUI.ts`のヘッダー等）を
      「◯日目」表記に変更する

**Checkpoint**: `npm run test`・`npm run typecheck`が通り、手動で土曜に
休出カードなしで進捗が止まること、休出カードで対象メンバーを選んで
使うとそのメンバーだけ進捗することを確認できる

---

## Phase 4: docs更新

- [X] T020 [P] `docs/03-詳細設計/カード/休出.md`を削除し、
      `休出（土）.md` `休出（日）.md`に分割する
- [X] T021 [P] `docs/03-詳細設計/バランスパラメータ.md`の「5稼働日ごと」等の
      記述を7ターン周期・月曜始まりの週モデルに更新する（「稼働日数」行も
      「締切（暦日ベース、土日を含む）」に表記変更）

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 全体の整合性確認

- [X] T022 [P] `tests/unit/calendar.test.ts`を新規作成し、`isWeekend`の
      全曜日パターン（月〜日）を検証する（turn 1,5,6,7,8,30で検証、全PASS）
- [X] T023 [P] `tests/unit/cards/holiday-work-sat.test.ts` `holiday-work-sun.test.ts`を
      新規作成する（対象指定時のremainingTurns計算・対象未指定時の無効果を検証、各4件PASS）
- [X] T024 既存の`tests/unit/turn.test.ts`を新しい週モデル（土日スキップ・
      週末回復タイミング）に合わせて更新する（週末回復をturn%7===0に変更、
      土日進捗スキップの新規describeブロックを追加、全46件PASS）
- [X] T025 `tests/unit/stages/poc-01.test.ts`のフィクスチャ・アサーションを
      新しい`deadline`（30）に合わせて更新する（conditionalEvents旧→新ターン
      マッピング、initialCardsに休出（土）（日）を追加）
- [X] T026 [P] `tests/e2e/`に対象選択UIのE2Eテストを追加する
      （休出カードをスロットに置く→対象選択オーバーレイが表示される→
      メンバーを選ぶ→確定できる）（`tests/e2e/target-picker.spec.ts`、2件PASS）
- [X] T027 `npm run typecheck` でエラー0を確認する（確認済み、エラー0）
- [X] T028 `npm run test` で全単体テストPASSを確認する（28ファイル358件全PASS）
- [X] T029 `npm run test:coverage` でカバレッジ lines/functions ≥ 80%,
      branches ≥ 75%（`src/game/**`）を確認する
      （lines 94.37% / functions 100% / branches 90.52%、全閾値クリア）
- [X] T030 `npm run test:e2e` で全E2EテストPASSを確認する（29件全PASS）
- [X] T031 `npm run lint` (Biome) でエラー0を確認する（確認済み、エラー0）
- [X] T032 `grep -r "phaser\|document\.\|window\." src/game/calendar.ts
      src/game/cards/holiday-work-sat.ts src/game/cards/holiday-work-sun.ts
      && echo VIOLATION || echo OK`でPhaser/DOM非依存を確認する（一致なし、OK）
- [X] T033 `grep -rl "\"休出\"" src public docs` が0件であることを確認する
      （旧カード名の残存チェック）（実コード上は0件。design-session/仕様書内の
      新旧対比の説明文のみ該当、コードの残存ではないため問題なし）
- [X] T034 `quickstart.md`の手動確認手順を実施する（`npm run dev`起動後、
      実ブラウザ（Playwright MCP）で休出（土）カードのドラッグ＆ドロップ→
      対象選択オーバーレイ表示→alice選択→オーバーレイ閉じるまで確認。
      さらに7日目（日曜）まで実際にターンを進め、ヘッダー表示が
      「N日目 / 残りM日」形式で正しく更新されること、ランタイムエラーが
      発生しないことを確認）

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし
- **Foundational (Phase 2)**: Phase 1完了後。全User Storyをブロックする
- **Phase 3（US1+US2統合実装）**: Phase 2完了後
- **Phase 4（docs更新）**: Phase 3完了後（カード名・週モデルの内容が固まってから）
- **Polish (Phase 5)**: 全Phase完了後

### Parallel Opportunities

- Phase 2のT003・T004は並行実施可能
- Phase 3のT008・T009（休出カード2種）、T018・T019は並行実施可能
- Phase 4のT020・T021は並行実施可能
- Phase 5のT022・T023・T026は並行実施可能

---

## Implementation Strategy

### MVP First

1. Phase 1〜2: Setup・Foundational
2. Phase 3: 週末スキップ・休出カード・対象選択UI（本Specの中核）
3. STOP and VALIDATE: 手動で土日の進捗停止・休出カードの動作を確認

### Incremental Delivery

1. Setup + Foundational → Phase 3 → 検証
2. Phase 4（docs更新）→ 検証
3. Polish
