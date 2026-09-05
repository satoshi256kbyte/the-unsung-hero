import { getConfig } from "./config.js";
import { drawCards } from "./deck.js";
import { setTaskStatus, updateTaskProgress } from "./gantt.js";
import { processTurn as processTurnCore } from "./turn.js";
import type {
  CardName,
  CardPoolEntry,
  ConditionalEvent,
  GameState,
  Member,
  StageData,
  TurnResult,
} from "./types.js";

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function buildInitialState(stageData: StageData): GameState {
  const { MEMBER_PARAMS } = getConfig().balance;
  // 初期配布分を drawCounts に集計する（配布回数上限の判定に含める）
  const drawCounts: Record<string, number> = {};
  for (const name of stageData.initialCards) {
    drawCounts[name] = (drawCounts[name] ?? 0) + 1;
  }
  return {
    turn: 1,
    members: [...stageData.initialMembers],
    gantt: { ...stageData.initialGantt },
    totalCost: 0,
    budget: stageData.budget,
    deadline: stageData.deadline,
    hand: [...stageData.initialCards],
    activeEffects: [],
    transparency: MEMBER_PARAMS.TRANSPARENCY.INITIAL,
    tension: MEMBER_PARAMS.TENSION.INITIAL,
    isGameOver: false,
    gameOverReason: null,
    drawCounts,
  };
}

function applyMemberUpdates(members: Member[], result: TurnResult): Member[] {
  const { MEMBER_PARAMS } = getConfig().balance;
  return members.map((member) => {
    const updates = result.memberUpdates.filter((u) => u.memberId === member.id);
    const moraleDelta = updates.reduce((acc, u) => acc + u.moraleDelta, 0);
    const healthDelta = updates.reduce((acc, u) => acc + u.healthDelta, 0);
    const skillDelta = updates.reduce((acc, u) => acc + (u.skillDelta ?? 0), 0);
    const expDelta = updates.reduce((acc, u) => acc + (u.expDelta ?? 0), 0);
    return {
      ...member,
      morale: clamp(
        member.morale + moraleDelta,
        MEMBER_PARAMS.MORALE.MIN,
        MEMBER_PARAMS.MORALE.MAX,
      ),
      health: clamp(
        member.health + healthDelta,
        MEMBER_PARAMS.HEALTH.MIN,
        MEMBER_PARAMS.HEALTH.MAX,
      ),
      skill: clamp(member.skill + skillDelta, MEMBER_PARAMS.SKILL.MIN, MEMBER_PARAMS.SKILL.MAX),
      exp: Math.max(member.exp + expDelta, MEMBER_PARAMS.EXP.MIN),
    };
  });
}

export class GameEngine {
  private state: GameState;
  private readonly conditionalEvents: ConditionalEvent[];
  private readonly cardPool: CardPoolEntry[];
  private readonly handLimit: number;
  private readonly rng: () => number;

  constructor(stageData: StageData, rng: () => number = Math.random) {
    this.conditionalEvents = stageData.conditionalEvents;
    this.cardPool = stageData.cardPool;
    this.handLimit = stageData.handLimit;
    this.rng = rng;
    this.state = buildInitialState(stageData);
  }

  processTurn(cards: { name: CardName; targetId?: string }[]): TurnResult {
    if (this.state.isGameOver) {
      throw new Error("Game is already over");
    }

    const result = processTurnCore(this.state, cards, this.conditionalEvents);

    const updatedTasks = this.state.gantt.tasks.map((task) => {
      const pu = result.progressUpdates.find((p) => p.taskId === task.id);
      const updated = pu ? updateTaskProgress(task, pu.delta) : task;
      const isStalled = result.events.some(
        (e) => e.id.startsWith("stall") && e.targetId === task.id,
      );
      const withStatus = isStalled ? setTaskStatus(updated, "stalled") : updated;

      // 実績（着手・完了ターン）の記録
      const gainedProgress = withStatus.progress > task.progress;
      const actualStartTurn =
        withStatus.actualStartTurn === null && gainedProgress
          ? this.state.turn
          : withStatus.actualStartTurn;
      const actualEndTurn =
        withStatus.actualEndTurn === null && withStatus.progress >= 100
          ? this.state.turn
          : withStatus.actualEndTurn;

      return { ...withStatus, actualStartTurn, actualEndTurn };
    });

    const updatedMembers = applyMemberUpdates(this.state.members, result);

    // 次ターン開始時点の手札を配布プールから handLimit まで補充する。
    // ゲーム終了時は補充しない（補充が終了判定を妨げないこと。Edge Case）。
    let nextHand = this.state.hand;
    let nextDrawCounts = this.state.drawCounts;
    if (!result.isGameOver) {
      const drawn = drawCards(
        this.cardPool,
        this.state.drawCounts,
        this.state.hand,
        this.handLimit,
        this.rng,
      );
      nextHand = drawn.hand;
      nextDrawCounts = drawn.drawCounts;
    }

    this.state = {
      ...this.state,
      gantt: { ...this.state.gantt, tasks: updatedTasks },
      members: updatedMembers,
      totalCost: this.state.totalCost + result.costDelta,
      turn: this.state.turn + 1,
      isGameOver: result.isGameOver,
      gameOverReason: result.gameOverReason,
      activeEffects: result.activeEffectsAfterTick,
      hand: nextHand,
      drawCounts: nextDrawCounts,
    };

    return result;
  }

  getState(): GameState {
    return { ...this.state };
  }

  isGameOver(): boolean {
    return this.state.isGameOver;
  }
}
