# Cooking-0.3 厨房制作 Demo

## 目标

建立正式项目结构的厨房制作闭环。

## 原则

- 不使用 Node `_draw()` 临时绘制。
- 美术缺失时使用 placeholder resource。
- 业务逻辑与场景表现分离。

## 流程

Player
→ CookingStation
→ CookingSession
→ CookingManager
→ Result Item

## Scene 规划

Kitchen
- Background (Sprite2D placeholder)
- CookingStation (Node2D)
- PlayerSpawn (Marker2D)

## 当前阶段

完成制作流程基础层，后续接入 UI 和正式场景。
