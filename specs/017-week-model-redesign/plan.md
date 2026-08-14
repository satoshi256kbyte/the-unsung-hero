# Implementation Plan: 週モデル変更（ターン＝暦日・7ターン周期）

**Branch**: `017-week-model-redesign` | **Date**: 2026-08-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/017-week-model-redesign/spec.md`

## Summary

`turn.ts`の週モデルを「5ターン=1週間（土日はターンを消費しない）」から
「ターン＝暦日、月曜始まり7ターン周期」に変更する。土日は休日出勤（土）／
休日出勤（日）カードで対象メンバーを1人指定して稼働させない限り進捗が発生しない。
カードに対象メンバーを指定する仕組み（対象選択UI）を新規に導入する。
PoCステージの締切・条件付きイベントのターン番号を新しい週モデルに合わせて
再校正する。

## Technical Context

**Language/Version**: TypeScript 5（strict mode、既存プロジェクト設定を継承）

**Primary Dependencies**: なし（新規依存追加なし）

**Storage**: `public/data/cards/holiday-work-sat.json` `holiday-work-sun.json`
（`holiday-work.json`を置き換え）、`public/data/stages/poc-01.json`の
`deadline`・`conditionalEvents`を更新

**Testing**: Vitest + fast-check（既存単体テスト方針を継承）。対象選択UIは
Playwright E2Eで検証

**Target Platform**: 既存と同じ

**Project Type**: 既存の単一プロジェクト構成を維持

**Performance Goals**: N/A

**Constraints**:

- Constitution Principle I: 曜日判定・カード効果ロジックは`src/game/`に置き
  Phaser/DOM非依存を維持する。対象選択UIは`src/ui/`に置く
- 既存カード（個別面談・表彰・計画休）のシグネチャ・挙動は変更しない

**Scale/Scope**: 新規ファイル`src/game/calendar.ts`、カード2件の新規実装
（既存`holiday-work.ts`を置き換え）、`turn.ts`・`cards/index.ts`・
`CardSlot.ts`・`MainGameUI.ts`・`types.ts`の変更、`poc-01.json`の再校正、
docs 2ファイルの更新

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 判定 | 備考 |
|------|------|------|
| I. Architecture Boundaries | PASS | `calendar.ts`・カードロジックは`src/game/`のまま。対象選択UIは`src/ui/`に追加し、Scene（`src/scenes/`）は変更しない |
| II. Test Coverage Gates | PASS | `calendar.ts`・カード2件は既存と同じ単体テスト方針。`turn.ts`の変更は既存`turn.test.ts`の更新でカバーする |
| III. Game Balance Invariant | PASS | 締切・条件付きイベントのターン番号再校正はdocs（`バランスパラメータ.md`）に反映する。カードコストは暫定値とし、バランス調整はテストプレイ後 |
| IV. Design Knowledge in Graph DB | PASS | ADR-025としてすでにNeo4jに反映済み |
| V. Dependency Hygiene | PASS | 新規依存追加なし |

違反なし。Complexity Trackingの記入は不要。

## Project Structure

### Documentation (this feature)

```text
specs/017-week-model-redesign/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── calendar-and-targeting-contracts.md
└── tasks.md
```

### Source Code (repository root)

```text
src/game/
├── calendar.ts               # 新規。isWeekend(turn) / dayNumber(turn)
├── turn.ts                     # 進捗ダイスの土日スキップ、週末回復判定の変更
├── types.ts                     # CardNameユニオン変更（休出→休出（土）／休出（日））
└── cards/
    ├── holiday-work-sat.ts      # 新規（holiday-work.tsを置き換え）
    ├── holiday-work-sun.ts      # 新規
    └── index.ts                  # CardDefinitionにtargetId引数、applyCards署名変更

src/ui/
├── CardSlot.ts                  # targetMemberIdフィールド追加
└── MainGameUI.ts                 # 対象選択UI追加、getPlacedCards()の戻り値変更

public/data/
├── cards/holiday-work-sat.json   # 新規
├── cards/holiday-work-sun.json    # 新規
└── stages/poc-01.json              # deadline・conditionalEventsのターン番号再校正

docs/03-詳細設計/
├── カード/休出.md                 # 休出（土）.md・休出（日）.mdに分割
└── バランスパラメータ.md            # 「5稼働日ごと」等の記述を7ターン周期に更新
```

**Structure Decision**: 既存の3層アーキテクチャを維持する。新規の曜日判定は
`src/game/`に、対象選択UIは`src/ui/`に追加し、Spec-13の1カード1ファイル・
Spec-15のJSON外部化の構造規約に従う。

## Complexity Tracking

*本Specでは違反なし。記入なし。*
