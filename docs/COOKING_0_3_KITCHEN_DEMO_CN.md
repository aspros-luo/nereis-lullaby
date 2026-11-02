# Cooking-0.3 厨房制作 Demo

## 目标

建立正式项目结构的厨房制作闭环。

## 原则

- 不使用 Node `_draw()` 临时绘制。
- 美术缺失时使用 placeholder resource / 空 Sprite2D。
- 业务逻辑与场景表现分离。

## 流程

Player
→ CookingStation.interact()
→ KitchenController.open()
→ CookingFlowController.request_cook(recipe_id)
→ CookingManager.cook()
→ Inventory 更新
→ CookingResult 信号回传

## Scene

`res://scenes/cooking/kitchen.tscn`

- Background (Sprite2D placeholder)
- CookingStation (Node2D)
- PlayerSpawn (Marker2D)

## 当前阶段（已完成基础层）

- [x] CookingFlowController
- [x] KitchenController
- [x] Kitchen 场景骨架
- [x] 资源加载与默认蜂蜜面包配方
- [x] Inventory 接入制作结果
- [x] Headless flow 测试脚本
- [ ] 正式 UI 面板（配方列表 / 反馈文本）
- [ ] 与主界面地点行动打通（在「我家附近」触发厨房）
- [ ] 多步骤操作表现（揉面 / 烘烤等过程演出）
