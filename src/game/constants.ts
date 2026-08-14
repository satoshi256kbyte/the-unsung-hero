// ===== 1. PoCステージ基本情報 =====

export const POC_STAGE = {
  /** 稼働日数（ターン数） */
  WORKING_DAYS: 22,
  MEMBER_COUNT: 2,
  /** 週次進捗会議回数 */
  WEEKLY_MEETING_COUNT: 4,
  /** 締め回数 */
  MILESTONE_COUNT: 3,
  /** 固定イベント合計（キックオフ1+週次4+締め3+クロージング1） */
  FIXED_EVENT_TOTAL: 9,
  /** 予算に対するバッファ比率 */
  BUFFER_RATIO: 0.25,
  /** 目標利益率 */
  TARGET_PROFIT_RATE: 0.05,
  /** 1日の上限コスト */
  DAILY_COST_CAP: 8,
  /** 残業許可使用時の上限コスト */
  OVERTIME_COST_CAP: 10,
} as const;

// ===== 2. メンバーパラメータ範囲と初期値 =====

export const MEMBER_PARAMS = {
  SKILL: { MIN: 0, MAX: 99, INITIAL_A: 10, INITIAL_B: 8 },
  EXP: { MIN: 0 },
  MORALE: { MIN: 0, MAX: 150, INITIAL: 100 },
  HEALTH: { MIN: 0, MAX: 100, INITIAL: 100 },
  TRANSPARENCY: { MIN: 0, MAX: 150, INITIAL: 100 },
  TENSION: { MIN: 0, MAX: 150, INITIAL: 100 },
} as const;

// ===== 3. 進捗ダイス基本範囲 =====

export const PROGRESS_DICE = {
  BASE_MIN: 3.0,
  BASE_MAX: 7.0,
} as const;

// ===== 4. 経験値・レベルアップ =====

export const EXP = {
  BASE_EXP: 10,
  LEVEL_FACTOR_MIN: 0.3,
  /** level_factor = max(LEVEL_FACTOR_MIN, 1.0 − skill × LEVEL_FACTOR_COEFF) */
  LEVEL_FACTOR_COEFF: 0.04,
  /** 教育カード付与経験値（される側） */
  EDUCATION_GRANT: 30,
  /** ペアプログラミングカード付与経験値（される側） */
  PAIR_PROG_GRANT: 15,
} as const;

/**
 * レベルアップ必要経験値テーブル。
 * 各エントリ: [技レベル下限, 必要経験値]。下から上へ順に評価する。
 */
export const LEVEL_UP_EXP: ReadonlyArray<readonly [number, number]> = [
  [0, 30],
  [5, 50],
  [10, 80],
  [15, 120],
  [25, 200],
  [50, 400],
];

// ===== 5. 心・体・透明性・緊張感の変動 =====

export const PARAM_DELTA = {
  /** 心の毎ターン自然変動：乱数(MORALE_NATURAL_MIN, MORALE_NATURAL_MAX) */
  MORALE_NATURAL_MIN: -3,
  MORALE_NATURAL_MAX: 1,
  /** 体の毎ターン自然低下：乱数(HEALTH_NATURAL_MIN, HEALTH_NATURAL_MAX) */
  HEALTH_NATURAL_MIN: -3,
  HEALTH_NATURAL_MAX: -1,
  /** 緊張感の毎ターン自然低下（納期が遠い間） */
  TENSION_NATURAL_DELTA: -1,
  /** 週末回復量 */
  WEEKEND_MORALE_RECOVERY: 8,
  WEEKEND_HEALTH_RECOVERY: 12,
  /** 雑談カードの心低下補正（毎ターン +2 / 3ターン持続） */
  CHAT_MORALE_MITIGATION: 2,
  CHAT_DURATION: 3,
  /** 個別面談 */
  ONE_ON_ONE_MORALE: 15,
  /** 表彰 */
  COMMENDATION_MORALE: 30,
  /** 計画休 */
  PLANNED_LEAVE_MORALE: 20,
  PLANNED_LEAVE_HEALTH: 25,
  /** イベントによる変動量 */
  EVENT_SICK_MORALE: -8,
  EVENT_SICK_HEALTH: -10,
  EVENT_REWORK_MORALE: -10,
  EVENT_STALL_MORALE: -12,
  EVENT_STALL_DEADLINE_MORALE: -20,
  EVENT_INSPIRATION_MORALE: 5,
  EVENT_REST_MORALE: 12,
  EVENT_REST_HEALTH: 10,
  EVENT_LOCAL_WIN_MORALE: 15,
} as const;

// ===== 6. ネガティブイベント発生閾値 =====

export const THRESHOLDS = {
  /** 心の閾値 */
  MORALE_LOW_START: 60,
  MORALE_LOW_DOUBLE: 30,
  MORALE_HIGH_START: 130,
  /** 体の閾値 */
  HEALTH_LOW_START: 50,
  HEALTH_LOW_DOUBLE: 30,
  /** 透明性の閾値 */
  TRANSPARENCY_LOW_START: 60,
  TRANSPARENCY_HIGH_START: 130,
  /** 緊張感の閾値 */
  TENSION_LOW_START: 60,
  TENSION_HIGH_START: 130,
  /** 締め失敗しきい値（完了率） */
  MILESTONE_FAIL_RATE: 0.9,
  /** 進捗ブースト判断ライン */
  PROGRESS_BOOST_LINE: 0.9,
} as const;

// ===== 8. 手戻りの巻き戻し量 =====

export const REWORK = {
  /** 巻き戻し率 = BASE − skill × COEFF */
  ROLLBACK_BASE: 0.4,
  ROLLBACK_COEFF: 0.01,
} as const;

// ===== 9. 停滞の持続ターン数分布 =====

export const STALL = {
  /** 1ターン停滞の確率（残りは2ターン） */
  ONE_TURN_PROB: 0.6,
  TWO_TURN_PROB: 0.4,
  /** トレーニング停滞ターン数 */
  EDUCATION_STALL_TEACHER: 1,
  EDUCATION_STALL_LEARNER: 2,
  PAIR_PROG_STALL: 1,
  ONBOARDING_STALL: 3,
} as const;

// ===== 10. 固定イベント（チェックポイント）確率 =====

export const CHECKPOINT_PROB = {
  KICKOFF: 0.6,
  WEEKLY_MEETING: 0.5,
  /** 週次会議での2件目追加確率 */
  WEEKLY_MEETING_SECOND: 0.3,
  MILESTONE_PASS: 0.45,
  CLOSING: 0.5,
} as const;

// ===== 12. skill_factor テーブル =====

/**
 * skill_factor テーブル。各エントリ: [技レベル下限, [min, max]]。
 * getSkillFactorRange() がこのテーブルを参照する。
 */
export const SKILL_FACTOR_TABLE: ReadonlyArray<readonly [number, readonly [number, number]]> = [
  [0, [0.6, 1.2]],
  [5, [0.75, 1.15]],
  [10, [0.85, 1.1]],
  [15, [0.9, 1.08]],
  [25, [0.95, 1.05]],
];

// ===== 13. health_factor テーブル =====

/**
 * health_factor テーブル。各エントリ: [体の値下限, [min, max]]。
 * getHealthFactor() がこのテーブルを参照する。
 */
export const HEALTH_FACTOR_TABLE: ReadonlyArray<readonly [number, readonly [number, number]]> = [
  [0, [0.5, 1.0]],
  [30, [0.7, 1.0]],
  [50, [0.85, 1.0]],
  [70, [1.0, 1.0]],
];
