extends Control
## 一周生活原型：地点探索、日常行动、关键 NPC、线索与阶段异变。

const GameStateScript = preload("res://scripts/core/game_state.gd")
const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")
const ClueJournalScript = preload("res://scripts/managers/clue_journal.gd")

const LOCATION_ORDER: Array[String] = [
	"FOREST", "GROVE", "PATH", "COMMONS", "SHRINE", "HOME", "CLINIC"
]
const ACTIVITY_LABELS: Dictionary = {
	"HOME": "整理家里",
	"COMMONS": "帮忙做些杂事",
	"SHRINE": "整理礼拜用品",
	"CLINIC": "分拣草药",
	"PATH": "采些常见草叶",
	"FOREST": "采摘野花",
	"GROVE": "坐下休息",
}
const OBSERVATION_TEXT: Dictionary = {
	"HOME": "窗边放着几本旧书，门口的花瓶里插着新鲜的枝叶。屋子里有熟悉的木头和面包香。",
	"COMMONS": "有人把篮子放在长椅边，远处传来谈笑声。每个人看起来都有忙不完的小事。",
	"SHRINE": "木台被擦得很干净，花束和折好的布料整齐摆在一旁。这里没有什么特别的地方。",
	"CLINIC": "干燥的叶片装在小罐子里，纸页上记着日期和名字。药草的气味有点苦，却让人安心。",
	"PATH": "泥土上留着浅浅的脚印。一只空篮子靠在路边，大概有人回家时忘了带走。",
	"FOREST": "树根旁长着细小的野花。枝叶间偶尔有鸟叫，风吹过时，光斑就在地上慢慢移动。",
	"GROVE": "草地柔软，几块石头被晒得暖暖的。花朵随着风轻轻摇动。",
}
const LOCATION_DESCRIPTIONS: Dictionary = {
	"HOME": "熟悉的屋子和门前小路。照料者总能把普通的一天安排得妥妥当当。",
	"COMMONS": "村民交换食物、闲聊和帮忙的地方。这里的热闹让人觉得安心。",
	"SHRINE": "村里公开举行礼拜和节庆准备的地方。木头、布料和花束都收拾得很整齐。",
	"CLINIC": "草药、干净的布和药瓶摆在架子上。医生总说，休息好比胡思乱想有用。",
	"PATH": "一条连接村庄各处的小路。有人经过，也有人把篮子暂时放在路边。",
	"FOREST": "林子比村庄安静得多。风穿过树叶时，听起来像有人在远处轻轻说话。",
	"GROVE": "树木围出一小片空地，阳光落在野花上。这里适合坐一会儿，也适合慢慢看看。"
}

var game_state
var schedule_manager
var clue_journal

var status_label: Label
var location_label: Label
var description_label: Label
var action_state_label: Label
var npc_container: VBoxContainer
var message_label: Label
var journal_label: Label
var relationship_label: Label
var action_button: Button
var observe_button: Button
var advance_button: Button
var finish_button: Button
var location_buttons: Array[Button] = []

