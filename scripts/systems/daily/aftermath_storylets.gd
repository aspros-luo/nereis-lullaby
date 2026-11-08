class_name AftermathStorylets
extends RefCounted
## Post-festival branches + Hero AF09/AF10 + AF11 soft ending threshold.
## Chain: AF02 → AF06 → AF09 → AF10 → AF11 soft ending threshold

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

func _hero_ready_for_second() -> bool:
	return has_seen("AF09_hero_talk") and (has_seen("AF09_hero_echo") or _aftermath_depth() >= 5)

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
					+ "只是把「还可以再问一次」这种感觉，留在了空地的空气里。\n\n"
					+ "——若他还来，会在更深一点的林缘。"
				),
			}
		if _t(flags) and not _p(flags):
			return {
				"id": "AF09_hero_echo",
				"text": (
					"闭上眼时，那人的脸比树影更清楚一点。\n"
					+ "他没有要我跟上去。\n"
					+ "可「你已经被看见了」这件事，比任何嘱咐都难推开。\n\n"
					+ "——他说过：来找我。林缘会有记号。"
				),
			}
		return {
			"id": "AF09_hero_echo",
			"text": (
				"闭上眼时，树影和那人的轮廓叠了一会儿。\n"
				+ "像有人把门推开一条缝，又没有真正走进来。\n\n"
				+ "风里像有一句未说完的：还会来。"
			),
		}
	if has_seen("AF10_hero_second") and not has_seen("AF10_hero_after"):
		mark("AF10_hero_after")
		if bool(flags.get("hero_offer_leave", false)):
			return {
				"id": "AF10_hero_after",
				"text": (
					"夜里很安静。\n"
					+ "他给过的方向还在——不是路标，是一种「可以不站在桌子这边」的可能。\n\n"
					+ "村子的灯仍亮着。两件事同时为真，让人睡不沉，也并不想立刻醒来。"
				),
			}
		if bool(flags.get("hero_ask_name", false)):
			return {
				"id": "AF10_hero_after",
				"text": (
					"名字没有换到手。\n"
					+ "他只说：名字是最后才该交换的东西。\n\n"
					+ "可被拒绝的感觉并不空。像有人把一只碗倒扣着放下，说里面以后会有。"
				),
			}
		return {
			"id": "AF10_hero_after",
			"text": (
				"第二次见面之后，林缘的风都像经过对质。\n"
				+ "我仍住在村里。他仍在外面。\n"
				+ "中间那条线，比任何名单都清楚一点了。"
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
	if not has_seen("AF11_ending_soft") and (has_seen("AF07_threshold") or has_seen("AF10_hero_after") or _aftermath_depth() >= 6):
		mark("AF11_ending_soft")
		var dims: Dictionary = EndingResolver.estimate_dims(flags, 0, _aftermath_depth())
		var result: Dictionary = EndingResolver.resolve(dims)
		var preview: String = EndingResolver.soft_preview_line(dims)
		var body := (
			"夜里有一段时间什么声音都没有。\n"
			+ "像有人把两种结局都放在枕边，等我选一个先拿起来。\n\n"
			+ "——此刻更近的是：「" + preview + "」\n\n"
			+ str(result.get("text", ""))
			+ "\n\n（这是 demo 软结算。完整结局页可在此基础上换皮。）"
		)
		return {
			"id": "AF11_ending_soft",
			"text": body,
			"ending": str(result.get("id", "")),
			"ending_label": str(result.get("label", "")),
			"set_flag": "ending_soft_seen",
		}
	if has_seen("AF11_ending_soft") and not has_seen("AF12_after_ending"):
		mark("AF12_after_ending")
		return {
			"id": "AF12_after_ending",
			"text": (
				"结算过后的夜里，灶灰仍温。\n"
				+ "没有鼓声，也没有人在窗外站着。\n\n"
				+ "我把碗叠好。日子还要过——\n"
				+ "只是有些路，已经知道自己不会再走第二次。"
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
	if loc == "FOREST" and _hero_ready_for_second() and not has_seen("AF10_hero_second"):
		mark("AF10_hero_second")
		return _hero_second_beat(flags)
	if loc == "FOREST" and has_seen("AF10_hero_second") and not has_seen("AF10_hero_choice"):
		mark("AF10_hero_choice")
		return _hero_second_choice(flags)
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
	if loc == "HOME" and not has_seen("AF11_ending_soft") and (has_seen("AF07_threshold") or has_seen("AF10_hero_after") or _aftermath_depth() >= 5):
		mark("AF11_ending_soft")
		var dims2: Dictionary = EndingResolver.estimate_dims(flags, 0, _aftermath_depth())
		var result2: Dictionary = EndingResolver.resolve(dims2)
		var preview2: String = EndingResolver.soft_preview_line(dims2)
		return {
			"id": "AF11_ending_soft",
			"text": (
				"我把这一段日子在心里过了一遍。\n"
				+ "灶、公共场、名单、林缘——它们不再只是地点。\n\n"
				+ "——此刻更近的是：「" + preview2 + "」\n\n"
				+ str(result2.get("text", ""))
				+ "\n\n（demo 软结算）"
			),
			"ending": str(result2.get("id", "")),
			"ending_label": str(result2.get("label", "")),
			"set_flag": "ending_soft_seen",
		}
	if loc == "HOME" and has_seen("AF11_ending_soft") and not has_seen("AF12_after_ending"):
		mark("AF12_after_ending")
		return {
			"id": "AF12_after_ending",
			"text": (
				"我把空碗洗干净，倒扣在架上。\n"
				+ "窗边没有新的花瓣。\n\n"
				+ "外面有人走过，脚步没有停。\n"
				+ "——日子还在往前。我还在这里。"
			),
		}
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

func _hero_second_beat(flags: Dictionary) -> Dictionary:
	var open := (
		"林缘比空地更深一寸。树把天割成细条。\n\n"
		+ "他已经在那里。\n"
		+ "像知道我会来，又像无论谁来他都会站到天黑。\n\n"
		+ "外来人\n"
		+ "「你来了。」\n\n"
		+ "不是惊喜。是点名。\n\n"
	)
	if _trace_count(flags) >= 3:
		open += (
			"外来人\n"
			+ "「痕迹你看得够多了。再多，就会有人开始问你为什么看。」\n\n"
			+ "他抬了抬下巴，指向村子反方向一条几乎看不见的缝。\n\n"
			+ "外来人\n"
			+ "「有一条不登记的路。不是逃跑。是换一种站法。」\n\n"
			+ "外来人\n"
			+ "「我不能替你选。我只能把缝指给你。」\n\n"
			+ "风停了一拍。他仍看着我，等我开口——或不开口。"
		)
	elif _t(flags) and not _p(flags):
		open += (
			"外来人\n"
			+ "「整理还在继续。名单会越来越薄。」\n\n"
			+ "外来人\n"
			+ "「你若要走，现在比以后干净。」\n\n"
			+ "他没有伸手。只把一条不被踩实的土路，用目光量了一遍。\n\n"
			+ "外来人\n"
			+ "「跟不跟，你说。」"
		)
	elif _p(flags) and not _t(flags):
		open += (
			"外来人\n"
			+ "「他们还愿意为你留灯。这不是坏事。」\n\n"
			+ "外来人\n"
			+ "「可灯也有罩。罩会让你看不清谁在外面等。」\n\n"
			+ "他难得停顿得更长一点。\n\n"
			+ "外来人\n"
			+ "「你仍可留下。我只问：留下的时候，眼睛要不要还睁着。」"
		)
	else:
		open += (
			"外来人\n"
			+ "「第二次见面，就该谈一点真的。」\n\n"
			+ "外来人\n"
			+ "「村子用节庆把人按进位子。有人适合位子。有人适合缝。」\n\n"
			+ "外来人\n"
			+ "「你站在中间太久了。中间最容易被两边同时使用。」\n\n"
			+ "他等待。像把选择权完整地放在我手里。"
		)
	return {
		"id": "AF10_hero_second",
		"portrait": "外来人",
		"text": open,
		"learn": {"id": "hero_second", "note": "在林缘再次见到外来人，他谈到路与选择。"},
		"set_flag": "hero_second_met",
	}

func _hero_second_choice(flags: Dictionary) -> Dictionary:
	var text := ""
	var flag := ""
	var note := ""
	if _trace_count(flags) >= 3 or (_t(flags) and not _p(flags)):
		flag = "hero_offer_leave"
		note = "外来人为我指出一条不登记的路；去留仍由我定。"
		text = (
			"「那条缝，我记住了。」\n\n"
			+ "外来人\n"
			+ "「记住就够。走的那天，不必跟任何人告别得太完整。」\n\n"
			+ "他第一次几乎像笑了一下，又收住。\n\n"
			+ "外来人\n"
			+ "「若你留下，也把缝留在心里。有人会来擦掉它。」\n\n"
			+ "外来人\n"
			+ "「我的名字——等你不再需要靠它才站稳时，再换。」\n\n"
			+ "人影没入更深的林。土路上只剩我们的两种脚印，有一阵风，又只剩一种。"
		)
	elif _p(flags) and not _t(flags):
		flag = "hero_stay_watch"
		note = "我选择暂时留下；外来人要我把眼睛睁着。"
		text = (
			"「我还不能走。家里还有灯。」\n\n"
			+ "外来人\n"
			+ "「那就留下。把灯看清楚是谁点的。」\n\n"
			+ "外来人\n"
			+ "「被需要，和被使用，有时共用同一张笑脸。」\n\n"
			+ "他退半步，把林缘重新让给夜色。\n\n"
			+ "外来人\n"
			+ "「你若哪天分清了，林缘还在。我也会在——不一定总在同一棵树下。」\n\n"
			+ "这一次他走得更慢。像留给我追问的余地，又像确信我暂时不会追。"
		)
	else:
		flag = "hero_ask_name"
		note = "我问了名字；他说名字是最后才交换的东西。"
		text = (
			"「你叫什么？」\n\n"
			+ "外来人\n"
			+ "「名字是最后才该交换的东西。」\n\n"
			+ "外来人\n"
			+ "「你还在用别人的称呼活着。先把自己的位子看穿。」\n\n"
			+ "并不算拒绝。更像延期。\n\n"
			+ "外来人\n"
			+ "「下次若还见，带一件你自己选的东西来。不是礼物。是证据。」\n\n"
			+ "「证据你还在问自己的问题。」\n\n"
			+ "林重新合上。我手里空着，却比来时重一点。"
		)
	return {
		"id": "AF10_hero_choice",
		"portrait": "外来人",
		"text": text,
		"learn": {"id": "hero_second_choice", "note": note},
		"set_flag": flag,
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
	if loc == "FOREST" and _hero_ready_for_second() and not has_seen("AF10_hero_second"):
		return "赴林缘之约"
	if loc == "FOREST" and has_seen("AF10_hero_second") and not has_seen("AF10_hero_choice"):
		return "回应他"
	if loc == "GROVE" and not has_seen("AF03_grove_signal"):
		if bool(flags.get("trace_path_scrap", false)) or _t(flags) or has_seen("AF06_hero_glimpse"):
			return "在空地里走走"
	if loc == "CLINIC" and not has_seen("AF04_clinic_quiet"):
		return "推开半掩的门看看"
	if loc == "SHRINE" and bool(flags.get("trace_shrine_flowers", false)) and not has_seen("AF08_shrine_reread"):
		return "再看一次旧花束"
	if loc == "HOME" and bool(flags.get("festival_done", false)) and not has_seen("AF11_ending_soft") and (has_seen("AF07_threshold") or has_seen("AF10_hero_after") or _aftermath_depth() >= 5):
		return "整理这一段日子"
	return ""
