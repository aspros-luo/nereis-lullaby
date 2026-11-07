class_name AftermathStorylets
extends RefCounted
## Post-festival narrative branches ("第二天余波" + visitor chain).
## Festival seeds: festival_helped / offered / refused → tendency_p_soft / tendency_t_soft
## Traces: bowl / seat / flowers / path scrap
## Chain: AF01 rest → AF02 rumor → AF06 glimpse → AF03/AF04 places → AF05/AF07 weight

var seen: Dictionary = {}

func mark(id: String) -> void:
	seen[id] = true

func has_seen(id: String) -> bool:
	return bool(seen.get(id, false))

func _p(flags: Dictionary) -> bool:
	return bool(flags.get("tendency_p_soft", false))

func _t(flags: Dictionary) -> bool:
	return bool(flags.get("tendency_t_soft", false))

func _trace_count(flags: Dictionary) -> int:
	var n := 0
	for k in ["trace_home_bowl", "trace_commons_seat", "trace_shrine_flowers", "trace_path_scrap"]:
		if bool(flags.get(k, false)):
			n += 1
	return n

func _aftermath_depth() -> int:
	var n := 0
	for k in seen.keys():
		if bool(seen[k]):
			n += 1
	return n

## Rest-driven beats.
func on_rest(segment_index: int, flags: Dictionary) -> Dictionary:
	if not bool(flags.get("festival_done", false)):
		return {}
	# AF01 — first morning after festival
	if not has_seen("AF01_morning"):
		mark("AF01_morning")
		var tail := ""
		if _p(flags) and not _t(flags):
			tail = "\n\n门外有人路过，脚步顿了一下，又走了。像想打招呼，又没想好怎么开口。"
		elif _t(flags) and not _p(flags):
			tail = "\n\n门外很安静。连鸟声都偏远。像村子把声音都收进了夜里。"
		else:
			tail = "\n\n风从窗缝进来，带着一点未散尽的甜，又很快被清晨吹淡。"
		return {
			"id": "AF01_morning",
			"text": (
				"节后的早晨比往日亮得晚一点。\n"
				+ "灶灰还温着。窗边那只空碗，不知何时被挪到了更靠里的位置。\n\n"
				+ "日子还在往前走。只是有些东西，已经不在原来的地方了。"
				+ tail
			),
		}
	# AF05 — night weight after seeing at least one object trace
	if not has_seen("AF05_night_weight"):
		if _trace_count(flags) >= 1:
			mark("AF05_night_weight")
			return {
				"id": "AF05_night_weight",
				"text": (
					"夜里躺下时，白天见过的东西会自己排好队。\n"
					+ "空碗。留白的座位。勒紧的旧花。撕剩的纸须。\n\n"
					+ "它们没有声音。\n"
					+ "可一旦排成一列，就很难假装没有看见。"
				),
			}
	# AF07 — threshold fork after enough aftermath depth (soft ending preview)
	if not has_seen("AF07_threshold") and _aftermath_depth() >= 3:
		mark("AF07_threshold")
		if _p(flags) and not _t(flags):
			return {
				"id": "AF07_threshold",
				"text": (
					"有那么一瞬间，村子像把我算进了它的呼吸里。\n"
					+ "门口的灯、公共场的空位、老婆婆没说完的那半句——\n"
					+ "都像在说：你还可以再留一天。\n\n"
					+ "这感觉很轻。轻得几乎不像是奖赏，更像是许可。"
				),
			}
		if _t(flags) and not _p(flags):
			return {
				"id": "AF07_threshold",
				"text": (
					"有那么一瞬间，村子像把我从名单上轻轻划掉。\n"
					+ "不是驱赶。是整理。\n"
					+ "像收拾节庆桌布时，把多出来的一角折进去。\n\n"
					+ "这感觉很干净。干净得让人想确认自己还站在原来的位置。"
				),
			}
		return {
			"id": "AF07_threshold",
			"text": (
				"有那么一瞬间，两种感觉叠在一起：\n"
				+ "像被留下，又像被整理。\n\n"
				+ "灯还亮着。名单不在桌上。\n"
				+ "我分不清哪一边才是真的在朝我靠近。"
			),
		}
	return {}

