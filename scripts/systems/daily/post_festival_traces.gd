class_name PostFestivalTraces
extends RefCounted
## Object / place / faceless traces after harvest festival (LN tone).
## Branch texts depend on festival flags.

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

func text_commons_place_helped() -> String:
	return (
		"公共场的长桌空了。\n"
		+ "我帮忙摆过的那一侧，桌脚还留着一点蜜渍，没人擦。\n\n"
		+ "有人走过时看了我一眼，又很快移开。"
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

func text_festival_end_summary(helped: bool, offered: bool, refused: bool) -> String:
	if refused and not helped and not offered:
		return "节散了。回到家附近时，窗边还留着一点花瓣。\n路上几乎没人跟我打招呼——也许只是累了。"
	if helped and offered:
		return "节散了。有人在路口朝我点了点头。\n回到家附近时，窗边花瓣被扫成小小一堆，像有人特意留给我看。"
	if helped or offered:
		return "节散了。回到家附近时，窗边还留着一点花瓣。\n空气里仍有一点甜，又有点沉。"
	return "节散了。回到家附近时，窗边还留着一点花瓣。"

func text_popo_post(helped: bool, offered: bool, refused: bool) -> String:
	if refused and not helped and not offered:
		return (
			"老婆婆把我头发上一点碎花瓣拈掉，说：\n"
			+ "「没去也没关系。人多的地方，本来就不是人人都要站进去。」\n\n"
			+ "她的手很稳。笑却浅了一点，浅得像故意留给我自己猜。"
		)
	if offered:
		return (
			"老婆婆把我头发上一点碎花瓣拈掉，说：\n"
			+ "「桌上那盘是你端的吧。有人问是谁做的，我没说。」\n\n"
			+ "她拍了拍我的手背：\n「办完就好。别想太多。」"
		)
	if helped:
		return (
			"老婆婆把我头发上一点碎花瓣拈掉，说：\n"
			+ "「听他们说你帮忙了。手还稳。」\n\n"
			+ "她看了看窗外：\n「办完就好。别想太多。」"
		)
	return (
		"老婆婆把我头发上一点碎花瓣拈掉，说：\n"
		+ "办完就好，别想太多。\n\n"
		+ "她的手很稳，笑却浅了一点。"
	)

func text_tendency_hint(has_p: bool, has_t: bool) -> String:
	if has_p and not has_t:
		return "夜里风从窗缝进来，带着一点未散尽的甜。像有人还把位子留着。"
	if has_t and not has_p:
		return "夜里风从窗缝进来，很干净，干净得不像节后该有的味道。"
	if has_p and has_t:
		return "夜里风里又有甜，又有一点空。两种味道叠在一起，分不清哪边更真。"
	return ""
