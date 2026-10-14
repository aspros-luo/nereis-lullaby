# Cooking-0.3 Kitchen Flow

## Goal

建立正式厨房制作流程，不使用代码绘图占位。

## Flow

Player
 -> Kitchen Scene
 -> CookingStation
 -> CookingMenuController
 -> CookingSession
 -> CookingResult

## Node Design

Kitchen

- Background (Sprite2D placeholder)
- CookingStation (Node2D)
- PlayerSpawn (Marker2D)

## Rules

- Placeholder assets are resources.
- No business logic inside visual nodes.
- Future replacement of art should not change cooking code.
