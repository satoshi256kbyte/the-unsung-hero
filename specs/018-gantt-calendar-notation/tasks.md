---

description: "Task list for docsガントチャート表記見直し（カレンダー列形式）"
---

# Tasks: docsガントチャート表記見直し（カレンダー列形式）

**Input**: Design documents from `/specs/018-gantt-calendar-notation/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: 本Specはドキュメント編集のみのため自動テストは対象外。markdownlintと
quickstart.mdの手動確認で検証する。

**Organization**: US1（ガントチャート表のカレンダー列形式化）とUS2（ヘッダー・
条件付きイベントの実データ整合）は同一ファイルを対象とするが、独立して
確認できるよう分けている。

## Phase 1: Setup

- [X] T001 `public/data/stages/poc-01.json`の現在値を確認する（`deadline`=30、
      `initialCards`5枚、`initialGantt.tasks`9件、`conditionalEvents`5件）
      （Pythonスクリプトで直接読み取り確認済み）

## Phase 2: Foundational

**⚠️ 前提**: US1のガントチャート表生成に必要な共通データ

- [X] T002 ターン1〜30それぞれについて「ターン番号(曜日)」形式の列見出し文字列
      （例: `1(月)`, `6(土)`, `7(日)`）を、`dayOfWeek(turn)=(turn-1)%7`
      （0=月, 1=火, 2=水, 3=木, 4=金, 5=土, 6=日）に基づき算出する
      （Pythonスクリプトで30列分生成済み）

**Checkpoint**: 列見出し30列分が用意できた状態。US1に着手できる

---

## Phase 3: User Story 1 - カレンダー列形式のガントチャート表 (Priority: P1)

**Goal**: ガントチャート表を、土日を含む連続したターン列（1〜30）を持つ
1枚の表として表現し、各タスクの稼働状態を■/・/空欄の3値で示す

**Independent Test**: `docs/03-詳細設計/ステージ/PoCステージ01.md`の
ガントチャート表を見て、列見出しがターン1〜30まで連続しており、各タスク行の
セルが■/・/空欄の3値で埋まっていることを確認する

- [X] T003 [P] [US1] `initialGantt.tasks`の各タスク（t01〜t09）について、
      `startTurn`・`duration`からセル値（期間内かつ平日=■、期間内かつ土日=・、
      期間外=空欄）を30列分算出する（Pythonスクリプトで算出済み）
- [X] T004 [US1] `docs/03-詳細設計/ステージ/PoCステージ01.md`の
      「## ガントチャート」セクションを、T002の列見出し・T003のセル値を
      もとに9行×30列の表に書き換える（列数31（タスク列+30列）を
      機械的に検証済み）
- [X] T005 [US1] 表の直後に凡例を1行追記する
      （`■`=平日稼働、`・`=期間内だが土日のため休日出勤カードなしには非稼働）

**Checkpoint**: ガントチャート表がカレンダー列形式に書き換わっている

---

## Phase 4: User Story 2 - ヘッダー・条件付きイベントの実データ整合 (Priority: P2)

**Goal**: ヘッダーテーブル（締切・初期カード・パス参照）と条件付きイベント表を
`public/data/stages/poc-01.json`の実値と完全一致させる

**Independent Test**: ヘッダーテーブル・条件付きイベント表の各値を
`public/data/stages/poc-01.json`と突き合わせ、すべて一致することを確認する

- [X] T006 [P] [US2] ヘッダーテーブルの「締切ターン」を22→30に修正する
- [X] T007 [P] [US2] ヘッダーテーブルの「初期カード」に「休出（土）」
      「休出（日）」を追加する（デイリー・レビュー・モニタリング・休出（土）・
      休出（日）の5枚にする）
- [X] T008 [P] [US2] ヘッダーテーブルの「ステージID」行にある
      存在しない`src/game/stages/poc-01.ts`パス参照を、実データの参照先
      `public/data/stages/poc-01.json`に修正する
- [X] T009 [US2] 「## ターンごとの条件付きイベント」表のターン番号を
      5, 10, 12, 16, 18（旧）から5, 12, 16, 22, 24（`conditionalEvents[].turn`
      の実値）に修正する

**Checkpoint**: ヘッダーテーブル・条件付きイベント表が実データと完全一致している

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 全体の整合性確認

- [X] T010 `npm run lint:md` でmarkdownlintエラー0を確認する
      （対象ファイルのみで検証済み。作業中に自作のspec.md/tasks.mdでMD013・
      MD036の指摘が出たため修正済み。`.claude/worktrees/`・`.specify/templates/`
      等の指摘は本Spec対象外の既存ファイルのため対象外）
- [X] T011 `quickstart.md`の手動確認手順（1〜8）を実施する
      （ヘッダーテーブル・ガントチャート表・条件付きイベント表をJSON実値と
      突き合わせて確認済み）
- [X] T012 ガントチャート表のヘッダー行のパイプ区切り数を数え、
      タスク列1列＋ターン列30列（計31列）になっていることを機械的に確認する
      （Pythonスクリプトで31列を確認済み）

---

## Dependencies & Execution Order

- Phase 1（Setup） → Phase 2（Foundational） → Phase 3（US1） → Phase 4（US2）
  → Phase 5（Polish）
- US1とUS2は同一ファイルの別セクションを対象とするため、T004・T005（US1）と
  T006〜T009（US2）はどちらを先に行っても結果は変わらないが、
  同一ファイルへの逐次編集になるため並列実行はしない

## Implementation Strategy

MVPはUS1（ガントチャート表のカレンダー列形式化）単独でも価値がある
（現状表記の主目的である「土日を含む暦日ベースの一望」を満たすため）。
US2（実データ整合）は同じ作業セッション内で続けて実施する。
