# 美食系统资源管线

## 目标

料理系统采用数据驱动方式。

代码负责流程：

- 制作逻辑
- 材料检查
- 结果生成

资源负责内容：

- 食材
- 配方
- 描述
- 扩展属性

## 当前流程

Ingredient Resource

↓

Recipe Resource

↓

CookingResourceLoader

↓

CookingManager

## 扩展料理

新增料理时优先新增资源文件，不修改核心代码。