func _ready() -> void:
	game_state = GameStateScript.new()
	schedule_manager = ScheduleManagerScript.new()
	clue_journal = ClueJournalScript.new()
	_build_ui()
	_refresh_ui()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)
	scroll.add_child(root)

	var title := Label.new()
	title.text = "蜜忒之歌｜村庄日常"
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "平常的日子里，总有许多值得记住的小事。"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(subtitle)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	root.add_child(status_label)

	var map_title := Label.new()
	map_title.text = "村庄与林地地图 · 选择一个地点"
	map_title.add_theme_font_size_override("font_size", 18)
	root.add_child(map_title)

	var map_grid := GridContainer.new()
	map_grid.columns = 3
	map_grid.add_theme_constant_override("h_separation", 8)
	map_grid.add_theme_constant_override("v_separation", 8)
	root.add_child(map_grid)
	for location_id in LOCATION_ORDER:
		var button := Button.new()
		button.text = schedule_manager.get_location_name(location_id)
		button.custom_minimum_size = Vector2(150, 38)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_location_selected.bind(location_id))
		map_grid.add_child(button)
		location_buttons.append(button)

	location_label = Label.new()
	location_label.add_theme_font_size_override("font_size", 21)
	root.add_child(location_label)

	description_label = Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(description_label)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	root.add_child(action_row)

	observe_button = Button.new()
	observe_button.text = "看看周围"
	observe_button.pressed.connect(_observe_location)
	action_row.add_child(observe_button)

	action_button = Button.new()
	action_button.text = str(ACTIVITY_LABELS.get(game_state.current_location, "做点日常的事"))
	action_button.pressed.connect(_do_daily_activity)
	action_row.add_child(action_button)

	advance_button = Button.new()
	advance_button.text = "等到下一个时段"
	advance_button.pressed.connect(_advance_time)
	action_row.add_child(advance_button)

	action_state_label = Label.new()
	action_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(action_state_label)

	var npc_title := Label.new()
	npc_title.text = "现在在这里的人"
	npc_title.add_theme_font_size_override("font_size", 18)
	root.add_child(npc_title)

	npc_container = VBoxContainer.new()
	npc_container.add_theme_constant_override("separation", 6)
	root.add_child(npc_container)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.text = "我想先在村子里走走。"
	root.add_child(message_label)

	var relationship_title := Label.new()
	relationship_title.text = "我和熟人的关系"
	relationship_title.add_theme_font_size_override("font_size", 18)
	root.add_child(relationship_title)

	relationship_label = Label.new()
	relationship_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(relationship_label)

	var journal_title := Label.new()
	journal_title.text = "线索簿"
	journal_title.add_theme_font_size_override("font_size", 20)
	root.add_child(journal_title)

	journal_label = Label.new()
	journal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journal_label.text = "暂时没有记录。我只记下自己亲眼看到的事，不急着判断原因。"
	root.add_child(journal_label)

	finish_button = Button.new()
	finish_button.text = "结束这一段日常"
	finish_button.visible = false
	finish_button.pressed.connect(_finish_demo)
	root.add_child(finish_button)

func _refresh_ui() -> void:
	var phase_label := "日常" if game_state.world_state["phase"] == "ordinary" else "村庄发生了变化"
	if game_state.world_state["phase"] == "demo_complete":
		phase_label = "序章结束"
	status_label.text = "第 %d 天 · %s · %s" % [
		game_state.day_index, game_state.get_slot_label(), phase_label
	]
	location_label.text = "我现在在：%s" % schedule_manager.get_location_name(game_state.current_location)
	description_label.text = _get_location_description(game_state.current_location)
	action_button.text = str(ACTIVITY_LABELS.get(game_state.current_location, "做点日常的事"))

	for button_index in range(location_buttons.size()):
		var location_id: String = LOCATION_ORDER[button_index]
		location_buttons[button_index].disabled = game_state.world_state["phase"] == "demo_complete"
		location_buttons[button_index].text = schedule_manager.get_location_name(location_id)

	for child in npc_container.get_children():
		npc_container.remove_child(child)
		child.queue_free()

	var present: Array = schedule_manager.get_npcs_at(
		game_state.current_location, game_state.day_index, game_state.slot_index
	)
	if present.is_empty():
		var empty_label := Label.new()
		empty_label.text = "这里暂时没有熟悉的村民。我可以看看周围、做点自己的事，或者等一会儿。"
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		npc_container.add_child(empty_label)
	else:
		for npc_id in present:
			var npc_button := Button.new()
			npc_button.text = "和%s聊聊" % schedule_manager.get_npc_name(npc_id)
			npc_button.disabled = not game_state.can_take_action()
			npc_button.pressed.connect(_talk_to_npc.bind(npc_id))
			npc_container.add_child(npc_button)

	action_button.disabled = not game_state.can_take_action()
	advance_button.disabled = game_state.world_state["phase"] != "ordinary"
	advance_button.text = "等到下一个时段" if game_state.world_state["phase"] == "ordinary" else "傍晚的时间停住了"
	observe_button.disabled = game_state.world_state["phase"] == "demo_complete"
	if game_state.world_state["phase"] == "ordinary":
		action_state_label.text = "每个时段可以安排一项主要活动。换地点和观察不消耗这项行动。"
	elif game_state.world_state["phase"] == "after_week":
		action_state_label.text = "村庄变得有些不同。我可以继续走访熟悉的地方，看看哪些细节变了。"
	else:
		action_state_label.text = "这一段故事暂时告一段落。线索和关系记录都保留在本次游玩中。"

	relationship_label.text = "照料者：%d    礼拜主持者：%d    医生：%d" % [
		game_state.relationship_state["caregiver"],
		game_state.relationship_state["worship_leader"],
		game_state.relationship_state["doctor"],
	]

	var journal_entries: Array[Dictionary] = clue_journal.get_entries()
	if journal_entries.is_empty():
		journal_label.text = "暂时没有记录。我只记下自己亲眼看到的事，不急着判断原因。"
	else:
		var lines: PackedStringArray = []
		for entry in journal_entries:
			lines.append("第 %d 天 · %s · %s\n%s\n%s" % [
				entry["day"], entry["slot"], entry["location"], entry["title"], entry["detail"]
			])
		journal_label.text = "\n\n".join(lines)

	finish_button.visible = (
		game_state.world_state["phase"] == "after_week"
		and game_state.investigation_state["visited_after_anomaly"].size() >= 3
	)

