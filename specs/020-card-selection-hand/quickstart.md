# Quickstart: カード選択・手札への組み込み機能

**Spec**: [spec.md](./spec.md) | **Date**: 2026-08-30

本フィーチャーの動作を検証する手順。契約は
[contracts/module-contracts.md](./contracts/module-contracts.md)、データ定義は
[data-model.md](./data-model.md) を参照。

## 前提

```bash
npm install
docker compose up -d   # ナレッジグラフ（設計参照用、実行検証には必須ではない）
```

## 自動検証（ユニット・型・E2E）

```bash
npx vitest run          # ユニット/プロパティテスト（deck 補充・上限除外・重み）
npx tsc --noEmit        # 型エラー 0
npx playwright test     # E2E（手札補充の DOM 検証）
```

期待結果:

- ユニットテスト全 PASS。`src/game/**` のカバレッジが Constitution 閾値
  （lines ≥ 80% / functions ≥ 80% / branches ≥ 75%）を満たす。
- `tsc --noEmit` が 0 で終了する。
- E2E 全 PASS。

## ユニット検証の要点（deck.ts）

- `eligibleEntries`: maxDraws に達したカードが除外される／未到達・無制限は含まれる
- `drawCards`（rng 注入で決定論化）:
  - 手札が handLimit 未満なら不足分だけ補充される
  - 手札が handLimit 以上なら補充されない（上限超過なし）
  - 配布されるカードは必ず pool 内かつ eligible なもの
  - 配布可能カードが尽きたら不足のまま打ち切る（例外を投げない）
  - 重み比に応じた配布傾向（統計的に多数回抽選して検証）

## 手動検証（受け入れシナリオ）

```bash
npm run dev
```

タイトル → ステージセレクト（PoCステージ）→ 確認 → 開始 でメイン画面に入る。

### シナリオ 1: 毎ターンの手札補充（US1 / FR-002, FR-003, FR-004 / SC-002）

1. ステージ開始直後、手札に初期枚数のカードがある（`hand-card-*`）。
2. カードを使ってターンを確定し、次ターンに入る。
3. 手札が handLimit まで補充されている（上限を超えない）。

### シナリオ 2: 配布プールによる制御（US2 / FR-005, FR-006 / SC-004）

1. 複数ターン進めて配布されるカードを観察する。
2. 配布されるカードはすべて poc-01 の cardPool 内のカードである。
3. 重みの大きいカードほど多く出る傾向がある（多ターン観察）。

### シナリオ 3: 配布回数上限（US3 / FR-007, FR-008 / SC-003）

1. cardPool で maxDraws=1 を設定したカードが、ステージを通じて最大 1 回しか配布されない。
2. maxDraws 未設定のカードは上限による除外を受けない。

### シナリオ 4: 到達可能性（SC-001）

1. initialCards に含めず cardPool にのみ入れたカード（例: 休出（土）（日））が、
   ゲーム進行中に手札へ配布され得ることを確認する。

### シナリオ 5: 回帰（FR-011 / SC-005）

1. カード選択・配置（コスト上限内）・対象選択・ターン確定の一連の操作が、
   本機能導入後も従来どおり完了できる。

## 検証と Spec の対応

| シナリオ | 対応 User Story / FR / SC |
|---------|--------------------------|
| 1 | US1 / FR-002, FR-003, FR-004, FR-010 / SC-002 |
| 2 | US2 / FR-005, FR-006 / SC-004 |
| 3 | US3 / FR-007, FR-008 / SC-003 |
| 4 | US1/US2 / FR-001, FR-005 / SC-001 |
| 5 | FR-011 / SC-005 |
