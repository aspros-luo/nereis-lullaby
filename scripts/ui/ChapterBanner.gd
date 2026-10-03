extends CanvasLayer

var label:Label
var chapter_label:Label
var active_tween:Tween

func _ready():
	layer = 90
	label = Label.new()
	label.position = Vector2(72, 54)
	label.size = Vector2(520, 44)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color("e3ceb0"))
	add_child(label)

	chapter_label = Label.new()
	chapter_label.position = Vector2(74, 98)
	chapter_label.size = Vector2(500, 26)
	chapter_label.add_theme_font_size_override("font_size", 13)
	chapter_label.add_theme_color_override("font_color", Color("9d907f"))
	add_child(chapter_label)

	hide_banner()

func show_chapter(title:String, subtitle:String)->void:
	label.text = title
	chapter_label.text = subtitle
	label.modulate.a = 0.0
	chapter_label.modulate.a = 0.0
	label.position.y = 70
	chapter_label.position.y = 114
	show()
	if active_tween and active_tween.is_running():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(label, "modulate:a", 1.0, 0.35)
	active_tween.tween_property(chapter_label, "modulate:a", 1.0, 0.45)
	active_tween.tween_property(label, "position:y", 54, 0.45)
	active_tween.tween_property(chapter_label, "position:y", 98, 0.45)
	active_tween.finished.connect(func():
		await get_tree().create_timer(2.2).timeout
		hide_banner())

func hide_banner():
	visible = false
