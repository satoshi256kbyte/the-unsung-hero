# Data Model: メンバーパラメータ変動エンジン

## エンティティ

### Member（既存: src/game/types.ts）

```typescript
interface Member {
  id: string;
  name: string;
  skill: number;   // 0–99
  exp: number;     // 0以上
  morale: number;  // 0–150 (心)
  health: number;  // 0–100 (体)
}
```

バリデーション規則（クランプで保証）:

| フィールド | 下限 | 上限 | 定数参照 |
|-----------|------|------|---------|
| skill | 0 | 99 | MEMBER_PARAMS.SKILL.{MIN,MAX} |
| exp | 0 | 制限なし | MEMBER_PARAMS.EXP.MIN |
| morale | 0 | 150 | MEMBER_PARAMS.MORALE.{MIN,MAX} |
| health | 0 | 100 | MEMBER_PARAMS.HEALTH.{MIN,MAX} |

## 定数テーブル（constants.ts 参照）

### PARAM_DELTA（心・体の変動量）

| 定数名 | 値 | 用途 |
|-------|----|------|
| MORALE_NATURAL_MIN | -3 | 心の自然変動・下限 |
| MORALE_NATURAL_MAX | +1 | 心の自然変動・上限 |
| HEALTH_NATURAL_MIN | -3 | 体の自然低下・下限 |
| HEALTH_NATURAL_MAX | -1 | 体の自然低下・上限 |
| WEEKEND_MORALE_RECOVERY | +8 | 週末回復・心 |
| WEEKEND_HEALTH_RECOVERY | +12 | 週末回復・体 |

### EXP（経験値・レベル係数）

| 定数名 | 値 | 用途 |
|-------|----|------|
| BASE_EXP | 10 | タスク完了時基本経験値 |
| LEVEL_FACTOR_MIN | 0.3 | level_factor の下限 |
| LEVEL_FACTOR_COEFF | 0.04 | level_factor 計算係数 |

経験値計算式: `expGain = BASE_EXP × max(LEVEL_FACTOR_MIN, 1.0 − skill × LEVEL_FACTOR_COEFF)`

### LEVEL_UP_EXP（レベルアップ必要経験値テーブル）

| 技レベル下限 | 必要経験値 |
|------------|---------|
| 0 | 30 |
| 5 | 50 |
| 10 | 80 |
| 15 | 120 |
| 25 | 200 |
| 50 | 400 |

ルックアップ: 現在の `skill` 以下で最大の「技レベル下限」行を採用する。
例: skill=8 → [0,30] と [5,50] が候補 → [5,50] を採用 → 必要経験値=50

## 関数シグネチャ（src/game/member.ts）

```typescript
// 毎ターンの心・体自然変動（整数乱数 + クランプ）
function applyTurnDecay(member: Member): Member

// 週末回復（固定加算 + クランプ）
function applyWeekendRecovery(member: Member): Member

// 経験値付与・レベルアップ判定
function applyExperience(member: Member, expGain: number): Member
```

全関数の不変条件:

- 引数の `member` を変更しない（イミュータブル操作）
- 戻り値の全フィールドが `Member` の範囲内に収まる
- Phaser / DOM API を import しない

## 状態遷移

```
applyTurnDecay:
  morale' = clamp(morale + randInt(−3, +1), 0, 150)
  health' = clamp(health + randInt(−3, −1), 0, 100)

applyWeekendRecovery:
  morale' = clamp(morale + 8, 0, 150)
  health' = clamp(health + 12, 0, 100)

applyExperience(expGain):
  required = LEVEL_UP_EXP lookup(skill)
  newExp = exp + expGain
  if newExp >= required && skill < 99:
    skill' = skill + 1
    exp'   = newExp - required
  else:
    skill' = skill
    exp'   = newExp
```
