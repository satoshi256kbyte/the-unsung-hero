// Phaser / DOM non-dependent pure TypeScript type definitions.

// ===== Union / Enum-like types =====

export type CardName =
  | "デイリー"
  | "デイリー中止"
  | "レビュー"
  | "モニタリング"
  | "サマライズ"
  | "臨時MTG"
  | "臨時モニタリング"
  | "臨時サマライズ"
  | "教育"
  | "ペアプログラミング"
  | "雑談"
  | "停滞対応"
  | "個別面談"
  | "表彰"
  | "計画休"
  | "残業許可"
  | "アサイン"
  | "入れ替え"
  | "巻取り"
  | "進捗ブースト"
  | "強制締め"
  | "リスケ"
  | "メンバー追加"
  | "休出"
  | "納期交渉"
  | "スコープ交渉";

export type CardApplicationMode = "immediate" | "set-auto" | "set-manual";
export type TargetType = "pm" | "member" | "task" | "project";

export type EffectType =
  | "task_event_prob_reduced"
  | "rework_prob_reduced"
  | "overreport_prob_reduced"
  | "morale_decay_mitigated"
  | "overtime_cap_extended"
  | "education_stall"
  | "pair_prog_stall";

export type EventType = "ニュートラル" | "ネガティブ" | "ポジティブ";

export type EventCategory =
  | "進捗ダウン"
  | "進捗アップ"
  | "デバフ系"
  | "バフ系"
  | "メンバー稼働系"
  | "スコープ変化系";

export type TaskStatus = "active" | "stalled" | "done";

// ===== Member & Card entities =====

export interface Member {
  id: string;
  name: string;
  /** 技レベル 0–99 */
  skill: number;
  /** 経験値 0以上 */
  exp: number;
  /** 心 0–150 */
  morale: number;
  /** 体 0–100 */
  health: number;
}

export interface CardEffect {
  cardName: CardName;
  /** メンバーIDまたは 'project' */
  targetId: string;
  effectType: EffectType;
  /** null = 手動解除まで継続 */
  remainingTurns: number | null;
}

export interface ProgressUpdate {
  taskId: string;
  /** 進捗変化量（%単位、正負両方あり） */
  delta: number;
}

export interface MemberUpdate {
  memberId: string;
  moraleDelta: number;
  healthDelta: number;
  skillDelta?: number;
  expDelta?: number;
}

// ===== Gantt chart entities =====

export interface GanttTask {
  id: string;
  name: string;
  phase: string;
  /** 開始ターン（1-indexed） */
  startTurn: number;
  /** 計画期間（ターン数） */
  duration: number;
  assignedMemberId: string;
  /** 現在進捗 0.0–100.0 */
  progress: number;
  status: TaskStatus;
  dependencies: string[];
}

export interface GanttChart {
  tasks: GanttTask[];
  /** null = デフォルトバリアント */
  variantId: string | null;
}

// ===== Event entities =====

export interface GameEvent {
  id: string;
  type: EventType;
  category: EventCategory | null;
  targetId: string | null;
  params: Record<string, unknown>;
}

export interface ConditionalEvent {
  id: string;
  /** 条件評価ターン */
  turn: number;
  /** 条件式（評価は別モジュールが担当） */
  condition: string;
  eventType: EventType;
  params: Record<string, unknown>;
}

export interface TurnResult {
  events: GameEvent[];
  progressUpdates: ProgressUpdate[];
  memberUpdates: MemberUpdate[];
  costDelta: number;
  isGameOver: boolean;
  gameOverReason: string | null;
  activeEffectsAdded: CardEffect[];
  activeEffectsAfterTick: CardEffect[];
}

// ===== Game state & Stage data =====

export interface GameState {
  /** 現在ターン（1-indexed） */
  turn: number;
  members: Member[];
  gantt: GanttChart;
  totalCost: number;
  budget: number;
  /** 納期ターン */
  deadline: number;
  hand: CardName[];
  activeEffects: CardEffect[];
  /** 透明性 0–150 */
  transparency: number;
  /** 緊張感 0–150 */
  tension: number;
  isGameOver: boolean;
  gameOverReason: string | null;
}

export interface StageData {
  id: string;
  name: string;
  budget: number;
  deadline: number;
  initialMembers: Member[];
  initialGantt: GanttChart;
  ganttVariants: Record<string, GanttChart>;
  conditionalEvents: ConditionalEvent[];
  initialCards: CardName[];
}
