# Nereis Lullaby / 蜜忒之歌

> A narrative adventure project centered on Mite: daily-life simulation, free exploration, and visual-novel storytelling. The separate Nereis-Hero action RPG is not developed here.

## Start here / 从这里开始

1. [Formal Project Baseline (CN)](docs/PROJECT_BASELINE_CN.md) / [EN](docs/PROJECT_BASELINE_EN.md)
2. [Session Start Here (CN)](docs/SESSION_START_HERE_CN.md) / [EN](docs/SESSION_START_HERE_EN.md)
3. [Worldview (CN)](docs/WORLDVIEW_CN.md) / [EN](docs/WORLDVIEW_EN.md)
4. [Narrative & Design Contracts (CN)](docs/DESIGN_CONTRACTS_CN.md) / [EN](docs/DESIGN_CONTRACTS_EN.md)
5. [Core Gameplay (CN)](docs/CORE_GAMEPLAY_CN.md) / [EN](docs/CORE_GAMEPLAY_EN.md)
6. [Roadmap (CN)](docs/ROADMAP_CN.md) / [EN](docs/ROADMAP_EN.md)
7. [Village Character and Secret Matrix (CN)](docs/VILLAGE_CHARACTER_SECRET_MATRIX_CN.md) / [EN](docs/VILLAGE_CHARACTER_SECRET_MATRIX_EN.md)
8. [Week One Schedule and Event Chain (CN)](docs/WEEK_ONE_SCHEDULE_EVENT_CHAIN_CN.md) / [EN](docs/WEEK_ONE_SCHEDULE_EVENT_CHAIN_EN.md)

## Confirmed identity

- Three action periods per day: morning, daytime, and evening.
- Region map with location-based exploration.
- Key NPC schedules and states, driven by both autonomous simulation and authored events.
- Primarily Mite's viewpoint, with narrative contrast between her sincere everyday understanding and the player's deductions.
- Relationship, clue/investigation, and world-state variables remain separate but can jointly influence endings.

## Prototype status / 原型状态

A minimal Godot 4 project shell is included. Open this repository in Godot 4.6.x and run the project file named project.godot to try the current text-based prototype.

Current prototype interactions:
- Move between five placeholder locations.
- Advance through morning, daytime, and evening across a seven-day schedule.
- See which of the three prototype NPCs is present at the current location and time.
- Talk to NPCs and observe selected locations to collect evidence in the player clue notebook.
- Review clue entries with day, time, location, and a factual description.

A core logic smoke-test script is included. With Godot installed, run: godot --headless --path . -s res://tests/prototype_smoke_test.gd. This test has been added but has not yet been executed in this environment.

This is an early system prototype, not a finished vertical slice. It uses text-only UI and placeholder location labels; it does not yet include final art, save/load, a complete dialogue system, a real map, or a finalized world anomaly. The Day 7 anomaly remains a proposal and is not forced by the current prototype.

当前已加入最小 Godot 4 项目骨架。请使用 Godot 4.6.x 打开仓库并运行项目文件 project.godot，体验文字界面的系统原型。

当前可交互内容：
- 在五个占位地点之间移动。
- 按七天日程推进早晨、白天和傍晚。
- 查看当前地点与时段在场的三名原型 NPC。
- 与 NPC 交谈、观察指定地点，并把证据记入玩家线索簿。
- 按日期、时段、地点回顾已记录内容。

已加入核心逻辑 smoke test 脚本。安装 Godot 后可运行：godot --headless --path . -s res://tests/prototype_smoke_test.gd。该测试脚本已写入仓库，但当前环境尚未实际执行。

这仍是早期系统原型，不是完成的垂直切片。当前使用纯文字 UI 和占位地点名称；尚无最终美术、存档/读档、完整对话系统、正式地图或定稿的世界异变。第七日异变仍为提案，当前原型不会强制触发。

## Narrative contract

Mite is an innocent village girl who does not know her connection to the Outer God or the ritual. There is no protagonist-facing insight meter. The player investigates through evidence, recurring details, character behavior, and changing context; the clue journal does not mean Mite understands the hidden truth.

## Project reset and canon discipline

This repository starts from a clean design baseline. Old story examples are not automatically canon. Unresolved world details, endings, and cross-game fates remain proposals until explicitly approved.

## Documentation and workflow

Chinese and English design documents are maintained together. When a rule changes, update both versions. Do not intentionally trigger GitHub Actions.

The source has been added through GitHub repository operations. Engine execution and hands-on playtesting have not yet been performed in this environment; do not treat the current code as runtime-verified.
