class_name UnitNameplate
extends RefCounted

const ALLY_COLOR := Color(0.55, 0.95, 0.65)
const PARTNER_COLOR := Color(1.0, 0.88, 0.35)
const PLAYER_COLOR := Color(0.45, 0.85, 1.0)
const ENEMY_COLOR := Color(0.95, 0.35, 0.3)


static func attach(parent: Node3D, text: String, color: Color, height: float = 2.2) -> Label3D:
	var old := parent.get_node_or_null("Nameplate")
	if old:
		old.queue_free()

	var label := Label3D.new()
	label.name = "Nameplate"
	label.text = text
	label.font_size = 26
	label.outline_size = 8
	label.modulate = color
	label.position = Vector3(0, height, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	parent.add_child(label)
	return label
