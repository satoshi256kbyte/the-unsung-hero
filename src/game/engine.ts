import { MEMBER_PARAMS } from "./constants.js";
import { setTaskStatus, updateTaskProgress } from "./gantt.js";
import { processTurn as processTurnCore } from "./turn.js";
import type {
  CardName,
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
  };
}

function applyMemberUpdates(members: Member[], result: TurnResult): Member[] {
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

  constructor(stageData: StageData) {
    this.conditionalEvents = stageData.conditionalEvents;
    this.state = buildInitialState(stageData);
  }

  processTurn(cards: CardName[]): TurnResult {
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
      return isStalled ? setTaskStatus(updated, "stalled") : updated;
    });

    const updatedMembers = applyMemberUpdates(this.state.members, result);

    this.state = {
      ...this.state,
      gantt: { ...this.state.gantt, tasks: updatedTasks },
      members: updatedMembers,
      totalCost: this.state.totalCost + result.costDelta,
      turn: this.state.turn + 1,
      isGameOver: result.isGameOver,
      gameOverReason: result.gameOverReason,
      activeEffects: result.activeEffectsAfterTick,
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
