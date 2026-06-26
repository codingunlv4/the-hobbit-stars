extends SceneTree

func _initialize() -> void:
	var err := change_scene_to_file("res://scenes/character_creator.tscn")
	if err != OK:
		push_error("Failed to load character creator: %s" % error_string(err))
		quit(1)
		return
	await process_frame
	await process_frame
	var creator := current_scene
	if creator == null:
		push_error("No current scene")
		quit(1)
		return
	if creator.has_method("_on_begin_pressed"):
		creator._on_begin_pressed()
	await process_frame
	await process_frame
	if current_scene == null or str(current_scene.scene_file_path) != "res://scenes/main.tscn":
		push_error("Scene change to main failed; current=%s" % current_scene)
		quit(1)
		return
	print("Launch test PASSED: character_creator -> main")
	quit(0)
