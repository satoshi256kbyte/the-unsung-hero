# Phase 0 Research: バランスデータのJSON外部化

Technical ContextにNEEDS CLARIFICATIONはない。ここでは主要な技術判断を記録する。

## 1. JSONロード後、`src/game/`へのデータの受け渡し方法

**Decision**: Phaserの`Registry`（`this.registry`、Scene間で共有されるグローバル
データストア）を使う。`PreloadScene`が起動時に全JSONをロード・検証した後、
`src/game/config.ts`の`initGameConfig(data)`を呼んでモジュール内の設定を確定させる。
以降`src/game/`内の各関数は`getConfig()`経由で値を参照する。

**Rationale**: 現状`constants.ts`は`export const X = {...} as const`という
モジュールレベルの静的な値であり、11ファイル（`balance.ts` `dice.ts` `gantt.ts`
`member.ts` `turn.ts` `engine.ts` `events/index.ts` `events/stall.ts`
`cards/commendation.ts` `cards/one-on-one.ts` `cards/planned-leave.ts`）が
これを直接importしている。JSON化後は値が起動時にしか手に入らないため、
「モジュール読み込み時に確定する定数」から「起動時に一度だけ設定される
シングルトン」に変える必要がある。関数シグネチャ（引数）を変えずに済むため、
呼び出し側の変更を最小限にできる。

**Alternatives considered**: 各関数の引数として明示的にテーブルを渡す完全な
依存性注入（却下、11ファイル・数十箇所の呼び出しシグネチャを変更する必要があり
本Specの規模に対して過大）。

## 2. `constants.ts`の扱い

**Decision**: `constants.ts`は削除し、型定義は`src/game/schemas/balanceConstants.ts`
のzodスキーマから`z.infer<>`で導出する。`config.ts`が`getConfig(): BalanceConstants`
を提供する。

**Rationale**: 値の実体がJSONに移った後、`constants.ts`に型だけを残すと
スキーマ（zod）と型定義（TS interface）を二重に手で同期させる必要が生じる。
zodスキーマから型を導出すれば単一の情報源になる。

## 3. `POC_STAGE`→`GLOBAL_RULES`

**Decision**: `constants.ts`の`POC_STAGE`のうち、`poc-01.ts`のStageDataと
重複・不整合していた値（`WORKING_DAYS`・`MEMBER_COUNT`等）は削除し、
ステージ非依存の4項目（`BUFFER_RATIO`・`TARGET_PROFIT_RATE`・
`DAILY_COST_CAP`・`OVERTIME_COST_CAP`）のみを`GLOBAL_RULES`として
`balance/constants.json`に残す。

**Rationale**: `MEMBER_COUNT: 2`が実際のPoCステージ（3人）と食い違っていた
既存の不整合を、JSON移行のこのタイミングで解消する。

## 4. カード・イベントJSONの形状

**Decision**: カードJSON = `{ "cost": number }`。イベントJSON =
`{ "baseProb": number }`に、カード使用時の派生確率がある場合は
`{ "baseProb": number, "withDailyReviewProb": number }`のように追加キーを持たせる
（キー名は`EVENT_PROB`の`_WITH_`系サフィックスをcamelCaseにしたもの）。

**Rationale**: Spec-13の`EventDefinition.roll()`実装がファイル内部で
`calcEventProbModifier`を呼ぶ形になっているため、その入力値をそのまま
JSON化する。

## 5. E2Eテストでの異常系検証方法

**Decision**: Playwright E2Eで、正常系（全JSON正常→ゲームが起動する）1件と、
異常系（`public/data/cards/`のいずれかのJSONを一時的に不正な内容に差し替えて
起動を試みる→エラーになる）1件を検証する。異常系のテストは、テスト実行時に
一時ディレクトリへ不正JSONを配置したビルド成果物を生成するか、開発サーバーの
該当ファイルを一時的に書き換えてテスト後に復元する方式のいずれかを
`/speckit-tasks`で具体化する。

**Rationale**: zodによる検証が実際に機能することを、単体テストだけでなく
実際の起動シーケンスで確認する必要があるため。
