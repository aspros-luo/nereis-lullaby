class_name PreFestivalEvents
extends RefCounted

## LN-style sample lines for pre-festival daily events.
## Texts from docs/DIALOGUE_STYLE_LN_CN.md

var seen: Dictionary = {}

func mark(id: String) -> void:
	seen[id] = true

func has_seen(id: String) -> bool:
	return bool(seen.get(id, false))

func text_pf02_first() -> String:
	return (
		"屋子里有淡淡的灶灰味。窗边那只花瓶，又被挪正了一点。\n\n"
		+ "老婆婆\n「回来了？……吃饭了没有。」\n\n"
		+ "她一边说，一边把我袖口的线头拈掉。指甲边缘有细小的布刺。\n\n"
		+ "老婆婆\n「门前园子里的叶子，可以摘一点回来。别等蔫了。」\n\n"
		+ "像只是随口一提。\n可被这样说着的时候，肚子又诚实响了一下。"
	)

func text_pf21_repeat() -> String:
	return (
		"老婆婆\n「吃饭了没有。」\n\n"
		+ "还是这句。\n连语调都差不多。\n\n"
		+ "我应了。她看着我，又看了看窗外。\n\n"
		+ "老婆婆\n「那就好。」\n\n"
		+ "什么也没有增加。\n什么也没有减少。\n这样反而让人想一直待在这句话里。"
	)

func text_pf17_festival_invite() -> String:
	return (
		"晚饭后的光把桌角拉得很长。老婆婆整理着一只旧匣子，布条从里面滑出来，颜色还新。\n\n"
		+ "老婆婆\n「丰收节快到了。」\n\n"
		+ "她把布条叠好，拍了拍我的手背。\n\n"
		+ "老婆婆\n「到时候来。人多，别自己往角落缩。」\n\n"
		+ "老婆婆\n「吃的也会多。你啊，到时候记得吃。」\n\n"
		+ "像往年也会这样说。\n我点头的时候，却觉得那只匣子关上的声音，稍稍偏响了一点。"
	)

func text_pf06_gift_popo() -> String:
	return (
		"碗还温着。我把它递过去的时候，汤面轻轻晃了一下。\n\n"
		+ "老婆婆\n「还热。」\n\n"
		+ "她吹了吹，喝了一口。眼睛没有看我，只是点了点头。\n\n"
		+ "老婆婆\n「手稳了些。」\n\n"
		+ "只是这样。\n可不知为什么，比被夸奖「好孩子」更让人想再做一次。"
	)

func text_pf09_smith_water() -> String:
	return (
		"棚后的锤声停了。铁匠站在门口，手里提着空桶，像已经等了一小会儿。\n\n"
		+ "铁匠\n「方便的话，帮我提一趟。」\n\n"
		+ "水很沉。木柄蹭得掌心发麻。\n他接过去时只说：\n\n"
		+ "铁匠\n「嗯。」\n\n"
		+ "锤声重新响起来。\n像这件事从来没有发生过——又像每天都会发生。"
	)

func text_pf09_smith_done() -> String:
	return "棚后锤声一下一下响着。空桶靠在门边，水痕还没干透。"

func text_pf20_drum() -> String:
	return (
		"公共场那边隐隐传来鼓声。不是正式敲，像在试音，一下，又一下。\n\n"
		+ "有人笑着走过，手里抱着还没展开的布。\n空气里有一点甜，也有尘土。\n\n"
		+ "——节要开始了。\n脚却还站在熟悉的路上。"
	)

func text_observe_home_vase() -> String:
	return "窗边的花瓶正对着光。谁刚用手拂过瓶口，那里还没有落灰。"

func text_observe_home_hammer() -> String:
	return "棚后再次传来锤声。一下，一下，像把白天钉在架子上。"

func text_observe_commons_basket() -> String:
	return "有人把篮子暂放在路边。提手还热着，像主人马上就会回来。"

func text_observe_shrine_paper() -> String:
	return "礼拜场所里有人翻纸。名单很薄，声音却很齐。"

func text_rest_sweet_night() -> String:
	return "我休息了一会儿。日子悄悄往前走了一点。\n风里似有一点甜味，安心，又像略略过饱。"


func text_observe_clinic() -> String:
	return (
		"诊疗处的门半掩着。架子上药瓶排得很齐，\n"
		+ "空气里有干净的苦味。\n\n"
		+ "里间有人轻咳了一声，又很快止住。\n"
		+ "柜台边放着一卷未拆封的纱布。"
	)

func text_observe_path() -> String:
	return (
		"通路上有人匆匆走过，怀里抱着还没展开的布。\n"
		+ "鞋底带起一点尘土，很快又落回去。"
	)

func text_observe_forest_pre() -> String:
	return (
		"林子比村子安静。风穿过叶子，像有人在远处试着开口，\n"
		+ "又把话咽了回去。"
	)

## Returns dialogue for talking to 老婆婆 based on segment and flags.
func resolve_popo_talk(segment: int, festival_done: bool) -> Dictionary:
	if festival_done:
		return {
			"id": "post_festival_popo",
			"text": "老婆婆把我头发上一点碎花瓣拈掉，说：办完就好，别想太多。她的手很稳，笑却浅了一点。",
			"learn_herb": false,
		}
	if segment >= 4 and not has_seen("PF17"):
		mark("PF17")
		return {"id": "PF17", "text": text_pf17_festival_invite(), "learn_herb": false}
	if has_seen("PF02"):
		mark("PF21")
		return {"id": "PF21", "text": text_pf21_repeat(), "learn_herb": false}
	mark("PF02")
	return {"id": "PF02", "text": text_pf02_first(), "learn_herb": true}
