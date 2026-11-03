# Cooking-0.4

## 目标

在不展示数值的前提下，让料理影响关系与隐藏世界标记。

## 赠食

```
CookingGiftService.gift_food(inventory, npc_id, food_id, game_state)
```

- 成功：消耗 1 份食物，返回对白文案，可选 `increase_relationship`
- 失败：材料不足等
- UI 只显示 `GiftResult.message`

## 隐藏影响

烹饪成功后：

- `flags.cooking_hidden.resonance_total`
- `flags.cooking_hidden.world_effects_seen`
- `flags.cooking_hidden.memory_effects_seen`
- `flags.cooking_hidden.gifts_given`

玩家界面不得打印这些字段。

## 食谱

| id | 名称 | 材料 |
|----|------|------|
| honey_bread | 蜂蜜面包 | flour, honey, egg |
| herb_porridge | 草药粥 | flour, herb |
