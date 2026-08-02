extends Control



func _ready():

	print(
		"TavernUI Ready"
	)


	update_status()



func update_status():


	if has_node(
		"Panel/VBox/StatusLabel"
	):

		$Panel/VBox/StatusLabel.text = "酒馆营业中"
