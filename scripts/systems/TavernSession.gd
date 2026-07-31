extends Node


var guests:Array = []


var current_guest_index:int = 0



func start_session():

	print(
		"Tavern Session Start"
	)


	load_today_guests()



func load_today_guests():


	guests.clear()


	guests.append(
		"老猎人"
	)


	guests.append(
		"旅行商人"
	)


	guests.append(
		"失忆的青年"
	)


	current_guest_index = 0


	print(
		"Tonight Guests:"
	)


	for guest in guests:

		print(
			guest
		)



func get_current_guest():

	if current_guest_index < guests.size():

		return guests[current_guest_index]


	return null



func next_guest():


	current_guest_index += 1


	if current_guest_index >= guests.size():

		end_session()

	else:

		print(
			"Next Guest:",
			get_current_guest()
		)



func end_session():

	print(
		"Tavern Closed"
	)


	DayManager.start_night()
