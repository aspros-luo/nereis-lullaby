extends Control
## 无素材文字冒险原型：自由移动地点、查看 NPC 日程、推进时间并记录玩家见闻。

const GameStateScript = preload("res://scripts/core/game_state.gd")
const ScheduleManagerScript = preload("res://scripts/managers/npc_schedule_manager.gd")
const ClueJournalScript = preload("res://scripts/managers/clue_journal.gd")

const LOCATION_ORDER: Array[String] = ["HOME", "COMMONS", "SHRINE", "CLINIC", "PATH"]

var game_state
var schedule_manager
var clue_journal

var status_label: Label
var location_label: Label
var npc_container: VBoxContainer
var message_label: Label
var journal_label: Label

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
	root.add_theme_constant_override("separation", 12)
	scroll.add_child(root)

	var title := Label.new()
	title.text = "蜜忒之歌｜村庄日常原型"
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "原型内容仅用于验证日程、探索与线索记录；隐藏真相不会自动写入蜜忒的认知。"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(subtitle)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 18)
	root.add_child(status_label)

	var location_title := Label.new()
	location_title.text = "前往地点"
	location_title.add_theme_font_size_override("font_size", 18)
	root.add_child(location_title)

	var location_row := HBoxContainer.new()
	location_row.add_theme_constant_override("separation", 8)
	root.add_child(location_row)
	for location_id in LOCATION_ORDER:
		var button := Button.new()
		button.text = schedule_manager.get_location_name(location_id)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_location_selected.bind(location_id))
		location_row.add_child(button)

	location_label = Label.new()
	location_label.add_theme_font_size_override("font_size", 20)
	root.add_child(location_label)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	root.add_child(action_row)

	var observe_button := Button.new()
	observe_button.text = "观察当前地点"
	observe_button.pressed.connect(_observe_location)
	action_row.add_child(observe_button)

	var advance_button := Button.new()
	advance_button.text = "推进到下一时段"
	advance_button.pressed.connect(_advance_time)
	action_row.add_child(advance_button)

	var npc_title := Label.new()
	npc_title.text = "此时在场的人"
	npc_title.add_theme_font_size_override("font_size", 18)
	root.add_child(npc_title)

	npc_container = VBoxContainer.new()
	npc_container.add_theme_constant_override("separation", 6)
	root.add_child(npc_container)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.text = "我可以自由探索村庄。"
	root.add_child(message_label)

	var journal_title := Label.new()
	journal_title.text = "线索簿"
	journal_title.add_theme_font_size_override("font_size", 20)
	root.add_child(journal_title)

	journal_label = Label.new()
	journal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journal_label.text = "暂时没有记录。我只记下自己亲眼观察到的内容，不急着判断真相。"
	root.add_child(journal_label)

func _refresh_ui() -> void:
	status_label.text = "第 %d 天 · %s · 世界阶段：%s" % [
		game_state.day_index,
		game_state.get_slot_label(),
		"日常" if game_state.world_state["phase"] == "ordinary" else "第一周结束",
	]
	location_label.text = "我现在在：%s" % schedule_manager.get_location_name(game_state.current_location)

	for child in npc_container.get_children():
		npc_container.remove_child(child)
		child.queue_free()

	var present: Array = schedule_manager.get_npcs_at(
		game_state.current_location,
		game_state.day_index,
		game_state.slot_index
	)
	if present.is_empty():
		var empty_label := Label.new()
		empty_label.text = "这里暂时没有熟悉的村民。我可以看看周围、去别处走走，或等一会儿。"
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		npc_container.add_child(empty_label)
	else:
		for npc_id in present:
			var npc_button := Button.new()
			npc_button.text = "交谈：%s" % schedule_manager.get_npc_name(npc_id)
			npc_button.pressed.connect(_talk_to_npc.bind(npc_id))
			npc_container.add_child(npc_button)

	var journal_entries: Array[Dictionary] = clue_journal.get_entries()
	if journal_entries.is_empty():
		journal_label.text = "暂时没有记录。我只记下自己亲眼观察到的内容，不急着判断真相。"
	else:
		var lines: PackedStringArray = []
		for entry in journal_entries:
			lines.append("第 %d 天 · %s · %s\n%s\n%s" % [
				entry["day"], entry["slot"], entry["location"], entry["title"], entry["detail"]
			])
		journal_label.text = "\n\n".join(lines)

