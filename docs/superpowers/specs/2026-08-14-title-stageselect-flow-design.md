# タイトル〜ステージセレクト画面遷移設計

## 概要

現状 `BootScene → PreloadScene → MainScene`（`getStage("poc-01")` 固定）という
1本道の遷移になっており、タイトル画面・ステージセレクト画面が存在しない
（`PreloadScene` はSpec-15で追加された、起動時にJSONデータをロード・検証する
Scene。カード・イベント・ステージのレジストリはこの時点で構築済みになる）。

画面フローを `BootScene → PreloadScene → TitleScene → StageSelectScene → MainScene`
に拡張し、タイトルからスタートを押してステージを選ぶとゲームが始まる、という
一般的なゲームの導線を追加する。

## スコープ

- ステージセレクト画面は現状唯一のステージである `poc-01` のみを選択肢として表示する。
  複数ステージ対応の一覧表示の仕組み自体（`getStage()`レジストリ経由）は
  Spec-15で既に用意されているため、今回はステージセレクト画面がそれを
  列挙するだけでよい。
- タイトル画面はタイトルロゴ＋スタートボタンのみ。設定・クレジット等のメニューは含めない。
- ステージセレクト画面でステージカードをクリックすると、選択したステージの
  **確認画面**（プロジェクト概要・予算・目標利益率を表示し「開始する」「もどる」を
  選ばせる）を表示する。「開始する」でゲームを開始する（ADR-020）。

## 画面遷移アーキテクチャ

```text
BootScene -> PreloadScene -> TitleScene -> StageSelectScene -> MainScene
```

各SceneはPhaserの `this.scene.start(key, data)` でデータを渡しながら切り替える。
DOM overlay（`#ui-overlay`）はScene間で使い回す（Spec-12の `MainGameUI` パターンを踏襲）。

## コンポーネント構成

| Scene | UIクラス | 内容 |
| ----- | -------- | ---- |
| `TitleScene` | `TitleUI` | タイトルロゴ＋スタートボタンのみ。ボタン押下で `StageSelectScene` へ遷移 |
| `StageSelectScene` | `StageSelectUI` | ステージカード一覧（現状`poc-01`のみ）＋確認画面（2状態）。「開始する」で`MainScene`へ遷移 |
| `MainScene` | 既存 `MainGameUI` | UI自体は変更なし。stageの受け取り方のみ変更（後述） |

`TitleUI` / `StageSelectUI` は `MainGameUI` 同様、コンストラクタで `container: HTMLElement`
を受け取りDOM構築する形にする。

Scene切り替え時にoverlay内の前のUIが残らないよう、`destroy()` メソッドを
`TitleUI` / `StageSelectUI` / `MainGameUI` の3クラスに追加し、各Sceneの `shutdown` イベント
（または遷移直前）で呼び出す。

## StageSelectUIの2状態

`StageSelectUI` は「一覧表示」「確認表示」の2状態を持ち、同一画面内で切り替える
（別Sceneには分けない）。

- **一覧表示**: `getStage()` レジストリに登録された全ステージ（現状`poc-01`のみ）を
  カードとして並べる。カードクリックで確認表示に切り替える
- **確認表示**: 選択したステージの`description`（プロジェクト概要）・`budget`（予算）・
  `GameConfig`の`balance.GLOBAL_RULES.TARGET_PROFIT_RATE`（目標利益率、率のみ表示。
  予算×率の具体金額は表示しない）を表示し、「開始する」「もどる」ボタンを出す。
  「もどる」で一覧表示に戻る。「開始する」で`this.scene.start("MainScene", { stageId })`

## StageDataへの`description`フィールド追加

確認画面でプロジェクト概要を表示するため、`StageData`（`src/game/types.ts`）に
`description: string` を追加する。これに伴い、Spec-15で導入した
`src/game/schemas/stageData.ts` の`stageDataSchema`にも`description: z.string()`を
追加し、`public/data/stages/poc-01.json`に実際の説明文を追記する。

## MainSceneの変更

現在 `MainScene.create()` は `getStage("poc-01")` を直接呼んでいる。これを
`init(data: { stageId: string })` で受け取ったidを使う形に変更する。

```typescript
init(data: { stageId: string }): void {
  this.stageId = data.stageId;
}

create(): void {
  this.engine = new GameEngine(getStage(this.stageId));
  // ...
}
```

`StageSelectScene` は以下のようにidだけを渡して遷移する（StageData本体は
`MainScene`側で`getStage()`により取得するため、Scene間データ渡しはidのみで済む）。

```typescript
this.scene.start("MainScene", { stageId: "poc-01" });
```

## テスト方針

既存の `MainGameUI` 等のUI層に単体テストは無く、動作確認はPlaywright e2e
（`tests/e2e/`）に一本化されているパターンに合わせる。ロジック（データ変換等）を
持たないUIなので、unit testは追加しない。

`tests/e2e/` に新規specを追加し、以下を確認する。

- タイトル画面が表示され、スタートボタンでステージセレクトへ遷移する
- ステージセレクト画面で`poc-01`のステージカードが表示され、クリックで
  確認画面（プロジェクト概要・予算・目標利益率）が表示される
- 確認画面で「もどる」を押すと一覧表示に戻る
- 確認画面で「開始する」を押すとゲーム画面（`MainScene`）へ遷移する
