extends Node3D

@onready var commander: Commander = $Commander
@onready var allies: Node3D = $Allies
@onready var enemies: Node3D = $Enemies
@onready var ground: MeshInstance3D = $Ground

const HERO_ALLY_SCENE: PackedScene = preload("res://scenes/hero_ally.tscn")
const CAPITAL_GUARD_SCENE: PackedScene = preload("res://scenes/capital_guard.tscn")

const ALLY_POSITIONS: Array[Vector3] = [
	Vector3(-4, 0, -3),
	Vector3(-4, 0, 3),
	Vector3(-6, 0, 0),
	Vector3(-6, 0, -4),
	Vector3(-6, 0, 4),
]

const STARTING_GUARD_POSITIONS: Array[Vector3] = [
	Vector3(8, 0, 18),
	Vector3(12, 0, 20),
	Vector3(4, 0, 22),
	Vector3(10, 0, 24),
]


func _ready() -> void:
	_apply_player_appearance()
	CommandSystem.register_commander(commander)
	_setup_battlefield()
	_spawn_partner_hero()
	_spawn_legendary_allies()
	_spawn_starting_guards()


func _apply_player_appearance() -> void:
	commander.apply_appearance(PlayerData.appearance)


func _setup_battlefield() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.34, 0.16)
	ground.material_override = mat
	_setup_ground_collision()


func _setup_ground_collision() -> void:
	if has_node("GroundBody"):
		return
	var body := StaticBody3D.new()
	body.name = "GroundBody"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(60.0, 0.2, 60.0)
	shape.shape = box
	shape.position = Vector3(0.0, -0.1, 0.0)
	body.add_child(shape)
	add_child(body)
	body.owner = owner if owner else self


func _get_excluded_hero_ids() -> Array[String]:
	var excluded: Array[String] = []
	if not PlayerData.appearance.hero_preset_id.is_empty():
		excluded.append(PlayerData.appearance.hero_preset_id)
	if not PlayerData.appearance.partner_hero_preset_id.is_empty():
		excluded.append(PlayerData.appearance.partner_hero_preset_id)
	return excluded


func _spawn_partner_hero() -> void:
	var partner_id := PlayerData.appearance.partner_hero_preset_id
	if partner_id.is_empty():
		return

	var partner: HeroAlly = HERO_ALLY_SCENE.instantiate()
	partner.hero_preset_id = partner_id
	partner.is_co_leader = true
	partner.set_follow_offset(Vector3(1.4, 0.0, -0.3))
	partner.global_position = commander.global_position + Vector3(1.4, 0, -0.3)
	allies.add_child(partner)
	CommandSystem.register_unit(partner)


func _register_allies() -> void:
	for child in allies.get_children():
		if child is CommandableUnit and not child.is_in_group("registered_ally"):
			child.add_to_group("registered_ally")
			CommandSystem.register_unit(child)


func _spawn_legendary_allies() -> void:
	var party := HeroPresets.get_party_ally_ids(_get_excluded_hero_ids())

	for i in party.size():
		if i >= ALLY_POSITIONS.size():
			break
		var hero: HeroAlly = HERO_ALLY_SCENE.instantiate()
		hero.hero_preset_id = party[i]
		hero.set_follow_offset(ALLY_POSITIONS[i])
		hero.global_position = ALLY_POSITIONS[i]
		allies.add_child(hero)

	_register_allies()


func _spawn_starting_guards() -> void:
	for pos in STARTING_GUARD_POSITIONS:
		var guard: Node3D = CAPITAL_GUARD_SCENE.instantiate()
		guard.global_position = pos
		enemies.add_child(guard)
