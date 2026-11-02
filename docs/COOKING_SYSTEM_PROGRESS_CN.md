# Nereis Lullaby Cooking System Progress

## Cooking-0.2 Resource Driven Architecture

Completed:

- Ingredient resources
- Recipe resources
- Resource loader foundation
- Database loader bridge

Pipeline:

Resource (.tres)
→ CookingResourceLoader
→ CookingDatabaseLoader / CookingDatabase
→ CookingManager

## Cooking-0.3 Kitchen Flow (current)

Completed:

- CookingFlowController（流程编排）
- KitchenController + `scenes/cooking/kitchen.tscn`
- CookingSession 状态机完善
- Inventory 接入（消耗材料、获得料理）
- `.tres` 资源修正（script 引用、ingredients 字典、result_item_id）
- `tests/cooking_flow_test.gd` headless 烟测

Still open:

- 厨房 UI（配方选择与结果反馈）
- 主游戏地点行动接入
- 多步骤制作过程演出
- NPC 赠送与隐藏世界影响

## Next

Cooking-0.4 候选：

1. 文本/简 UI 配方菜单
2. 在「我家附近」行动中打开厨房
3. 蜂蜜面包多步骤过程（准备 → 揉面 → 烘烤 → 完成）
