# Data Model: メイン画面UI

Phase 1 output for Spec-12

## MainGameUI

DOM overlay ルートクラス。`#ui-overlay` div を管理する。

| フィールド | 型 | 説明 |
|---|---|---|
| `root` | `HTMLElement` | `#ui-overlay` への参照 |
| `slots` | `CardSlot[]` | 最大 8 コスト分のスロット配列 |
| `loading` | `LoadingScreen` | ターン移行ロード画面インスタンス |

### メソッド

| メソッド | シグネチャ | 説明 |
|---|---|---|
| `render` | `(state: GameState) => void` | GameState を受け取り全 UI を再描画 |
| `getPlacedCards` | `() => CardName[]` | 現在スロットに配置されたカード一覧を返す |
| `reset` | `() => void` | スロットを全クリア（ターン開始時） |

## CardSlot

カードスロット 1 枠を表す DOM コンポーネント。

| フィールド | 型 | 説明 |
|---|---|---|
| `el` | `HTMLElement` | スロットの DOM 要素 |
| `card` | `CardName \| null` | 配置中のカード名（null = 空） |
| `cost` | `number` | 配置中カードのコスト（0 = 空） |

### イベント

| イベント | 発生タイミング |
|---|---|
| `cardPlaced` | カードがスロットに配置されたとき |
| `cardRemoved` | カードがスロットから除去されたとき |

### バリデーション

- 合計コストが 8 を超える場合は `cardPlaced` をブロックし `data-blocked="true"` 属性を付与
- 空スロットへのドロップのみ受け付ける（既にカードがある場合は除去してから配置）

## LoadingScreen

ターン移行ロード画面コンポーネント。

| フィールド | 型 | 説明 |
|---|---|---|
| `el` | `HTMLElement` | ローディング画面の DOM 要素 |
| `termEl` | `HTMLElement` | PM 用語テキスト表示領域 |

### LoadingScreen メソッド

| メソッド | シグネチャ | 説明 |
|---|---|---|
| `show` | `() => void` | ローディング画面を表示し PM 用語をランダム選択して表示 |
| `hide` | `() => void` | ローディング画面を非表示にする |

## pmTerms 定数

PM 用語プール。初期実装 15 件。

| フィールド | 型 |
|---|---|
| `terms` | `ReadonlyArray<{ name: string; description: string }>` |

## MainScene（Phaser Scene）

`src/scenes/MainScene.ts`。Phaser Scene として `src/game/` と `src/ui/` を協調させる。

| フィールド | 型 | 説明 |
|---|---|---|
| `engine` | `GameEngine` | `pocStage` で初期化した GameEngine インスタンス |
| `ui` | `MainGameUI` | DOM overlay インスタンス |

### ライフサイクル

| フック | 処理 |
|---|---|
| `create()` | `GameEngine(pocStage)` 生成・`MainGameUI` 生成・初期 `render()` 呼び出し |
| `confirmTurn()` | ローディング表示 → `processTurn(cards)` → `sleep(1000)` → UI 更新 → ローディング非表示 |

## 状態遷移

```text
初期化
  └→ create(): engine = new GameEngine(pocStage)
               ui.render(engine.getState())
               [ダッシュボード表示]

ターン操作
  └→ カード配置/除去 (CardSlot DOM events)
     合計コスト確認 (≤8)
     「ターン確定」ボタン押下

ターン確定
  └→ LoadingScreen.show()
     Promise.all([processTurn(cards), sleep(1000)])
     ui.render(engine.getState())
     LoadingScreen.hide()
     [次ターンのダッシュボード表示]

ゲームオーバー
  └→ isGameOver === true
     ターン確定ボタン非活性化
     ゲームオーバーメッセージ表示
```
