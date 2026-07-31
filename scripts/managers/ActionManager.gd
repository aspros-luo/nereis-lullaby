extends Node


enum Action
{
	NONE,
	FOREST,
	FARM,
	LIVESTOCK
}


var today_action:Action = Action.NONE



func _ready():

	print(
		"ActionManager Ready"
	)



func execute_action(action:Action):

	today_action = action


	match action:

		Action.FOREST:

			forest_collect()


		Action.FARM:

			farm_work()


		Action.LIVESTOCK:

			livestock_work()



func forest_collect():

	print(
		"Morning Action: Forest"
	)


	ResourceManager.add_resource(
		"flower",
		1
	)


	ResourceManager.add_resource(
		"herb",
		1
	)



func farm_work():

	print(
		"Morning Action: Farm"
	)


	ResourceManager.add_resource(
		"food",
		2
	)



func livestock_work():

	print(
		"Morning Action: Livestock"
	)


	ResourceManager.add_resource(
		"milk",
		1
	)



func reset():

	today_action = Action.NONE
