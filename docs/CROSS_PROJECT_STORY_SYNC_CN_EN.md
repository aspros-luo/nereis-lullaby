# 跨项目剧情同步台账 / Cross-Project Narrative Sync Ledger

> 状态 / Status: Active working contract  
> 主项目 / Repositories: `aspros-luo/Nereis-Hero` + `aspros-luo/nereis-lullaby`  
> 维护原则 / Rule: 同步世界观事实与角色认知边界，不合并玩法；最新明确用户决策优先于旧文档。

## 中文

### 1. 工作流程

每次继续开发 Lullaby，尤其在修改剧情、NPC 对话、线索、事件条件或世界状态之前：

1. 检查 Hero 的 `development` 分支最新提交。
2. 阅读 Hero 的 `docs/DEVELOPER_STORY_MEMORY.md`、`docs/DEVELOPMENT_WORKING_CHARTER_CN_EN.md`，并检查最近变更涉及的剧情/地图文档。
3. 将新信息分类为 **已确认 / 提案 / 待讨论 / 与当前记录冲突**。
4. 判断它是否影响 Lullaby 的客观世界事实、蜜忒认知边界、村民知识边界、时间线或玩家可见证据。
5. 只有兼容且有依据的事实才同步进 Lullaby；重要剧情分歧不自行裁定。
6. 若发现冲突，先记录冲突和来源，采用最近一次明确用户决策作为当前工作依据；必要时再向用户提出一个聚焦问题。
7. 修改同步台账或相关设计文档时，同时维护中英文版本。

这不是后台常驻的自动监控服务：我无法在没有正在进行的会话/工具调用时持续轮询 GitHub。但每次实际推进相关工作时，会主动检查 Hero 的最新状态，不依赖用户手动提醒。

### 2. 当前跨项目基线

- **玩法独立、世界观兼容。** Hero 是第三人称叙事视角的横版 Soulslike 动作 RPG；Lullaby 是蜜忒视角的日常生活模拟、自由探索与视觉小说。不得把对方的玩法系统直接搬入本仓库。
- **蜜忒的认知边界。** 蜜忒起初不知道自己与外神、仪式的真实关系；她的情感是真实的。玩家从线索中推理，不等于蜜忒已经理解真相。
- **Hero 的古神残留。** Hero 的教会实验留下古神物质/力量残留，是 Hero 后期剧情的一条因果线。Lullaby 不应因此让蜜忒提前理解古神、外神或她自身的客观身份。
- **村民知识要分层。** 某些村民可能本能地保护蜜忒，或感觉她很重要；这不自动代表他们知道仪式目的，更不代表他们知道她是外神代理。
- **线索簿属于玩家信息整理工具。** 不把线索自动写成蜜忒的超自然认知，也不把玩家的猜测升级为客观事实。
- **不强制跨游戏同一进度。** 两作的事件可共享背景事实，但不要求同一玩家先玩哪一作，也不把另一作的任务完成度作为本作必要条件。

### 3. 最新明确决策优先级

以下决策必须覆盖旧文档中可能仍然存在的过时描述：

- **结局走向暂不锁定。** “凡人之墓 / 永恒乐园 / 烈火天罚”可以作为当前讨论中的方向，但不能仅因旧 Hero 文档称其为 canonical 就视为永久定稿。
- **Hero 结局判定不得以与蜜忒发生身体结合为必要条件。** 用户已明确要求移除此类硬性条件；结局应由鸣响、道具、探索等状态决定。身体亲密可以是特定剧情的事件，但不是所有结局的通用门槛。
- **跨游戏衔接示例不是剧情定稿。** 任何 Hero 与 Lullaby 的先后顺序、相遇细节、因果连接或结局对应，除非用户明确批准，否则保持提案/待讨论。
- **Lullaby 的异变垂直切片是原型内容，不自动成为世界观正史。**

### 4. 当前已知需防止的文档冲突

Hero 的 `README.md` 与 `docs/DEVELOPER_STORY_MEMORY.md` 中仍有将三个结局写成“canonical”或较强确定语气的段落。这与用户较新的“结局暂不锁定”决策存在状态冲突。开发时以较新的明确用户决策为准，并将这类文档视为需要后续校准的旧记录，而不是擅自锁定结局。

