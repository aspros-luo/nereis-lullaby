# 料理出炉大图规范

## 路径约定

```
res://assets/cooking/results/<recipe_id>.png
```

示例：

- `res://assets/cooking/results/honey_bread.png`

## 风格（香草社向）

- 手绘插画感，清晰笔触与体积光
- 暗色厨房环境 + 暖色食物主体
- 项目色参考：`#1a1e28` `#3a3544` `#c46a72` `#c8bfa8`，食物可用琥珀金与蜜色
- 建议分辨率：1024×1024 或 1024×768
- 主体居中，四周留白，便于 UI 缩放

## 接入状态

- 配方字段：`result_image_path`
- 出炉成功时 `CookingMenuUI` 显示 `TextureRect`
- 资源缺失时自动隐藏，不报错

## 放入资源后

1. 将 PNG 放到 `assets/cooking/results/`
2. Godot 会生成 `.import`
3. 重新运行厨房流程，完成出炉即可看到大图
