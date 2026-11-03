extends Control
## TEMPORARY bootstrap main UI with kitchen entry.
## Full village prototype will be restored in a follow-up commit.

const InventoryScript = preload("res://scripts/systems/item/inventory.gd")
const KitchenControllerScript = preload("res://scripts/systems/cooking/kitchen_controller.gd")

var status_label: Label
var message_label: Label
var cook_button: Button
var kitchen_controller
var player_inventory

func _ready() -> void:
	_apply_visual_style()
	_build_ui()
	_setup_kitchen()

func _apply_visual_style() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("#15141b")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	move_child(backdrop, 0)

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

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

	var title := Label.new()
	title.text = "蜜忒之歌｜临时入口"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(title)

	status_label = Label.new()
	status_label.text = "主界面原型正在恢复中。你可以先从这里进入厨房。"
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("#e8dfd2"))
	root.add_child(status_label)

	message_label = Label.new()
	message_label.text = "家里很安静。桌上放着面粉、蜂蜜和鸡蛋。"
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_color", Color("#c8bfa8"))
	root.add_child(message_label)

	cook_button = Button.new()
	cook_button.text = "去做点吃的"
	cook_button.pressed.connect(_open_kitchen)
	root.add_child(cook_button)

func _setup_kitchen() -> void:
	player_inventory = InventoryScript.new()
	player_inventory.add_item("flour", 3)
	player_inventory.add_item("honey", 3)
	player_inventory.add_item("egg", 3)

	kitchen_controller = KitchenControllerScript.new()
	add_child(kitchen_controller)
	kitchen_controller.bootstrap_with(player_inventory)
	if not kitchen_controller.cooking_completed.is_connected(_on_cooking_completed):
		kitchen_controller.cooking_completed.connect(_on_cooking_completed)
	if not kitchen_controller.kitchen_closed.is_connected(_on_kitchen_closed):
		kitchen_controller.kitchen_closed.connect(_on_kitchen_closed)

func _open_kitchen() -> void:
	if kitchen_controller == null:
		return
	kitchen_controller.open()
	message_label.text = "我走进厨房，准备做一点简单的食物。"

func _on_cooking_completed(result) -> void:
	if result == null:
		return
	if result.success:
		message_label.text = "做好了：%s。%s" % [result.output_item_id, result.message]
	else:
		message_label.text = "这次没能完成：%s" % result.message

func _on_kitchen_closed() -> void:
	message_label.text = "我离开厨房，回到家里熟悉的光线里。"
