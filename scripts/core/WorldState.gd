extends Node


var values:Dictionary = {

	"village_corruption":0,

	"outer_god_progress":0,

	"church_truth":0,

	"hero_memory":0,

	"hero_humanity":100,

	"mite_humanity":100

}



func add_value(
	key:String,
	value:int
):

	if values.has(key):

		values[key] += value



func get_value(
	key:String
):

	return values.get(key,0)



func set_value(
	key:String,
	value
):

	values[key]=value



func debug_print():

	print("================")
	print(values)
	print("================")
