extends Control

@onready var archive_button:Button = $Center/Panel/VBox/Archive
@onready var continue_button:Button = $Center/Panel/VBox/Continue
@onready var new_game_button:Button = $Center/Panel/VBox/NewGame
@onready var ng_plus_button:Button = $Center/Panel/VBox/NewGamePlus
@onready var quit_button:Button = $Center/Panel/VBox/Quit
@onready var subtitle:Label = $Center/Panel/VBox/Subtitle
@onready var status:Label = $Center/Panel/VBox/Status

const TEXT := Color("eadfcd")
const MUTED := Color("9d9489")
const ACCENT := Color("d9b56d")

func _ready():
	continue_button.pressed.connect(_continue)
	new_game_button.pressed.connect(_new_game)
	ng_plus_button.pressed.connect(_ng_plus)
	quit_button.pressed.connect(_quit)
	_refresh()

func _refresh():
	continue_button.disabled = not SaveManager.has_save(0)
	ng_plus_button.disabled = not SaveManager.has_completed_run()
	status.text = "第 %d 天 · 第 %d 周目" % [GameManager.current_day, GameManager.run_cycle] if SaveManager.has_save(0) else "尚无旅途记录"
	subtitle.text = "酒馆只是开始。森林、教会与潮声都在等你。"
	archive_button.text = "结局图鉴 · %d/3" % SaveManager.get_discovered_endings().filter(func(id): return id in ["outer_god","church","human"]).size()
	_apply_button_style()

func _apply_button_style():
	for button in [archive_button, continue_button, new_game_button, ng_plus_button, quit_button]:
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_color_override("font_color", TEXT)
		button.add_theme_color_override("font_hover_color", ACCENT)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _archive():
	var endings := SaveManager.get_discovered_endings()
	var lines:Array[String] = ["结局图鉴", ""]
	var labels := {"outer_god":"潮声","church":"圣火之下","human":"留下来","true":"潮声之心"}
	for id in ["outer_god","church","human","true"]:
		lines.append(("◆ " if endings.has(id) else "◇ ") + labels[id])
	lines.append("")
	lines.append("已发现：%d" % endings.size())
	var dialog := AcceptDialog.new()
	dialog.title = "结局图鉴"
	dialog.dialog_text = "\n".join(lines)
	dialog.ok_button_text = "返回"
	add_child(dialog)
	dialog.popup_centered(Vector2i(420, 320))

func _continue():
	if SaveManager.load_game(0):
		queue_free()

func _new_game():
	GameManager.start_new_game(false)

func _ng_plus():
	GameManager.start_new_game(true)

func _quit():
	get_tree().quit()
