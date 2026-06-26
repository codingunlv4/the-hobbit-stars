class_name Commander
extends CharacterBody3D

const Nameplate = preload("res://scripts/unit_nameplate.gd")
const GlbVisualScript = preload("res://scripts/glb_visual.gd")

signal health_changed(current: float, maximum: float)
signal combo_changed(combo: int)
signal fighter_defeated
signal attack_landed(target_name: String)

enum FighterState { FREE, ATTACK_LIGHT, ATTACK_HEAVY, BLOCKING, DODGING, HITSTUN }

@export var move_speed: float = 7.0
@export var commander_title: String = "Captain of the Free Peoples"
@export var max_health: float = 200.0
@export var light_damage: float = 18.0
@export var heavy_damage: float = 30.0
@export var light_range: float = 2.6
@export var heavy_range: float = 3.3
@export var block_reduction: float = 0.7
@export var dodge_speed: float = 15.0
@export var dodge_duration: float = 0.2

var health: float
var combo_count: int = 0

var _state: FighterState = FighterState.FREE
var _state_timer: float = 0.0
var _attack_hit: bool = false
var _light_combo_window: float = 0.0
var _combo_decay: float = 0.0
var _iframes: float = 0.0
var _dodge_direction: Vector3 = Vector3.ZERO
var _is_blocking: bool = false
var _camera_yaw: float = 0.0
var _flash_timer: float = 0.0

@onready var character_visual: CharacterVisual = $CharacterVisual
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D


func _ready() -> void:
	add_to_group("commander")
	apply_hero_stats()
	health = max_health
	collision_layer = 2
	collision_mask = 1
	_iframes = 3.0
	health_changed.emit(health, max_health)


func apply_appearance(app: CharacterAppearance) -> void:
	commander_title = app.player_name
	if character_visual:
		character_visual.apply_appearance(app)
	Nameplate.attach(self, app.player_name, Nameplate.PLAYER_COLOR)


func apply_glb_model(glb_path: String, scale: float = 1.0, y_offset: float = 0.0, display_name: String = "Knight") -> void:
	commander_title = display_name
	GlbVisualScript.hide_procedural(self)
	GlbVisualScript.attach(self, glb_path, scale, y_offset, 180.0)
	Nameplate.attach(self, display_name, Nameplate.PLAYER_COLOR)


func apply_hero_stats() -> void:
	var hero_id := PlayerData.appearance.hero_preset_id
	if hero_id.is_empty():
		return
	var stats := HeroPresets.get_stats(hero_id)
	if stats.is_empty():
		return
	max_health = stats.get("max_health", max_health)
	move_speed = stats.get("move_speed", move_speed)
	light_damage = stats.get("attack_damage", light_damage)
	heavy_damage = light_damage * 1.65


func take_damage(amount: float, knockback: Vector3 = Vector3.ZERO, hitstun: float = 0.0) -> void:
	if _iframes > 0.0 or health <= 0.0:
		return
	if _is_blocking:
		amount *= 1.0 - block_reduction
		hitstun *= 0.35
		knockback *= 0.25
	health -= amount
	health_changed.emit(health, max_health)
	if knockback.length() > 0.01:
		velocity += knockback
	if hitstun > 0.0 and _state != FighterState.DODGING:
		_enter_state(FighterState.HITSTUN, hitstun)
	_flash_timer = 0.12
	if health <= 0.0:
		_die()


func _die() -> void:
	fighter_defeated.emit()
	if camera:
		camera.current = false
	if character_visual:
		character_visual.visible = false
	var glb := get_node_or_null("GlbModel")
	if glb:
		glb.visible = false
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	set_process_unhandled_input(false)


func _physics_process(delta: float) -> void:
	_state_timer = maxf(_state_timer - delta, 0.0)
	_light_combo_window = maxf(_light_combo_window - delta, 0.0)
	_iframes = maxf(_iframes - delta, 0.0)
	_flash_timer = maxf(_flash_timer - delta, 0.0)
	_update_hit_flash()

	if _combo_decay > 0.0:
		_combo_decay -= delta
		if _combo_decay <= 0.0 and combo_count > 0:
			combo_count = 0
			combo_changed.emit(combo_count)

	match _state:
		FighterState.FREE:
			_process_free(delta)
		FighterState.ATTACK_LIGHT, FighterState.ATTACK_HEAVY:
			_process_attack(delta)
		FighterState.BLOCKING:
			_process_blocking(delta)
		FighterState.DODGING:
			_process_dodge(delta)
		FighterState.HITSTUN:
			_process_hitstun(delta)

	move_and_slide()


