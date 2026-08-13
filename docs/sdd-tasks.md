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
- [ ] Spec-07: ターン統合エンジン（カード効果 × アクティブ効果管理）

## Phase 4: イベント・停滞ロジック

- [ ] Spec-08: ランダムイベントエンジン（停滞・手戻り本体）
- [ ] Spec-09: 条件付きイベントエンジン

## Phase 5: ゲームループ・ステージ

- [ ] Spec-10: GameEngine（フルターンループ）
- [ ] Spec-11: PoCステージデータ

## Phase 6: 画面

- [ ] Spec-12: メイン画面UI（DOM overlay + Phaser Scene）

---

## 実行ルール

- 各Specは `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement` の順で実行
- 各Spec完了後 `/sync-graphdb` を実行してグラフDBへ反映
- 各Spec完了後、pre-push（typecheck + coverage + audit）を通過させてからpush
