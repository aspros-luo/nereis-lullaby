extends Control

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
	_apply_button_style()

func _apply_button_style():
	for button in [continue_button, new_game_button, ng_plus_button, quit_button]:
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_color_override("font_color", TEXT)
		button.add_theme_color_override("font_hover_color", ACCENT)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _continue():
	if SaveManager.load_game(0):
		queue_free()

func _new_game():
	GameManager.start_new_game(false)

func _ng_plus():
	GameManager.start_new_game(true)

func _quit():
	get_tree().quit()
