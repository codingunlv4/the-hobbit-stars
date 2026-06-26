extends SceneTree

const GlbVisual = preload("res://scripts/glb_visual.gd")


func _initialize() -> void:
	for path in [GlbVisual.KNIGHT, GlbVisual.DRAGON]:
		var packed: PackedScene = load(path)
		var node: Node3D = packed.instantiate()
		root.add_child(node)
		var aabb := _find_aabb(node)
		print("%s size=%s center=%s" % [path, aabb.size, aabb.get_center()])
		node.free()
	quit(0)


func _find_aabb(node: Node) -> AABB:
	var combined := AABB()
	var first := true
	for mesh_inst in node.find_children("*", "MeshInstance3D", true, false):
		if mesh_inst is MeshInstance3D and mesh_inst.mesh:
			var local: AABB = mesh_inst.mesh.get_aabb()
			var xf: AABB = mesh_inst.global_transform * local
			if first:
				combined = xf
				first = false
			else:
				combined = combined.merge(xf)
	return combined
