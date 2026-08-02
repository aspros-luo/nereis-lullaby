extends Node2D



@export var npc_scene:PackedScene



var positions={


	"hunter":
	Vector2(650,300),


	"merchant":
	Vector2(250,280),


	"hero":
	Vector2(450,350)

}



func spawn_npc(
	id:String
):


	if npc_scene==null:

		print(
			"NPC Scene Missing"
		)

		return



	var npc = npc_scene.instantiate()



	add_child(npc)



	npc.position = positions.get(
		id,
		Vector2(400,300)
	)



	npc.setup(id)





func spawn_tonight_guests():


	spawn_npc(
		"hunter"
	)


	spawn_npc(
		"merchant"
	)


	spawn_npc(
		"hero"
	)
