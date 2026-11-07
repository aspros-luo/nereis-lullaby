class_name AftermathStorylets
extends RefCounted
## Post-festival narrative branches + Hero face-to-face short event (AF09).
## Chain: AF02 rumor → AF06 tracks → AF09 meet/talk at GROVE → AF03 may reference him

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

func on_rest(segment_index: int, flags: Dictionary) -> Dictionary:
	if not bool(flags.get("festival_done", false)):
		return {}
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
	if has_seen("AF09_hero_talk") and not has_seen("AF09_hero_echo"):
		mark("AF09_hero_echo")
		if _p(flags) and not _t(flags):
			return {
				"id": "AF09_hero_echo",
				"text": (
					"闭上眼时，还能看见那人站在树影里的样子。\n"
					+ "他没有要我跟上去。\n"
					+ "只是把「还可以再问一次」这种感觉，留在了空地的空气里。"
				),
			}
		if _t(flags) and not _p(flags):
			return {
				"id": "AF09_hero_echo",
				"text": (
					"闭上眼时，那人的脸比树影更清楚一点。\n"
					+ "他没有要我跟上去。\n"
					+ "可「你已经被看见了」这件事，比任何嘱咐都难推开。"
				),
			}
		return {
			"id": "AF09_hero_echo",
			"text": (
				"闭上眼时，树影和那人的轮廓叠了一会儿。\n"
				+ "像有人把门推开一条缝，又没有真正走进来。"
			),
		}
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
	if loc == "GROVE" and has_seen("AF06_hero_glimpse") and not has_seen("AF09_hero_meet"):
		mark("AF09_hero_meet")
		return {
			"id": "AF09_hero_meet",
			"portrait": "外来人",
			"text": (
				"空地那头的树影里站着一个人。\n\n"
				+ "不是村民的站法。肩背很稳，手是空的，却不像迷路。\n"
				+ "风从他身侧过去时，叶子响了一下，他又不动了。\n\n"
				+ "他看见了我。\n"
				+ "没有躲，也没有先开口。\n\n"
				+ "只是点了点头——幅度很小，像确认一件早就料到的事。"
			),
			"learn": {"id": "hero_face", "note": "在林中空地见到了那个外来人。"},
		}
	if loc == "GROVE" and has_seen("AF09_hero_meet") and not has_seen("AF09_hero_talk"):
		mark("AF09_hero_talk")
		return _hero_talk_beat(flags)
	if loc == "GROVE" and not has_seen("AF03_grove_signal"):
		if bool(flags.get("trace_path_scrap", false)) or _t(flags) or has_seen("AF06_hero_glimpse"):
			mark("AF03_grove_signal")
			var grove := (
				"林中空地比记忆中更静。\n"
				+ "有一根细枝被折成记号，新断的白茬还没氧化。\n\n"
			)
			if has_seen("AF09_hero_meet"):
				grove += "记号离他刚才站的位置不远。像他留下的，又像他在看谁留下的。\n\n"
			elif has_seen("AF06_hero_glimpse"):
				grove += "记号朝向与那行脚印一致。像同一个人留下的两种说法。\n\n"
			grove += "不是孩子玩的那种。\n也没有人在附近解释它是谁留下的。"
			return {
				"id": "AF03_grove_signal",
				"text": grove,
				"learn": {"id": "grove_signal", "note": "林中空地有新折的细枝记号。"},
			}
	if loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
		mark("AF04_clinic_quiet")
		var clinic := (
			"诊疗处的门半掩着。药瓶排得很齐。\n"
			+ "架子上多了一卷新纱布，封口还没拆。\n\n"
			+ "里面没有人。\n"
		)
		if _t(flags) and not _p(flags):
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

