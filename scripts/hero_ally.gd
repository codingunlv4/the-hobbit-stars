class_name HeroAlly
extends CommandableUnit

@export var hero_preset_id: String = ""
@export var is_co_leader: bool = false

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

	if command_marker:
		command_marker.position.y = 1.85

	if selection_ring:
		selection_ring.position.y = 0.05
