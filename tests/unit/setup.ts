import { initCardRegistry } from "../../src/game/cards/index.js";
import { initGameConfig } from "../../src/game/config.js";
import { initEventRegistry } from "../../src/game/events/index.js";
import { testBalanceConstants, testCardCostData, testEventProbData } from "./testConfig.js";

initGameConfig({ balance: testBalanceConstants });
initCardRegistry(testCardCostData);
initEventRegistry(testEventProbData);
