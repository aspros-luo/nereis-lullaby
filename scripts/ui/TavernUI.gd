extends Control



@onready var guest_label = $Panel/VBox/GuestLabel

@onready var status_label = $Panel/VBox/StatusLabel



func _ready():


	print(
		"TavernUI Ready"
	)


	$Panel/VBox/NormalDrinkButton.pressed.connect(
		_on_normal_drink
	)


	$Panel/VBox/TalkButton.pressed.connect(
		_on_talk
	)


	$Panel/VBox/SpecialDrinkButton.pressed.connect(
		_on_special_drink
	)


	$Panel/VBox/NextGuestButton.pressed.connect(
		_on_next_guest
	)



	TavernSession.session_started.connect(
		refresh
	)


	TavernSession.guest_changed.connect(
		refresh
	)



func refresh():


	var guest = TavernSession.get_current_guest()


	if guest:

		guest_label.text = (
			"当前客人: "
			+ guest
		)

	else:

		guest_label.text = (
			"没有客人"
		)




func _on_normal_drink():


	var guest = TavernSession.get_current_guest()


	if guest == null:

		status_label.text = (
			"现在没有客人。"
		)

		return


	print(
		"Serve normal drink:",
		guest
	)


	status_label.text = (
		"你递给 %s 一杯普通麦酒。"
		% guest
	)




func _on_talk():


	var guest = TavernSession.get_current_guest()


	if guest == null:

		return


	print(
		"Talk:",
		guest
	)



func _on_special_drink():


	var guest = TavernSession.get_current_guest()


	if guest == null:

		return


	print(
		"Special drink:",
		guest
	)



func _on_next_guest():


	TavernSession.next_guest()
