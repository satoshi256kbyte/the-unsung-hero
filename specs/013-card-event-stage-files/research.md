# Phase 0 Research: カード・イベント・ステージのファイル構造再編

Technical ContextにNEEDS CLARIFICATIONはない（既存プロジェクトの技術スタックをそのまま
継承する内部リファクタリングのため）。ここでは設計上の主要な決定事項を記録する。

## 1. カードレジストリと `CardName` 型の扱い

**Decision**: `CardName` は `types.ts` に明示的なunion型として残す。
`cards/index.ts` のレジストリは `satisfies Record<CardName, CardDefinition>` を用いる。

**Rationale**: レジストリから型を逆算する方式（`keyof typeof CARD_REGISTRY`）は
ファイル追加だけで完結する利点があるが、カード名の一覧を1箇所（`types.ts`）で
見渡せる可読性を優先した。`satisfies` により「`CardName` に追加したがファイルを
作り忘れる」はコンパイルエラーで検知できるため、安全性は同等に確保できる。

**Alternatives considered**: レジストリからの型導出（却下）。

## 2. イベント定義の共通インターフェース

**Decision**: 各イベントファイルは `roll(state, activeEffects): GameEvent | null` を
exportする。確率補正が必要なイベントはファイル内部で `calcEventProbModifier` を
呼び出す（共通データ形状には固めない）。

**Rationale**: 既存の `rollRandomEvents` は「対象タスクをランダム選択する系」
（stall・rework）と「対象メンバーをランダム選択する系」（sick等）で処理形状が異なる。
無理に共通データ構造に押し込めるより、各ファイルが `roll()` の中で自由に実装できる
形にする方が既存ロジックの移植が単純になる。

**Alternatives considered**: `{ baseProb, targetSelector, effectBuilder }`
のような完全データ駆動形状（却下、既存ロジックとの差異が大きくなるため）。

## 3. 汎用適用処理の配置

**Decision**: `applyEventToProgress` / `applyEventToMember`
（イベント種別に依存しない汎用処理）は `events/index.ts` に残す。

**Rationale**: これらは `event.id` の文字列プレフィックスや `params` の汎用キー
（`moraleDelta` 等）に基づく処理であり、特定のイベント種別のロジックではないため
分割対象にしない。

## 4. ステージファイルの命名

**Decision**: `stages/poc-01.ts`（フラット、タイプ-連番）。`StageData.id` も
`"poc-01"` にする。

**Rationale**: 「PoC」は難易度・規模の分類であり個別ステージの識別子ではないため、
複数のPoC相当ステージが増えても曖昧にならない命名にする。

## 5. 既存単体テストの再編方針

**Decision**: 実装済みのカード・イベント（カード6種・イベント5種）は
`tests/unit/cards/<name>.test.ts` / `tests/unit/events/<name>.test.ts` として
ソースと同じ粒度に分割する。未実装分（カード19種・イベント10種前後）は
それぞれ `tests/unit/cards/stubs.test.ts` / `tests/unit/events/stubs.test.ts` に
まとめ、「コストのみ持ち効果が空である」ことを一括で検証する。

**Rationale**: ソース構造とテスト構造の粒度を揃えることで「1ファイル追加するだけで
完結する」というSpecの目的をテストコードにも適用する。一方で未実装分は
ほぼ同一内容のテストが19+10ファイルに分散すると保守性が悪化するため、
スタブ検証は集約する。

**Alternatives considered**: 全カード・イベントを個別テストファイルに分割
（却下、未実装分の同型テストが大量に増えるだけで得るものが少ない）。
既存の `card.test.ts` / `event.test.ts` を分割せず維持（却下、ソース構造との
非対称が残る）。

## 6. ドキュメント側のカード名 = ファイル名

**Decision**: `docs/03-詳細設計/カード/` `イベント/` のファイル名は、カード名・
イベント名（`CardName`・イベント名の文字列）とそのまま一致させる。

**Rationale**: カード・イベントはコード側の識別子（`CardName`の文字列自体）が
既に日本語であるため、ドキュメント側との対応にステージのような特別な
リンク属性（ID表記）は不要。
