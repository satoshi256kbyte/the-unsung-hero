# Phase 0 Research: タイトル〜ステージセレクト画面遷移

Technical ContextにNEEDS CLARIFICATIONはない。主要な決定事項を記録する。

## 1. Scene構成

**Decision**: `TitleScene`・`StageSelectScene`を新規Sceneとして追加し、
`BootScene → PreloadScene → TitleScene → StageSelectScene → MainScene`と接続する。

**Rationale**: 既存の`BootScene`（起動）・`PreloadScene`（Spec-15、データロード）の
役割を変えず、その後段にゲームフロー向けのScene列を追加する。Spec-12の
`MainScene`+`MainGameUI`パターンを踏襲し、Scene=Phaser制御、UIクラス=DOM構築、
という責務分担を維持する。

## 2. StageSelectUIの状態管理

**Decision**: `StageSelectScene`は1つのSceneのまま、`StageSelectUI`内部に
「一覧表示」「確認表示」の2状態を持たせる。別Sceneには分割しない。

**Rationale**: 会話内で既に確認済みの決定（ADR-020）。ステージ選択という
1つのタスクの中の2ステップであり、Scene分割するほどの独立性はない。

## 3. `description`フィールドの追加箇所

**Decision**: 3箇所に追加する。(1) `src/game/types.ts`の`StageData`インターフェース、
(2) `src/game/schemas/stageData.ts`の`stageDataSchema`（zod）、
(3) `public/data/stages/poc-01.json`の実データ。

**Rationale**: Spec-15でステージデータがJSON化されているため、型・スキーマ・
実データの3箇所すべてに追加しないと`PreloadScene`のzod検証で弾かれるか、
型エラーになる。

## 4. `MainScene`へのデータ渡し方

**Decision**: `StageSelectScene`は`this.scene.start("MainScene", { stageId: "poc-01" })`
のようにidのみ渡す。`MainScene`は`init(data: { stageId: string })`を実装し、
`create()`内で`getStage(this.stageId)`を呼ぶ。

**Rationale**: `getStage()`レジストリ（Spec-15）がすでに全ステージデータを
保持しているため、Scene間でStageData本体を受け渡す必要がない。idだけで
十分であり、Phaserの`scene.start(key, data)`のペイロードを最小化できる。

## 5. 目標利益率の表示元

**Decision**: `getConfig().balance.GLOBAL_RULES.TARGET_PROFIT_RATE`
（Spec-15で導入済み）をパーセント表示に変換して表示する。予算×率の
具体金額は計算・表示しない（FR-006）。

**Rationale**: ADR-022で確定済みの方針。`PreloadScene`が起動時に
`initGameConfig()`を呼んでいるため、`StageSelectScene`の時点で
`getConfig()`は利用可能。

## 6. テスト方針

**Decision**: 既存のUI層と同様、単体テストは追加せずPlaywright E2Eで検証する。
`tests/e2e/title-stageselect.spec.ts`を新規作成する。

**Rationale**: `MainGameUI`・`CardSlot`等の既存UIクラスもunit testを持たず
E2Eのみで検証されており、一貫性を保つ。
