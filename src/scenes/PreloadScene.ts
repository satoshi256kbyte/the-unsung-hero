import Phaser from "phaser";
import { CARD_JSON_FILES, initCardRegistry } from "../game/cards/index.js";
import { initGameConfig } from "../game/config.js";
import { EVENT_JSON_FILES, initEventRegistry } from "../game/events/index.js";
import { balanceConstantsSchema } from "../game/schemas/balanceConstants.js";
import { cardDataSchema } from "../game/schemas/cardData.js";
import { eventDataSchema } from "../game/schemas/eventData.js";
import { stageDataSchema } from "../game/schemas/stageData.js";
import { initStageRegistry } from "../game/stages/index.js";
import type { CardName, StageData } from "../game/types.js";

const CARD_KEY_PREFIX = "card:";
const EVENT_KEY_PREFIX = "event:";
const STAGE_KEY_PREFIX = "stage:";
const BALANCE_KEY = "balance:constants";

export class PreloadScene extends Phaser.Scene {
  constructor() {
    super({ key: "PreloadScene" });
  }

  preload(): void {
    for (const [cardName, fileName] of Object.entries(CARD_JSON_FILES)) {
      this.load.json(`${CARD_KEY_PREFIX}${cardName}`, `data/cards/${fileName}.json`);
    }
    for (const [eventKey, fileName] of Object.entries(EVENT_JSON_FILES)) {
      this.load.json(`${EVENT_KEY_PREFIX}${eventKey}`, `data/events/${fileName}.json`);
    }
    this.load.json(`${STAGE_KEY_PREFIX}poc-01`, "data/stages/poc-01.json");
    this.load.json(BALANCE_KEY, "data/balance/constants.json");
  }

  create(): void {
    const balanceRaw = this.cache.json.get(BALANCE_KEY);
    const balance = balanceConstantsSchema.parse(balanceRaw);
    initGameConfig({ balance });

    const costData = {} as Record<CardName, { cost: number }>;
    for (const cardName of Object.keys(CARD_JSON_FILES) as CardName[]) {
      const raw = this.cache.json.get(`${CARD_KEY_PREFIX}${cardName}`);
      costData[cardName] = cardDataSchema.parse(raw);
    }
    initCardRegistry(costData);

    const probData: Record<string, ReturnType<typeof eventDataSchema.parse>> = {};
    for (const eventKey of Object.keys(EVENT_JSON_FILES)) {
      const raw = this.cache.json.get(`${EVENT_KEY_PREFIX}${eventKey}`);
      probData[eventKey] = eventDataSchema.parse(raw);
    }
    initEventRegistry(probData);

    const stageRaw = this.cache.json.get(`${STAGE_KEY_PREFIX}poc-01`);
    const stageData = stageDataSchema.parse(stageRaw) as unknown as StageData;
    initStageRegistry({ "poc-01": stageData });

    this.scene.start("TitleScene");
  }
}
