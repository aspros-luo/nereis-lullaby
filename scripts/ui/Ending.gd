extends Control


@onready var title_label:Label = $Center/Panel/VBox/Title
@onready var body_label:Label = $Center/Panel/VBox/Body
@onready var hint_label:Label = $Center/Panel/VBox/Hint
@onready var restart_button:Button = $Center/Panel/VBox/Restart


func _ready():
	_apply_ending()
	restart_button.pressed.connect(_restart)


func _apply_ending():
	var ending_id:String = str(StoryState.get_flag("demo_ending", "village"))

	match ending_id:
		"outer_god":
			title_label.text = "潮声"
			body_label.text = "你终于听见了那道声音。\n森林没有回答你。\n它只是记住了你的名字。"
			hint_label.text = "结局 A · 潮声 · 第 %d 周目" % GameManager.run_cycle

		"church":
			title_label.text = "圣火之下"
			body_label.text = "你把看到的一切交给了教会。\n村庄暂时恢复了平静。\n但你开始怀疑，他们究竟在守护什么。"
			hint_label.text = "结局 B · 圣火之下 · 第 %d 周目" % GameManager.run_cycle

		"human":
			title_label.text = "留下来"
			body_label.text = "你没有回应森林，也没有把一切交给教会。\n你选择留下来。\n至少今晚，酒馆的灯还亮着。"
			hint_label.text = "结局 C · 留下 · 第 %d 周目" % GameManager.run_cycle

		_:
			title_label.text = "未完"
			body_label.text = "这一段故事结束了。"
			hint_label.text = "Playable Demo"


func _restart():
	StoryState.reset()
	StoryManager.reset_runtime_state()
	WorldState.reset()
	ResourceManager.reset()
	ActionManager.reset()
	TavernSession.reset_session()
	NPCManager.reset_runtime_state()
	GameManager.current_day = 1
	DayManager.current_day = 1
	EndingManager.current_ending = ""
	EndingManager._ending_started = false
	GameManager.start_game()
