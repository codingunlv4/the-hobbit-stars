extends SceneTree

const GlbVisual = preload("res://scripts/glb_visual.gd")


func _initialize() -> void:
	var failed := false

	for path in [GlbVisual.KNIGHT, GlbVisual.DRAGON]:
		if load(path) == null:
			push_error("Missing: %s" % path)
			failed = true

	var main_packed: PackedScene = load("res://scenes/main.tscn")
	var main: Node3D = main_packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var commander := main.get_node_or_null("Commander")
	if commander == null or not commander.has_node("GlbModel"):
		push_error("Knight not on commander")
		failed = true
	else:
		print("OK: Knight on commander")

	var allies := main.get_node_or_null("Allies")
	var dragon_found := false
	if allies:
		for child in allies.get_children():
			if child is HeroAlly and child.has_node("GlbModel"):
				if child.unit_name == "Dragon":
					dragon_found = true
					print("OK: Dragon ally spawned")
	if not dragon_found:
		push_error("Dragon ally missing GlbModel")
		failed = true

	main.free()

	if failed:
		push_error("Model test FAILED")
		quit(1)
	else:
		print("Model test PASSED")
		quit(0)
