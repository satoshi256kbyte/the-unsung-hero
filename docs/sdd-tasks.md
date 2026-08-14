# SDD タスクリスト

実装計画の詳細は `docs/superpowers/plans/2026-08-12-sdd-task-breakdown.md` を参照。

## Phase 1: コアデータ構造

- [x] Spec-01: ゲームパラメータ型定義・定数
- [x] Spec-02: ガントチャート・タスクモデル

## Phase 2: ゲームロジック

- [x] Spec-03: 進捗ダイスエンジン
- [x] Spec-04: メンバーパラメータ変動エンジン
- [x] Spec-05: ターン処理エンジン（コア）

## Phase 3: カード・アクティブ効果ロジック

- [x] Spec-06: カード効果エンジン（applyCards）
- [x] Spec-07: ターン統合エンジン（カード効果 × アクティブ効果管理）

## Phase 4: イベント・停滞ロジック

- [x] Spec-08: ランダムイベントエンジン（停滞・手戻り本体）
- [x] Spec-09: 条件付きイベントエンジン

## Phase 5: ゲームループ・ステージ

- [x] Spec-10: GameEngine（フルターンループ）
- [x] Spec-11: PoCステージデータ

## Phase 6: 画面

- [x] Spec-12: メイン画面UI（DOM overlay + Phaser Scene）

## Phase 7: データ構造リファクタリング

- [x] Spec-13: カード・イベント・ステージのファイル構造再編
      （設計: `docs/superpowers/specs/2026-08-14-game-data-file-restructure-design.md`）

## Phase 8: 画面遷移

- [ ] Spec-14: タイトル〜ステージセレクト画面遷移
      （設計: `docs/superpowers/specs/2026-08-14-title-stageselect-flow-design.md`、
      ステージ確認画面の追記が未反映のため設計ドキュメントの更新が必要）

---

## SDD外タスク（ツール・スキル整備）

Specの実装対象（ゲームロジック・画面）ではなく、開発ツール・AIエージェント向けの
スキル整備タスク。`/speckit-specify` 等のSDDパイプラインは通さない。

- [ ] `docs/03-詳細設計/カード/` `イベント/` `ステージ/` 配下のMarkdownから
      `src/game/cards/` `events/` `stages/` 配下のソースコードを生成するskillを作る。
      Spec-13でdocsとソースコードが1カード/1イベント/1ステージ=1ファイルの
      1:1構造になることが前提。表形式のデータ（コスト・確率・ガントチャート・
      条件付きイベント）の変換は大部分プログラム化できる見込み。
      Spec-13完了後に着手する

## 実行ルール

- 各Specは `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement` の順で実行
- 各Spec完了後 `/sync-graphdb` を実行してグラフDBへ反映
- 各Spec完了後、pre-push（typecheck + coverage + audit）を通過させてからpush
