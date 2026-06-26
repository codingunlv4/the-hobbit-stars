class_name HeroAlly
extends CommandableUnit

const Nameplate = preload("res://scripts/unit_nameplate.gd")
const GlbVisualScript = preload("res://scripts/glb_visual.gd")

@export var hero_preset_id: String = ""
@export var is_co_leader: bool = false
@export var glb_model_path: String = ""
@export var glb_scale: float = 1.0
@export var glb_y_offset: float = 0.0
@export var glb_rotation_y: float = 180.0

@onready var character_visual: CharacterVisual = $CharacterVisual


func _ready() -> void:
	add_to_group("allies")
	if is_co_leader:
		set_follow_offset(Vector3(1.4, 0.0, -0.3))
	if mesh:
		mesh.visible = false
	_apply_hero_preset()
	super._ready()
	if is_co_leader:
		call_deferred("_bind_co_leader")


func _bind_co_leader() -> void:
	var commander_nodes := get_tree().get_nodes_in_group("commander")
	if commander_nodes.is_empty():
		return
	follow_target = commander_nodes[0]
	current_command = CommandType.Type.FOLLOW


func _apply_hero_preset() -> void:
	if not glb_model_path.is_empty():
		_apply_glb_model()
		return
	if hero_preset_id.is_empty():
		return

	var app := HeroPresets.build_appearance(hero_preset_id)
	unit_name = app.player_name

	var stats := HeroPresets.get_stats(hero_preset_id)
	max_health = stats.get("max_health", max_health)
	move_speed = stats.get("move_speed", move_speed)
	attack_damage = stats.get("attack_damage", attack_damage)
	faction_color = app.accent_color

	if character_visual:
		character_visual.apply_appearance(app)

	if is_co_leader:
		unit_name = "%s (Partner)" % app.player_name
		max_health *= 1.15
		attack_damage *= 1.1

	var plate_color: Color = Nameplate.PARTNER_COLOR if is_co_leader else Nameplate.ALLY_COLOR
	Nameplate.attach(self, unit_name, plate_color)

	if command_marker:
		command_marker.position.y = 1.85

	if selection_ring:
		selection_ring.position.y = 0.05
		selection_ring.visible = true
		var ring_mat := StandardMaterial3D.new()
		ring_mat.albedo_color = Nameplate.ALLY_COLOR
		ring_mat.emission_enabled = true
		ring_mat.emission = Nameplate.ALLY_COLOR * 0.4
		ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_mat.albedo_color.a = 0.55
		selection_ring.material_override = ring_mat


func _apply_glb_model() -> void:
	if unit_name.is_empty():
		unit_name = "Dragon"
	if mesh:
		mesh.visible = false
	GlbVisualScript.hide_procedural(self)
	GlbVisualScript.attach(self, glb_model_path, glb_scale, glb_y_offset, glb_rotation_y)
	var plate_color: Color = Nameplate.PARTNER_COLOR if is_co_leader else Nameplate.ALLY_COLOR
	Nameplate.attach(self, unit_name, plate_color)
	if command_marker:
		command_marker.position.y = 2.5
	if selection_ring:
		selection_ring.position.y = 0.05
		selection_ring.visible = true
		var ring_mat := StandardMaterial3D.new()
		ring_mat.albedo_color = Nameplate.ALLY_COLOR
		ring_mat.emission_enabled = true
		ring_mat.emission = Nameplate.ALLY_COLOR * 0.4
		ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ring_mat.albedo_color.a = 0.55
		selection_ring.material_override = ring_mat