func _process_free(delta: float) -> void:
	if Input.is_action_pressed("block"):
		_enter_state(FighterState.BLOCKING, 0.0)
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var cam_basis := camera_pivot.global_transform.basis
	var direction := (cam_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	direction.y = 0.0

	if direction.length() > 0.01:
		velocity = direction * move_speed
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 0.2)
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 10.0)


func _process_blocking(delta: float) -> void:
	_is_blocking = Input.is_action_pressed("block")
	if not _is_blocking:
		_state = FighterState.FREE
		return
	velocity = velocity.lerp(Vector3.ZERO, delta * 14.0)


func _process_dodge(delta: float) -> void:
	velocity = _dodge_direction * dodge_speed
	if _state_timer <= 0.0:
		_state = FighterState.FREE
		velocity = velocity.lerp(Vector3.ZERO, delta * 8.0)


func _process_hitstun(delta: float) -> void:
	velocity = velocity.lerp(Vector3.ZERO, delta * 6.0)
	if _state_timer <= 0.0:
		_state = FighterState.FREE


func _process_attack(delta: float) -> void:
	velocity = velocity.lerp(Vector3.ZERO, delta * 12.0)
	var windup := 0.08 if _state == FighterState.ATTACK_LIGHT else 0.14
	if not _attack_hit and _state_timer <= windup:
		_resolve_attack_hit()
	if _state_timer <= 0.0:
		_state = FighterState.FREE


func _start_light_attack() -> void:
	if _state != FighterState.FREE:
		return
	_attack_hit = false
	_enter_state(FighterState.ATTACK_LIGHT, 0.32)


func _start_heavy_attack() -> void:
	if _state != FighterState.FREE and not (_state == FighterState.ATTACK_LIGHT and _light_combo_window > 0.0):
		return
	_attack_hit = false
	_enter_state(FighterState.ATTACK_HEAVY, 0.52)


func _start_dodge() -> void:
	if _state != FighterState.FREE:
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var cam_basis := camera_pivot.global_transform.basis
	_dodge_direction = (cam_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	_dodge_direction.y = 0.0
	if _dodge_direction.length() < 0.01:
		_dodge_direction = -global_transform.basis.z
		_dodge_direction.y = 0.0
		_dodge_direction = _dodge_direction.normalized()
	_iframes = 0.38
	_enter_state(FighterState.DODGING, dodge_duration)


func _resolve_attack_hit() -> void:
	if _attack_hit:
		return
	_attack_hit = true

	var is_heavy := _state == FighterState.ATTACK_HEAVY
	var damage: float = heavy_damage if is_heavy else light_damage
	var reach: float = heavy_range if is_heavy else light_range
	var knockback_force: float = 7.0 if is_heavy else 3.5
	var hitstun: float = 0.45 if is_heavy else 0.22

	if not is_heavy:
		_light_combo_window = 0.55
	elif _light_combo_window > 0.0:
		damage *= 1.4

	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	for group_name in ["enemies", "capital"]:
		for node in get_tree().get_nodes_in_group(group_name):
			if not node is Node3D or not node.has_method("take_damage"):
				continue
			var to_target: Vector3 = node.global_position - global_position
			to_target.y = 0.0
			var dist: float = to_target.length()
			if dist > reach:
				continue
			if dist > 0.05 and forward.dot(to_target.normalized()) < 0.25:
				continue
			var knockback: Vector3 = forward * knockback_force
			node.take_damage(damage, knockback, hitstun)
			combo_count += 1
			_combo_decay = 2.5
			combo_changed.emit(combo_count)
			attack_landed.emit(node.name)


func _enter_state(new_state: FighterState, duration: float) -> void:
	_state = new_state
	_state_timer = duration
	if new_state != FighterState.BLOCKING:
		_is_blocking = false


func _update_hit_flash() -> void:
	if not character_visual:
		return
	var scale_val := 1.08 if _flash_timer > 0.0 else 1.0
	character_visual.scale = Vector3.ONE * scale_val


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_camera_yaw -= event.relative.x * 0.003
		camera_pivot.rotation.y = _camera_yaw

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.z = clampf(camera.position.z - 1.0, -18.0, -8.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.z = clampf(camera.position.z + 1.0, -18.0, -8.0)
		elif event.button_index == MOUSE_BUTTON_LEFT and _state == FighterState.FREE:
			if not _is_pointer_over_ui():
				_start_light_attack()

	if event.is_action_pressed("attack_light"):
		_start_light_attack()
	elif event.is_action_pressed("attack_heavy"):
		_start_heavy_attack()
	elif event.is_action_pressed("dodge"):
		_start_dodge()


func get_charge_direction() -> Vector3:
	return -global_transform.basis.z.normalized()


func _is_pointer_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null
