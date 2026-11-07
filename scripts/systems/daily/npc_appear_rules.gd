class_name NpcAppearRules
extends RefCounted
## NPC appearance rules grouped by chapter phase + clue group.
## Query-only: main_shell / aftermath / intent scheduler can ask who may show.

const CH_PRE := "pre"
const CH_FESTIVAL := "festival"
const CH_POST := "post"

const G_DAILY := "daily_life"
const G_HERB := "herb_trade"
const G_FEST_SEED := "festival_seed"
const G_TRACE := "post_traces"
const G_VISITOR := "visitor_rumor"
const G_HERO := "hero_chain"
const G_SHRINE := "shrine_list"
const G_CLINIC := "clinic_quiet"

var _fired_once: Dictionary = {}

func resolve_chapter(segment_index: int, festival_done: bool, event_focus: bool) -> String:
	if event_focus:
		return CH_FESTIVAL
	if festival_done:
		return CH_POST
	return CH_PRE

func _trace_count(flags: Dictionary) -> int:
	var n := 0
	for k in ["trace_home_bowl", "trace_commons_seat", "trace_shrine_flowers", "trace_path_scrap"]:
		if bool(flags.get(k, false)):
			n += 1
	return n

func _has_knowledge(knowledge, ids: Array) -> bool:
	if knowledge == null or ids.is_empty():
		return ids.is_empty()
	for id in ids:
		if knowledge.has_method("has") and knowledge.has(str(id)):
			return true
		if knowledge.get("known") is Dictionary and bool(knowledge.known.get(str(id), false)):
			return true
	return false

