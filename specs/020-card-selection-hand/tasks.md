# Tasks: カード選択・手札への組み込み機能

**Input**: Design documents from `/specs/020-card-selection-hand/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/module-contracts.md

**Tests**: テストタスクを含む。plan.md の Constitution Check II（Test Coverage Gates）と
Technical Context（Vitest + fast-check、rng 注入で決定論化）で明示的にテストが要求されている。

**Organization**: タスクはユーザーストーリー単位でグループ化し、各ストーリーを独立して
実装・テストできるようにする。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並列実行可能（別ファイル・未完了タスクへの依存なし）
- **[Story]**: 対応するユーザーストーリー（US1, US2, US3）
- 説明には正確なファイルパスを含める

## Path Conventions

単一プロジェクト構成。ロジック層 `src/game/`、テスト `tests/`、ステージデータ
`public/data/stages/`、数値文書 `docs/03-詳細設計/`。パスは plan.md の Project Structure に従う。

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 本フィーチャーで扱う型とテスト基盤の前提を確認する

- [X] T001 `src/game/types.ts` の既存 `StageData` / `GameState` / `CardName` 定義を確認し、
  拡張ポイント（cardPool・handLimit・drawCounts・CardPoolEntry の追加位置）を把握する
- [X] T002 [P] `tests/` 配下の既存 Vitest 構成と fast-check の利用パターン
  （`tests/unit/*.test.ts`）を確認し、`tests/unit/deck.test.ts` 追加の雛形方針を決める

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべてのユーザーストーリーが依存する型・スキーマの土台を整える

**⚠️ CRITICAL**: このフェーズ完了までユーザーストーリーの実装は開始できない

- [X] T003 `src/game/types.ts` に `CardPoolEntry` 型（name: CardName, weight: number,
  maxDraws?: number）を追加する（contracts/module-contracts.md の型契約に準拠）
- [X] T004 `src/game/types.ts` の `StageData` に `cardPool: CardPoolEntry[]` と
  `handLimit: number` を追加する
- [X] T005 `src/game/types.ts` の `GameState` に `drawCounts: Record<string, number>` を追加する
- [X] T006 `src/game/schemas/stageData.ts` に cardPool スキーマ
  （`z.array(z.object({ name, weight: z.number().positive(),
  maxDraws: z.number().int().positive().optional() }))`、既定 `[]`）と handLimit スキーマ
  （`z.number().int().positive()`、既定は initialCards 長）を追加し、既存 JSON の後方互換を保つ

**Checkpoint**: 型・スキーマが整い、各ユーザーストーリーの実装を開始できる

---

## Phase 3: User Story 1 - プレイヤーが毎ターン手札を補充されて選択肢を得る (Priority: P1) 🎯 MVP

**Goal**: ステージ開始時に初期枚数を配布し、以降ターン開始時に手札上限まで配布プールから
補充する。使ったカードの分だけ補充され、上限を超えて増えない。

**Independent Test**: ステージ開始後に初期枚数の手札があることを確認し、ターンを確定して
次ターンに進むと手札が上限枚数まで補充される（上限超過しない）ことを確認する。

### Tests for User Story 1 ⚠️（実装前に FAIL することを確認）

- [X] T007 [P] [US1] `tests/unit/deck.test.ts` に `drawCards` の基本補充テストを追加:
  不足分だけ handLimit まで補充する / 既に上限なら追加しない / 入力を破壊しない（純関数）
  ことを rng 注入で決定論的に検証する
- [X] T008 [P] [US1] `tests/unit/engine.test.ts` に補充挙動テストを追加:
  buildInitialState 直後に手札が initialCards 枚数である / processTurn 後の次ターン開始で
  handLimit まで補充される / 上限超過しないことを検証する

### Implementation for User Story 1

- [X] T009 [US1] `src/game/deck.ts`（新規）に `drawCards(pool, drawCounts, hand, handLimit,
  rng?)` を純関数として実装する。不足分を算出し、配布可能カードから抽選して hand と
  drawCounts を新規オブジェクトで返す。rng 既定は Math.random。配布可能が尽きたら打ち切り
  （エラーにしない、FR-009）
- [X] T010 [US1] `src/game/engine.ts` の `buildInitialState` で `drawCounts` を initialCards から
  初期化する（各カードを +1 集計）
- [X] T011 [US1] `src/game/engine.ts` の `processTurn` 末尾（state 確定・turn +1 後の次ターン開始
  時点）に補充ステップを追加し、`drawCards` で handLimit まで手札を補充する。turn.ts の
  シグネチャは変更しない（互換性契約）

**Checkpoint**: US1 単独で「初期配布→ターン確定→上限まで補充」が動作し独立テスト可能

---

## Phase 4: User Story 2 - ステージ設計者が配布プールで出現カードを制御する (Priority: P2)

**Goal**: 配布プール（カード集合と重み）を定義でき、補充されるカードは必ずプール内であり、
重みの大きいカードほど配布されやすい。プール外は配布されない。

**Independent Test**: 特定カードのみを含むプールを定義し複数ターン進めて、配布が全てプール内で
あること・プール外が配布されないこと、重みに差があるプールで多数回配布して重み傾向が出ることを
統計的に確認する。

### Tests for User Story 2 ⚠️（実装前に FAIL することを確認）

- [X] T012 [P] [US2] `tests/unit/deck.test.ts` に「配布はプール内のみ」テストを追加:
  補充されるカードが必ず cardPool に含まれる / プール外が出ないことを検証する（FR-005, SC-004）
- [X] T013 [P] [US2] `tests/unit/deck.test.ts` に重み反映のプロパティテスト（fast-check）を追加:
  重みの大きいエントリほど多く配布される統計的傾向を、決定論 rng または多数試行で検証する
  （FR-006）

### Implementation for User Story 2

- [X] T014 [US2] `src/game/deck.ts` の `drawCards` の抽選部を重み付き抽選として実装する
  （weight に比例した確率、プール内のみから選択）。プール外を配らないことを保証する
- [X] T015 [US2] `public/data/stages/poc-01.json` に `cardPool`（候補カードと weight）と
  `handLimit`（研究の初期値 8）を追加する。数値は T018 の docs 文書化と整合させる

**Checkpoint**: US1 と US2 が両立し、プール制御と重み配布が独立テスト可能

---

## Phase 5: User Story 3 - 配布回数に上限のあるカードが上限到達後は配られない (Priority: P3)

**Goal**: maxDraws を持つカードは配布累計が上限に達すると以降の補充対象から除外される。
maxDraws を持たないカードは回数による除外を受けない。

**Independent Test**: maxDraws=1 のカードをプールに入れ複数ターン進めて、そのカードが最大1回
しか配布されず上限到達後は除外されること、maxDraws 無しのカードは除外されないことを確認する。

### Tests for User Story 3 ⚠️（実装前に FAIL することを確認）

- [X] T016 [P] [US3] `tests/unit/deck.test.ts` に配布回数上限テストを追加:
  maxDraws=1 のカードは1回配布後に除外される / maxDraws 無しは除外されない / 配布可能が
  尽きたら補充を打ち切ることを検証する（FR-007, FR-008, FR-009, SC-003）

### Implementation for User Story 3

- [X] T017 [US3] `src/game/deck.ts` に `eligibleEntries(pool, drawCounts)` を実装し
  （maxDraws 未到達のエントリのみ返す）、`drawCards` の抽選対象をこれに限定する。
  補充のたびに drawCounts を加算し上限到達カードを以降除外する

**Checkpoint**: 全ユーザーストーリーが独立して機能する

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 数値バランスの文書化（Constitution 原則 III）と回帰・検証

- [X] T018 `docs/03-詳細設計/` に poc-01 のカード配布数値（cardPool 構成・各カードの weight・
  maxDraws・handLimit）を文書化する。Constitution 原則 III により実装数値の受け入れ条件。
  markdown lint ルール（見出し・リスト・テーブル前後の空行、120字以内）に従う
- [X] T019 ADR-026（休出（土）（日）の initialCards 静的追加による暫定対応）を本フィーチャーで
  恒久化する: poc-01 の cardPool に休出（土）（日）を含め、initialCards から外す
  （research.md Decision 5、ADR-029 が SUPERSEDES）
- [X] T020 回帰確認: 既存のカード選択・使用・ターン確定が本フィーチャー導入後も従来どおり
  完了することを確認する（FR-011, SC-005）。`turn.ts` / `applyCards` / `cards/index.ts` の
  シグネチャ不変を確認する
- [X] T021 `npx tsc --noEmit` で型エラー 0 を確認し、`src/game/**` のカバレッジ閾値
  （lines≥80 / functions≥80 / branches≥75）を満たすことを Vitest カバレッジで確認する
- [X] T022 quickstart.md の検証手順を実行し、手札補充の DOM 挙動（初期配布・ターン補充・
  上限）が期待どおりであることを確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし。即開始可能
- **Foundational (Phase 2)**: Setup 完了に依存。全ユーザーストーリーをブロックする
- **User Stories (Phase 3-5)**: すべて Foundational 完了に依存
  - US1（P1）は他ストーリーに依存しない MVP
  - US2（P2）は US1 の deck.ts / engine 補充を土台に重み付き抽選を拡張する
  - US3（P3）は deck.ts の抽選に eligibleEntries による除外を加える
- **Polish (Phase 6)**: 対象ストーリー完了に依存

### User Story Dependencies

- **US1 (P1)**: Foundational 完了後に開始可能。単独で完結（MVP）
- **US2 (P2)**: Foundational 完了後に開始可能。deck.ts の抽選部を重み付きに拡張するため
  US1 の `drawCards` 骨格を前提とする
- **US3 (P3)**: Foundational 完了後に開始可能。`drawCards` の抽選対象を eligibleEntries に
  限定するため US1・US2 の抽選実装を前提とする

### Within Each User Story

- テストを先に書き FAIL を確認してから実装する
- deck.ts（純関数）→ engine.ts（状態確定）の順で実装する
- ストーリー完了後に次の優先度へ進む

### Parallel Opportunities

- Setup の T002 は [P]
- 各ストーリーのテストタスク（T007/T008, T012/T013, T016）は [P]（別テストケース群）
- Foundational の型追加（T003-T005）は同一ファイル `types.ts` のため直列

---

## Parallel Example: User Story 1

```bash
# US1 のテストを並列で着手（実装前に FAIL 確認）:
Task: "tests/unit/deck.test.ts に drawCards 基本補充テストを追加"
Task: "tests/unit/engine.test.ts に補充挙動テストを追加"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup を完了
2. Phase 2: Foundational を完了（全ストーリーをブロック）
3. Phase 3: US1 を完了
4. **STOP and VALIDATE**: US1 を独立テスト（初期配布→補充→上限）
5. 動作すれば MVP としてデモ可能

### Incremental Delivery

1. Setup + Foundational → 土台完成
2. US1 追加 → 独立テスト → MVP
3. US2 追加（プール制御・重み）→ 独立テスト
4. US3 追加（配布回数上限）→ 独立テスト
5. Polish（数値 docs 文書化・回帰・カバレッジ・quickstart 検証）

---

## Notes

- [P] = 別ファイル・依存なし
- [Story] ラベルでタスクとユーザーストーリーを対応付ける
- 各ユーザーストーリーは独立して完了・テスト可能
- 実装前にテストが FAIL することを確認する
- タスクまたは論理的なまとまりごとにコミットする
- `src/game/` は Phaser/DOM 非依存を維持（Constitution 原則 I）
- 数値バランスは実装前に docs へ文書化（Constitution 原則 III、T018）
