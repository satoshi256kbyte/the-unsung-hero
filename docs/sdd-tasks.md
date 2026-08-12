# SDD タスクリスト

実装計画の詳細は `docs/superpowers/plans/2026-08-12-sdd-task-breakdown.md` を参照。

## Phase 1: コアデータ構造

- [x] Spec-01: ゲームパラメータ型定義・定数
- [ ] Spec-02: ガントチャート・タスクモデル

## Phase 2: ゲームロジック

- [ ] Spec-03: 進捗ダイスエンジン
- [ ] Spec-04: メンバーパラメータ変動エンジン
- [ ] Spec-05: ターン処理エンジン（コア）

## Phase 3: イベント・カードロジック

- [ ] Spec-06: ランダムイベントエンジン
- [ ] Spec-07: カードエフェクトエンジン

## Phase 4: ゲームループ・画面

- [ ] Spec-08: GameEngine（フルターンループ）
- [ ] Spec-09: PoCステージデータ
- [ ] Spec-10: メイン画面UI（DOM overlay + Phaser Scene）

---

## 実行ルール

- 各Specは `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement` の順で実行
- Phase 1・Phase 2（03/04）・Phase 3（06/07）・Phase 4（08/09）は同フェーズ内で並列実行可
- Spec-05 は Spec-03・04 完了後に開始
- Spec-10 は Spec-08・09 完了後に開始
- 各Spec完了後、pre-push（typecheck + coverage + audit）を通過させてからpush