func beat_at_location(loc: String, flags: Dictionary) -> Dictionary:
	if not bool(flags.get("festival_done", false)):
		return {}
	# AF02 — visitor rumor (COMMONS)
	if loc == "COMMONS" and not has_seen("AF02_visitor_rumor"):
		mark("AF02_visitor_rumor")
		return {
			"id": "AF02_visitor_rumor",
			"text": (
				"公共场有人压低声音：\n"
				+ "「节后路上见过生人。不是商贩那种。」\n\n"
				+ "旁边的人嘘了一声，话题很快转去天气。\n"
				+ "像有一块布被迅速扯平，皱褶却还在。"
			),
			"learn": {"id": "visitor_rumor", "note": "有人说节后见过生人，不是商贩。"},
		}
	# AF06 — hero glimpse (PATH), needs AF02
	if loc == "PATH" and has_seen("AF02_visitor_rumor") and not has_seen("AF06_hero_glimpse"):
		mark("AF06_hero_glimpse")
		var body := (
			"路边泥里有一行偏新的脚印。\n"
			+ "步幅比村里人长一点，停过一次，又继续往林缘去了。\n\n"
		)
		if _p(flags) and not _t(flags):
			body += "脚印边缘还沾着一点干花瓣。像节庆没完全从那人鞋底离开。"
		elif _t(flags) and not _p(flags):
			body += "脚印很干净。干净得像故意不留下除了形状以外的任何东西。"
		else:
			body += "说不清那人是路过，还是在等人开口。"
		return {
			"id": "AF06_hero_glimpse",
			"text": body,
			"learn": {"id": "hero_tracks", "note": "通路有往林缘去的生人脚印。"},
		}
	# AF03 — grove signal (branch gate)
	if loc == "GROVE" and not has_seen("AF03_grove_signal"):
		if bool(flags.get("trace_path_scrap", false)) or _t(flags) or has_seen("AF06_hero_glimpse"):
			mark("AF03_grove_signal")
			var grove := (
				"林中空地比记忆中更静。\n"
				+ "有一根细枝被折成记号，新断的白茬还没氧化。\n\n"
			)
			if has_seen("AF06_hero_glimpse"):
				grove += "记号朝向与那行脚印一致。像同一个人留下的两种说法。\n\n"
			grove += "不是孩子玩的那种。\n也没有人在附近解释它是谁留下的。"
			return {
				"id": "AF03_grove_signal",
				"text": grove,
				"learn": {"id": "grove_signal", "note": "林中空地有新折的细枝记号。"},
			}
	# AF04 — clinic quiet
	if loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
		mark("AF04_clinic_quiet")
		var clinic := (
			"诊疗处的门半掩着。药瓶排得很齐。\n"
			+ "架子上多了一卷新纱布，封口还没拆。\n\n"
			+ "里面没有人。\n"
n		if _t(flags) and not _p(flags):
			clinic += "空气凉一点。像有人刚处理完什么，又把痕迹擦得很干净。"
		elif _p(flags) and not _t(flags):
			clinic += "窗边放着一只洗过的碗，还没干。像有人会回来。"
		else:
			clinic += "空气却像刚有人匆忙离开，把话留在了门槛上。"
		return {
			"id": "AF04_clinic_quiet",
			"text": clinic,
			"learn": {"id": "clinic_quiet", "note": "诊疗处有未拆封的新纱布，人却不在。"},
		}
	# AF08 — shrine re-read after traces (optional deepen)
	if loc == "SHRINE" and bool(flags.get("trace_shrine_flowers", false)) and not has_seen("AF08_shrine_reread"):
		mark("AF08_shrine_reread")
		var shrine := "角落那束旧花还在。绳子勒出的印比昨天更深一点——或者只是我看久了。\n\n"
		if bool(flags.get("festival_helped", false)) or bool(flags.get("festival_offered_food", false)):
			shrine += "有人在门口对我点了点头。很轻。像确认我还在名单能看见的那一侧。"
		elif bool(flags.get("festival_refused", false)):
			shrine += "门口经过的人目光从我身上滑开，速度太均匀，均匀得像练习过。"
		else:
			shrine += "名单仍不在桌上。翻纸的声音也没有回来。"
		return {"id": "AF08_shrine_reread", "text": shrine}
	return {}

func available_action_label(loc: String, flags: Dictionary) -> String:
	if not bool(flags.get("festival_done", false)):
		return ""
	if loc == "COMMONS" and not has_seen("AF02_visitor_rumor"):
		return "听听节后闲话"
	if loc == "PATH" and has_seen("AF02_visitor_rumor") and not has_seen("AF06_hero_glimpse"):
		return "辨认路边的脚印"
	if loc == "GROVE" and not has_seen("AF03_grove_signal"):
		if bool(flags.get("trace_path_scrap", false)) or _t(flags) or has_seen("AF06_hero_glimpse"):
			return "在空地里走走"
	if loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
		return "推开半掩的门看看"
	if loc == "SHRINE" and bool(flags.get("trace_shrine_flowers", false)) and not has_seen("AF08_shrine_reread"):
		return "再看一次旧花束"
	return ""
