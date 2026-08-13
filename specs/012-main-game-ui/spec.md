# Feature Specification: メイン画面UI

**Feature Branch**: `012-main-game-ui`

**Created**: 2026-08-13

**Status**: Draft

**Input**: User description: "メイン画面UI（DOM overlay + Phaser Scene）"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - ダッシュボードでゲーム状態を確認できる (Priority: P1)

プレイヤーがゲーム画面を開いたとき、ヘッダー・ダッシュボード・カード枠・メニュー・
ターン確定ボタンが正しくレイアウトされ、`GameState` の値が画面に反映されている。

**Why this priority**: ゲームの全操作の起点となる画面。
これがなければプレイヤーはゲームをプレイできない。

**Independent Test**: `pocStage` で初期化した `GameEngine` の `getState()` を画面に渡すと、
ターン番号・予算・メンバーステータス（技/心/体）・手札カードが正しく表示されることを
Playwright E2E テストで確認できる。

**Acceptance Scenarios**:

1. **Given** ゲーム画面が表示されている、**When** `getState()` を参照する、
   **Then** ヘッダーに「ターン 1 / 残り 22」が表示される
2. **Given** ゲーム画面が表示されている、**When** ダッシュボードを確認する、
   **Then** 予想利益・予想利益率・SPI・CPI・透明性・緊張感が表示される
3. **Given** ゲーム画面が表示されている、**When** メンバーエリアを確認する、
   **Then** 3名分の「技（数値）・心（ゲージ）・体（ゲージ）」が表示される
4. **Given** ゲーム画面が表示されている、**When** カード枠を確認する、
   **Then** 手札カード（デイリー・レビュー・モニタリング）がカードスロットに表示される

---

### User Story 2 - カード枠でターンのアクションを組み立てられる (Priority: P2)

プレイヤーが手札からカードをカードスロットに配置・除去し、
8コスト以内でターンのアクションセットを組み立てられる。

**Why this priority**: ターン制ゲームのコアインタラクション。
ダッシュボード表示（US1）の後に必要となる操作機能。

**Independent Test**: 手札からカードをスロットに配置すると合計コストが更新され、
8コストを超えた場合は配置がブロックされることを Playwright E2E テストで確認できる。

**Acceptance Scenarios**:

1. **Given** 手札にカードがある、**When** カードをスロットにドラッグ＆ドロップする、
   **Then** スロットにカードが配置され合計コストが増加する
2. **Given** スロットにカードが配置されている、**When** カードをスロットから除去する、
   **Then** スロットが空になり合計コストが減少する
3. **Given** 合計コストが8コストに達している、**When** 追加カードを配置しようとする、
   **Then** 配置がブロックされ「コスト上限」のフィードバックが表示される
4. **Given** カードスロットを組み立て済み、**When** 「ターン確定」ボタンを押す、
   **Then** 配置カードのセットが `GameEngine.processTurn()` に渡される

---

### User Story 3 - ターン確定後にターン移行ロード画面が表示される (Priority: P3)

プレイヤーが「ターン確定」ボタンを押すと、次ターン処理中にロード画面が表示され、
PM用語の解説テキストが1件表示される。処理完了後、次ターンの画面に切り替わる。

**Why this priority**: ゲームループの完結に必要。US1・US2 が完成した後に実装できる。

**Independent Test**: ターン確定後にロード画面が最低1秒表示され、
PM用語テキストが表示されること、次ターンのターン番号に更新されることを
Playwright E2E テストで確認できる。

**Acceptance Scenarios**:

1. **Given** ターン確定ボタンを押した、**When** 次ターン処理が実行される、
   **Then** ロード画面が表示され PM 用語テキストが1件表示される
2. **Given** ロード画面が表示されている、**When** 処理が短時間で完了する、
   **Then** 最低1秒はロード画面が維持される
