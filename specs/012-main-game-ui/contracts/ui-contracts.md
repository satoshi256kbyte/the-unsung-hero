# UI Contracts: メイン画面UI

Phase 1 output for Spec-12

Playwright E2E テストが参照する DOM 要素の契約定義。

## data-testid 一覧

| コンポーネント | data-testid | 説明 |
|---|---|---|
| ヘッダー | `header-turn` | 「ターン N / 残り M」テキスト |
| KPI: 予想利益 | `kpi-profit` | 予想利益（数値テキスト） |
| KPI: 予想利益率 | `kpi-profit-rate` | 予想利益率（数値テキスト） |
| KPI: SPI ゲージ | `kpi-spi` | SPI 横棒ゲージ（`aria-valuenow` 属性で値を持つ） |
| KPI: CPI ゲージ | `kpi-cpi` | CPI 横棒ゲージ |
| KPI: 透明性ゲージ | `kpi-transparency` | 透明性横棒ゲージ |
| KPI: 緊張感ゲージ | `kpi-tension` | 緊張感横棒ゲージ |
| メンバーエリア | `member-list` | メンバー一覧コンテナ |
| メンバー1行 | `member-{id}` | 各メンバーの行（例: `member-alice`） |
| メンバー技 | `member-{id}-skill` | 技の数値テキスト |
| メンバー心ゲージ | `member-{id}-morale` | 心の横棒ゲージ |
| メンバー体ゲージ | `member-{id}-health` | 体の横棒ゲージ |
| カードスロット | `card-slot-{n}` | n番目のスロット（0-indexed） |
| 手札カード | `hand-card-{name}` | 手札のカード要素（例: `hand-card-デイリー`） |
| 合計コスト表示 | `total-cost` | 現在の合計コスト数値テキスト |
| ターン確定ボタン | `confirm-turn-btn` | ターン確定ボタン |
| ローディング画面 | `loading-screen` | ターン移行ロード画面コンテナ |
| PM用語テキスト | `pm-term-text` | PM用語名 + 説明テキスト |

## DOM 状態コントラクト

### カードスロット（`card-slot-{n}`）

| 状態 | DOM 属性 |
|---|---|
| 空 | `data-occupied="false"` |
| カード配置済み | `data-occupied="true"`, `data-card="{CardName}"` |
| コスト超過ブロック | `data-blocked="true"` |

### ターン確定ボタン（`confirm-turn-btn`）

| 状態 | DOM 属性 |
|---|---|
| 操作可能 | `disabled` 属性なし |
| ゲームオーバー時 | `disabled` 属性あり |

### ローディング画面（`loading-screen`）

| 状態 | DOM 属性 |
|---|---|
| 非表示 | `aria-hidden="true"` または `display: none` |
| 表示中 | `aria-hidden="false"` |

## E2E テストシナリオ概要

### dashboard.spec.ts（US1）

1. `http://localhost:5173` にアクセス
2. `[data-testid="header-turn"]` に「ターン 1」が含まれることを確認
3. `[data-testid="member-alice-skill"]` に「12」が含まれることを確認
4. `[data-testid="hand-card-デイリー"]` が存在することを確認

### card-slot.spec.ts（US2）

1. `[data-testid="hand-card-デイリー"]` を `[data-testid="card-slot-0"]` にドラッグ＆ドロップ
2. `[data-testid="card-slot-0"][data-occupied="true"]` になることを確認
3. `[data-testid="total-cost"]` が「1」になることを確認
4. コスト 9 になる追加ドロップが `data-blocked="true"` でブロックされることを確認

### turn-cycle.spec.ts（US3）

1. `[data-testid="confirm-turn-btn"]` をクリック
2. `[data-testid="loading-screen"]` が表示されることを確認
3. `[data-testid="pm-term-text"]` にテキストが存在することを確認
4. 1 秒以上後に `[data-testid="header-turn"]` が「ターン 2」に更新されることを確認
