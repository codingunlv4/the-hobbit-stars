extends SceneTree

## UI input smoke test — run with:
## godot --path . --headless --script res://scripts/ui_input_test.gd

const CHARACTER_CREATOR := "res://scenes/character_creator.tscn"
const MAIN_SCENE := "res://scenes/main.tscn"


func _initialize() -> void:
	var failed := false

	var creator_packed: PackedScene = load(CHARACTER_CREATOR)
	var creator: Control = creator_packed.instantiate()
	root.add_child(creator)
	await process_frame

	if creator.has_node("HBox/OptionsPanel/PanelVBox/ActionBar/ButtonRow/BeginButton"):
		var begin_btn: Button = creator.get_node(
			"HBox/OptionsPanel/PanelVBox/ActionBar/ButtonRow/BeginButton"
		)
		if begin_btn.disabled:
			push_error("Begin button starts disabled")
			failed = true
		if begin_btn.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			push_error("Begin button ignores mouse")
			failed = true
	else:
		push_error("Begin button node missing")
		failed = true

	if creator.has_node("UILayer"):
		push_error("UILayer should not exist — input fix regressed")
		failed = true

	creator.free()
	await process_frame

	var main_packed: PackedScene = load(MAIN_SCENE)
	var main: Node3D = main_packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	if not main.has_node("GameUI/CommandUI"):
		push_error("CommandUI missing from main scene")
		failed = true
	else:
		var command_ui: Control = main.get_node("GameUI/CommandUI")
		var buttons := command_ui.get_node("Panel/Margin/VBox/CommandButtons")
		if buttons.get_child_count() < 6:
			push_error("Command buttons were not built")
			failed = true

	main.free()

	if failed:
		push_error("UI input test FAILED")
		quit(1)
	else:
		print("UI input test PASSED")
		quit(0)
