# Implementation Plan: ランダムイベントエンジン（停滞・手戻り本体）

**Branch**: `008-random-event-engine` | **Date**: 2026-08-13 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/008-random-event-engine/spec.md`

## Summary

`src/game/event.ts` を新規作成し、5種のランダムイベント判定（rollRandomEvents）・
progressMap 反映（applyEventToProgress）・メンバーパラメータ反映（applyEventToMember）の
3純粋関数を実装する。turn.ts の Step 5（簡易 rework 判定）を rollRandomEvents に置き換え、
エンドツーエンドのイベントパイプラインを完成させる。

## Technical Context

**Language/Version**: TypeScript 5（strict mode）

**Primary Dependencies**: Vitest + fast-check（テスト）、既存 `src/game/` モジュール群

**Storage**: N/A（純粋関数・ステートレス）

**Testing**: Vitest + fast-check（ユニット + プロパティテスト）

**Target Platform**: Node.js（game logic layer のみ）

**Project Type**: ゲームロジックライブラリ（src/game/ の純粋関数モジュール）

**Performance Goals**: 1ターン処理 < 1ms（純粋関数のため問題なし）

**Constraints**: Phaser/DOM 非依存、全関数イミュータブル

**Scale/Scope**: 5イベント種別、3エクスポート関数

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| Architecture Boundary（src/game/ は Phaser/DOM 非依存） | PASS | event.ts は純粋 TS |
| Test Coverage ≥ 80%（lines/functions） | 計画中 | event.test.ts で担保 |
| tsc --noEmit 0 エラー | 計画中 | 型チェック確認タスク含む |
| Phaser 非依存 grep チェック | 計画中 | Polish フェーズで確認 |

## Project Structure

### Documentation (this feature)

```text
specs/008-random-event-engine/
├── plan.md              # This file
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks output
```

### Source Code (repository root)

```text
src/game/
├── event.ts             # NEW: rollRandomEvents / applyEventToProgress / applyEventToMember
├── turn.ts              # UPDATE: Step 5 を rollRandomEvents に置き換え
└── types.ts             # 変更なし（GameEvent 型は既存）

tests/unit/
├── event.test.ts        # NEW: 単体テスト + fast-check
└── turn.test.ts         # UPDATE: イベント統合テスト追加
```

## Key Design Decisions

### KD-1: event.ts を turn.ts から分離

effect.ts（Spec-07）と同様に、イベント判定ロジックを独立モジュールとして分離する。
理由: 単独テスト容易性・Phaser 非依存の機械的検証・将来的なイベント種別追加の変更最小化。

### KD-2: stall イベントの progressMap 反映

stall イベントが発生したタスクの progressMap エントリを 0 にリセットする
（そのターンの進捗増加を無効化）。
負のデルタを加算する方式ではなく「上書きゼロ」を採用。
理由: stall = 「そのターン何も進まない」という意味論に忠実。

### KD-3: rework デルタの計算タイミング

`rollRandomEvents` 内で `applyRework` を呼び出して reworkDelta を計算し、
`GameEvent.params.reworkDelta` に格納する。
`applyEventToProgress` はこの値を progressMap に加算する。
理由: delta 計算責務をイベント生成側に集約し、反映側をシンプルに保つ。

### KD-4: メンバーイベントのデルタ積算方式

`applyEventToMember` は After – Before のデルタではなく新しい Member を返す。
turn.ts 側で `newMember.morale - member.morale` を計算して MemberUpdate を生成し、
decayMemberUpdates に統合する。
理由: applyEventToMember が「差分」ではなく「状態」を返すほうが再利用性が高い。
クランプ後の実際の変化量が自動的に正確になる。

### KD-5: processTurn の処理順序

```
Step 1: applyCards → effectsToAdd + cardMemberUpdates
Step 2: currentEffects = [...state.activeEffects, ...effectsToAdd]
Step 3: progress dice per member
Step 4: applyTurnDecay + applyWeekendRecovery → decayMemberUpdates
Step 5: rollRandomEvents(state, currentEffects) → randomEvents
        applyEventToProgress で progressMap 更新
        applyEventToMember でイベント由来 MemberUpdate 生成 → eventMemberUpdates
Step 6: applyEffectTick(currentEffects) → activeEffectsAfterTick
Step 7: memberUpdates = [...cardMemberUpdates, ...decayMemberUpdates, ...eventMemberUpdates]
```

Step 5 では turn.ts 既存の簡易 rework 判定を **完全に削除**して rollRandomEvents に統合する。

## Complexity Tracking

Constitution Check に違反なし。Complexity Tracking は不要。
