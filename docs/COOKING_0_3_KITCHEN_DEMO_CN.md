# Cooking-0.3 厨房制作 Demo

## 目标

建立正式项目结构的厨房制作闭环，且制作是**有步骤的过程**。

## 流程

Player
→ 选择配方
→ 校验材料（不立刻消耗）
→ 步骤 1..N（玩家按「继续」推进）
→ 最后一步「完成出炉」
→ 消耗材料、获得料理、显示结果

## 蜂蜜面包步骤

1. 准备：倒面粉、加蜂蜜和鸡蛋
2. 揉面
3. 烘烤
4. 完成出炉

## 清单

- [x] CookingFlowController
- [x] KitchenController
- [x] Kitchen 场景骨架
- [x] Inventory 接入
- [x] 正式 UI 面板
- [x] 多步骤操作表现（文本步骤）
- [ ] 与主界面地点行动打通（补丁见 `docs/patches/main_kitchen_home.patch`）
