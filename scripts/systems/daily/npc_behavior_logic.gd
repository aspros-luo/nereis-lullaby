class_name NpcBehaviorLogic
extends RefCounted
## Unified NPC behavior layer for the daily shell.
## Priority: authored story (aftermath / festival) > schedule presence > routine choice > talk variant.
## Does not invent knowledge; talk lines only use local flags the NPC is allowed to notice.

const Profiles = preload("res://scripts/data/npc_behavior_profiles.gd")

const ID_MAP: Dictionary = {
	"popo": "caregiver",
	"caregiver": "caregiver",
	"smith": "smith",
	"merchant": "merchant",
	"worship": "worship_leader",
	"worship_leader": "worship_leader",
	"doctor": "doctor",
	"hero": "hero",
	"villager": "villager",
}

const EXTENDED: Dictionary = {
	"smith": {
		"role": "village_smith",
		"goals": ["keep tools usable", "stay useful without prying"],
		"motives": ["work", "reliability"],
		"action_preferences": ["work", "help"],
		"knowledge_boundaries": ["knows who asked for repairs", "does not know festival list contents", "hears road gossip but treats it as gossip"],
		"stress_response": "bury into work, short answers, offer practical help only",
		"fallback_action": "hammer and sort iron",
	},
	"merchant": {
		"role": "passing_trader",
		"goals": ["trade", "leave before trouble"],
		"motives": ["profit", "curiosity"],
		"action_preferences": ["trade", "gossip"],
		"knowledge_boundaries": ["knows road prices and herb names", "does not know village private lists"],
		"stress_response": "smile, change subject, pack goods sooner",
		"fallback_action": "rearrange baskets",
	},
	"hero": {
		"role": "outside_watcher",
		"goals": ["observe seams", "offer a non-registered path without forcing"],
		"motives": ["clarity", "distance", "reluctant care"],
		"action_preferences": ["watch", "point"],
		"knowledge_boundaries": ["sees traces and patterns, not household intimacy", "does not claim village membership"],
		"stress_response": "step back into trees, leave a mark not a speech",
		"fallback_action": "wait at the forest edge",
	},
	"villager": {
		"role": "local_villager",
		"goals": ["keep face", "share safe gossip"],
		"motives": ["belonging", "caution"],
		"action_preferences": ["gossip", "work"],
		"knowledge_boundaries": ["knows public festival prep", "whispers about strangers only after festival"],
		"stress_response": "lower voice, switch to weather",
		"fallback_action": "return to chores",
	},
}

const ROUTINE_LINES: Dictionary = {
	"caregiver": {
		"pre": [
			{"id": "popo_pre_meal", "line": "老婆婆把灶边的灰扫进簸箕，说饭还得再炖一会儿。", "goal": "care"},
			{"id": "popo_pre_home", "line": "老婆婆把窗边的布巾拧干，挂回原处。", "goal": "stability"},
		],
		"post": [
			{"id": "popo_post_soft", "line": "老婆婆拈掉我头发上一点花瓣，没有多问节上的事。", "goal": "care"},
			{"id": "popo_post_watch", "line": "老婆婆看了看窗外，又把碗筷摆正，像日子必须保持原样。", "goal": "stability"},
		],
		"stress": [
			{"id": "popo_stress", "line": "老婆婆手上的事没停，只是话比往日短。", "goal": "care"},
		],
	},
	"smith": {
		"pre": [
			{"id": "smith_pre_work", "line": "铁匠把一块铁翻了个面，火星短短亮了一下。", "goal": "work"},
			{"id": "smith_pre_help", "line": "铁匠朝水桶偏了偏下巴：「手闲着的话，提一趟。」", "goal": "help"},
		],
		"post": [
			{"id": "smith_post", "line": "铁匠仍在打铁。节散了，锤子的节奏却没变。", "goal": "work"},
		],
		"stress": [
			{"id": "smith_stress", "line": "铁匠敲得更密，像不愿让沉默停太久。", "goal": "work"},
		],
	},
	"merchant": {
		"pre": [
			{"id": "mer_pre_trade", "line": "商人掀开盖布，草药味混着一点路上的尘。", "goal": "trade"},
			{"id": "mer_pre_talk", "line": "商人笑着说丰收节近了，路上的货都紧着往村里送。", "goal": "gossip"},
		],
		"post": [
			{"id": "mer_post", "line": "商人已经收拾了一半的担子：「节过了，路也好走些。」", "goal": "trade"},
		],
		"stress": [
			{"id": "mer_stress", "line": "商人把话头转到天气，手指却在袋绳上绕得更紧。", "goal": "trade"},
		],
	},
	"worship_leader": {
		"pre": [{"id": "wor_pre", "line": "有人在礼拜场所核对照片与花束，声音平、不急。", "goal": "community"}],
		"post": [{"id": "wor_post", "line": "礼拜场所里名单不在桌上。整理过的痕迹比花香更明显。", "goal": "tradition"}],
		"stress": [{"id": "wor_stress", "line": "公共安排仍在推进，只是解释少了一句。", "goal": "coordination"}],
	},
	"doctor": {
		"pre": [{"id": "doc_pre", "line": "诊疗处药瓶排得很齐。有人翻记录时停了一下，又合上。", "goal": "evidence"}],
		"post": [{"id": "doc_post", "line": "门半掩着。架子上多了未拆封的纱布，人却不在。", "goal": "caution"}],
		"stress": [{"id": "doc_stress", "line": "记录被重新码过，不确定的日期用另一种墨水标着。", "goal": "evidence"}],
	},
	"hero": {
		"pre": [],
		"post": [{"id": "hero_edge", "line": "林缘有一段时间风也不响。像有人刚站过，又把声音带走了。", "goal": "watch"}],
		"stress": [{"id": "hero_stress", "line": "树影里没有人。只有一根细枝的折法不像偶然。", "goal": "point"}],
	},
	"villager": {
		"pre": [{"id": "vil_pre", "line": "有人提起丰收节，笑了一下，又去忙自己的事。", "goal": "gossip"}],
		"post": [{"id": "vil_post", "line": "公共场有人压低声音，话题很快转去天气。", "goal": "gossip"}],
		"stress": [{"id": "vil_stress", "line": "闲话停得太整齐，像有人在场边轻轻咳了一声。", "goal": "gossip"}],
	},
}

