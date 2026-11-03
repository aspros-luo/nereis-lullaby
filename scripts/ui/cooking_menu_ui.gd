class_name CookingMenuUI
extends Control

## Text-first kitchen menu.
## Matches the prototype dark UI style used by the main village screen.

signal recipe_cook_requested(recipe_id: String)
signal step_continue_requested
signal close_requested

var title_label: Label
var status_label: Label
var inventory_label: Label
var recipe_container: VBoxContainer
var step_label: Label
var message_label: Label
var continue_button: Button
var close_button: Button

var _recipe_meta: Dictionary = {}
var _inventory_snapshot: Dictionary = {}
var _in_process: bool = false

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func open_menu(recipe_ids: Array, manager, inventory) -> void:
	_recipe_meta.clear()
	_inventory_snapshot = {}
	_in_process = false
	if inventory != null:
		_inventory_snapshot = inventory.items.duplicate()

	for recipe_id in recipe_ids:
		var id_str := str(recipe_id)
		var display_name := id_str
		var can_cook := false
		var missing: Array = []

		if manager != null:
			var recipe = manager.get_recipe(id_str)
			if recipe != null:
				display_name = str(recipe.display_name) if str(recipe.display_name) != "" else id_str
				can_cook = recipe.can_cook(_inventory_snapshot)
				for ingredient_id in recipe.ingredients.keys():
					var need := int(recipe.ingredients[ingredient_id])
					var have := int(_inventory_snapshot.get(ingredient_id, 0))
					if have < need:
						missing.append("%s ×%d" % [ingredient_id, need - have])

		_recipe_meta[id_str] = {
			"display_name": display_name,
			"can_cook": can_cook,
			"missing": missing,
		}

	_refresh_recipe_list()
	_refresh_inventory_label()
	_set_process_mode(false)
	status_label.text = "厨房里很安静。桌上放着面粉、蜂蜜和鸡蛋。"
	message_label.text = "选一份想做的料理吧。"
	step_label.text = ""
	visible = true

func show_step(progress_label: String, step_text: String, is_last: bool) -> void:
	_in_process = true
	_set_process_mode(true)
	status_label.text = "正在制作……"
	step_label.text = "%s\n%s" % [progress_label, step_text]
	if is_last:
		continue_button.text = "完成出炉"
		message_label.text = "最后一步了。"
	else:
		continue_button.text = "继续"
		message_label.text = "按自己的节奏做就好。"

func show_result(result, inventory = null) -> void:
	_in_process = false
	_set_process_mode(false)
	if inventory != null:
		_inventory_snapshot = inventory.items.duplicate()
		_refresh_inventory_label()

	if result == null:
		message_label.text = "没有得到结果。"
		return

	if result.success:
		status_label.text = "料理完成了。"
		step_label.text = ""
		message_label.text = "做好了：%s\n%s" % [result.output_item_id, result.message]
	else:
		status_label.text = "这次没能完成。"
		step_label.text = ""
		message_label.text = str(result.message)

func close_menu() -> void:
	_in_process = false
	visible = false

func _set_process_mode(active: bool) -> void:
	if continue_button != null:
		continue_button.visible = active
	if recipe_container != null:
		recipe_container.visible = not active

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var backdrop := ColorRect.new()
	backdrop.color = Color("#15141b")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	title_label = Label.new()
	title_label.text = "蜜忒之歌｜厨房"
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(title_label)

	var subtitle := Label.new()
	subtitle.text = "做一点平常的食物。味道会留在记忆里。"
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(subtitle)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(status_label)

	var inv_title := Label.new()
	inv_title.text = "手里的材料"
	inv_title.add_theme_font_size_override("font_size", 18)
	inv_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(inv_title)

	inventory_label = Label.new()
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(inventory_label)

	var recipe_title := Label.new()
	recipe_title.text = "可以尝试的料理"
	recipe_title.add_theme_font_size_override("font_size", 18)
	recipe_title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(recipe_title)

	recipe_container = VBoxContainer.new()
	recipe_container.add_theme_constant_override("separation", 8)
	root.add_child(recipe_container)

	step_label = Label.new()
	step_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	step_label.add_theme_font_size_override("font_size", 16)
	step_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	step_label.text = ""
	root.add_child(step_label)

	message_label = Label.new()
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	message_label.text = ""
	root.add_child(message_label)

	continue_button = Button.new()
	continue_button.text = "继续"
	continue_button.visible = false
	continue_button.pressed.connect(func(): step_continue_requested.emit())
	_style_button(continue_button)
	root.add_child(continue_button)

	close_button = Button.new()
	close_button.text = "离开厨房"
	close_button.pressed.connect(func(): close_requested.emit())
	_style_button(close_button)
	root.add_child(close_button)

func _refresh_recipe_list() -> void:
	for child in recipe_container.get_children():
		recipe_container.remove_child(child)
		child.queue_free()

	if _recipe_meta.is_empty():
		var empty := Label.new()
		empty.text = "还没有学会任何料理。"
		empty.add_theme_color_override("font_color", Color("#e8dfd2"))
		recipe_container.add_child(empty)
		return

	for recipe_id in _recipe_meta.keys():
		var meta: Dictionary = _recipe_meta[recipe_id]
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation", 4)

		var button := Button.new()
		var label := str(meta.get("display_name", recipe_id))
		if meta.get("can_cook", false):
			button.text = "制作：%s" % label
			button.disabled = false
		else:
			button.text = "材料不足：%s" % label
			button.disabled = true
		button.pressed.connect(_on_recipe_pressed.bind(str(recipe_id)))
		_style_button(button)
		row.add_child(button)

		var detail := Label.new()
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.add_theme_color_override("font_color", Color("#c8bfa8"))
		if meta.get("can_cook", false):
			detail.text = "材料齐全，可以开始。"
		else:
			var missing: Array = meta.get("missing", [])
			detail.text = "还缺：%s" % ", ".join(missing)
		row.add_child(detail)

		recipe_container.add_child(row)

func _refresh_inventory_label() -> void:
	if _inventory_snapshot.is_empty():
		inventory_label.text = "（空）"
		return

	var parts: Array = []
	for item_id in _inventory_snapshot.keys():
		var count := int(_inventory_snapshot[item_id])
		if count > 0:
			parts.append("%s ×%d" % [item_id, count])
	if parts.is_empty():
		inventory_label.text = "（空）"
	else:
		inventory_label.text = "、".join(parts)

func _on_recipe_pressed(recipe_id: String) -> void:
	if _in_process:
		return
	recipe_cook_requested.emit(recipe_id)

func _style_button(button: Button) -> void:
	var normal := _make_style(Color("#29252f"), Color("#665344"))
	var hover := _make_style(Color("#3b3038"), Color("#c09a6a"))
	var pressed := _make_style(Color("#4a3540"), Color("#d0b17e"))
	var disabled := _make_style(Color("#211f26"), Color("#39343d"))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color("#e8dfd2"))
	button.add_theme_color_override("font_hover_color", Color("#fff4e6"))
	button.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color("#77717b"))

func _make_style(fill_color: Color, edge_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = edge_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style
