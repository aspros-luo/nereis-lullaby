# NPC 出现规则（按章节 · 按线索组）

> 实现：`scripts/systems/daily/npc_appear_rules.gd`  
> 查询：`list_available(ctx)` / `list_by_group(ctx)`  
> 与余波链、节庆焦点共用同一套章节划分。

---

## 章节

| 代号 | 条件 | 说明 |
|------|------|------|
| **pre** | 未 `festival_done`，非节庆焦点 | 节前日常 |
| **festival** | `event_focus` | 丰收节内；仅节庆互动 |
| **post** | `festival_done` | 节后余波与暗线 |

---

## 线索组

| 组 | 含义 | 前置强度 |
|----|------|----------|
| `daily_life` | 婆、铁匠等常驻 | 低：地点 + 轻段数 |
| `herb_trade` | 商人 / 草药交换 | 低 |
| `festival_seed` | 节庆预告闲话 | 中：segment ≥ 2 |
| `post_traces` | 空碗、留白、旧花、纸须 | 中：仅 post，各一次 |
| `visitor_rumor` | 生人闲话 | 中：仅 post · COMMONS |
| `hero_chain` | 脚印→见面→约见 | 高：线索链硬锁 |
| `clinic_quiet` | 诊疗处缺席 | 中：post · CLINIC |
| `shrine_list` | 旧花重读 / 目光 | 中：需已见旧花 |

---

## 规则总表

### 节前 pre

| id | NPC | 地点 | 段 | 组 | 行动提示 |
|----|-----|------|----|----|----------|
| pre_popo_talk | 老婆婆 | HOME | ≥0 | daily | 和老婆婆聊聊 |
| pre_smith_water | 铁匠 | HOME/PATH | ≥2 | daily | 帮铁匠提一桶水 |
| pre_merchant | 商人 | COMMONS | ≥0 | herb | 和外地商人聊两句 |
| pre_villager_fest_hint | 村民 | COMMONS | ≥2 | fest_seed | 和村民闲聊（once） |

### 节中 festival

| id | NPC | 地点 | 组 | 备注 |
|----|-----|------|----|------|
| fest_crowd | 节庆人群 | COMMONS | fest_seed | 仅焦点内；禁用闲逛 NPC |

### 节后 post

| id | 对象 | 地点 | 组 | 前置 | 行动提示 |
|----|------|------|----|------|----------|
| post_popo | 老婆婆 | HOME | daily | festival_done | 聊聊（台词随分支） |
| post_trace_* | 物件痕迹×4 | 各点 | traces | festival_done；各 once | 观察类 |
| post_visitor_rumor | 村民耳语 | COMMONS | visitor | festival_done · once | 听听节后闲话 |
| post_hero_tracks | 脚印 | PATH | hero | 知识 visitor_rumor | 辨认脚印 |
| post_hero_meet | 外来人 | GROVE | hero | 知识 hero_tracks | 走进空地 |
| post_hero_talk | 外来人 | GROVE | hero | hero_face / met | 上前说话 |
| post_hero_second | 外来人 | FOREST | hero | 已谈话 + 回声/深度 | 赴林缘之约 |
| post_clinic | 缺席 | CLINIC | clinic | festival_done · once | 推门 |
| post_shrine_reread | 目光 | SHRINE | shrine | trace_shrine_flowers | 再看旧花 |

---

## 穿插原则

1. **同段日常最多 1 条高优先级暗线**（priority ≥ 40）；日常组不限。  
2. **节庆焦点**只放行 `allow_event_focus`。  
3. **Hero 链**不与节庆重叠；约见要求谈话后休息（AF09_echo）。  
4. **痕迹组**是观察，不是对话 NPC；可与婆同段共存。  
5. 错过允许：once 规则不重刷，不锁死结局。

---

## 查询示例（GDScript）

```gdscript
var rules := NpcAppearRules.new()
var ctx := {
  "segment_index": economy.segment_index,
  "festival_done": world_flags.has_flag("festival_done"),
  "event_focus": mode_controller.is_event_focus(),
  "location": game_state.current_location,
  "flags": world_flags.flags,
  "knowledge": knowledge,
  "aftermath_seen": aftermath.seen,
}
var available: Array = rules.list_available(ctx)
var by_group: Dictionary = rules.list_by_group(ctx)
```

---

## 与现有系统

| 系统 | 关系 |
|------|------|
| `aftermath_storylets` | Hero/余波仍走 AF 链；本表描述**何时该出现行动** |
| `npc_intent_scheduler` | 轻量休息赠物/闲话，属 daily 组 |
| `main_shell` | 可逐步改为只渲染 `list_available` 的 action_hint |

下一步可选：让 `main_shell._rebuild_actions` 对暗线组改读本表，避免与 AF 双份条件。