const TALK_BEATS: Dictionary = {
	"popo": {
		"pre": {"default": "老婆婆说灶还热着。若要出门，记得天黑前回来。"},
		"post": {
			"refused": "老婆婆把我头发上一点碎花瓣拈掉：「没去也没关系。人多的地方，本来就不是人人都要站进去。」",
			"offered": "老婆婆：「桌上那盘是你端的吧。有人问是谁做的，我没说。」她拍了拍我的手背。",
			"helped": "老婆婆：「听他们说你帮忙了。手还稳。」她看向窗外：「办完就好。别想太多。」",
			"default": "老婆婆：「办完就好，别想太多。」她的手很稳，笑却浅了一点。",
		},
	},
	"smith": {
		"pre": {
			"default": "铁匠：「水在那边。提一趟，手就不会闲得发慌。」",
			"after_help": "铁匠点了点头，没有多余的话。锤子又响起来。",
		},
		"post": {"default": "铁匠：「节散了。铁还是铁。」他没有问我节上站在哪一边。"},
	},
	"merchant": {
		"pre": {"default": "商人压低声音说林子边上有野葱，煮汤刚好。像顺口，又像在换一种招呼。"},
		"post": {"default": "商人：「节后的路好走些。你若还收草药，我下回还带。」担子已经绑紧了一半。"},
	},
}

var _previous_action: Dictionary = {}

func profile_for(npc_id: String) -> Dictionary:
	var key: String = str(ID_MAP.get(npc_id, npc_id))
	var p: Dictionary = Profiles.get_profile(key)
	if not p.is_empty():
		return p
	if EXTENDED.has(key):
		return (EXTENDED[key] as Dictionary).duplicate(true)
	if EXTENDED.has(npc_id):
		return (EXTENDED[npc_id] as Dictionary).duplicate(true)
	return {}

func chapter_key(festival_done: bool, event_focus: bool) -> String:
	if event_focus:
		return "festival"
	if festival_done:
		return "post"
	return "pre"

func stress_level(flags: Dictionary) -> int:
	var s := 0
	if bool(flags.get("festival_done", false)):
		s += 1
	if bool(flags.get("tendency_t_soft", false)):
		s += 1
	if bool(flags.get("hero_met", false)) or bool(flags.get("hero_second_met", false)):
		s += 1
	if bool(flags.get("trace_shrine_flowers", false)) and bool(flags.get("trace_path_scrap", false)):
		s += 1
	return s

