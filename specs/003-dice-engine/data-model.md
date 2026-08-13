# Data Model: 進捗ダイスエンジン

## 関数インターフェース

### rollProgress

```typescript
rollProgress(member: Member): number
```

- **引数**: `Member`（`src/game/types.ts` で定義済み）
- **戻り値**: 進捗上昇量（正の浮動小数点数）
- **副作用**: なし（イミュータブル・純粋関数）

### 内部計算フロー

```
1. [min, max] = getSkillFactorRange(member.skill)   // balance.ts
2. skill_factor = min + (max - min) * Math.random()

3. [hMin, hMax] = getHealthFactor(member.health)    // balance.ts
4. health_factor = hMin + (hMax - hMin) * Math.random()

5. base = PROGRESS_DICE.BASE_MIN
         + (PROGRESS_DICE.BASE_MAX - PROGRESS_DICE.BASE_MIN) * Math.random()

6. return base × skill_factor × health_factor
```

## 依存データ

| 定数/関数 | 場所 | 用途 |
|-----------|------|------|
| `PROGRESS_DICE` | `src/game/constants.ts` | base の範囲 [3.0, 7.0] |
| `getSkillFactorRange` | `src/game/balance.ts` | 技レベルに応じた [min, max] を返す |
| `getHealthFactor` | `src/game/balance.ts` | 体の値に応じた [min, max] を返す |
| `Member` | `src/game/types.ts` | skill（0〜99）・health（0〜100）を持つ型 |

## 戻り値の理論範囲

| 条件 | 最小値 | 最大値 |
|------|--------|--------|
| 技0・体0（最悪） | 3.0 × 0.6 × 0.5 = **0.9** | 7.0 × 1.2 × 1.0 = **8.4** |
| 技99・体100（最良） | 3.0 × 0.95 × 1.0 = **2.85** | 7.0 × 1.05 × 1.0 = **7.35** |
| 技10・体100（初期値想定） | 3.0 × 0.85 × 1.0 = **2.55** | 7.0 × 1.10 × 1.0 = **7.70** |

戻り値は常に正（最小値 = 0.9）。0〜100へのクランプは呼び出し側（ターン処理エンジン）が担う。
