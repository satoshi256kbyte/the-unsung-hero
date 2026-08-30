# Research: ゲーム内ガントチャートUI

**Spec**: [spec.md](./spec.md) | **Date**: 2026-08-30

本フィーチャーの技術方針を確定するための調査結果。spec.md の Assumptions で plan に先送りした
論点（実績データの持ち方、稲妻線の折れ量算出、実績記録タイミング、予定差し替え時の実績連続性、
画面切替の実装方式）をここで解決する。

## 前提となる既存実装の把握

- `GanttTask`（`src/game/types.ts`）は `id / name / phase / startTurn / duration /
  assignedMemberId / progress(0-100) / status / dependencies` を持つ。
- `TaskStatus = "active" | "stalled" | "done"`。全タスクは初期状態から `active`。
  `startTurn` は計画上の開始ターンだが、実際の着手ターン・完了ターンは記録されていない。
- `src/game/gantt.ts` の `updateTaskProgress` が `progress === 100` で `status` を `done` にする。
- `src/game/engine.ts` の `GameEngine.processTurn` がターンごとに各タスクの progress / status を
  更新し、`state.turn` を +1 する。ここが実績記録の唯一の差し込みポイント。
- `dayOfWeek(turn) = (turn - 1) % 7`（0=月〜6=日）、`isWeekend` は土(5)日(6)。ターン軸の
  曜日表示にそのまま使える（Spec-16 の契約）。
- `MainGameUI`（`src/ui/MainGameUI.ts`）は DOM overlay 方式（Phaser 不使用）。ヘッダー／
  ダッシュボード／カード枠／フッターのみで、画面切替メニューは未実装。全要素に `data-testid` を
  付与し Playwright E2E から参照可能（Constitution 原則 I 準拠）。
- `ganttVariants`（リスケ／仕様追加時の予定差し替え）機構が既に存在する。

## Decision 1: 実績データ（着手・完了ターン）の保持方法

**Decision**: `GanttTask` に楽観的な実績フィールドを2つ追加する。

- `actualStartTurn: number | null` — 実際に進捗が初めて加算されたターン（未着手は null）
- `actualEndTurn: number | null` — `progress` が 100 に到達したターン（未完了は null）

**Rationale**: 稲妻線（予定対実績のずれ）と実績行（着手〜完了の帯）を正確に描くには、
`progress` だけでは「いつ着手したか」を復元できない。既存の `startTurn`（計画）とは別に
実績を明示的に持つ必要がある（Q2=B の決定）。null 許容にすることで未着手・未完了を表現でき、
既存の初期データ（実績なし）とも整合する。

**Alternatives considered**:

- progress と現在ターンからの逆算のみ（Q2=A）: 着手ターンが復元できず却下。
- 別テーブル（実績専用エンティティ）で管理: タスクと1:1で状態が結びつくため、
  同一エンティティに持つ方が単純。オーバーエンジニアリングとして却下。

## Decision 2: 実績の記録タイミング

**Decision**: `GameEngine.processTurn` 内のタスク更新時に記録する。

- そのターンで `progressUpdates` により進捗が 0 より増えた、かつ `actualStartTurn` が null の
  タスクは、`actualStartTurn = state.turn`（更新前の現在ターン）を設定する。
- 更新の結果 `progress` が 100 に達し、かつ `actualEndTurn` が null のタスクは、
  `actualEndTurn = state.turn` を設定する。

**Rationale**: progress / status 更新は engine の1箇所に集約されており、そこに実績記録を
足すのが最小変更。`turn.ts` の純粋関数群のシグネチャは変えず、状態確定を担う engine に
実績確定も寄せることで責務が一貫する。

**Alternatives considered**:

- `turn.ts` の `processTurn`（純粋関数）側で記録: turn.ts は state を変更せず結果だけ返す
  設計であり、実績確定は state を持つ engine の責務。既存契約（Spec-16 で維持と明記）を
  崩さないため却下。

## Decision 3: 稲妻線（進捗ライン）の折れ量算出方式

**Decision**: 進捗率ベースで「実績到達ターン」を算出し、現在ターンとの差で折れ量を決める。

タスクごとに次を計算する。

- 期待進捗位置 = `startTurn + duration * (progress / 100)` を基準にするのではなく、
  各タスクについて「予定上、現在ターンまでに完了しているべき割合」と「実際の progress」の
  ずれを用いる。