func _on_location_selected(location_id: String) -> void:
	game_state.current_location = location_id
	message_label.text = "我来到了%s。" % schedule_manager.get_location_name(location_id)
	_refresh_ui()

func _advance_time() -> void:
	game_state.advance_time()
	message_label.text = "时间又过去了一段。村里的人也在忙着各自的事。"
	_refresh_ui()

func _observe_location() -> void:
	var added := false
	if game_state.day_index == 5 and game_state.current_location == "SHRINE":
		added = clue_journal.add_fact(
			"day5_repeated_object_shrine",
			"礼拜场所里的普通物件",
			"你注意到一种普通物件被仔细摆放。它的用途目前并不明确，也可能只是日常用品。",
			game_state.day_index,
			game_state.get_slot_label(),
			schedule_manager.get_location_name(game_state.current_location)
		)
	elif game_state.day_index == 5 and game_state.current_location == "COMMONS":
		added = clue_journal.add_fact(
			"day5_repeated_object_commons",
			"公共空间里的相似准备",
			"这里也出现了与其他场景相似的准备方式。重复本身值得记下，但还不能说明原因。",
			game_state.day_index,
			game_state.get_slot_label(),
			schedule_manager.get_location_name(game_state.current_location)
		)
	elif game_state.day_index == 7 and game_state.world_state["phase"] == "ordinary":
		message_label.text = "我没发现能说明异常的新证据。也许以后再来看看，会有新的发现。"
		return

	if added:
		game_state.register_fact("day5_repeated_object_" + game_state.current_location)
		message_label.text = "我把这件事记了下来。不过它也许有普通的解释，现在还不能下结论。"
	else:
		message_label.text = "这里暂时没什么新发现。我可以换个地方、和在场的人聊聊，或者等到下一个时段。"
	_refresh_ui()

func _talk_to_npc(npc_id: String) -> void:
	var added := false
	var reply := "我们聊了些日常琐事。对方没有提到什么特别的事。"

	if game_state.day_index == 3 and npc_id == "doctor" and game_state.current_location == "CLINIC":
		added = clue_journal.add_fact(
			"day3_similar_sleep_reports",
			"相似的睡眠困扰",
			"医生的记录提到不止一名居民最近睡眠不佳或做相似的梦。原因尚不清楚，压力或普通疾病也可能造成这种情况。",
			game_state.day_index,
			game_state.get_slot_label(),
			schedule_manager.get_location_name(game_state.current_location)
		)
		reply = "医生提到最近有几位居民睡得不太好，但认为目前还不能确定原因。"
	elif game_state.day_index == 4 and npc_id == "caregiver" and game_state.current_location == "HOME":
		added = clue_journal.add_fact(
			"day4_caregiver_custom",
			"关于习俗的日常解释",
			"照料者把某项安排解释为村里沿用已久的生活习惯。她说得很自然，没有表现出自己在揭露秘密。",
			game_state.day_index,
			game_state.get_slot_label(),
			schedule_manager.get_location_name(game_state.current_location)
		)
		reply = "照料者说这只是村里一直沿用的习惯。"
	elif game_state.day_index == 4 and npc_id == "worship_leader" and game_state.current_location == "SHRINE":
		added = clue_journal.add_fact(
			"day4_worship_custom",
			"关于习俗的公共解释",
			"礼拜主持者从公共传统和社区秩序的角度解释了类似安排。与另一种说法的差异值得比较，但并不能证明有人撒谎。",
			game_state.day_index,
			game_state.get_slot_label(),
			schedule_manager.get_location_name(game_state.current_location)
		)
		reply = "礼拜主持者把类似安排解释为维护公共传统的一部分。"
	elif game_state.day_index == 6 and npc_id == "doctor" and game_state.current_location == "CLINIC":
		added = clue_journal.add_fact(
			"day6_date_discrepancy",
			"病患记得的日期并不一致",
			"几位病患对不适开始的时间记忆不同。压力、记忆偏差或其他普通因素都可能解释差异，目前不能认定它们有共同原因。",
			game_state.day_index,
			game_state.get_slot_label(),
			schedule_manager.get_location_name(game_state.current_location)
		)
		reply = "医生发现几位病患对症状开始的日期说法不一，打算继续核对记录。"

	message_label.text = reply if not added else reply + " 我把听到的内容记进了线索簿。"
	_refresh_ui()