func _get_location_description(location_id: String) -> String:
	var description := str(LOCATION_DESCRIPTIONS.get(location_id, "这里很安静。"))
	if game_state.world_state["phase"] == "after_week":
		match location_id:
			"HOME":
				description += "\n门边的花束不知何时换了方向，像是有人特意整理过。"
			"SHRINE":
				description += "\n礼拜用的布料已经收起，木台上却留下了一圈浅浅的潮痕。"
			"FOREST":
				description += "\n林子里没有风，树叶却轻轻碰撞着。远处的鸟鸣忽然停了。"
			"GROVE":
				description += "\n野花仍然开着，只是空地中央多出一块没有沾上露水的泥土。"
			"CLINIC":
				description += "\n医生把几份记录重新叠在一起，看到我时又把它们收进抽屉。"
	return description

func _on_location_selected(location_id: String) -> void:
	if game_state.world_state["phase"] == "demo_complete":
		return
	game_state.current_location = location_id
	game_state.mark_post_anomaly_visit(location_id)
	message_label.text = "我来到了%s。" % schedule_manager.get_location_name(location_id)
	if game_state.world_state["phase"] == "after_week":
		message_label.text += " 这里好像和之前有些不一样。"
	_refresh_ui()

func _advance_time() -> void:
	if game_state.world_state["phase"] == "demo_complete":
		return
	var was_ordinary: bool = game_state.world_state["phase"] == "ordinary"
	game_state.advance_time()
	if was_ordinary and game_state.world_state["phase"] == "after_week":
		message_label.text = "远处忽然传来一声沉闷的鸣响。它很快消失，村庄却安静得有些不寻常。"
		clue_journal.add_fact(
			"day7_village_change",
			"一声从远处传来的鸣响",
			"傍晚时，远处传来一声沉闷的鸣响。没有人解释它从哪里来；村庄很快恢复安静，但安静得让人有些在意。",
			game_state.day_index,
			game_state.get_slot_label(),
			schedule_manager.get_location_name(game_state.current_location)
		)
		game_state.register_fact("day7_village_change")
	else:
		message_label.text = "时段过去了。村里的人也继续忙着各自的事。"
	_refresh_ui()

func _observe_location() -> void:
	if game_state.world_state["phase"] == "demo_complete":
		return
	if game_state.world_state["phase"] == "after_week":
		game_state.mark_post_anomaly_visit(game_state.current_location)
		var added_after := _record_anomaly_clue_if_available(game_state.current_location)
		message_label.text = "我仔细看了看周围。" if not added_after else "我发现了一处不太寻常的细节。（线索簿已更新。）"
		_refresh_ui()
		return

	var added := false
	if game_state.day_index >= 5 and game_state.current_location == "SHRINE":
		added = _add_fact(
			"day5_repeated_object_shrine", "礼拜场所里的普通物件",
			"我注意到一种普通物件被仔细摆放。它的用途目前并不明确，也可能只是日常用品。"
		)
	elif game_state.day_index >= 5 and game_state.current_location == "COMMONS":
		added = _add_fact(
			"day5_repeated_object_commons", "公共空间里的相似准备",
			"这里也出现了与其他场景相似的准备方式。重复本身值得记下，但还不能说明原因。"
		)
	elif game_state.current_location == "FOREST" or game_state.current_location == "GROVE":
		added = _add_fact(
			"forest_flower_observation", "林间的野花",
			"林边长着几簇野花，花茎被折下的地方很整齐。也许只是有人采花时留下的痕迹。"
		)
	message_label.text = "线索簿更新了。这件事也许有普通的解释。" if added else "我没发现新的明确线索，但这里还有值得慢慢看的地方。"
	_refresh_ui()