func all_rules() -> Array:
	return [
		{"id": "pre_popo_talk", "npc_id": "popo", "label": "老婆婆", "chapters": [CH_PRE, CH_POST], "locations": ["HOME"], "segment_min": 0, "segment_max": -1, "flags_all": [], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": false, "priority": 10, "group": G_DAILY, "action_hint": "和老婆婆聊聊", "allow_event_focus": false},
		{"id": "pre_smith_water", "npc_id": "smith", "label": "铁匠", "chapters": [CH_PRE], "locations": ["HOME", "PATH"], "segment_min": 2, "segment_max": -1, "flags_all": [], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": false, "priority": 20, "group": G_DAILY, "action_hint": "帮铁匠提一桶水", "allow_event_focus": false},
		{"id": "pre_merchant", "npc_id": "merchant", "label": "外地商人", "chapters": [CH_PRE], "locations": ["COMMONS"], "segment_min": 0, "segment_max": -1, "flags_all": [], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": false, "priority": 15, "group": G_HERB, "action_hint": "和外地商人聊两句", "allow_event_focus": false},
		{"id": "pre_villager_fest_hint", "npc_id": "villager", "label": "村民", "chapters": [CH_PRE], "locations": ["COMMONS"], "segment_min": 2, "segment_max": -1, "flags_all": [], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": true, "priority": 12, "group": G_FEST_SEED, "action_hint": "和村民闲聊", "allow_event_focus": false},
		{"id": "fest_crowd", "npc_id": "festival_crowd", "label": "节庆人群", "chapters": [CH_FESTIVAL], "locations": ["COMMONS"], "segment_min": 0, "segment_max": -1, "flags_all": [], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": false, "priority": 100, "group": G_FEST_SEED, "action_hint": "节庆互动", "allow_event_focus": true},
		{"id": "post_popo", "npc_id": "popo", "label": "老婆婆", "chapters": [CH_POST], "locations": ["HOME"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": false, "priority": 10, "group": G_DAILY, "action_hint": "和老婆婆聊聊", "allow_event_focus": false},
		{"id": "post_trace_bowl", "npc_id": "trace_bowl", "label": "窗边空碗", "chapters": [CH_POST], "locations": ["HOME"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": ["trace_home_bowl"], "knowledge_any": [], "min_traces": 0, "once": true, "priority": 30, "group": G_TRACE, "action_hint": "查看窗边空碗", "allow_event_focus": false},
		{"id": "post_trace_seat", "npc_id": "trace_seat", "label": "长桌留白", "chapters": [CH_POST], "locations": ["COMMONS"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": ["trace_commons_seat"], "knowledge_any": [], "min_traces": 0, "once": true, "priority": 30, "group": G_TRACE, "action_hint": "留意长桌边的留白", "allow_event_focus": false},
		{"id": "post_trace_flowers", "npc_id": "trace_flowers", "label": "旧花束", "chapters": [CH_POST], "locations": ["SHRINE"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": ["trace_shrine_flowers"], "knowledge_any": [], "min_traces": 0, "once": true, "priority": 30, "group": G_TRACE, "action_hint": "看看角落的旧花束", "allow_event_focus": false},
		{"id": "post_trace_scrap", "npc_id": "trace_scrap", "label": "告示纸须", "chapters": [CH_POST], "locations": ["PATH"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": ["trace_path_scrap"], "knowledge_any": [], "min_traces": 0, "once": true, "priority": 30, "group": G_TRACE, "action_hint": "看看告示板边角", "allow_event_focus": false},
		{"id": "post_visitor_rumor", "npc_id": "villager_whisper", "label": "压低声音的村民", "chapters": [CH_POST], "locations": ["COMMONS"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": true, "priority": 40, "group": G_VISITOR, "action_hint": "听听节后闲话", "allow_event_focus": false, "aftermath_id": "AF02_visitor_rumor"},
		{"id": "post_hero_tracks", "npc_id": "hero_tracks", "label": "生人脚印", "chapters": [CH_POST], "locations": ["PATH"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": [], "knowledge_any": ["visitor_rumor"], "min_traces": 0, "once": true, "priority": 50, "group": G_HERO, "action_hint": "辨认路边的脚印", "allow_event_focus": false, "aftermath_id": "AF06_hero_glimpse"},
		{"id": "post_hero_meet", "npc_id": "hero", "label": "外来人", "chapters": [CH_POST], "locations": ["GROVE"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": [], "knowledge_any": ["hero_tracks"], "min_traces": 0, "once": true, "priority": 60, "group": G_HERO, "action_hint": "沿着脚印走进空地", "allow_event_focus": false, "aftermath_id": "AF09_hero_meet"},
		{"id": "post_hero_talk", "npc_id": "hero", "label": "外来人", "chapters": [CH_POST], "locations": ["GROVE"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": ["hero_met"], "flags_forbid": [], "knowledge_any": ["hero_face"], "min_traces": 0, "once": true, "priority": 61, "group": G_HERO, "action_hint": "上前说话", "allow_event_focus": false, "aftermath_id": "AF09_hero_talk"},
		{"id": "post_hero_second", "npc_id": "hero", "label": "外来人", "chapters": [CH_POST], "locations": ["FOREST"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": ["hero_met"], "flags_forbid": [], "knowledge_any": ["hero_spoken"], "min_traces": 0, "once": true, "priority": 70, "group": G_HERO, "action_hint": "赴林缘之约", "allow_event_focus": false, "aftermath_id": "AF10_hero_second", "require_rest_after_hero": true},
		{"id": "post_clinic", "npc_id": "clinic_absence", "label": "诊疗处（人不在）", "chapters": [CH_POST], "locations": ["CLINIC"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done"], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": true, "priority": 35, "group": G_CLINIC, "action_hint": "推开半掩的门看看", "allow_event_focus": false, "aftermath_id": "AF04_clinic_quiet"},
		{"id": "post_shrine_reread", "npc_id": "shrine_gaze", "label": "礼拜门口的目光", "chapters": [CH_POST], "locations": ["SHRINE"], "segment_min": 0, "segment_max": -1, "flags_all": ["festival_done", "trace_shrine_flowers"], "flags_any": [], "flags_forbid": [], "knowledge_any": [], "min_traces": 0, "once": true, "priority": 36, "group": G_SHRINE, "action_hint": "再看一次旧花束", "allow_event_focus": false, "aftermath_id": "AF08_shrine_reread"},
	]

func list_available(ctx: Dictionary) -> Array:
	var segment: int = int(ctx.get("segment_index", 0))
	var festival_done: bool = bool(ctx.get("festival_done", false))
	var event_focus: bool = bool(ctx.get("event_focus", false))
	var location: String = str(ctx.get("location", ""))
	var flags: Dictionary = ctx.get("flags", {})
	if not (flags is Dictionary):
		flags = {}
	var knowledge = ctx.get("knowledge", null)
	var aftermath_seen: Dictionary = ctx.get("aftermath_seen", {})
	if not (aftermath_seen is Dictionary):
		aftermath_seen = {}
	var chapter: String = resolve_chapter(segment, festival_done, event_focus)
	var traces: int = _trace_count(flags)
	var out: Array = []
	for rule in all_rules():
		if not _rule_matches(rule, chapter, segment, location, flags, knowledge, traces, event_focus, aftermath_seen):
			continue
		out.append(rule)
	out.sort_custom(func(a, b): return int(a.get("priority", 0)) > int(b.get("priority", 0)))
	return out

func list_by_group(ctx: Dictionary) -> Dictionary:
	var grouped: Dictionary = {}
	for rule in list_available(ctx):
		var g: String = str(rule.get("group", "other"))
		if not grouped.has(g):
			grouped[g] = []
		grouped[g].append(rule)
	return grouped

func list_by_chapter(ctx: Dictionary) -> Dictionary:
	var chapter: String = resolve_chapter(int(ctx.get("segment_index", 0)), bool(ctx.get("festival_done", false)), bool(ctx.get("event_focus", false)))
	return {chapter: list_available(ctx)}

func _rule_matches(rule: Dictionary, chapter: String, segment: int, location: String, flags: Dictionary, knowledge, traces: int, event_focus: bool, aftermath_seen: Dictionary) -> bool:
	var chapters: Array = rule.get("chapters", [])
	if not chapters.has(chapter):
		return false
	if event_focus and not bool(rule.get("allow_event_focus", false)):
		return false
	var locs: Array = rule.get("locations", [])
	if location != "" and not locs.has(location):
		return false
	if segment < int(rule.get("segment_min", 0)):
		return false
	var seg_max: int = int(rule.get("segment_max", -1))
	if seg_max >= 0 and segment > seg_max:
		return false
	for f in rule.get("flags_all", []):
		if not bool(flags.get(str(f), false)):
			return false
	var any_flags: Array = rule.get("flags_any", [])
	if not any_flags.is_empty():
		var ok_any := false
		for f in any_flags:
			if bool(flags.get(str(f), false)):
				ok_any = true
				break
			if knowledge != null and knowledge.has_method("has") and knowledge.has(str(f)):
				ok_any = true
				break
		if not ok_any:
			return false
	for f in rule.get("flags_forbid", []):
		if bool(flags.get(str(f), false)):
			return false
	var know_any: Array = rule.get("knowledge_any", [])
	if not know_any.is_empty() and not _has_knowledge(knowledge, know_any):
		return false
	if traces < int(rule.get("min_traces", 0)):
		return false
	var af_id: String = str(rule.get("aftermath_id", ""))
	if af_id != "" and bool(aftermath_seen.get(af_id, false)):
		return false
	if bool(rule.get("once", false)):
		var rid: String = str(rule.get("id", ""))
		if bool(_fired_once.get(rid, false)):
			return false
	if bool(rule.get("require_rest_after_hero", false)):
		if not bool(aftermath_seen.get("AF09_hero_echo", false)) and not bool(aftermath_seen.get("AF09_hero_talk", false)):
			return false
	return true

func mark_fired(rule_id: String) -> void:
	_fired_once[rule_id] = true

func reset_fired() -> void:
	_fired_once.clear()

func describe_groups() -> Dictionary:
	return {
		G_DAILY: "常驻日常：地点即可，可反复",
		G_HERB: "草药/交换：商人与采集知识",
		G_FEST_SEED: "节庆种子：段数推进后出现邀请与鼓声",
		G_TRACE: "节后物件痕迹：观察解锁，一次",
		G_VISITOR: "生人传闻：节后公共场一次",
		G_HERO: "Hero 链：闲话→脚印→见面→约见，硬前置",
		G_SHRINE: "礼拜/名单侧：旧花后重读",
		G_CLINIC: "诊疗处缺席：节后一次",
	}
