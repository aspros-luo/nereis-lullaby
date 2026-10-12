# Nereis Lullaby / 蜜忒之歌

> A narrative adventure centered on Mite: daily-life simulation, free exploration, and visual-novel storytelling. The separate Nereis-Hero action RPG is not developed here.

## Start here / 从这里开始

1. [Formal Project Baseline (CN)](docs/PROJECT_BASELINE_CN.md) / [EN](docs/PROJECT_BASELINE_EN.md)
2. [Session Start Here (CN)](docs/SESSION_START_HERE_CN.md) / [EN](docs/SESSION_START_HERE_EN.md)
3. [Worldview (CN)](docs/WORLDVIEW_CN.md) / [EN](docs/WORLDVIEW_EN.md)
4. [Narrative & Design Contracts (CN)](docs/DESIGN_CONTRACTS_CN.md) / [EN](docs/DESIGN_CONTRACTS_EN.md)
5. [Core Gameplay (CN)](docs/CORE_GAMEPLAY_CN.md) / [EN](docs/CORE_GAMEPLAY_EN.md)
6. [Roadmap (CN)](docs/ROADMAP_CN.md) / [EN](docs/ROADMAP_EN.md)
7. [Prologue Vertical Slice Plan (CN)](docs/PROLOGUE_VERTICAL_SLICE_PLAN_CN.md) / [EN](docs/PROLOGUE_VERTICAL_SLICE_PLAN_EN.md)
7. [Village Character and Secret Matrix (CN)](docs/VILLAGE_CHARACTER_SECRET_MATRIX_CN.md) / [EN](docs/VILLAGE_CHARACTER_SECRET_MATRIX_EN.md)
8. [Week One Schedule and Event Chain (CN)](docs/WEEK_ONE_SCHEDULE_EVENT_CHAIN_CN.md) / [EN](docs/WEEK_ONE_SCHEDULE_EVENT_CHAIN_EN.md)
9. [Playable Prototype Guide (CN)](docs/PLAYTEST_GUIDE_CN.md) / [EN](docs/PLAYTEST_GUIDE_EN.md)
10. [Cross-Project Narrative Sync Ledger (CN/EN)](docs/CROSS_PROJECT_STORY_SYNC_CN_EN.md)

## Confirmed identity

- Three action periods per day: morning, daytime, and evening.
- Region-map navigation with location-based exploration.
- Key NPC schedules and relationship values.
- Primarily Mite's viewpoint: the player may infer more than Mite understands.
- Relationship, clues, and world state are tracked separately.

## Playable vertical-slice prototype

Open this repository in Godot 4.6.x and run `project.godot`.

The current prototype code includes:
- Seven destinations: Mite's home area, village commons, public shrine, clinic, village path, forest path, and forest clearing.
- A seven-day schedule with morning, daytime, and evening.
- One meaningful action per time period, with free travel and observation.
- Three scheduled NPCs, relationship feedback, and conversation-based evidence.
- A clue journal that records observations without automatically explaining their meaning.
- Alternate discovery windows for several early clues, so missing the exact original day does not block them.
- A staged village anomaly at the end of the seventh day, followed by altered location descriptions, changed NPC responses, and post-event clues.
- Contextual objectives and day-opening story beats to make the seven-day loop easier to follow.
- Local single-slot save/load for time, relationships, world state, action history, and the clue journal.
- An optional short prologue ending after the player revisits three locations after the anomaly.

The anomaly and its specific details are **prototype scenario content**, not finalized world canon. The current build is intentionally text-first; production art, audio, and a fuller dialogue presentation remain future work. Save/load is implemented as a single local slot.

### Run the core regression checks

With Godot available:

```sh
godot --headless --path . -s res://tests/prototype_smoke_test.gd
```

The smoke-test script covers time progression, the anomaly phase, action limits, NPC schedule coverage, location-content coverage, clue de-duplication, relationship bounds, and save restoration. The script has been updated in the repository but **has not been executed in the current tool environment**. Static inspection is not a substitute for an engine run or a human playtest.

## 可试玩垂直切片原型

使用 Godot 4.6.x 打开仓库，运行 `project.godot`。

当前原型代码包含：
- 七个可前往地点：我家附近、村庄公共空间、公开礼拜场所、诊疗处、村庄通路、林间小径和林中空地。
- 七天、每天早晨／白天／傍晚的日程。
- 每个时段一项主要行动；移动和观察不消耗该行动。
- 三名有固定日程的关键 NPC、关系反馈与交谈线索。
- 只记录玩家见闻、不自动解释真相的线索簿。
- 部分早期线索提供较宽的触发时间，错过最初日期仍有机会发现。
- 第七日傍晚的阶段异变；异变后地点描述、NPC 回应和可发现线索都会变化。
- 根据日期显示行动提示与日初叙事片段。
- 加入单槽本机存档／读档，恢复时间、关系、世界状态、行动记录与线索簿。
- 异变后回访三个地点即可主动结束序章。

异变及其具体细节目前属于**原型剧情**，不代表世界观已经正式定稿。当前仍以文字界面为主；正式美术、音频和更完整的对话表现仍待开发。存档／读档已提供单槽本机实现。

### 运行核心回归检查

安装 Godot 后运行：

```sh
godot --headless --path . -s res://tests/prototype_smoke_test.gd
```

测试脚本覆盖时间推进、异变阶段、行动次数限制、NPC 日程、七个地点的观察内容覆盖、线索去重、关系值边界与存档恢复。脚本已经更新写入仓库，但**当前工具环境尚未执行测试**。静态检查不能代替引擎运行或人工游玩。

## Narrative contract / 叙事约束

Mite is innocent and does not know her connection to the Outer God or the ritual. The player may notice contradictions earlier than she does. The clue journal is a player-facing evidence organizer, not Mite's supernatural insight system.

蜜忒仍然纯真且不知道自己与外神、仪式的关系。玩家可以比她更早察觉矛盾；线索簿服务于玩家推理，不是蜜忒的超自然认知系统。

## Project and workflow discipline / 项目纪律

Chinese and English design documents are maintained together. Design proposals must not silently become canon. Do not intentionally trigger GitHub Actions. Report static review, automated tests, engine execution, and human playtesting as separate verification levels.
