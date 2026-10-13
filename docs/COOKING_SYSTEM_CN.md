# 蜜忒之歌 - 料理系统设计 / Cooking System

## 状态

Phase 1: Cooking System Vertical Slice

## 核心定位

料理不是传统物品合成系统，而是蜜忒连接村庄、人际关系和世界变化的核心媒介。

玩家视角：
- 制作美味食物
- 分享给村民
- 了解故事

系统内部：
- 记录隐藏影响
- 影响 NPC 信息传播
- 连接 Worldline Event Ledger

## 设计原则

- 不显示神识浓度或外神影响数值。
- 蜜忒不知道自己的行为产生了异常影响。
- 玩家通过 NPC 反应、事件变化和剧情发现异常。
- 料理制作必须是操作过程，不使用简单菜单选择。

## 第一阶段目标

实现：

小屋厨房
→ 准备材料
→ 制作过程
→ 获得料理
→ 携带料理
→ NPC 赠送接口

## 初始料理

### 蜂蜜面包

用途：教学料理。

流程：
- 准备面粉
- 加入牛奶和鸡蛋
- 揉面
- 发酵
- 烘烤
- 装饰

### 苹果派

用途：村庄交流料理。

### 森林果酱

用途：探索相关料理。

### 奶油蛋糕

用途：关系事件料理。

## 数据方向

Ingredient:
- id
- name
- tags
- quality
- origin

Recipe:
- ingredients
- cooking steps
- result

Cooking Result:
- visible quality
- visible description
- hidden world effects

## 后续扩展

料理结果将接入：

Cooking
→ NPC Relationship
→ Information Network
→ Worldline Event Ledger
