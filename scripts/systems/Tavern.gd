extends Node

const NPC_SCENE:PackedScene = preload("res://scenes/TavernNPC.tscn")

const NPC_POSITIONS := {
	"hunter": Vector2(650, 300),
	"merchant": Vector2(250, 280),
	"hero": Vector2(450, 350)
}

func _ready():
	print("Tavern Scene Loaded")
	TavernManager.open_tavern()
	_spawn_tonight_guests()

	if DayManager.has_method("finish_scene_transition"):
		DayManager.finish_scene_transition()

func _spawn_tonight_guests():
	for npc_id in ["hunter", "merchant", "hero"]:
		_spawn_npc(npc_id)

func _spawn_npc(npc_id:String):
	var npc = NPC_SCENE.instantiate()
	add_child(npc)
	npc.position = NPC_POSITIONS.get(npc_id, Vector2(400, 300))
	npc.setup(npc_id)
