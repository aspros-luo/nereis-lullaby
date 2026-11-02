# 厨房接入主界面补丁说明

## 事故说明

Cooking-0.3 厨房 UI 已成功提交。在接入主界面 `scripts/ui/main.gd` 时，一次错误提交把该文件截断。

请先恢复 `main.gd`，再应用厨房接入。

## 恢复 main.gd

若本地仍有完整历史：

```sh
git checkout 631045fb86eb51aa09a31755591bde6f268ff57b -- scripts/ui/main.gd
```

该提交对应 CookingMenuUI 已完成、main.gd 尚未被截断的状态。

## 接入补丁要点

在恢复后的 `scripts/ui/main.gd` 中：

1. 增加变量：`cook_button` / `player_inventory` / `kitchen_controller`
2. `_ready()` 中调用 `_setup_kitchen()`
3. 行动按钮旁增加「去做点吃的」按钮
4. `_refresh_ui()` 中仅在 `HOME` + 日常阶段 + 仍有行动次数时显示该按钮
5. 成功烹饪后消耗本时段行动，并写入世界线事件

完整 diff 见 `docs/patches/main_kitchen_home.patch`。

## 已完成（无需补丁）

- `scripts/ui/cooking_menu_ui.gd`
- `KitchenController` 已挂 UI
- `tests/cooking_flow_test.gd` UI 路径断言