3. **Given** ロード画面が表示されている、**When** 次ターン処理が完了する、
   **Then** ダッシュボードのターン番号が次のターンに更新される

---

### Edge Cases

- `GameState.isGameOver === true` の場合、ゲームオーバー画面を表示する（ターン確定ボタンを非活性にする）
- 手札が空（`hand.length === 0`）の場合、カードなしでターン確定できる
- 全カードスロットが埋まった場合、手札カードはドラッグ不可状態になる
- メンバーの心・体が 0 の場合、ゲージが空の状態で表示される

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: メイン画面は `GameState` を受け取り、ヘッダー・ダッシュボード・
  カード枠・メニュー・ターン確定ボタンの5エリアを表示しなければならない
- **FR-002**: ダッシュボードは予想利益・予想利益率（数値）、SPI・CPI・透明性・緊張感
  （横棒ゲージ）の7指標を表示しなければならない
- **FR-003**: メンバーエリアは全メンバーの技（数値）・心（ゲージ）・体（ゲージ）を
  表示しなければならない
- **FR-004**: カード枠は最大8コスト分のスロットを持ち、手札カードの配置・除去が
  できなければならない
- **FR-005**: 合計コストが8コストを超えるカード配置はブロックされ、
  フィードバックを表示しなければならない
- **FR-006**: 「ターン確定」ボタン押下後、ロード画面を表示してから
  `GameEngine.processTurn()` を呼び出し、次ターンの `GameState` で画面を更新しなければならない
- **FR-007**: ロード画面は最低1秒表示し、PM用語テキストを1件ランダムに表示しなければならない
- **FR-008**: UI実装は `src/ui/` 配下の DOM overlay コンポーネントとして実装し、
  ビジネスロジックを含まないこと（Constitution 原則 I に準拠）
- **FR-009**: Phaser Scene（`src/scenes/`）はキャンバス背景のみを担当し、
  DOM overlay と協調して動作しなければならない
- **FR-010**: すべてのインタラクティブな UI 要素は Playwright E2E テストで
  DOM 要素として操作できなければならない

### Key Entities

- **MainGameUI**: DOM overlay のルートコンポーネント。`GameState` を受け取り表示を更新する
- **CardSlot**: カードスロット1枠を表すコンポーネント。カードの配置・除去を管理する
- **LoadingScreen**: ターン移行ロード画面コンポーネント。PM用語テキストを表示する
- **MainScene**: Phaser Scene。キャンバス背景と DOM overlay の協調制御を担当する

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `pocStage` の初期 `GameState` で画面を表示したとき、
  全UI要素が正しい値で表示される（Playwright E2E テスト全件 PASS）
- **SC-002**: カード配置・除去・ターン確定の操作フローが
  Playwright E2E テストで通過する
- **SC-003**: ロード画面が最低1秒表示され、PM用語テキストが表示される
- **SC-004**: TypeScript の型チェックがエラー0で通過する
- **SC-005**: `src/ui/` に Phaser・DOM API 直接参照が含まれない
  （Constitution 原則 I の Architecture Boundaries に違反しない）
- **SC-006**: Playwright E2E テストがヘッドレス CI 環境で通過する

## Assumptions

- Phaser 4 と DOM overlay の協調は `src/scenes/MainScene.ts` が担当する
- カードのドラッグ＆ドロップは DOM の標準 drag events または
  Pointer Events で実装する（Phaser の入力イベントは使用しない）
- PM用語プールは `src/ui/` 配下の定数ファイルに定義する（初期実装は10〜20件）
- メニューのガントチャート・リスクグラフ画面への切替は本 Spec のスコープ外
  （画面切替ボタンは表示するが、切替先実装は別 Spec）
- ゲームオーバー画面の詳細は本 Spec のスコープ外（isGameOver 時は簡易メッセージを表示）
- SPI・CPI の計算式はゲームエンジン側で算出済みの値を受け取る前提
  （本 Spec では表示のみ）
