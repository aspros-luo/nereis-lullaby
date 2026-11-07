# NPC 行为逻辑（细化版）

> 实现：`scripts/systems/daily/npc_behavior_logic.gd`  
> 依赖：`npc_behavior_profiles.gd`（三张核心卡）+ 扩展卡（铁匠/商人/Hero/村民）  
> 原则：**作者剧情 > 出现规则 > 日程在场 > 日常动作/对白变体**

---

## 决策栈

```
1. authored_active（余波 AF / 节庆焦点）
      → 行为层返回 blocked，不抢戏
2. NpcAppearRules（章节 + 线索组）
      → 决定「能不能出现行动」
3. 日程 / 地点在场（NpcScheduleManager，可选）
      → 决定「人是否在这个点」
4. NpcBehaviorLogic
      → presence_note / routine 氛围句 / talk_line 对白
```

---

## 输入上下文 `ctx`

| 键 | 含义 |
|----|------|
| `festival_done` | 节后 |
| `event_focus` | 节庆焦点 |
| `location` | 当前地点 |
| `flags` | world flags |
| `segment_index` | 日常段，用于轮换 routine |
| `authored_active` | 主链占用时为 true |
| `smith_helped` | 本段已帮铁匠 |

---

## 章节 × 压力

| 章节 | 来源 |
|------|------|
| pre | 未节后、非焦点 |
| post | festival_done |
| festival | event_focus（行为层少说话） |

压力 `stress_level`（0～4）：节后 / 软倾向 T / 见过 Hero / 旧花+纸须。  
`stress >= 3` 时 routine 改用 **stress** 句桶。

---

## 对白变体（talk_line）

老婆婆 post：拒绝 / 上菜 / 帮忙 / 默认四支。  
铁匠、商人：pre 工作交换，post 不追问站队。  
Hero 对白仍由 `aftermath_storylets` 作者链驱动。

---

## API

```gdscript
var logic := NpcBehaviorLogic.new()
var packet := logic.decide("popo", {
  "festival_done": true,
  "location": "HOME",
  "flags": world_flags.flags,
  "segment_index": economy.segment_index,
  "authored_active": false,
})
```

---

## 分工

| 模块 | 管什么 |
|------|--------|
| `npc_appear_rules` | 何时何地何线索可出现 |
| `npc_behavior_logic` | 出现后怎么动、怎么说 |
| `aftermath_storylets` | 写死的余波与 Hero 链 |

可选接线：`main_shell` 聊婆/铁匠/商人时调 `talk_line`；进地点显示 `presence_note`。
