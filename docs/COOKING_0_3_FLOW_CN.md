# Cooking-0.3 Kitchen Flow

## Goal

建立正式厨房制作流程，不使用代码绘图占位。

## Flow

Player
→ Kitchen Scene (`scenes/cooking/kitchen.tscn`)
→ CookingStation
→ KitchenController / CookingFlowController
→ CookingMenuController
→ CookingSession
→ CookingManager
→ CookingResult
→ Inventory

## Node Design

Kitchen (Node2D + KitchenController)

- Background (Sprite2D placeholder texture)
- CookingStation (Node2D + CookingStation script)
- PlayerSpawn (Marker2D)

## Rules

- Placeholder assets are resources / editor-assigned textures.
- No business logic inside pure visual nodes.
- Future replacement of art should not change cooking code.
- Inventory is injected; CookingManager does not own global inventory.

## Runtime entry

```gdscript
var kitchen = preload("res://scenes/cooking/kitchen.tscn").instantiate()
add_child(kitchen)
kitchen.bootstrap_with(player_inventory) # optional shared inventory
kitchen.open()
kitchen.request_recipe("honey_bread")
```

## Verification

```sh
godot --headless --path . -s res://tests/cooking_flow_test.gd
```
