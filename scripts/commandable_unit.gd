class_name CommandableUnit
extends CharacterBody3D

signal command_changed(new_command: CommandType.Type)
signal morale_changed(value: float)
signal died

@export var unit_name: String = "Soldier"
@export var max_health: float = 100.0
@export var move_speed: float = 5.0
@export var attack_damage: float = 15.0
@export var attack_range: float = 2.0
@export var faction_color: Color = Color(0.3, 0.55, 0.9)

var health: float
var morale: float = 1.0
var current_command: CommandType.Type = CommandType.Type.FOLLOW
var follow_target: Node3D
var defend_position: Vector3
var charge_direction: Vector3 = Vector3.FORWARD
var is_selected: bool = false
var _attack_cooldown: float = 0.0
var _rally_timer: float = 0.0
var _follow_offset: Vector3 = Vector3.ZERO
var _follow_offset_set: bool = false

@onready var mesh: MeshInstance3D = $Mesh
@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var command_marker: MeshInstance3D = $CommandMarker


func _ready() -> void:
	health = max_health
	_setup_collision()
	_ensure_follow_offset()
	_apply_faction_color()
	_update_selection_visual()
	_update_command_marker()


func _setup_collision() -> void:
	collision_layer = 4
	collision_mask = 1 | 8


func set_follow_offset(offset: Vector3) -> void:
	_follow_offset = offset
	_follow_offset_set = true


func _ensure_follow_offset() -> void:
	if _follow_offset_set:
		return
	_follow_offset = Vector3(randf_range(-2.5, 2.5), 0.0, randf_range(-2.5, 2.5))
	_follow_offset_set = true


func _physics_process(delta: float) -> void:
	if health <= 0.0:
		return

	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	_process_morale(delta)
	_execute_command(delta)
	move_and_slide()


func receive_command(type: CommandType.Type, data: Dictionary = {}) -> void:
	current_command = type
	match type:
		CommandType.Type.FOLLOW:
			follow_target = data.get("target", follow_target)
		CommandType.Type.HOLD:
			defend_position = global_position
		CommandType.Type.CHARGE:
			charge_direction = data.get("direction", -global_transform.basis.z).normalized()
			morale = minf(morale + 0.15, 1.0)
		CommandType.Type.DEFEND:
			defend_position = data.get("position", global_position)
		CommandType.Type.RALLY:
			_rally_timer = 3.0
			morale = minf(morale + 0.4, 1.0)
			if follow_target and is_instance_valid(follow_target):
				defend_position = follow_target.global_position

	_update_command_marker()
	command_changed.emit(type)


func take_damage(amount: float) -> void:
	health -= amount
	morale = maxf(morale - 0.12, 0.0)
	morale_changed.emit(morale)
	if health <= 0.0:
		_die()


func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_selection_visual()


func _execute_command(delta: float) -> void:
	var speed_mult := lerpf(0.6, 1.0, morale)
	match current_command:
		CommandType.Type.FOLLOW:
			_move_toward(_get_follow_point(), move_speed * speed_mult)
		CommandType.Type.HOLD:
			velocity = velocity.lerp(Vector3.ZERO, delta * 8.0)
		CommandType.Type.CHARGE:
			velocity = charge_direction * move_speed * 1.6 * speed_mult
			_try_attack_nearby()
		CommandType.Type.ATTACK:
			var target := _find_combat_target()
			if target:
				_move_toward(target.global_position, move_speed * speed_mult)
				var strike_range := _get_strike_range(target)
				if global_position.distance_to(target.global_position) <= strike_range:
					_try_attack(target)
			else:
				_move_toward(defend_position, move_speed * 0.5 * speed_mult)
		CommandType.Type.DEFEND:
			var enemy := _find_nearest_enemy_in_range(8.0)
			if enemy:
				_try_attack(enemy)
			else:
				_move_toward(defend_position, move_speed * 0.35 * speed_mult)
		CommandType.Type.RALLY:
			if follow_target and is_instance_valid(follow_target):
				_move_toward(follow_target.global_position, move_speed * 0.8 * speed_mult)
			_rally_timer -= delta
			if _rally_timer <= 0.0:
				receive_command(CommandType.Type.HOLD)


func _get_follow_point() -> Vector3:
	if follow_target and is_instance_valid(follow_target):
		return follow_target.global_position + _follow_offset
	return global_position


func _move_toward(target: Vector3, speed: float) -> void:
	var flat_target := Vector3(target.x, global_position.y, target.z)
	var direction := (flat_target - global_position)
	direction.y = 0.0
	if direction.length() > 0.55:
		direction = direction.normalized()
		velocity = direction * speed
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 0.15)
	else:
		velocity = velocity.lerp(Vector3.ZERO, 0.25)


func _find_nearest_enemy() -> Node3D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node3D = null
	var best_dist := INF
	for node in enemies:
		if node is Node3D and node.has_method("take_damage"):
			var dist := global_position.distance_to(node.global_position)
			if dist < best_dist:
				best_dist = dist
				nearest = node
	return nearest


func _find_combat_target() -> Node3D:
	var enemy := _find_nearest_enemy()
	var capital := RebellionManager.get_capital_target()
	if enemy and capital:
		var enemy_dist := global_position.distance_to(enemy.global_position)
		var capital_dist := global_position.distance_to(capital.global_position)
		return enemy if enemy_dist <= capital_dist else capital
	if enemy:
		return enemy
	return capital


func _get_strike_range(target: Node3D) -> float:
	if target.is_in_group("capital"):
		return attack_range + 6.0
	return attack_range


func _find_nearest_enemy_in_range(range: float) -> Node3D:
	var enemy := _find_nearest_enemy()
	if enemy and global_position.distance_to(enemy.global_position) <= range:
		return enemy
	return null


func _try_attack_nearby() -> void:
	var enemy := _find_nearest_enemy_in_range(attack_range)
	if enemy:
		_try_attack(enemy)
		return
	var capital := RebellionManager.get_capital_target()
	if capital and global_position.distance_to(capital.global_position) <= attack_range + 6.0:
		_try_attack(capital)


func _try_attack(target: Node3D) -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = 0.8
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)


func _process_morale(delta: float) -> void:
	if current_command == CommandType.Type.HOLD:
		morale = minf(morale + delta * 0.02, 1.0)
	elif current_command == CommandType.Type.CHARGE:
		morale = minf(morale + delta * 0.05, 1.0)
	else:
		morale = maxf(morale - delta * 0.01, 0.2)
	morale_changed.emit(morale)


func _apply_faction_color() -> void:
	if mesh and mesh.mesh:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = faction_color
		mesh.material_override = mat


func _update_selection_visual() -> void:
	if selection_ring:
		selection_ring.visible = is_selected


func _update_command_marker() -> void:
	if not command_marker:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = CommandType.color_for(current_command)
	mat.emission_enabled = true
	mat.emission = CommandType.color_for(current_command) * 0.5
	command_marker.material_override = mat


func _die() -> void:
	died.emit()
	queue_free()
