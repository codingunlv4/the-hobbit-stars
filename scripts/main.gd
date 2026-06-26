extends Node3D

@onready var commander: Commander = $Commander
@onready var allies: Node3D = $Allies
@onready var enemies: Node3D = $Enemies
@onready var ground: MeshInstance3D = $Ground

const GlbVisual = preload("res://scripts/glb_visual.gd")
const HERO_ALLY_SCENE: PackedScene = preload("res://scenes/hero_ally.tscn")
const CAPITAL_GUARD_SCENE: PackedScene = preload("res://scenes/capital_guard.tscn")

const KNIGHT_SCALE := 1.0
const KNIGHT_Y_OFFSET := 0.0
const DRAGON_SCALE := 0.32
const DRAGON_Y_OFFSET := 0.4

const STARTING_GUARD_POSITIONS: Array[Vector3] = [
	Vector3(8, 0, 18),
	Vector3(12, 0, 20),
	Vector3(4, 0, 20),
	Vector3(10, 0, 22),
]


func _ready() -> void:
	_setup_fallback_camera()
	_apply_knight_hero()
	CommandSystem.register_commander(commander)
	commander.fighter_defeated.connect(_on_commander_defeated)
	_setup_battlefield()
	_spawn_dragon_ally()
	_spawn_starting_guards()


func _setup_fallback_camera() -> void:
	if has_node("FallbackCamera"):
		return
	var cam := Camera3D.new()
	cam.name = "FallbackCamera"
	cam.position = Vector3(0, 20, -14)
	cam.rotation_degrees = Vector3(-50, 0, 0)
	cam.fov = 65.0
	cam.current = false
	add_child(cam)


func _on_commander_defeated() -> void:
	var cam := get_node_or_null("FallbackCamera") as Camera3D
	if cam:
		cam.current = true


func _apply_knight_hero() -> void:
	commander.apply_glb_model(GlbVisual.KNIGHT, KNIGHT_SCALE, KNIGHT_Y_OFFSET, "Knight")
	commander.max_health = 160.0
	commander.health = commander.max_health
	commander.move_speed = 5.5
	commander.light_damage = 22.0
	commander.heavy_damage = 36.0
	commander.health_changed.emit(commander.health, commander.max_health)


func _setup_battlefield() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.34, 0.16)
	ground.material_override = mat
	_setup_ground_collision()
	_brighten_world()


func _brighten_world() -> void:
	var world_env := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_env and world_env.environment:
		world_env.environment.ambient_light_energy = 0.65
		world_env.environment.ambient_light_color = Color(0.75, 0.82, 0.95)
	var sky := world_env.environment.sky if world_env and world_env.environment else null
	if sky and sky.sky_material is ProceduralSkyMaterial:
		var proc_sky: ProceduralSkyMaterial = sky.sky_material
		proc_sky.sky_top_color = Color(0.35, 0.55, 0.9)
		proc_sky.sky_horizon_color = Color(0.65, 0.78, 0.95)
		proc_sky.ground_horizon_color = Color(0.25, 0.38, 0.18)
		proc_sky.ground_bottom_color = Color(0.12, 0.2, 0.1)


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


func _spawn_dragon_ally() -> void:
	var dragon: HeroAlly = HERO_ALLY_SCENE.instantiate()
	dragon.unit_name = "Dragon"
	dragon.glb_model_path = GlbVisual.DRAGON
	dragon.glb_scale = DRAGON_SCALE
	dragon.glb_y_offset = DRAGON_Y_OFFSET
	dragon.glb_rotation_y = 180.0
	dragon.max_health = 220.0
	dragon.attack_damage = 28.0
	dragon.move_speed = 5.0
	dragon.is_co_leader = true
	dragon.set_follow_offset(Vector3(-2.8, 0.0, -1.2))
	allies.add_child(dragon)
	dragon.global_position = commander.global_position + Vector3(-2.8, 0, -1.2)
	CommandSystem.register_unit(dragon)


func _spawn_starting_guards() -> void:
	for pos in STARTING_GUARD_POSITIONS:
		var guard: Node3D = CAPITAL_GUARD_SCENE.instantiate()
		enemies.add_child(guard)
		guard.global_position = pos
