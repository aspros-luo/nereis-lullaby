extends SceneTree


func _initialize() -> void:
	print("=== V0.3 STORY RUNTIME ACCEPTANCE START ===")

	# Give autoloads a frame to finish their _ready() initialization.
	await process_frame

	_assert_true(StoryManager.get_event("v03_test_event") != null, "v03_test_event must be registered")
	_assert_true(not StoryState.has_flag("event:v03_test_event"), "test event must start unconsumed")

	GameManager.current_day = 1
	StoryState.remove_flag("v03_runtime_test")
	StoryState.remove_flag("event:v03_test_event")

	StoryManager.evaluate_events()
	_assert_true(not StoryState.has_flag("v03_runtime_test"), "event must not execute before day 2")

	GameManager.current_day = 2
	StoryManager.evaluate_events()

	_assert_true(StoryState.get_flag("v03_runtime_test", false) == true, "event must set v03_runtime_test on day 2")
	_assert_true(StoryState.has_flag("event:v03_test_event"), "once event must record its consumed flag")

	StoryState.set_flag("v03_runtime_test", false)
	StoryManager.evaluate_events()

	_assert_true(StoryState.get_flag("v03_runtime_test", false) == false, "once event must not execute twice")

	print("=== V0.3 STORY RUNTIME ACCEPTANCE PASSED ===")
	quit(0)


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		push_error("ACCEPTANCE FAILED: " + message)
		quit(1)
