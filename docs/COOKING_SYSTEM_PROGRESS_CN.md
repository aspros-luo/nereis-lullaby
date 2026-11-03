# Nereis Lullaby Cooking System Progress

## Cooking-0.2 Resource Driven Architecture

Completed:

- Ingredient resources
- Recipe resources
- Resource loader foundation
- Database loader bridge

## Cooking-0.3 Kitchen Flow

Completed:

- CookingFlowController（流程编排）
- KitchenController + `scenes/cooking/kitchen.tscn`
- CookingSession 状态机 + **多步骤推进**
- Inventory 接入（仅在最后一步完成时消耗材料）
- CookingMenuUI（配方列表 / 步骤叙述 / 继续 / 结果反馈）
- 蜂蜜面包四步：准备 → 揉面 → 烘烤 → 完成
- `tests/cooking_flow_test.gd` 覆盖多步骤路径

Still open:

- 确认主界面 HOME「去做点吃的」已合并（若尚未合并，见 `docs/patches/main_kitchen_home.patch`）
- NPC 赠送与隐藏世界影响
- 更多食谱（苹果派、森林果酱、奶油蛋糕）

## Next (Cooking-0.4 候选)

1. 主界面接入验收与手测
2. NPC 赠送接口（把料理交给村民）
3. 隐藏世界影响挂钩（不向玩家显示数值）
