# 日常环技术框架（采集 / 线索 / 交换 / 主动与被动）

> 状态：**实现前框架 v1（2026-11-04）**  
> 依附：`GAMEPLAY_CONSTITUTION_CN.md`、`STORY_CONSTITUTION_CN.md`  
> 目标：先定数据与流程，再写代码；服务高自由度日常 + 上限推进 + 事件焦点。

---

## 1. 玩家期望的日常手感（需求原文整理）

### 主动行为
- 村外：**采集特殊香料**（需先有线索/知悉，不可无脑全图刷）  
- 村内：**收获食物材料**  
- 与村民 **交换**  
- 与村民 **聊天**；聊天后可 **赠送**（食物或成品）  

### 材料来源
- 线索来自：  
  - 村民对话  
  - **外地商人**  
  - **Hero 侧其他 NPC 到访** 时的对话  
- 获得线索后，才解锁或提示对应采集点/交换  

### 被动行为
- NPC **主动找蜜忒对话**  
- NPC **主动赠送食材**  

约束：日常有上限；进入丰收节等锚点时，上述自由操作收束或关闭。

---

## 2. 子系统划分

```
GameModeController          daily | event_focus
  ├─ DailyActionEconomy     当日有重量行动次数 / 休息推进
  ├─ LocationPresence       蜜忒当前地点；谁在场
  ├─ Inventory              材料与成品（已有可演进）
  ├─ IngredientKnowledge    线索与「已知可采集/可交换」
  ├─ GatherSystem           村内收获 / 村外采集（检查知识+地点+模式）
  ├─ TradeSystem            与在场者交换
  ├─ DialogueRouter         主动交谈 / 被动发起
  ├─ GiftService            蜜忒赠出（已有 CookingGiftService 可泛化）
  ├─ NpcIntentScheduler     NPC 主动对话、主动赠材
  └─ WorldFlags             丰收节后等暗线旗帜（节后改人/物/事）
```

原则：

- **知识（线索）与背包分离**：没听说过的香料点，即使人站在附近也不给采集，或只给「还不知道能采什么」的弱提示。  
- **主动/被动对话共用台词与后果管道**，只是发起方不同。  
- **事件焦点**下 Gather/Trade/闲逛入口由 Mode 统一关掉，不在每个按钮上散落 if。

---

## 3. 核心数据

### 3.1 物品 `ItemDef`

| 字段 | 说明 |
|------|------|
| id | 如 `herb`, `spice_moonleaf`, `honey_bread` |
| kind | `ingredient` / `spice` / `food` / `key_item` |
| display_name | 显示名 |
| tags | `perishable`, `festival`, `gift_ok` 等 |

### 3.2 采集点 `GatherSpot`

| 字段 | 说明 |
|------|------|
| id | |
| location_id | 村内田/园或村外某点 |
| item_id | 产出 |
| amount_range | |
| requires_knowledge_id | **无此线索则不可采或不可发现** |
| daily_limit | 与行动经济的关系 |
| available_when | 旗帜/季节/丰收节后 等 |

### 3.3 知识/线索 `KnowledgeDef`

| 字段 | 说明 |
|------|------|
| id | 如 `know_moonleaf_edge` |
| source_types | `villager` / `merchant` / `hero_visitor` |
| unlocks | gather_spot_ids / trade_offer_ids |
| player_note | 线索簿用短句（玩家层，≠蜜忒开悟） |

### 3.4 交换 `TradeOffer`

| 字段 | 说明 |
|------|------|
| npc_id | 在场可谈 |
| give | 玩家交出 |
| receive | 玩家获得 |
| requires_knowledge_id | 可选 |
| requires_flags | 可选 |

### 3.5 NPC 主动意图 `NpcIntent`

