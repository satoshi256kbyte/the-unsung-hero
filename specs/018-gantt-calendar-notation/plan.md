# Implementation Plan: docsガントチャート表記見直し（カレンダー列形式）

**Branch**: `018-gantt-calendar-notation` | **Date**: 2026-08-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/018-gantt-calendar-notation/spec.md`

## Summary

`docs/03-詳細設計/ステージ/PoCステージ01.md`のガントチャート表を、
ターン1〜締切ターンの全ターンを1列ずつ持つカレンダー形式（列見出し
「ターン番号(曜日)」）に書き換える。あわせて同ファイルのヘッダーテーブル
（締切・初期カード・パス参照）と条件付きイベント表のターン番号を、
`public/data/stages/poc-01.json`の実値に合わせて修正する。純粋なMarkdown
編集作業であり、`src/`配下のコード変更は発生しない。

## Technical Context

**Language/Version**: Markdown（対象ファイルのみ）。生成にあたり
`public/data/stages/poc-01.json`の値をPython/Node等のワンショットスクリプトで
読み取り、表を機械的に構築する

**Primary Dependencies**: なし（既存の`src/game/calendar.ts`の`dayOfWeek`
ロジックを手動で踏襲するのみ。曜日計算はターン生成スクリプト内で
そのロジックを再現する）

**Storage**: N/A（ドキュメントファイルのみ）

**Testing**: markdownlint-cli2（既存のpre-commitフックで自動実行）。
加えて生成した表の値を`public/data/stages/poc-01.json`と目視突合する
（自動テストの対象外、docsは実行可能コードではないため）

**Target Platform**: N/A

**Project Type**: ドキュメント編集（既存リポジトリのdocs/配下）

**Performance Goals**: N/A

**Constraints**: `.markdownlint.json`のルール（MD013の行長制限はテーブル
除外済みのため30列の表でも問題にならない）に準拠すること

**Scale/Scope**: 対象ファイルは`docs/03-詳細設計/ステージ/PoCステージ01.md`
1ファイルのみ（現状ステージは`poc-01`のみ存在するため）

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Architecture Boundaries**: 該当なし（`src/`配下のコード変更なし）。PASS
- **II. Test Coverage Gates**: 該当なし（テストコードの変更なし。ドキュメントの
  みの変更であり、`src/game/**`のカバレッジに影響しない）。PASS
- **III. Game Balance Invariant**: 該当なし（数値・バランスの変更なし。
  表記のみの変更）。PASS
- **IV. Design Knowledge in Graph DB**: 本Specの完了後、グラフDBへの反映
  （`sync-graphdb`）を通じてSpec-17の完了・ドキュメント更新内容を記録する。
  ステージのガントチャート表・条件付きイベントは元々docs/にも二重管理として
  置く対象（`CLAUDE.md`のdocs/運用方針表）であり、今回の表記変更後もこの
  位置づけを維持する。PASS
- **V.**（存在する場合の追加原則、該当なし）

全項目PASS。違反なし。

## Project Structure

### Documentation (this feature)

```text
specs/018-gantt-calendar-notation/
├── plan.md              # このファイル
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md         # Phase 1 output
└── tasks.md             # Phase 2 output（/speckit-tasksで作成）
```

contracts/は作成しない（本Specは外部インターフェース・APIを持たない
純粋なドキュメント編集のため）。

### Source Code (repository root)

```text
docs/03-詳細設計/ステージ/
└── PoCステージ01.md     # 変更対象（ヘッダーテーブル・ガントチャート表・
                          # 条件付きイベント表の3セクションを修正）
```

**Structure Decision**: 新規ディレクトリ・新規ファイルの作成は発生しない。
既存の`docs/03-詳細設計/ステージ/PoCステージ01.md`を直接編集する
（Spec-13で確立した1ステージ1ファイルの構造を維持）。

## Complexity Tracking

*本Specに憲法違反はないため、このセクションは記入不要。*
