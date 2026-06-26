class_name GlbVisual
extends RefCounted

const KNIGHT := "res://knight.glb"
const DRAGON := "res://dragon.glb"
const ELF := "res://elf.glb"
const MAGE := "res://mage.glb"
const NAIN := "res://nain.glb"


static func attach(parent: Node3D, glb_path: String, scale: float = 1.0, y_offset: float = 0.0, rotation_y_deg: float = 0.0) -> Node3D:
	var old := parent.get_node_or_null("GlbModel")
	if old:
		old.queue_free()

	var packed: PackedScene = load(glb_path)
	if packed == null:
		push_error("GlbVisual: failed to load %s" % glb_path)
		return null

	var model: Node3D = packed.instantiate()
	model.name = "GlbModel"
	model.scale = Vector3.ONE * scale
	model.position.y = y_offset
	model.rotation_degrees.y = rotation_y_deg
	parent.add_child(model)
	return model


static func hide_procedural(parent: Node3D) -> void:
	var visual := parent.get_node_or_null("CharacterVisual")
	if visual:
		visual.visible = false
