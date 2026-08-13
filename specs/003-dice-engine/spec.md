# Feature Specification: 進捗ダイスエンジン

**Feature Branch**: `003-dice-engine`

**Created**: 2026-08-13

**Status**: Draft

## User Scenarios & Testing

### User Story 1 - メンバーの1ターン進捗量を計算できる (Priority: P1)

ゲームエンジンが各ターンに「このメンバーがこのタスクをどれだけ進めたか」を
進捗ダイスで計算できる。技と体のパラメータに基づいて確率的な進捗量が返される。

**Why this priority**: 進捗計算はターン処理エンジン（Spec-05）の核心。
これがなければ1ターンも進行できない。

**Independent Test**: メンバーオブジェクト（技・体の値を持つ）を渡したとき、
正の数値が返されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 技10・体100のメンバー、**When** rollProgress を呼び出す、
   **Then** 正の進捗量が返される
2. **Given** 技0・体100のメンバー、**When** rollProgress を呼び出す、
   **Then** base(3.0〜7.0) × skill_factor(0.6〜1.2) × 1.0 の範囲内の値が返される
3. **Given** 技25・体100のメンバー、**When** rollProgress を呼び出す、
   **Then** base(3.0〜7.0) × skill_factor(0.95〜1.05) × 1.0 の範囲内の値が返される

---

### User Story 2 - 体が低いメンバーは進捗が下振れする (Priority: P2)

体パラメータが低いメンバーは health_factor により進捗上昇量が下振れしやすくなる。
体が70以上のメンバーへの補正はない。

**Why this priority**: 体管理カード（計画休など）の意義づけ。
体の影響が正確でないとゲームバランスが崩れる。

**Independent Test**: 同じ技レベルで体の値を変えた複数回の呼び出しで、
体が低いほど health_factor の上限が1.0に制限されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 技10・体100のメンバー、**When** rollProgress を呼び出す、
   **Then** health_factor は 1.0（補正なし）
2. **Given** 技10・体50のメンバー、**When** rollProgress を呼び出す、
   **Then** health_factor は乱数(0.85, 1.0) の範囲内
3. **Given** 技10・体20のメンバー、**When** rollProgress を呼び出す、
   **Then** health_factor は乱数(0.50, 1.0) の範囲内

---

### Edge Cases

- 技が99（最大値）のとき、skill_factor は乱数(0.95, 1.05) が適用される
- 体が0のとき、health_factor は乱数(0.50, 1.0) が適用され、0にはならない
- 体がちょうど境界値（70, 50, 30）のときに正しいテーブルが選択される
- 結果は常に正の数（base の最小値 3.0 × skill_factor 最小 0.6 × health_factor 最小 0.5 = 0.9 > 0）

## Requirements

### Functional Requirements

- **FR-001**: システムは、Member の技レベル（0〜99）に応じた skill_factor の乱数範囲を
  SKILL_FACTOR_TABLE から選択しなければならない
- **FR-002**: システムは、Member の体の値（0〜100）に応じた health_factor の乱数範囲を
  HEALTH_FACTOR_TABLE から選択しなければならない
- **FR-003**: システムは、base = 一様乱数(3.0, 7.0) × skill_factor × health_factor を
  計算して進捗上昇量として返さなければならない
- **FR-004**: システムは、rollProgress の戻り値として常に正の数値を返さなければならない
- **FR-005**: システムは、Phaser および DOM API に一切依存してはならない
- **FR-006**: システムは、引数の Member オブジェクトを変更してはならない（イミュータブル操作）

### Key Entities

- **Member**: 技（0〜99）と体（0〜100）を持つゲームキャラクター
- **SKILL_FACTOR_TABLE**: 技レベル帯ごとの乱数範囲 [min, max] の定義
- **HEALTH_FACTOR_TABLE**: 体の値の閾値ごとの乱数範囲 [min, max] の定義

## Success Criteria

### Measurable Outcomes

- **SC-001**: 全実装関数の型チェックがエラーゼロで通る
- **SC-002**: 技の全境界値（0/4/5/9/10/14/15/24/25/99）でテストが全件 PASS する
- **SC-003**: 体の全境界値（0/29/30/49/50/69/70/100）でテストが全件 PASS する
- **SC-004**: fast-check プロパティテストで任意の技(0〜99)・体(0〜100) を入力しても
  パニックせず正の数値が返されることを確認できる
- **SC-005**: `grep -r "phaser\|document\|window" src/game/dice.ts` が 0 件

## Assumptions

- Member 型は Spec-01 の `src/game/types.ts` で定義済みであることを前提とする
- SKILL_FACTOR_TABLE と HEALTH_FACTOR_TABLE は Spec-01 の `src/game/constants.ts`
  に定義済みであることを前提とする
- 進捗量の結果は 0〜100 にクランプしない（呼び出し側のターン処理エンジンが行う）
- 乱数生成は組み込みの `Math.random()` を使用する（シードによる再現性はこの Spec の対象外）
