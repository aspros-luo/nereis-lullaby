# 当前进度与待办（2026-11-14 晚）

> 文字可玩闭环已通。大文件改动多通过 `scripts/tools/apply_*.py` 本地接线。

---

## 进度总览

| 模块 | 状态 |
|------|------|
| 标题 / 三槽存档 / 日常壳 | 已完成 |
| Day-1：采集·交易·厨房·赠食 PF06–08 | 已完成（需 apply 脚本） |
| 节前：观察·鼓声·铁匠提水·礼拜/诊疗对白 | 已完成（需 apply） |
| 丰收节焦点与软倾向 | 已完成 |
| 节后痕迹 + Hero AF09–10 + 软结局页 + AF12 | 已完成 |
| VisualLibrary 接口 | 已完成（真图未投） |
| NPC 行为层接线 | 已完成（需 apply） |
| AF08/08b 名单重读、AF04/04b 诊疗 | 脚本已推，需本地 apply |
| AF13 救人插曲 + 结局 F | 脚本已推，需本地 apply |
| Hero 对白挂钩 rescue_helped | 脚本已推，需本地 apply |
| 地点/立绘真资源 | 未做 |
| 日程在场 / appear_rules 全面对齐 | 未做 |
| 独立结局场景 | 未做（现为叠层软结局） |

## 建议你本地一次跑齐（幂等）

```bash
git pull origin development
for f in scripts/tools/apply_*.py; do echo "== $f"; python3 "$f" || true; done
git add -u
git status   # 确认无 .uid
git commit -m "Apply pending experience wiring batch"
git push origin development
```

## 下一步优先

1. **真资源**：`assets/locations` / `assets/portraits` 投图  
2. **日程在场**与 appear_rules  
3. **独立结局场景**（替换纯叠层）  

## 节后推荐路径

诊疗静场 → 脚印 → 路旁救人 → 名单重读两段 → Hero → 整理日子（结局页）
