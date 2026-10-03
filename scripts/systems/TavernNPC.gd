extends Area2D

var npc_id:String = ""
var npc:NPCBase
var base_scale:Vector2 = Vector2.ONE

var portrait_hunter = preload("res://assets/npc/hunter.svg")
var portrait_merchant = preload("res://assets/npc/merchant.svg")
var portrait_hero = preload("res://assets/npc/hero.svg")

func setup(id:String):
	npc_id = id
	npc = NPCManager.get_npc(id)

	if npc:
		$Label.text = npc.npc_name
		_apply_visual_identity()
	else:
		print("NPC Not Found:", id)

	print("Tavern NPC Spawn:", id)

func _ready():
	base_scale = scale
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_apply_label_style()

func _apply_visual_identity():
	var texture:Texture2D = null

	match npc_id:
		"hunter": texture = portrait_hunter
		"merchant": texture = portrait_merchant
		"hero": texture = portrait_hero

	if texture:
		$Sprite2D.texture = texture
		$Sprite2D.scale = Vector2(0.34, 0.34)
		$Sprite2D.position = Vector2(0, -48)

func _apply_label_style():
	$Label.position = Vector2(-48, 20)
	$Label.size = Vector2(96, 28)
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Label.add_theme_font_size_override("font_size", 14)
	$Label.add_theme_color_override("font_color", Color("e2d4b5"))
	$Label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	$Label.add_theme_constant_override("shadow_offset_x", 2)
	$Label.add_theme_constant_override("shadow_offset_y", 2)

func _on_mouse_entered():
	if NarrativeManager.is_playing:
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", base_scale * 1.06, 0.12)

func _on_mouse_exited():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", base_scale, 0.12)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		interact()

func interact():
	print("Interact NPC:", npc_id)

	var ui = get_parent().get_node_or_null("NPCInteractionUI")
	if ui == null:
		ui = get_tree().current_scene.get_node_or_null("NPCInteractionUI")

	if ui:
		ui.open(npc_id)
	else:
		print("NPCInteractionUI Missing")
