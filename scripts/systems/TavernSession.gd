extends Node


signal session_started

signal guest_changed

signal session_finished



#
# 今日客人列表
#
var guests:Array = []


#
# 当前客人索引
#
var current_guest_index:int = 0



#
# 开始营业
#
func start_session():


	print(
		"Tavern Session Start"
	)


	load_today_guests()


	session_started.emit()


	guest_changed.emit()




#
# 加载今日客人
#
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


#
# 获取当前客人
#
func get_current_guest():


	if current_guest_index < guests.size():

		return guests[current_guest_index]


	return null




#
# 获取当前客人数据
#
func get_current_guest_data():


	var id = get_current_guest()


	if id == null:

		return null


	return NPCManager.get_npc(id)




#
# 服务普通酒
#
func serve_normal_drink():


	var id = get_current_guest()


	if id == null:

		return



	print(
		"Serve normal drink:",
		id
	)



	#
	# 普通酒效果
	#
	NPCManager.change_relation(
		id,
		1
	)



	NPCManager.change_trust(
		id,
		1
	)




	var npc = NPCManager.get_npc(id)


	print(
		npc["name"],
		" relation +1 trust +1"
	)





#
# 服务外神特调
#
func serve_special_drink():


	var id=get_current_guest()


	if id==null:

		return



	print(
		"Serve special drink:",
		id
	)



	#
	# 特调影响
	#
	NPCManager.add_corruption(
		id,
		5
	)



	WorldState.add_value(
		"village_corruption",
		1
	)



	WorldState.add_value(
		"outer_god_progress",
		1
	)




#
# 下一个客人
#
func next_guest():


	current_guest_index+=1



	if current_guest_index >= guests.size():


		end_session()


	else:


		print(
			"Next Guest:",
			get_current_guest()
		)


		guest_changed.emit()





#
# 结束营业
#
func end_session():


	print(
		"Tavern Closed"
	)

	DayManager.start_night()
