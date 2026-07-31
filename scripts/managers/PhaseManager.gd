extends Node


enum Phase
{
	MORNING,
	TAVERN,
	NIGHT
}


var current_phase:Phase = Phase.MORNING



func _ready():

	print(
		"PhaseManager Ready"
	)



func change_phase(
	new_phase:Phase
):

	current_phase = new_phase


	print(
		"Current Phase:",
		Phase.keys()[current_phase]
	)


	emit_phase_changed()



func get_phase():

	return current_phase



func emit_phase_changed():

	match current_phase:

		Phase.MORNING:

			print(
				"Morning Begin"
			)


		Phase.TAVERN:

			print(
				"Tavern Begin"
			)


		Phase.NIGHT:

			print(
				"Night Begin"
			)
