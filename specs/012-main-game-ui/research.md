# Research: メイン画面UI

Phase 0 output for Spec-12

## DOM overlay と Phaser Scene の協調

- Decision: `#ui-overlay` div を永続レイヤーとして扱い、Scene は `style.display` 切替と
  内容更新のみを行う
- Rationale: Phaser 4 には DOM overlay のライフサイクル API がない。
  既存 `index.html` の `#game-container` (relative) + `#ui-overlay` (absolute) 構造が
  すでに正しく、動的マウント/アンマウントは不要
- Alternatives considered: Shadow DOM・Web Components — 複雑さに対してメリットなし

## ドラッグ＆ドロップ方式

- Decision: HTML5 ネイティブ drag events を使用（`draggable="true"` + `dragstart`/`dragover`/`drop`）
- Rationale: デスクトップブラウザゲームとしてシンプルかつ追加ライブラリ不要。
  カード ID は `dataTransfer.setData("text/plain", cardId)` で渡す。
  ドラッグ対象・ドロップ先は `.interactive` クラスで `pointer-events: auto` を有効化する必要がある
- Alternatives considered: Pointer Events API — マルチタッチ要件なしのため不採用

## Scene → DOM overlay の通知パターン

- Decision: Scene が overlay インスタンスの `render(state: GameState)` メソッドを直接呼ぶ
- Rationale: `GameEngine.getState()` がスナップショットを返す設計なので、
  Scene がターン後に `overlay.render(engine.getState())` を呼ぶだけで十分。
  EventEmitter や pub/sub は間接層を増やすだけで利点がない
- Alternatives considered: Phaser の global EventEmitter — 複数 Scene 間通信が必要になった場合の
  エスカレーションパスとして保留

## ローディング画面の最低表示時間

- Decision: `Promise.all([Promise.resolve(engine.processTurn(cards)), sleep(1000)])` パターンを使用
- Rationale: 現在の `processTurn` は同期的なので `Promise.resolve()` でラップ。
  `sleep` と `Promise.all` で最低 1 秒を保証しつつ、将来非同期化しても呼び出し側変更不要
- Alternatives considered: `setTimeout` の固定遅延 — processTurn が将来非同期になった際に
  二重待ちが発生するため不採用

## UI コンポーネントの境界

- `src/ui/` は純粋な DOM 操作のみ（Phaser import 禁止・ビジネスロジック禁止）
- `src/scenes/` が `src/ui/` と `src/game/` の両方を import し協調を担当
- `src/game/` は今 Spec では変更なし
