# Nereis Lullaby Cooking System Progress

## Cooking-0.2 Resource Driven Architecture

Completed:

- Ingredient resources
- Recipe resources
- Resource loader foundation
- Database loader bridge

## Cooking-0.3 Kitchen Flow (current)

Completed:

- CookingFlowController（流程编排）
- KitchenController + `scenes/cooking/kitchen.tscn`
- CookingSession 状态机完善
- Inventory 接入（消耗材料、获得料理）
- `.tres` 资源修正
- `tests/cooking_flow_test.gd` headless 烟测
- **CookingMenuUI** 文本配方菜单与结果反馈

In progress / blocked:

- 主游戏 `main.gd` HOME 接入：补丁已写在 `docs/patches/main_kitchen_home.patch`
  - 注意：一次错误提交曾截断 `scripts/ui/main.gd`，需先恢复到 `631045fb` 再打补丁
- 多步骤制作过程演出
- NPC 赠送与隐藏世界影响

## Next

1. 恢复并打上 HOME 接入补丁
2. 蜂蜜面包多步骤过程（准备 → 揉面 → 烘烤 → 完成）
3. 本机 Godot 运行 `cooking_flow_test.gd` 与主界面手测