func _do_daily_activity() -> void:
	if not game_state.can_take_action():
		return
	var action_id := "activity_" + game_state.current_location.to_lower()
	var activity_text := ""
	match game_state.current_location:
		"HOME":
			activity_text = "我整理了家里的东西，又把门前的花瓶换了水。"
			if _npc_is_present("caregiver"):
				game_state.increase_relationship("caregiver")
		"COMMONS":
			activity_text = "我帮忙收拾公共空间，和路过的村民说了几句话。"
			if _npc_is_present("caregiver"):
				game_state.increase_relationship("caregiver")
		"SHRINE":
			activity_text = "我帮忙把布料和花束摆整齐。大家看起来都很满意。"
			if _npc_is_present("worship_leader"):
				game_state.increase_relationship("worship_leader")
		"CLINIC":
			activity_text = "我帮忙分拣干燥的草药，屋里都是淡淡的苦香。"
			if _npc_is_present("doctor"):
				game_state.increase_relationship("doctor")
		"PATH":
			activity_text = "我沿着小路采了些常见的草叶，准备带回家。"
		"FOREST":
			activity_text = "我采了几朵颜色好看的野花。树影很安静，我忍不住多待了一会儿。"
			_add_fact("forest_flower_picked", "带回家的野花", "我在林子里采了几朵野花。花茎上有细小的水珠，闻起来带着雨后的气味。")
		"GROVE":
			activity_text = "我在空地上坐了一会儿，听树叶和鸟儿的声音。"
	if game_state.take_action(action_id, activity_text):
		message_label.text = activity_text
	_refresh_ui()

func _talk_to_npc(npc_id: String) -> void:
	if not game_state.can_take_action():
		return
	var reply := _get_daily_dialogue(npc_id)
	var fact_added := false
	if game_state.world_state["phase"] == "after_week":
		match npc_id:
			"caregiver":
				reply = "照料者照常关心我有没有吃饭。说到傍晚那声鸣响时，她停了一下，只说也许是远处的旧钟。"
			"worship_leader":
				reply = "礼拜主持者说村里一切都好，但他把原本放在桌上的木盒收了起来。"
			"doctor":
				reply = "医生说大家可能只是累了。他把几页记录压在手下，没有继续说下去。"
	else:
		if npc_id == "doctor" and game_state.day_index >= 3 and game_state.current_location == "CLINIC":
			fact_added = _add_fact(
				"day3_similar_sleep_reports", "相似的睡眠困扰",
				"医生提到有几位居民最近睡得不太好，也做过相似的梦。压力或普通疾病也可能造成这种情况。"
			)
			reply = "医生提到最近有几位居民睡得不太好，但认为目前还不能确定原因。"
		elif npc_id == "caregiver" and game_state.day_index >= 4 and game_state.current_location == "HOME":
			fact_added = _add_fact(
				"day4_caregiver_custom", "关于习俗的日常解释",
				"照料者把某项安排解释为村里沿用已久的生活习惯。她说得很自然，没有表现出自己在揭露秘密。"
			)
			reply = "照料者说这只是村里一直沿用的习惯，还问我晚饭想吃什么。"
		elif npc_id == "worship_leader" and game_state.day_index >= 4 and game_state.current_location == "SHRINE":
			fact_added = _add_fact(
				"day4_worship_custom", "关于习俗的公共解释",
				"礼拜主持者从公共传统和社区秩序的角度解释了类似安排。与另一种说法的差异值得比较，但并不能证明有人撒谎。"
			)
			reply = "礼拜主持者把类似安排解释为维护公共传统的一部分。"
		if npc_id == "doctor" and game_state.day_index >= 6 and game_state.current_location == "CLINIC":
			fact_added = _add_fact(
				"day6_date_discrepancy", "病患记得的日期并不一致",
				"几位病患对不适开始的时间记忆不同。压力、记忆偏差或其他普通因素都可能解释差异。"
			) or fact_added
			reply += " 医生还发现，几位病患记得的日期并不一致。"

	if not game_state.take_action("talk_" + npc_id, "与" + schedule_manager.get_npc_name(npc_id) + "交谈"):
		return
	game_state.increase_relationship(npc_id)
	message_label.text = reply
	if fact_added:
		message_label.text += "（线索簿已更新。）"
	_refresh_ui()