### 5. 每次同步检查记录格式

在出现实质剧情变化时，追加简短记录：

- 日期：
- Hero 分支 / 最新提交：
- 变更文件：
- 新信息状态：已确认 / 提案 / 待讨论 / 冲突
- 对 Lullaby 的影响：
- 已同步的文件：
- 尚未解决的问题：

不必每次都向用户输出完整报告；只在发现实质变化、冲突或需要用户裁定时简短汇报。

## English

### 1. Workflow

Whenever continuing Lullaby development—especially before changing plot, NPC dialogue, clues, event conditions, or world state:

1. Check the latest commit on Hero's `development` branch.
2. Read Hero's `docs/DEVELOPER_STORY_MEMORY.md` and `docs/DEVELOPMENT_WORKING_CHARTER_CN_EN.md`, plus any narrative/map docs touched by recent changes.
3. Classify new information as **Confirmed / Proposed / Open / Conflicting**.
4. Assess its impact on Lullaby's objective world facts, Mite's knowledge boundary, villagers' knowledge, chronology, and player-facing evidence.
5. Synchronize only supported, compatible facts. Do not decide major narrative conflicts unilaterally.
6. Record conflicts and their sources. The latest explicit user decision takes precedence over older documents; ask a focused question only when a consequential conflict cannot otherwise be resolved.
7. Keep Chinese and English versions aligned whenever this ledger or related design docs change.

This is not a permanently running background monitor. I cannot poll GitHub continuously while no session/tool call is active. However, I will actively check Hero's latest state whenever I resume relevant development, rather than relying on the user to remind me.

### 2. Current cross-project baseline

- **Independent gameplay, compatible worldbuilding.** Hero is a side-scrolling Soulslike action RPG; Lullaby is a Mite-viewpoint daily-life simulation, free-exploration game, and visual novel. Do not copy the other game's gameplay systems into this repository.
- **Mite's knowledge boundary.** Initially, Mite does not know her true relationship to the Outer God or the ritual. Her feelings are genuine. Player deduction does not mean Mite understands the truth.
- **Hero's ancient-god residue.** The Church's experiments leave ancient-god material/power residue in Hero, forming one causal thread in Hero's later story. This must not make Lullaby's Mite prematurely understand the ancient gods, Outer God, or her objective identity.
- **Layer villagers' knowledge carefully.** A villager may instinctively protect Mite or sense that she matters without knowing the ritual's purpose or knowing that she is the Outer God's proxy.
- **The clue journal organizes player information.** It must not automatically become Mite's supernatural awareness or turn player hypotheses into objective facts.
- **No mandatory cross-game order.** The games may share background facts, but neither should require the player to finish the other game first.

### 3. Priority of latest explicit decisions

These decisions override stale descriptions that may remain in older docs:

- **Ending directions are not locked yet.** “A Grave for Mortals / Eternal Paradise / Blazing Divine Punishment” may remain working directions, but must not be treated as permanently canonical merely because an older Hero document says so.
- **Hero ending checks must not require physical union with Mite.** The user explicitly requested removal of this hard condition. Endings should be determined by states such as Resonance, items, and exploration. Intimacy may be a specific story event, but is not a universal ending gate.
- **Cross-game connections are examples, not finalized plot.** Chronology, encounter details, causal links, and ending mappings remain Proposed/Open unless explicitly approved by the user.
- **Lullaby's anomaly vertical slice is prototype content, not automatically world canon.**

### 4. Known documentation conflict to guard against

Hero's `README.md` and parts of `docs/DEVELOPER_STORY_MEMORY.md` still describe the three endings as “canonical” or use similarly definitive wording. This conflicts with the user's newer decision to keep ending directions open. Follow the newer explicit user decision during development; treat the older wording as documentation requiring later reconciliation, not as authority to lock the endings.

### 5. Lightweight sync record

For each substantive narrative change, record:

- Date:
- Hero branch / latest commit:
- Changed files:
- Status: Confirmed / Proposed / Open / Conflicting
- Impact on Lullaby:
- Files synchronized:
- Unresolved questions:

Do not send a full report every time. Briefly notify the user only when a material change, conflict, or decision requiring their judgment is found.
