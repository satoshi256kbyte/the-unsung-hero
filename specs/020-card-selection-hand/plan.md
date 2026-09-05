# Implementation Plan: カード選択・手札への組み込み機能

**Branch**: `020-card-selection-hand` | **Date**: 2026-08-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/020-card-selection-hand/spec.md`

## Summary

手札を「ステージ開始時の固定配列」から「ステージ配布プールからのターン補充方式」に変更する。
ステージデータに配布プール（カード・重み・任意の配布回数上限）と手札上限を追加し、
`GameState` に配布回数の記録を持たせる。補充ロジックは `src/game/deck.ts`（新規）に純関数として
実装し、`GameEngine.processTurn` の末尾で手札を上限まで補充する。実際の乱数は既存流儀
（`Math.random()` 直接）に合わせつつ、純関数は rng 注入でテスト可能にする。これにより
initialCards に含めないカードも到達可能になり、ADR-026 の暫定対応を恒久化する。

技術方針の根拠は [research.md](./research.md)、データ定義は [data-model.md](./data-model.md)、
インターフェースは [contracts/module-contracts.md](./contracts/module-contracts.md)、
検証手順は [quickstart.md](./quickstart.md) を参照。

## Technical Context

**Language/Version**: TypeScript 5（strict）

**Primary Dependencies**: zod（ステージ JSON スキーマ）。新規依存なし

**Storage**: ステージ定義は `public/data/stages/*.json`（Spec-15 の JSON 外部化）。
ゲーム状態はメモリ上の `GameState`

**Testing**: Vitest + fast-check（deck.ts の補充・上限除外・重み、engine の補充挙動）。
Playwright（手札補充の DOM 検証）。乱数は rng 注入で決定論化してテスト

**Target Platform**: ブラウザ

**Project Type**: 単一プロジェクト（`src/game/` ロジック層 + `src/ui/` DOM 層 + `src/scenes/`）

**Performance Goals**: 補充処理はターン確定時の状態更新に体感遅延なく収まる

**Constraints**: Constitution 原則 I（`src/game/` は Phaser/DOM 非依存）、原則 III
（数値バランスは docs に文書化してから実装）。`turn.ts` の純粋関数シグネチャは変更しない

**Scale/Scope**: 対象ステージは poc-01（cardPool・handLimit を定義）。カードは既存 27 種

## Constitution Check

*GATE: Phase 0 前に評価し、Phase 1 設計後に再評価する。*

### Phase 0 前評価

- **I. Architecture Boundaries（NON-NEGOTIABLE）**: 補充ロジックは `src/game/deck.ts`（純関数、
  Phaser/DOM 非依存）に置き、状態確定は `src/game/engine.ts`。UI（`MainGameUI`）は既存の
  `state.hand` 描画のまま変更不要。境界を侵さない。PASS
- **II. Test Coverage Gates（NON-NEGOTIABLE）**: deck.ts の純関数（eligibleEntries/drawCards）に
  ユニット・プロパティテストを追加し、rng 注入で決定論化。engine の補充挙動もテスト。
  `src/game/**` の閾値（lines≥80/functions≥80/branches≥75）を維持、`tsc --noEmit` 0。PASS
- **III. Game Balance Invariant**: 本フィーチャーは配布プールの重み・手札上限・配布回数上限という
  **数値バランスに直結するパラメータ**を導入する。Constitution III に従い、これらの数値
  （poc-01 の cardPool 構成・weight・maxDraws・handLimit）は実装前に `docs/03-詳細設計/` に
  文書化する（Phase 1 のタスクに含める）。設計根拠は ADR-029 として Neo4j に記録済み。
  配布はランダムだが、利益率インバリアント（無策で 5% 未満、適切なプレイで 15–25%）は
  プール設計とテストプレイで担保する。**条件付き PASS**（数値の docs 文書化を実装前提とする）
- **IV. Design Knowledge in Graph DB（NON-NEGOTIABLE）**: 本 plan の決定・ADR-029 は
  `after_plan` フックの `/sync-graphdb` で Neo4j に反映する。PASS
- **V. Dependency Hygiene**: 新規依存を追加しない。PASS

Phase 0 前：原則 III を「数値を docs に文書化してから実装」する条件付きで PASS。その他 PASS。

### Phase 1 後評価

- Phase 1 の設計（data-model / contracts / quickstart）を経ても新規依存・境界逸脱はない。
  deck.ts は純関数、engine のみ state を確定、turn.ts は不変。
- 原則 III について、data-model.md で cardPool/handLimit/maxDraws をエンティティとして定義し、
  実装フェーズ（tasks）で poc-01 の具体数値を `docs/03-詳細設計/` に文書化することを明記した。
  この文書化を実装の受け入れ条件に含めることで III を満たす。全項目 PASS を維持。

## Project Structure

### Documentation (this feature)

```text
specs/020-card-selection-hand/
├── plan.md              # このファイル
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── module-contracts.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output（/speckit-tasks で作成）
```

### Source Code (repository root)

```text
src/
├── game/
│   ├── types.ts         # StageData に cardPool/handLimit、GameState に drawCounts、CardPoolEntry
│   ├── deck.ts          # 新規: eligibleEntries / drawCards（重み付き抽選・上限除外の純関数）
│   ├── engine.ts        # buildInitialState で drawCounts 初期化、processTurn に補充ステップ
│   └── schemas/
│       └── stageData.ts # cardPool/handLimit のスキーマ（既定値補完）
└── （UI 変更なし）        # MainGameUI は state.hand をそのまま描画

public/data/stages/
└── poc-01.json          # cardPool・handLimit を追加、initialCards を再構成

docs/03-詳細設計/
└── （カード配布の数値）    # poc-01 の cardPool 構成・重み・上限・handLimit を文書化（原則 III）

tests/
├── unit/deck.test.ts    # 新規: deck 純関数のユニット・プロパティテスト
└── unit/engine.test.ts  # 補充挙動のテストを追加
```

**Structure Decision**: 既存の3層構造を維持。補充は `src/game/deck.ts`（純関数）＋`engine.ts`
（状態確定）に閉じ、UI は変更しない。ステージ数値は JSON（Spec-15 の外部化方針）に置き、
docs に文書化する（原則 III）。

## Complexity Tracking

*憲法違反はない（原則 III は数値を docs 文書化する運用で充足）。このセクションは記入不要。*
