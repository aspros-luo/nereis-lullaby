# VisualLibrary 美术接入说明

## 目录约定

```
assets/
  locations/     # 地点底图 16:9 或接近舞台比例
    home.png
    commons.png
    path.png
    shrine.png
    clinic.png
    forest.png
    grove.png
    festival.png
  portraits/     # 立绘半身，透明底优先
    popo.png
    hero.png
    merchant.png
    smith.png
    festival.png
```

路径写在 `scripts/ui/visual_library.gd` 的 `LOCATION_PATHS` / `PORTRAIT_PATHS`。

## 行为

- **有图**：舞台 TextureRect 显示底图；立绘 TextureRect 显示肖像。
- **无图**：沿用地点色块（`LOCATION_COLORS`）+ 立绘占位文字，不报错。
- 换皮只需替换 PNG，或改字典路径；不必改 `main_shell` 逻辑。

## 建议规格（demo）

| 类型 | 建议 |
|------|------|
| 地点底图 | 1280×720 或 960×540，暗调，勿抢对话框 |
| 立绘 | 高 600–900px，角色偏右或居中，透明底 |
| 格式 | PNG / WebP；Godot 导入默认即可 |

## 与剧情的衔接

节庆焦点使用 `FESTIVAL` 地点键与 `festival` 立绘键。  
Hero 链 `beat.portrait` 可传 `hero` / `visitor`；未识别时回退占位字。
