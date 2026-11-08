# 应用可玩版 main_shell（day-1）

当前远程 `main_shell.gd` 曾被截断，请本地还原完整可玩版：

## 方法一（推荐）

```bash
git fetch origin
git checkout development

# 1) 还原到最后一次完整壳
git show 73e4137:scripts/ui/main_shell.gd > scripts/ui/main_shell.gd

# 2) 若你有 agent 导出的完整文件：
# cp /path/to/main_shell_PLAYABLE.gd scripts/ui/main_shell.gd

# 3) 提交
git add scripts/ui/main_shell.gd
git commit -m "Playable day-1: gather/trade/kitchen + enter_event fix"
git push origin development
```

## 方法二：关键 diff 要点（相对 73e4137）

1. `enter_event_focus()` → `enter_event("harvest_festival")`
2. preload + new `NpcBehaviorLogic`
3. HOME：`做饭`、`收取园里的草药`（开局 `know_home_herb_patch`）
4. COMMONS：商人 + `用草药换面粉`
5. PATH/HOME 段≥2：帮铁匠
6. `_do_gather` / `_do_trade` / 氛围 observe
7. 存档写入 `segment` 与 `pre_events_seen`

验证：新游戏在家应看到 **做饭**、**收取园里的草药**；公共场可聊天/换货；段≥4 可进丰收节。