| 字段 | 说明 |
|------|------|
| id | |
| npc_id | |
| kind | `talk` / `gift_ingredient` |
| weight | 日常调度权重 |
| conditions | 地点、旗帜、是否已送过、日常段 |
| payload | 对话 id / 物品与数量 |
| love_skin | 设计备注：情/欲/利外皮（不进玩家 UI） |

### 3.6 到访者 `VisitorDef`（商人 / Hero NPC）

| 字段 | 说明 |
|------|------|
| id | |
| origin | `merchant` / `hero_cast` |
| appear_when | 日常段、旗帜、随机权重 |
| location_id | 多在公共空间/路口 |
| knowledge_ids | 可聊出的线索 |
| trade_ids | 可交换 |

**Hero NPC 到访**：只带来**兼容的世界观信息与材料线索**，不把 Hero 战斗玩法搬进 Lullaby；不强迫玩家先通关 Hero。

---

## 4. 主流程（日常模式）

```
玩家行动
  → Mode == daily?
  → 消耗行动经济（若该动作有重量）
  → 分支：
      采集：有 GatherSpot + Knowledge + 在地点 → Inventory +
      收获：同上，村内点
      交谈：DialogueRouter（玩家发起）
          → 可能写入 Knowledge
          → 可能打开 Gift / Trade
      交换：TradeOffer 检查
      赠送：GiftService（成品或约定可赠物）
  → NpcIntentScheduler 可能在行动后或进入地点时
      插入被动对话 / 塞给食材
  → 经济耗尽 → 提示休息 → 推进日常段 → 检查锚点条件（丰收节）
```

### 事件焦点模式

- `GatherSystem` / 自由 `Trade` / 非事件 `NpcIntent`：**禁用或大幅降权**  
- 仅事件图提供的选项（可含一次「用食物参与节日」等语义化动作）

---

## 5. 与现有代码的衔接

| 已有 | 用法 |
|------|------|
| `Inventory` | 扩展 item 种类；材料与食物共用 |
| `Cooking*` | 消耗材料出食物；节日可特供菜 |
| `CookingGiftService` | 泛化为 `GiftService` 或保留并挂食品 |
| `game_state.world_state.flags` | 知识解锁、节后暗线、到访者 |
| `npc_schedule` / presence | 谁可聊、谁可塞话 |
| 线索簿 | 记录 Knowledge 的 player_note，不升格为蜜忒超自然认知 |

旧「每时段一次主行动」：由 **DailyActionEconomy** 替换，不再绑早中晚标签。

---

## 6. 丰收节衔接（暗线预留）

节前日常：通过采集/交换囤材料、与人建立外皮互动。  
节中：焦点模式；可选消耗特定食物/香料。  
节后旗帜示例（实现时再填表）：

- `festival_done`  
- `festival_helped` / `festival_offered_food`  
- 改写：某 GatherSpot 产量或可用性、某 NpcIntent 权重、某观察文案  

---

## 7. 实现顺序（技术）

1. **Mode + DailyActionEconomy**（上限与休息推进）  
2. **IngredientKnowledge + 线索写入对话**  
3. **GatherSpot**（村内收获 / 村外香料，知识门闩）  
4. **TradeOffer**  
5. **NpcIntentScheduler**（主动对话、主动赠材）  
6. **VisitorDef**（商人；Hero 到访可第二波）  
7. **丰收节 event_focus + 节后旗帜改写**  

---

## 8. 验收标准（框架级）

- 无线索不能稳定刷到「特殊香料」。  
- 村民/商人/到访者对话能打开至少一条采集或交换。  
- NPC 能在条件满足时主动对话或给材料一次。  
- 日常有上限，休息后世界/锚点条件前进。  
- 丰收节中自由采集/闲聊入口关闭或收束。  
- 不出现「献祭进度」类玩家可见数值。

---

## 9. 刻意不做

- 开放世界无脑采集。  
- 把 Hero 战斗/地图搬进 Lullaby。  
- 用复杂生活模拟替代锚点故事。  
- 在事件焦点里保持完整日常刷材料。
