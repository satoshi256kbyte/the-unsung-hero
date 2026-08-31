# Research: カード選択・手札への組み込み機能

**Spec**: [spec.md](./spec.md) | **Date**: 2026-08-30

spec.md の Assumptions で plan に先送りした論点（手札上限・初期枚数、poc-01 の配布プール、
乱数方式、配布回数記録の持たせ方、initialCards からの移行、重複配布の可否）をここで解決する。

## 前提となる既存実装の把握

- `GameState.hand: CardName[]` は `engine.ts` の `buildInitialState` で
  `hand: [...stageData.initialCards]` として一度だけ設定され、以降補充されない（ADR-026）。
- ターン処理は `GameEngine.processTurn`（`src/game/engine.ts`）が state を確定し `state.turn` を
  +1 する。`turn.ts` の `processTurn` は純粋関数で state を変更しない。
- 乱数は `dice.ts` の `randomInRange` が `Math.random()` を直接使用。ランダムイベント抽選
  （`events/*.ts`）も全て `Math.random()` を直接使う。seed 注入機構は存在せず、テストは
  統計的性質・境界条件で検証している。
- ステージデータは `public/data/stages/poc-01.json` を zod スキーマ（`schemas/stageData.ts`）で
  検証してロードする（Spec-15 の JSON 外部化）。`initialCards: CardName[]` を持つ。
- 27 種のカードは `cards/index.ts` のレジストリで管理。カード名は `CardName` union（types.ts）。

## Decision 1: 配布プールのデータ構造

**Decision**: `StageData` に `cardPool` を追加する。各エントリはカード名・重み・任意の配布回数上限。

```text
cardPool: Array<{ name: CardName; weight: number; maxDraws?: number }>
```

**Rationale**: ステージごとに出現カードと出やすさを制御する（Q1=A）。`weight` は相対的な
出やすさ、`maxDraws` は「ステージ中の配布回数上限」（Q3=A、省略時は無制限）。既存の
`initialCards` と同じくステージ JSON に持たせ、zod スキーマで検証する（Spec-15 の流儀）。

**Alternatives considered**:

- 全 27 カードから一律ランダム（案 B）: ステージ設計の自由度が低く却下（spec で決定済み）。
- デッキ（山札）配列を積む（案 C）: Out of Scope。

## Decision 2: 手札上限と初期枚数

**Decision**: `StageData` に `handLimit`（手札上限）を追加する。初期配布は既存の
`initialCards` を引き続き用い、その枚数は `handLimit` 以下に整合させる。

- poc-01 の暫定値: `handLimit = 8`（基本設計「8コスト分のカード枠」と整合）、
  初期配布は現行の `initialCards`（5 枚）を維持。
- 具体値は最終的にバランス調整の対象。plan では上記を初期値として設定し、テストプレイで再校正可。

**Rationale**: 手札上限をステージ定義に持たせることで、ステージごとに手札運用を変えられる。
初期配布を initialCards に据え置くことで既存データとの後方互換を保ちつつ、以降を補充で拡張する。

## Decision 3: 補充タイミングと補充ロジック

**Decision**: `GameEngine.processTurn` の最後（state 確定・`turn` +1 の直前後）に「補充ステップ」を
追加し、次ターン開始時点で手札が `handLimit` に満たなければプールから不足分を配る。

- 補充ロジックは純関数として `src/game/deck.ts`（新規）に分離する:
  `drawCards(pool, drawCounts, handSize, limit, rng)` のような形で、
  配布可能カード（プールに存在し `maxDraws` 未到達）から重み付き抽選する。
- 実際の乱数は既存流儀に合わせ `Math.random()` を用いる（`rng` 引数のデフォルトで注入）。
  純関数部分（重み選択・上限除外・不足分計算）は `rng` を注入してテスト可能にする。

**Rationale**: 補充は state を確定する engine の責務。ロジックを純関数に分離することで、
既存の乱数流儀（Math.random 直接）を壊さずに、抽選の正しさ（プール内のみ・上限除外・
重み反映）を決定論的にテストできる（rng 注入）。

**Alternatives considered**:

- `turn.ts` の純粋関数内で補充: turn.ts は state 非変更の設計であり、手札という state の
  更新は engine の責務。既存契約を崩さないため却下。

## Decision 4: 配布回数の記録

**Decision**: `GameState` に `drawCounts: Record<string, number>`（カード名→累計配布回数）を
追加し、engine が補充のたびに加算する。初期配布分も記録に含める。

**Rationale**: `maxDraws`（配布回数上限）との比較に必要。手札から使って無くなった後の
再配布可否も、上限がある限りこの記録で制御される。ゲーム状態として進行中に保持する
（data-model.md に定義）。

## Decision 5: initialCards からの移行

**Decision**: `initialCards` は初期配布として存続させる。ADR-026 の暫定対応（休出（土）（日）を
initialCards に追加）は、poc-01 の `cardPool` に休出（土）（日）を含めることで恒久化し、
initialCards からは外してよい（初期手札に固定で持たせる必要がなくなる）。

- ただし poc-01 の initialCards/cardPool の最終構成はバランス調整対象。plan では
  「cardPool に全候補（休出含む）を重み付きで定義、initialCards は基本カード数枚」を初期案とする。

**Rationale**: 到達可能性（SC-001）は cardPool で担保されるため、休出カードを initialCards に
固定する必要がなくなる。ADR-026 の暫定対応の役割を Spec-19 が引き継ぐ（ADR-029 が SUPERSEDES）。

**実装時の確定（2026-08-31、ADR-030）**: 対象選択UIの E2E（`tests/e2e/target-picker.spec.ts`、
Spec-16）が初期手札の休出（土）の存在に依存し、`requiresTarget` を持つカードが休出（土）（日）の
2種のみで補充はランダムなため、E2E で確実に手札へ出すのが難しい。そこで案1を採用し、poc-01 の
initialCards に休出（土）を1枚残しつつ cardPool にも含めて入手経路を二重化した
（休出（日）はプール経由のみ）。initialCards は4枚（デイリー・レビュー・モニタリング・休出（土））、
handLimit は 8。将来 `requiresTarget` カードが増えれば E2E を別カードへ移して初期から外せる。

## Decision 6: 重複配布の可否

**Decision**: 同一カードが手札に複数枚存在してよい（重複を許す）。ただし `maxDraws` があるカードは
その上限までしか配られない。

**Rationale**: プール＋重み方式では自然に重複が起こり得る。重複を一律禁止すると実装が複雑になり、
基本設計の「デイリー等を毎ターン使う」運用（同じカードを繰り返し使う）とも整合しない。
特別なカードの希少性は `maxDraws` で表現する。

## Decision 7: 乱数のテスタビリティ

**Decision**: 既存流儀（`Math.random()` 直接）を維持する。補充の純関数 `drawCards` は乱数関数を
引数で受け取れるようにし（デフォルト `Math.random`）、テストでは決定論的な rng を注入する。

**Rationale**: プロジェクト全体が seed 機構を持たず Math.random 直接の方針（events/dice）。
これに合わせることでアーキテクチャの一貫性を保ちつつ、rng 注入で抽選ロジックはテスト可能にする。

## 未解決事項

なし。数値（handLimit・重み・maxDraws）の最終調整はバランス調整タスクとして
実装後のテストプレイに委ねる（plan の初期値で機能検証は可能）。
