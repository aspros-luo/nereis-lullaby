extends Node


signal session_started
signal guest_changed
signal session_finished


var guests:Array[String] = []
var current_guest_index:int = 0


func start_session():

	print("Tavern Session Start")

	load_today_guests()

	session_started.emit()
	guest_changed.emit()


func load_today_guests():

	guests.clear()

	guests.append("hunter")
	guests.append("merchant")
	guests.append("hero")

	current_guest_index = 0

	print("Tonight Guests:")

	for id in guests:
		var npc = NPCManager.get_npc(id)
		if npc:
			print(npc.npc_name)


func get_current_guest()->String:

	if current_guest_index < guests.size():
		return guests[current_guest_index]

	return ""


func get_current_guest_data()->NPCBase:

	var id = get_current_guest()

	if id.is_empty():
		return null

	return NPCManager.get_npc(id)


func serve_normal_drink():

	var npc = get_current_guest_data()

	if npc == null:
		return

	print("Serve normal drink:", npc.id)

	var result = npc.drink("normal")

	print(
		npc.npc_name,
		" drink result:",
		result
	)


func serve_special_drink():

	var npc = get_current_guest_data()

	if npc == null:
		return

	print("Serve special drink:", npc.id)

	var result = npc.drink("special")

	WorldState.add_value("village_corruption", 1)
	WorldState.add_value("outer_god_progress", 1)

	print(
		npc.npc_name,
		" special drink result:",
		result
	)


func next_guest():

	current_guest_index += 1

	if current_guest_index >= guests.size():
		end_session()
		return

	print("Next Guest:", get_current_guest())
	guest_changed.emit()


func end_session():

	print("Tavern Closed")
	session_finished.emit()

	DayManager.start_night()
