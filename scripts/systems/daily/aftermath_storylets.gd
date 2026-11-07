class_name AftermathStorylets
extends RefCounted
## Post-festival "第二天余波" beats. Triggered by rest / location after festival_done.

var seen: Dictionary = {}

func mark(id: String) -> void:
	seen[id] = true

func has_seen(id: String) -> bool:
	return bool(seen.get(id, false))

## Called after rest advances segment when festival is done.
## Returns { "id", "text", "learn": {id, note} optional } or empty.
func on_rest(segment_index: int, flags: Dictionary) -> Dictionary:
	if not bool(flags.get("festival_done", false)):
		return {}
	if not has_seen("AF01_morning"):
		mark("AF01_morning")
		var p := bool(flags.get("tendency_p_soft", false))
		var t := bool(flags.get("tendency_t_soft", false))
		var tail := ""
		if p and not t:
			tail = "\n\n门外有人路过，脚步顿了一下，又走了。像想打招呼，又没想好怎么开口。"
		elif t and not p:
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
	if segment_index >= 1 and not has_seen("AF05_night_weight"):
		if bool(flags.get("trace_home_bowl", false)) or bool(flags.get("trace_commons_seat", false)):
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
	return {}

func beat_at_location(loc: String, flags: Dictionary) -> Dictionary:
	if not bool(flags.get("festival_done", false)):
		return {}
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
	if loc == "GROVE" and not has_seen("AF03_grove_signal"):
		if bool(flags.get("trace_path_scrap", false)) or bool(flags.get("tendency_t_soft", false)):
			mark("AF03_grove_signal")
			return {
				"id": "AF03_grove_signal",
				"text": (
					"林中空地比记忆中更静。\n"
					+ "有一根细枝被折成记号，新断的白茬还没氧化。\n\n"
					+ "不是孩子玩的那种。\n"
					+ "也没有人在附近解释它是谁留下的。"
				),
				"learn": {"id": "grove_signal", "note": "林中空地有新折的细枝记号。"},
			}
	if loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
		mark("AF04_clinic_quiet")
		return {
			"id": "AF04_clinic_quiet",
			"text": (
				"诊疗处的门半掩着。药瓶排得很齐。\n"
				+ "架子上多了一卷新纱布，封口还没拆。\n\n"
				+ "里面没有人。\n"
				+ "空气却像刚有人匆忙离开，把话留在了门槛上。"
			),
			"learn": {"id": "clinic_quiet", "note": "诊疗处有未拆封的新纱布，人却不在。"},
		}
	return {}

func available_action_label(loc: String, flags: Dictionary) -> String:
	if not bool(flags.get("festival_done", false)):
		return ""
	if loc == "COMMONS" and not has_seen("AF02_visitor_rumor"):
		return "听听节后闲话"
	if loc == "GROVE" and not has_seen("AF03_grove_signal"):
		if bool(flags.get("trace_path_scrap", false)) or bool(flags.get("tendency_t_soft", false)):
			return "在空地里走走"
	if loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
		return "推开半掩的门看看"
	return ""