- 具体的には、現在ターン `T` における予定進捗率
  `plannedRate = clamp((T - startTurn + 1) / duration, 0, 1) * 100` を求め、
  `progress - plannedRate` の符号で稲妻線の折れ方向（正=前倒しで右、負=遅れで左）を決める。
- 折れ位置のターン座標 = `startTurn - 1 + duration * (progress / 100)` を実績到達ターンとして
  用い、これと現在ターン `T` の差を水平方向のオフセットとして描画する。

**Rationale**: 稲妻線は「予定に対する進み・遅れ」を示す一般的なガント表現。進捗率ベースは
残作業量の推定を必要とせず、既存の `progress`・`startTurn`・`duration` だけで算出できるため
実装が単純で、SC-002（3状態を100%読み取れる）を満たせる。

**Alternatives considered**:

- 残作業（残ターン数）ベース: メンバーのスキルや稼働見込みが必要で算出が複雑。
  本フィーチャーは表示専用であり、将来予測（Out of Scope）に踏み込むため却下。

## Decision 4: 予定差し替え（リスケ）時の実績連続性

**Decision**: 実績フィールド（`actualStartTurn` / `actualEndTurn`）はタスク id をキーに保持し、
`ganttVariants` による予定差し替えが起きても、同一 id のタスクの実績値は引き継ぐ。

**Rationale**: リスケは「予定（startTurn/duration）」を差し替えるものであり、既に発生した
実績（いつ着手したか）は事実として不変。id が一致するタスクは実績を保持することで、
差し替え後も実績行・稲妻線が破綻しない。差し替えで消えた id・新規 id は実績なし（null）とする。

**Alternatives considered**:

- 差し替え時に実績を全リセット: 過去の実績が失われ稲妻線が不正確になるため却下。
- 実績を variant ごとに別管理: 複雑化。id ベースの引き継ぎで十分。

## Decision 5: ガントチャート画面の実装方式と画面切替

**Decision**: DOM overlay 方式で新規に `GanttChartUI`（`src/ui/GanttChartUI.ts`）を実装し、
`MainGameUI` にメニュー（画面切替）を追加してダッシュボード⇔ガント画面をトグルする。

- ガント画面はテーブル状の DOM（タスク行＝予定行＋実績行の2行、列＝ターン1〜deadline）で構成。
- 稲妻線は各タスク行に折れ線要素（絶対配置の線 or 疑似要素）で重畳する。
- タスク選択で依存（先行タスク）をハイライトする。
- 全要素に `data-testid` を付与し Playwright から参照可能にする（Constitution 原則 I）。
- 画面切替はメニューのボタン押下で `MainGameUI` の表示/非表示と `GanttChartUI` の表示/非表示を
  トグルする。ガント画面は現在の `GameState` を受け取って描画する（閲覧専用、状態更新なし）。

**Rationale**: 既存 UI（`MainGameUI` / `CardSlot` / `LoadingScreen`）が全て DOM overlay 方式で、
Phaser canvas を使わずに E2E 可能にしている。ガント画面も同方式にすることで Constitution の
アーキテクチャ境界（`src/ui/` は DOM、`src/game/` はロジックのみ）を維持でき、E2E で
稲妻線・実績行・依存表示を検証できる。

**Alternatives considered**:

- Phaser Scene 上に canvas 描画: canvas は E2E から不透明で Constitution 原則 I（DOM overlay で
  E2E 可能）に反するため却下。
- 別 Phaser Scene への遷移: 状態受け渡しが複雑化。オーバーレイのトグルで十分。

## Decision 6: ターン軸のスクロールと表示範囲

**Decision**: 列はターン1〜`deadline`（poc-01 では30）を全て描画し、横スクロールで閲覧可能にする。
タスク行が多い場合は縦スクロール可能にする。土日列は視覚的に色を変える（任意要件だが、
Spec-17 の docs 表記（■/・）と整合させ、土日は淡色で区別する）。

**Rationale**: Edge Cases（画面に収まらない場合のスクロール、最終ターンでの破綻回避）と
FR-011 を満たす。曜日表示（FR-008）は `dayOfWeek` を用いる。

## 未解決事項

なし。全ての NEEDS CLARIFICATION は上記 Decision で解決済み。
