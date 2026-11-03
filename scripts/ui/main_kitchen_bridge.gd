class_name MainKitchenBridge
extends RefCounted

## Small helper so main.gd only needs a few call sites for cooking.
## Keeps kitchen wiring out of the huge prototype UI script when possible.

const InventoryScript = preload("res://scripts/systems/item/inventory.gd")
const KitchenControllerScript = preload("res://scripts/systems/cooking/kitchen_controller.gd")

var host: Node
var cook_button: Button
var player_inventory
var kitchen_controller

func setup(host_node: Node) -> void:
	host = host_node
	player_inventory = InventoryScript.new()
	player_inventory.add_item("flour", 3)
	player_inventory.add_item("honey", 3)
	player_inventory.add_item("egg", 3)

	kitchen_controller = KitchenControllerScript.new()
	host.add_child(kitchen_controller)
	kitchen_controller.bootstrap_with(player_inventory)
	if not kitchen_controller.cooking_completed.is_connected(_on_cooking_completed):
		kitchen_controller.cooking_completed.connect(_on_cooking_completed)
	if not kitchen_controller.kitchen_closed.is_connected(_on_kitchen_closed):
		kitchen_controller.kitchen_closed.connect(_on_kitchen_closed)

func add_cook_button(action_row: HBoxContainer) -> void:
	cook_button = Button.new()
	cook_button.text = "去做点吃的"
	cook_button.visible = false
	cook_button.pressed.connect(open_kitchen)
	action_row.add_child(cook_button)

func refresh_cook_button(game_state) -> void:
	if cook_button == null or game_state == null:
		return
	var can_cook_here := (
		str(game_state.current_location) == "HOME"
		and game_state.world_state["phase"] == "ordinary"
		and game_state.can_take_action()
	)
	cook_button.visible = can_cook_here
	cook_button.disabled = not can_cook_here

func open_kitchen() -> void:
	if kitchen_controller == null or host == null:
		return
	var game_state = host.get("game_state")
	var message_label = host.get("message_label")
	if game_state == null:
		return
	if game_state.world_state["phase"] != "ordinary":
		if message_label:
			message_label.text = "现在不适合进厨房。"
		return
	if str(game_state.current_location) != "HOME":
		if message_label:
			message_label.text = "只有回到家里才能进厨房。"
		return
	if not game_state.can_take_action():
		if message_label:
			message_label.text = "这个时段我已经忙完了，还是等到下一个时段再做吧。"
		return
	kitchen_controller.open()
	if message_label:
		message_label.text = "我走进厨房，准备做一点简单的食物。"

func _on_cooking_completed(result) -> void:
	if host == null or result == null:
		return
	var message_label = host.get("message_label")
	if not result.success:
		if message_label:
			message_label.text = "厨房：%s" % result.message
		return

	var game_state = host.get("game_state")
	var clue_journal = host.get("clue_journal")
	var worldline_ledger = host.get("worldline_ledger")
	if game_state == null:
		return

	var action_id: String = "activity_home_cooking"
	var activity_text: String = "我在厨房做了%s，屋里渐渐有了食物的香气。" % result.output_item_id

	if host.has_method("_copy_game_state") and host.has_method("_copy_clue_journal") and host.has_method("_copy_worldline_ledger"):
		var staged_state = host._copy_game_state(game_state)
		var staged_journal = host._copy_clue_journal(clue_journal)
		var staged_ledger = host._copy_worldline_ledger(worldline_ledger)
		if staged_state == null or staged_journal == null or staged_ledger == null:
			if message_label:
				message_label.text = "料理做好了，但这项活动暂时无法安全记录。"
			return
		if not staged_state.take_action(action_id, activity_text):
			if message_label:
				message_label.text = "料理做好了，可这个时段已经没有行动机会了。"
			if host.has_method("_refresh_ui"):
				host._refresh_ui()
			return
		var cook_event_id: String = "lullaby.activity.day%d.slot%d.home_cooking" % [staged_state.day_index, staged_state.slot_index]
		if not staged_ledger.record_event(cook_event_id, "lullaby", "mite", action_id, "HOME"):
			if message_label:
				message_label.text = "料理做好了，但活动记录无法提交；本时段行动没有消耗。"
			return
		host.set("game_state", staged_state)
		host.set("clue_journal", staged_journal)
		host.set("worldline_ledger", staged_ledger)
		if message_label:
			message_label.text = activity_text + "（获得 %s）" % result.output_item_id
		if host.has_method("_refresh_ui"):
			host._refresh_ui()
		return

	# Fallback: show result without staging if copy helpers unavailable.
	if message_label:
		message_label.text = activity_text + "（获得 %s）" % result.output_item_id

func _on_kitchen_closed() -> void:
	if host == null:
		return
	var message_label = host.get("message_label")
	var game_state = host.get("game_state")
	if message_label != null and game_state != null:
		if str(game_state.current_location) == "HOME":
			message_label.text = "我离开厨房，回到家里熟悉的光线里。"
	if host.has_method("_refresh_ui"):
		host._refresh_ui()
