extends Area2D

var npc_id:String = ""
var npc:NPCBase
var base_scale:Vector2 = Vector2.ONE
var halo:Polygon2D
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
	_create_halo()

func _create_halo():
	halo = Polygon2D.new()
	halo.name = "Halo"
	var points := PackedVector2Array()
	for i in range(32):
		var angle := TAU * float(i) / 32.0
		points.append(Vector2(cos(angle), sin(angle)) * 72.0)
	halo.polygon = points
	halo.color = Color(0.72, 0.56, 0.32, 0.10)
	halo.z_index = -2
	halo.position = Vector2(0, -34)
	$Sprite2D.add_child(halo)

func _apply_visual_identity():
	var texture:Texture2D = null
	match npc_id:
		"hunter":
			texture = portrait_hunter
			halo.color = Color(0.47, 0.55, 0.42, 0.12)
		"merchant":
			texture = portrait_merchant
			halo.color = Color(0.60, 0.48, 0.31, 0.12)
		"hero":
			texture = portrait_hero
			halo.color = Color(0.44, 0.49, 0.62, 0.13)

	if texture:
		$Sprite2D.texture = texture
		$Sprite2D.scale = Vector2(0.34, 0.34)
		$Sprite2D.position = Vector2(0, -48)

func _apply_label_style():
	$Label.position = Vector2(-58, 18)
	$Label.size = Vector2(116, 28)
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Label.add_theme_font_size_override("font_size", 14)
	$Label.add_theme_color_override("font_color", Color("e2d4b5"))
	$Label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	$Label.add_theme_constant_override("shadow_offset_x", 2)
	$Label.add_theme_constant_override("shadow_offset_y", 2)

func _on_mouse_entered():
	if NarrativeManager.is_playing:
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", base_scale * 1.06, 0.12)
	if is_instance_valid(halo):
		tween.tween_property(halo, "color:a", 0.22, 0.12)

func _on_mouse_exited():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", base_scale, 0.12)
	if is_instance_valid(halo):
		tween.tween_property(halo, "color:a", 0.10, 0.12)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		interact()

func interact():
	if NarrativeManager.is_playing:
		return
	print("Interact NPC:", npc_id)
	var ui = get_tree().current_scene.get_node_or_null("NPCInteractionUI")
	if ui:
		ui.open(npc_id)
	else:
		print("NPCInteractionUI Missing")