func _get_daily_dialogue(npc_id: String) -> String:
	var day := game_state.day_index
	match npc_id:
		"caregiver":
			if day == 1:
				return "你醒啦？我把面包放在桌上了。今天不用急，天气不错，想去哪儿走走都行。"
			if day == 2:
				return "窗边的花开得真好。你小时候也总喜欢把路边的小花带回来。"
			if day <= 4:
				return "村里的人都互相照应着，日子就能过得安稳些。你也别忘了照顾自己。"
			return "最近大家似乎都睡得不太好。大概是天气变化吧，等过几天就好了。"
		"worship_leader":
			if day <= 2:
				return "早晨好。礼拜一直是村里人聚在一起的机会，谁有空就来帮一点忙。"
			if day <= 4:
				return "有些习俗流传了很久，未必每个人都记得最初的缘由。重要的是大家仍愿意一起做。"
			return "准备工作都很顺利。大家各自做一点，最后就能把事情安排妥当。"
		"doctor":
			if day <= 2:
				return "药草晒得差不多了。最近没有什么大病，大家只是偶尔累着，休息一下就好。"
			if day <= 5:
				return "这几天来诊疗处的人多了一点，不过症状都不严重。我还在整理他们的记录。"
			return "我正在核对几份记录。日期有些对不上，也许只是病人记错了，先不能急着下结论。"
	return "我们聊了些日常琐事。对方没有提到什么特别的事。"

func _npc_is_present(npc_id: String) -> bool:
	return schedule_manager.get_location(
		npc_id, game_state.day_index, game_state.slot_index
	) == game_state.current_location

func _add_fact(fact_id: String, title: String, detail: String) -> bool:
	var added: bool = clue_journal.add_fact(
		fact_id, title, detail, game_state.day_index, game_state.get_slot_label(),
		schedule_manager.get_location_name(game_state.current_location)
	)
	if added:
		game_state.register_fact(fact_id)
	return added

func _record_anomaly_clue_if_available(location_id: String) -> bool:
	var fact_id := ""
	var title := ""
	var detail := ""
	match location_id:
		"HOME":
			fact_id = "after_anomaly_home"
			title = "门前花束的方向"
			detail = "门边的花束换了方向。照料者平时很会整理东西，也许是她顺手调整过。"
		"SHRINE":
			fact_id = "after_anomaly_shrine"
			title = "木台上的潮痕"
			detail = "木台上留着一圈浅浅的潮痕，但屋顶没有漏水，附近也没有打翻的水盆。"
		"FOREST":
			fact_id = "after_anomaly_forest"
			title = "忽然停下的鸟鸣"
			detail = "林子里的鸟鸣忽然停了片刻。过了一会儿，声音又慢慢回来了。"
		"GROVE":
			fact_id = "after_anomaly_grove"
			title = "没有露水的泥土"
			detail = "空地中央有一小块泥土没有沾上露水，边缘却没有明显的脚印。"
		"CLINIC":
			fact_id = "after_anomaly_clinic"
			title = "被收起的记录"
			detail = "医生把几份记录收进抽屉。也许是病人的隐私，不方便让人看见。"
	if fact_id.is_empty():
		return false
	return _add_fact(fact_id, title, detail)

func _finish_demo() -> void:
	game_state.complete_demo()
	message_label.text = "第一段故事结束了。村庄依旧是熟悉的村庄，但有些小事已经无法像从前那样轻易解释。"
	_refresh_ui()
