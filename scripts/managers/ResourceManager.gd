extends Node



var resources = {}



func _ready():

	print(
		"ResourceManager Ready"
	)



func add_resource(
	name:String,
	amount:int
):


	if not resources.has(name):

		resources[name] = 0


	resources[name] += amount


	print(
		"Resource +",
		name,
		amount
	)



func get_resource(
	name:String
):

	if resources.has(name):

		return resources[name]


	return 0



func print_resources():

	print("================")

	print(resources)

	print("================")
