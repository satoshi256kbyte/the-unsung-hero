# UI Contracts: タイトル〜ステージセレクト画面遷移

Spec-12の`ui-contracts.md`パターンを踏襲し、DOM要素の`data-testid`契約を記載する。

## TitleUI

| data-testid | 要素 | 説明 |
| ----------- | ---- | ---- |
| `title-logo` | タイトルロゴ表示 | テキストまたは画像 |
| `title-start-btn` | ボタン | 押下で`StageSelectScene`へ遷移 |

## StageSelectUI

| data-testid | 要素 | 説明 |
| ----------- | ---- | ---- |
| `stage-list` | コンテナ | 一覧表示モード時に表示 |
| `stage-card-<stageId>` | カード | クリックで確認表示に切り替え |
| `stage-confirm` | コンテナ | 確認表示モード時に表示 |
| `stage-confirm-description` | テキスト | プロジェクト概要 |
| `stage-confirm-budget` | テキスト | 予算 |
| `stage-confirm-profit-rate` | テキスト | 目標利益率（率のみ、例:「目標利益率 5%以上」） |
| `stage-confirm-start-btn` | ボタン | 押下で`MainScene`へ遷移（`stageId`を渡す） |
| `stage-confirm-back-btn` | ボタン | 押下で一覧表示に戻る |

## Scene遷移の契約

```typescript
// TitleScene
this.scene.start("StageSelectScene");

// StageSelectScene（確認画面「開始する」時）
this.scene.start("MainScene", { stageId: string });

// MainScene
init(data: { stageId: string }): void;
```

## 互換性契約

- `MainScene`の`init(data)`はSceneが再起動された場合も同じ`stageId`で
  再初期化できること（`GameEngine`の生成は`create()`内で行い、`init()`では
  `stageId`の保持のみ行う）
