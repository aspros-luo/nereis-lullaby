# Nereis Lullaby Cooking System Progress

## Cooking-0.2 Resource Driven Architecture

Completed:

- Ingredient resources
- Recipe resources
- Resource loader foundation
- Database loader bridge

## Cooking-0.3 Kitchen Flow — **CLOSED for logic**

Completed:

- CookingFlowController（流程编排）
- KitchenController + `scenes/cooking/kitchen.tscn`
- CookingSession 状态机 + 多步骤推进
- Inventory 接入（仅在最后一步完成时消耗材料）
- CookingMenuUI（配方列表 / 步骤叙述 / 继续 / 结果反馈）
- 蜂蜜面包四步
- `tests/cooking_flow_test.gd`
- 出炉图位（可选资源，缺图不报错）

Deferred (not blocking 0.3):

- 完整村庄主界面恢复（当前为临时入口）
- 美术资源

## Cooking-0.4 — In progress

Completed this pass:

- 第二道食谱：**草药粥**（herb_porridge）
- `CookingGiftService`：把料理交给 NPC（消耗背包、关系软增加、文案反馈）
- `CookingWorldInfluence`：隐藏 resonance / memory / world tags（不向玩家显示数值）
- 烹饪完成时写入 `game_state.world_state.flags.cooking_hidden`
- `tests/cooking_0_4_test.gd`

Still open:

1. 主界面恢复后把赠食挂到 NPC 对话按钮
2. 更多食谱（苹果派、森林果酱）
3. 隐藏效果反哺观察文本 / NPC 日程（只通过已有 soft 通道）

## How to test

```sh
godot --headless --path . -s res://tests/cooking_flow_test.gd
godot --headless --path . -s res://tests/cooking_0_4_test.gd
```
