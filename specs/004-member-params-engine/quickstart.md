# Quickstart Validation Guide: メンバーパラメータ変動エンジン

## 前提条件

- Node.js 20+
- `npm install` 済み
- `src/game/types.ts` および `src/game/constants.ts` が Spec-01 の実装済み状態であること

## 実装後の検証手順

### 1. 型チェック

```bash
npx tsc --noEmit
```

期待結果: エラー 0 件

### 2. ユニットテスト実行

```bash
npx vitest run tests/unit/member.test.ts
```

期待結果: 全テスト PASS

### 3. DOM/Phaser 依存がないことを確認

```bash
grep -r "phaser\|document\|window" src/game/member.ts
```

期待結果: マッチ 0 件

### 4. Lint チェック

```bash
npx biome check src/game/member.ts tests/unit/member.test.ts
```

期待結果: エラー 0 件

## 検証シナリオ

### シナリオ A: applyTurnDecay 基本動作

```typescript
import { applyTurnDecay } from "../src/game/member.js";

const member = { id: "m1", name: "Alice", skill: 10, exp: 0, morale: 100, health: 100 };
const result = applyTurnDecay(member);

// 心は 97〜101 の範囲（クランプ前）→ 0〜150 に収まる
// 体は 97〜99 の範囲（クランプ前）→ 0〜100 に収まる
console.assert(result.morale >= 0 && result.morale <= 150);
console.assert(result.health >= 0 && result.health <= 100);
// 引数が変化していないこと
console.assert(member.morale === 100 && member.health === 100);
```

### シナリオ B: applyTurnDecay 下限クランプ

```typescript
const minMember = { id: "m2", name: "Bob", skill: 5, exp: 0, morale: 0, health: 0 };
const result = applyTurnDecay(minMember);
// 心・体ともに 0 以下にならない
console.assert(result.morale === 0);
console.assert(result.health === 0);
```

### シナリオ C: applyWeekendRecovery 上限クランプ

```typescript
import { applyWeekendRecovery } from "../src/game/member.js";

const nearMax = { id: "m3", name: "Carol", skill: 15, exp: 0, morale: 145, health: 95 };
const result = applyWeekendRecovery(nearMax);
// 心は 150 にクランプ（145+8=153→150）
console.assert(result.morale === 150);
// 体は 100 にクランプ（95+12=107→100）
console.assert(result.health === 100);
```

### シナリオ D: applyExperience レベルアップ

```typescript
import { applyExperience } from "../src/game/member.js";

// 技8・経験値40・閾値50（skill=8→LEVEL_UP_EXP[5]=50）
const member = { id: "m4", name: "Dave", skill: 8, exp: 40, morale: 100, health: 100 };
const result = applyExperience(member, 15);
// 40+15=55 >= 50 → レベルアップ: 技9・経験値5
console.assert(result.skill === 9);
console.assert(result.exp === 5);
```

### シナリオ E: applyExperience 技上限

```typescript
const maxSkill = { id: "m5", name: "Eve", skill: 99, exp: 0, morale: 100, health: 100 };
const result = applyExperience(maxSkill, 9999);
// 技 99 を超えない
console.assert(result.skill === 99);
```

## fast-check プロパティテストのポイント

以下の不変条件を任意入力でテストすること。

| 不変条件 | 確認方法 |
|---------|---------|
| applyTurnDecay 後の morale が 0〜150 | fc.integer({min:0,max:150}) × fc.integer({min:0,max:100}) |
| applyTurnDecay 後の health が 0〜100 | 同上 |
| applyWeekendRecovery 後のパラメータが範囲内 | 同上 |
| applyExperience 後の skill が 0〜99 | fc.integer({min:0,max:99}) × fc.integer({min:0,max:500}) |
| イミュータブル操作（引数変化なし） | 全関数で member のフィールド比較 |