func presence_note(npc_id: String, location: String, festival_done: bool, event_focus: bool) -> String:
	if event_focus:
		return ""
	var ch := chapter_key(festival_done, event_focus)
	var key: String = str(ID_MAP.get(npc_id, npc_id))
	if key == "caregiver" and location == "HOME":
		return "老婆婆在" if ch != "post" else "老婆婆仍在"
	if key == "smith" and location in ["HOME", "PATH"]:
		return "铁匠的敲打声很近"
	if key == "merchant" and location == "COMMONS" and not festival_done:
		return "外地商人的担子还在"
	if key == "doctor" and location == "CLINIC":
		return "诊疗处有人翻记录的声音" if not festival_done else "诊疗处异常安静"
	if key == "hero" and location in ["GROVE", "FOREST"] and festival_done:
		return "树影里像有人站过"
	return ""

func choose_routine(npc_id: String, ctx: Dictionary) -> Dictionary:
	var key: String = str(ID_MAP.get(npc_id, npc_id))
	var festival_done: bool = bool(ctx.get("festival_done", false))
	var event_focus: bool = bool(ctx.get("event_focus", false))
	if event_focus:
		return {}
	var flags: Dictionary = ctx.get("flags", {})
	if not (flags is Dictionary):
		flags = {}
	var bucket := "pre"
	if festival_done:
		bucket = "post"
	if stress_level(flags) >= 3:
		bucket = "stress"
	var table: Dictionary = ROUTINE_LINES.get(key, {})
	var options: Array = table.get(bucket, [])
	if options.is_empty():
		options = table.get("pre", [])
	if options.is_empty():
		return {}
	var prev: String = str(_previous_action.get(key, ""))
	var pool: Array = []
	for o in options:
		if str(o.get("id", "")) != prev:
			pool.append(o)
	if pool.is_empty():
		pool = options
	var tick: int = int(ctx.get("segment_index", 0))
	var pick: Dictionary = pool[tick % pool.size()].duplicate(true)
	pick["npc_id"] = npc_id
	pick["profile_id"] = key
	pick["decision_basis"] = "routine_goals_chapter_stress"
	_previous_action[key] = str(pick.get("id", ""))
	return pick

func talk_line(npc_id: String, ctx: Dictionary) -> String:
	var flags: Dictionary = ctx.get("flags", {})
	if not (flags is Dictionary):
		flags = {}
	var festival_done: bool = bool(ctx.get("festival_done", false))
	var beats: Dictionary = TALK_BEATS.get(npc_id, {})
	if beats.is_empty():
		beats = TALK_BEATS.get(str(ID_MAP.get(npc_id, "")), {})
	var phase: Dictionary = beats.get("post" if festival_done else "pre", {})
	if phase.is_empty():
		return ""
	if festival_done:
		if bool(flags.get("festival_refused", false)) and not bool(flags.get("festival_helped", false)) and not bool(flags.get("festival_offered_food", false)):
			if phase.has("refused"):
				return str(phase["refused"])
		if bool(flags.get("festival_offered_food", false)) and phase.has("offered"):
			return str(phase["offered"])
		if bool(flags.get("festival_helped", false)) and phase.has("helped"):
			return str(phase["helped"])
	if bool(ctx.get("smith_helped", false)) and phase.has("after_help"):
		return str(phase["after_help"])
	return str(phase.get("default", ""))

func decide(npc_id: String, ctx: Dictionary) -> Dictionary:
	if bool(ctx.get("authored_active", false)):
		return {"blocked_by": "authored_story"}
	var festival_done: bool = bool(ctx.get("festival_done", false))
	var event_focus: bool = bool(ctx.get("event_focus", false))
	var location: String = str(ctx.get("location", ""))
	var profile: Dictionary = profile_for(npc_id)
	var flags: Dictionary = ctx.get("flags", {})
	if not (flags is Dictionary):
		flags = {}
	return {
		"npc_id": npc_id,
		"profile_id": str(ID_MAP.get(npc_id, npc_id)),
		"chapter": chapter_key(festival_done, event_focus),
		"stress": stress_level(flags),
		"presence_note": presence_note(npc_id, location, festival_done, event_focus),
		"routine": choose_routine(npc_id, ctx),
		"talk_line": talk_line(npc_id, ctx),
		"fallback": str(profile.get("fallback_action", "")),
		"stress_response": str(profile.get("stress_response", "")),
		"decision_basis": "behavior_logic_v1",
	}

func describe_stack() -> String:
	return "authored > appear_rules > schedule presence > routine/talk variants (chapter+stress+flags)"
