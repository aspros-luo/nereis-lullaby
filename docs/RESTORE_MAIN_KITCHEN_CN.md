# 恢复主界面厨房入口（本地冲突时）

若本地 `main.gd` 冲突，请**放弃本地对该文件的修改**，只跟远程：

```sh
git fetch origin
git checkout origin/development -- scripts/ui/main.gd
git restore project.godot   # 可选：丢掉编辑器改动
# 不要提交 .godot/ 与 *.uid
git pull origin development
```

## 当前推荐试玩方式（无需主界面）

1. 打开 `scenes/cooking/kitchen.tscn`
2. 按 F6 运行当前场景
3. 自动出现厨房菜单 → 制作蜂蜜面包 → 继续 → 完成出炉

## 主界面入口目标

- 地点：家附近
- 按钮：去做点吃的
- 条件：日常阶段 + 本时段还有行动次数
