extends SceneTree

## Headless boot check — run with:
## godot --path . --headless --script res://scripts/smoke_test.gd

const SCENES := [
	"res://scenes/character_creator.tscn",
	"res://scenes/main.tscn",
]


func _initialize() -> void:
	var failed := false
	for scene_path in SCENES:
		if not ResourceLoader.exists(scene_path):
			push_error("Missing scene: %s" % scene_path)
			failed = true
			continue
		var packed: PackedScene = load(scene_path)
		if packed == null:
			push_error("Failed to load: %s" % scene_path)
			failed = true
			continue
		var node := packed.instantiate()
		if node == null:
			push_error("Failed to instantiate: %s" % scene_path)
			failed = true
			continue
		root.add_child(node)
		await process_frame
		node.free()
		print("OK: %s" % scene_path)

	if failed:
		push_error("Smoke test FAILED")
		quit(1)
	else:
		print("Smoke test PASSED")
		quit(0)
