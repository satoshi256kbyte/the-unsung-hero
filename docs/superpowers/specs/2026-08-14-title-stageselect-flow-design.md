# タイトル〜ステージセレクト画面遷移設計

## 概要

現状 `BootScene → MainScene`（`pocStage` 固定）という1本道の遷移になっており、
タイトル画面・ステージセレクト画面が存在しない。

画面フローを `BootScene → TitleScene → StageSelectScene → MainScene` に拡張し、
タイトルからスタートを押してステージを選ぶとゲームが始まる、という一般的なゲームの
導線を追加する。

## スコープ

- ステージセレクト画面は現状唯一のステージである `pocStage` のみを選択肢として表示する。
  複数ステージ対応の仕組み（ステージ一覧データソースの抽象化等）は今回のスコープ外。
- タイトル画面はタイトルロゴ＋スタートボタンのみ。設定・クレジット等のメニューは含めない。
- ステージセレクト画面はステージカードをクリックした時点で即座にゲームを開始する。
  「選択→決定ボタン」の2ステップは導入しない。

## 画面遷移アーキテクチャ

```
BootScene -> TitleScene -> StageSelectScene -> MainScene
```

各SceneはPhaserの `this.scene.start(key, data)` でデータを渡しながら切り替える。
DOM overlay（`#ui-overlay`）はScene間で使い回す（Spec-12の `MainGameUI` パターンを踏襲）。

## コンポーネント構成

| Scene | UIクラス | 内容 |
| ----- | -------- | ---- |
| `TitleScene` | `TitleUI` | タイトルロゴ＋スタートボタンのみ。ボタン押下で `StageSelectScene` へ遷移 |
| `StageSelectScene` | `StageSelectUI` | ステージカード一覧（現状PoCステージ1件のみ）。カードクリックで即 `MainScene` へ遷移 |
| `MainScene` | 既存 `MainGameUI` | UI自体は変更なし。stageの受け取り方のみ変更（後述） |

`TitleUI` / `StageSelectUI` は `MainGameUI` 同様、コンストラクタで `container: HTMLElement`
を受け取りDOM構築する形にする。

Scene切り替え時にoverlay内の前のUIが残らないよう、`destroy()` メソッドを
`TitleUI` / `StageSelectUI` / `MainGameUI` の3クラスに追加し、各Sceneの `shutdown` イベント
（または遷移直前）で呼び出す。

## MainSceneのリファクタ

現在 `MainScene` は `import { pocStage } from "../game/stages/pocStage.js"` を直接読み込んで
`GameEngine` に渡している。これを `init(data: { stage: StageData })` で受け取る形に変更する。

`StageSelectScene` は以下のようにデータを渡して遷移する。

```typescript
this.scene.start("MainScene", { stage: pocStage });
```

これにより将来ステージが増えても `MainScene` 自体の変更は不要になる。

`StageSelectScene` 側は `[pocStage]` という配列をハードコードで持つだけにする
（ステージ一覧データソースの抽象化は今回のスコープ外）。

## テスト方針

既存の `MainGameUI` 等のUI層に単体テストは無く、動作確認はPlaywright e2e
（`tests/e2e/`）に一本化されているパターンに合わせる。ロジック（データ変換等）を
持たないUIなので、unit testは追加しない。

`tests/e2e/` に新規specを追加し、以下を確認する。

- タイトル画面が表示され、スタートボタンでステージセレクトへ遷移する
- ステージセレクト画面でPoCステージカードが表示され、クリックでゲーム画面
  （MainScene）へ遷移する
