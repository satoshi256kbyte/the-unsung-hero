# バランスデータのJSON外部化設計

## 概要

ステージ・カード・イベントの数値データ（コスト・発生確率・ガントチャート・条件付き
イベント・メンバー初期値等）と、`constants.ts`/`balance.ts`の係数テーブルを、
TypeScriptのリテラルからJSONファイルに外部化する。効果ロジック（`applyEffect`/
`roll`関数等）はTypeScriptのまま残す。

**目的**: バランス調整（チューニング）作業を、TypeScriptのビルド・型チェックを介さず
JSONの数値編集だけで回せるようにする。

## 対象データと現状

Spec-13（`docs/superpowers/specs/2026-08-14-game-data-file-restructure-design.md`）で
カード・イベント・ステージは既に1ファイル1定義の構造になっている。今回はそのうち
「数値・データ部分」だけをJSONへ切り出す。

| 対象 | 現状 | 切り出す部分 |
| ---- | ---- | ------------ |
| カード（26） | `src/game/cards/<name>.ts` に `cost` + `applyEffect` | `cost` のみ |
| イベント（15） | `src/game/events/<name>.ts` に基本確率 + `roll` | 基本確率（派生確率含む）のみ |
| ステージ（1） | `src/game/stages/poc-01.ts` にStageData全体 | ほぼ全体（純粋データのため） |
| バランス係数 | `src/game/constants.ts` の各テーブル | 全体（`POC_STAGE`は下記の通り整理） |

`constants.ts`の`POC_STAGE`オブジェクトは、`WORKING_DAYS`/`MEMBER_COUNT`等が
`poc-01.ts`のStageDataと重複・一部不整合（`MEMBER_COUNT: 2`だが実際は3人）を
起こしている。JSON移行のタイミングで重複分は削除し、ステージ非依存の
グローバルルール（`BUFFER_RATIO`・`TARGET_PROFIT_RATE`・`DAILY_COST_CAP`・
`OVERTIME_COST_CAP`）のみを残して`GLOBAL_RULES`に改名する。

## JSONファイルの配置

Viteの`public/`配下は素通しで配信されるため、ここに置く（ビルドし直さず
デプロイ先の`dist/`内JSONを直接書き換えれば次回ロード時に反映される）。

```text
public/data/
  cards/
    daily.json          { "cost": 1 }
    ...（26ファイル、Spec-13のcards/と1:1対応）
  events/
    stall.json           { "baseProb": 0.05 }
    rework.json           { "baseProb": 0.08, "withDailyReviewProb": 0.05 }
    ...（15ファイル、Spec-13のevents/と1:1対応）
  stages/
    poc-01.json           StageData相当（id・name・budget・deadline・
                           initialMembers・initialGantt・ganttVariants・
                           conditionalEvents・initialCards・description）
  balance/
    constants.json        MEMBER_PARAMS・PROGRESS_DICE・EXP・LEVEL_UP_EXP・
                           PARAM_DELTA・THRESHOLDS・STALL・CHECKPOINT_PROB・
                           SKILL_FACTOR_TABLE・HEALTH_FACTOR_TABLE・GLOBAL_RULES
```

## スキーマ検証（zod）

新規依存として`zod`（MITライセンス、既存の承認済みライセンス方針に適合）を追加する。
`src/game/schemas/`配下にJSON形状ごとのスキーマを置く。

```text
src/game/schemas/
  cardData.ts        z.object({ cost: z.number().int().nonnegative() })
  eventData.ts        z.object({ baseProb: z.number().min(0).max(1) }).catchall(z.number())
  stageData.ts         StageDataと同型のスキーマ
  balanceConstants.ts   constants.tsの各テーブルと同型のスキーマ
```

読み込んだJSONは各スキーマの`.parse()`を通す。検証失敗時は起動時に例外で落とし、
不正なデータのまま起動しないようにする。

## 起動時ロードフロー

`src/game/`はConstitution Principle I（Phaser/DOM非依存）によりfetchを持てないため、
`src/scenes/`側で読み込む。新規`PreloadScene`を`BootScene`と`TitleScene`の間に挟む。

```text
BootScene → PreloadScene（JSON一括ロード＋zod検証＋レジストリ構築） → TitleScene → ...
```

`PreloadScene.preload()`でPhaserの`this.load.json(key, path)`を、カード26＋
イベント15＋ステージ1＋バランス1＝43ファイル分ループで呼び出す（対象名の一覧は
`CARD_NAMES`/`EVENT_KEYS`等、既存のレジストリのキー一覧から生成し、二重管理しない）。
`create()`でzod検証後、`buildCardRegistry()`等を呼んでレジストリを構築し、
`this.registry.set(...)`でPhaserのグローバルレジストリに載せて後続Sceneに渡す。

## `src/game/`レジストリ構築の変更

現状（Spec-13）は`CARD_REGISTRY`がモジュール読み込み時に確定する定数
（`satisfies Record<CardName, CardDefinition>`）。JSON化後は次の形に変える。

```typescript
export function buildCardRegistry(
  costData: Record<CardName, { cost: number }>,
): Record<CardName, CardDefinition> {
  return {
    デイリー: { cost: costData.デイリー.cost, applyEffect: dailyApplyEffect },
    ...
  } satisfies Record<CardName, CardDefinition>;
}
```

`applyEffect`/`roll`本体（ロジック）は各ファイルからexportされる純粋関数のまま
変更しない。`satisfies`による網羅性チェックは関数内に残るため、Spec-13の
ADR-019/021の安全性は維持される。

イベント・ステージも同様に`buildEventRegistry(probData)`・
`buildStageRegistry(stageDataJson)`という構築関数に変える。

## docs・グラフDBにおける数値記載方針

数値の生きた実体はJSONファイルのみに置く。docsとグラフDBは以下のみを記載する。

- 係数・パラメータの**存在・意味・使われる計算式の形**
- 対応するJSONファイルパスとキー（例:「目標利益率 → `public/data/balance/constants.json`
  の`GLOBAL_RULES.TARGET_PROFIT_RATE`」）

具体的な現在値は書かない。理由: ADR-018/ネオ4jの重複ノード修正で踏んだのと同じ
「更新漏れによる陳腐化」を、数値がJSON側で頻繁に変わる今回の変更で再発させないため。

変更対象:

- `docs/03-詳細設計/バランスパラメータ.md`: 数値列を削除し、計算式・意味・JSON参照先を残す
- `docs/03-詳細設計/カード/*.md`・`イベント/*.md`: コスト・確率の数値表記をJSON参照に置き換え
- グラフDBの`Parameter`ノード: 数値プロパティを削除し`jsonPath`プロパティに変える

## 移行方針

- 効果ロジック自体（既存6カード・5イベントの計算式）は変更しない
- `constants.ts`の`POC_STAGE`は`GLOBAL_RULES`に改名し、ステージ非依存の4項目のみ残す
  （`WORKING_DAYS`等ステージ固有の重複値は削除。`poc-01.ts`側が唯一の情報源になる）
- 既存の単体テストは変更不要（純粋関数へオブジェクトを直接渡す形は維持）

## テスト方針

- `src/game/`内の各関数（`applyEffect`・`roll`・`getSkillFactorRange`等）は引き続き
  同期・純粋関数のままなので、既存の単体テストは変更不要
- `buildCardRegistry`等の構築関数は、テスト用のダミーデータを渡すテストを追加する
- `PreloadScene`のJSON読み込み・zod検証・エラー時の起動失敗は、Playwright E2Eで検証する
  （正常系1件・不正JSON時に起動失敗する異常系1件）