func _hero_talk_beat(flags: Dictionary) -> Dictionary:
	var traces := _trace_count(flags)
	var text := ""
	var learn_note := "与林缘的外来人说了几句话。"
	if traces >= 2:
		text = (
			"我把空碗、留白、旧花和纸须，一件一件说得很慢。\n\n"
			+ "外来人\n"
			+ "「你看见了。」\n\n"
			+ "不是惊讶。像在核对清单。\n\n"
			+ "外来人\n"
			+ "「看见和说出来，不是同一件事。你已经做了后一件。」\n\n"
			+ "他看向村子的方向，又收回目光。\n\n"
			+ "外来人\n"
			+ "「我还会来。若你还愿意站在能被问到的地方。」\n\n"
			+ "说完，他退回树影里。脚步很轻，像不愿惊动名单上的字。"
		)
		learn_note = "外来人确认了我看见的痕迹，并说还会再来。"
	elif _p(flags) and not _t(flags):
		text = (
			"「你也是来过节的吗？」\n\n"
			+ "外来人\n"
			+ "「站在外面的那种。」\n\n"
			+ "他顿了顿，声线仍低：\n\n"
			+ "外来人\n"
			+ "「有人被留下，是因为被需要。有人被留下，是因为还没被算完。」\n\n"
			+ "外来人\n"
			+ "「你像后一种——目前。」\n\n"
			+ "风起时，他已经侧过身。\n\n"
			+ "外来人\n"
			+ "「别急着选边。先分清：谁在叫你的名字，谁在擦掉它。」"
		)
		learn_note = "外来人暗示我尚未被「算完」，并提醒分清呼唤与擦除。"
	elif _t(flags) and not _p(flags):
		text = (
			"他先开口。\n\n"
			+ "外来人\n"
			+ "「他们开始整理了。」\n\n"
			+ "不是问句。\n\n"
			+ "外来人\n"
			+ "「被划掉的人，有时比被留下的人更清楚桌子长什么样。」\n\n"
			+ "他看了我的手，又看向通路。\n\n"
			+ "外来人\n"
			+ "「你若还想从里面走出来，别独自去对名单。来找我。」\n\n"
			+ "树影合拢时，人已经不在。只留下那句不像安慰的嘱咐。"
		)
		learn_note = "外来人说村子在「整理」，并要我别独自去对名单。"
	else:
		text = (
			"我们站了很久，久到一只鸟从空地对面飞走。\n\n"
			+ "外来人\n"
			+ "「你还在看。」\n\n"
			+ "我点头。\n\n"
			+ "外来人\n"
			+ "「那就继续看。看到能说出哪一口锅是空的、哪一个座位不能坐为止。」\n\n"
			+ "外来人\n"
			+ "「到那时，我们再谈名字。」\n\n"
			+ "他离开时没有回头。空地重新变得很大，大得像什么都没发生过。"
		)
		learn_note = "外来人要我继续看，直到能指认空位与空锅。"
	return {
		"id": "AF09_hero_talk",
		"portrait": "外来人",
		"text": text,
		"learn": {"id": "hero_spoken", "note": learn_note},
		"set_flag": "hero_met",
	}

func available_action_label(loc: String, flags: Dictionary) -> String:
	if not bool(flags.get("festival_done", false)):
		return ""
	if loc == "COMMONS" and not has_seen("AF02_visitor_rumor"):
		return "听听节后闲话"
	if loc == "PATH" and has_seen("AF02_visitor_rumor") and not has_seen("AF06_hero_glimpse"):
		return "辨认路边的脚印"
	if loc == "GROVE" and has_seen("AF06_hero_glimpse") and not has_seen("AF09_hero_meet"):
		return "沿着脚印走进空地"
	if loc == "GROVE" and has_seen("AF09_hero_meet") and not has_seen("AF09_hero_talk"):
		return "上前说话"
	if loc == "GROVE" and not has_seen("AF03_grove_signal"):
		if bool(flags.get("trace_path_scrap", false)) or _t(flags) or has_seen("AF06_hero_glimpse"):
			return "在空地里走走"
	if loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
		return "推开半掩的门看看"
	if loc == "SHRINE" and bool(flags.get("trace_shrine_flowers", false)) and not has_seen("AF08_shrine_reread"):
		return "再看一次旧花束"
	return ""
