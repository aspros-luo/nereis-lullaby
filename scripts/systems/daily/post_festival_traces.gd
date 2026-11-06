class_name PostFestivalTraces
extends RefCounted

## Object / place / faceless traces after harvest festival (LN tone).
## Writes narrative + knowledge notes; dimensions C conceptually.

func text_home_object_petals() -> String:
	return (
		"窗台下多了一只空碗。\n"
		+ "碗沿还沾着一点干了的花瓣碎屑，像有人倒过什么，又收拾得很急。\n\n"
		+ "我伸手碰了碰。碎片很轻。\n"
		+ "屋里没有别人提起过这只碗。"
	)

func text_home_object_seen() -> String:
	return "那只空碗还在原处。花瓣碎屑少了一些，像被风吹过，又像被谁拈走过。"

func text_commons_place() -> String:
	return (
		"公共场的长桌空了。\n"
		+ "有一个座位前的地面扫得特别干净，干净得不像是忘记，倒像是故意留白。\n\n"
		+ "有人从旁边走过，没有看那里。"
	)

func text_shrine_place() -> String:
	return (
		"礼拜场所里花束换了新的。\n"
		+ "旧花被捆成很小一束，塞在角落，绳子勒得很紧。\n\n"
		+ "翻纸的声音没有了。名单不在桌上。"
	)

func text_faceless_path_scrap() -> String:
	return (
		"路旁贴过告示的木板空着。\n"
		+ "边角还挂着一条撕剩的纸须，字看不清。\n\n"
		+ "没有人站在那里解释它是什么。"
	)

func text_festival_refuse() -> String:
	return (
		"我说今天有点累，先不参与安排了。\n\n"
		+ "对面的人顿了一下，很快笑开：\n"
		+ "「也好。回来吃就行。」\n\n"
		+ "鼓声仍在。\n"
		+ "我站在人圈外，手里什么也没有递出去。"
	)
