extends Node


signal session_started
signal guest_changed
signal session_finished


var guests:Array = []
var current_guest_index:int = 0



func start_session():

	print(
		"Tavern Session Start"
	)

	load_today_guests()

	session_started.emit()
	guest_changed.emit()



func load_today_guests():

	guests.clear()

	guests.append("hunter")
	guests.append("merchant")
	guests.append("hero")

	current_guest_index = 0

	print(
		"Tonight Guests:"
	)

	for id in guests:

		var npc = NPCManager.get_npc(id)

		if npc:
			print(
				npc.npc_name
			)



func get_current_guest():

	if current_guest_index < guests.size():
		return guests[current_guest_index]

	return null



func get_current_guest_data():

	var id = get_current_guest()

	if id == null:
		return null

	return NPCManager.get_npc(id)



# ==========================
# 酒水服务
# ==========================


func serve_normal_drink():

	var id = get_current_guest()

	if id == null:
		return null

	print(
		"Serve normal drink:",
		id
	)

	NPCManager.drink(
		id,
		"normal"
	)

	var trust = NPCManager.change_trust(
		id,
		1
	)

	var npc = NPCManager.get_npc(id)

	if npc:
		print(
			npc.npc_name,
			" trust +1 => ",
			trust
		)

	return npc



func serve_special_drink():

	var id = get_current_guest()

	if id == null:
		return null

	print(
		"Serve special drink:",
		id
	)

	NPCManager.drink(
		id,
		"special"
	)

	NPCManager.add_corruption(
		id,
		1
	)

	WorldState.add_value(
		"outer_god_progress",
		1
	)

	return NPCManager.get_npc(id)



# ==========================
# 下一个客人
# ==========================


func next_guest():

	current_guest_index += 1

	if current_guest_index >= guests.size():
		end_session()

	else:
		print(
			"Next Guest:",
			get_current_guest()
		)

		guest_changed.emit()



func end_session():

	print(
		"Tavern Closed"
	)

	session_finished.emit()

	DayManager.start_night()
