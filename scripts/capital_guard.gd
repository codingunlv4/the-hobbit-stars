extends CharacterBody3D

const Nameplate = preload("res://scripts/unit_nameplate.gd")

@export var max_health: float = 95.0
@export var move_speed: float = 4.5
@export var attack_damage: float = 9.0
@export var attack_range: float = 2.0

var health: float
var _attack_cooldown: float = 0.0
var _hitstun_timer: float = 0.0
var _target: Node3D
var _flash_timer: float = 0.0

@onready var mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	collision_layer = 8
	collision_mask = 1 | 2 | 4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.72, 0.14, 0.12)
	mat.emission_enabled = true
	mat.emission = Color(0.9, 0.2, 0.15) * 0.35
	mesh.material_override = mat
	mesh.scale = Vector3(1.08, 1.08, 1.08)
	Nameplate.attach(self, "Capital Guard", Nameplate.ENEMY_COLOR, 2.0)


func _physics_process(delta: float) -> void:
	if health <= 0.0:
		return

	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	_hitstun_timer = maxf(_hitstun_timer - delta, 0.0)
	_flash_timer = maxf(_flash_timer - delta, 0.0)
	_update_hit_flash()

	if _hitstun_timer > 0.0:
		velocity = velocity.lerp(Vector3.ZERO, delta * 10.0)
		move_and_slide()
		return

	_target = _find_priority_target()
	if _target:
		var dist := global_position.distance_to(_target.global_position)
		if dist > attack_range:
			var dir := (_target.global_position - global_position).normalized()
			dir.y = 0.0
			velocity = dir * move_speed
			var target_yaw := atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, target_yaw, 0.15)
		else:
			velocity = Vector3.ZERO
			if _attack_cooldown <= 0.0:
				_attack_cooldown = 0.85
				if _target.has_method("take_damage"):
					_target.take_damage(attack_damage, -global_transform.basis.z * 2.0, 0.15)
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 4.0)

	move_and_slide()


func take_damage(amount: float, knockback: Vector3 = Vector3.ZERO, hitstun: float = 0.0) -> void:
	health -= amount
	_hitstun_timer = maxf(_hitstun_timer, hitstun)
	if knockback.length() > 0.01:
		velocity += knockback
	_flash_timer = 0.1
	if health <= 0.0:
		queue_free()


func _find_priority_target() -> Node3D:
	for node in get_tree().get_nodes_in_group("commander"):
		if node is Node3D and node.has_method("take_damage"):
			var dist: float = global_position.distance_to(node.global_position)
			if dist < 18.0:
				return node

	var targets: Array = get_tree().get_nodes_in_group("allies")
	var nearest: Node3D = null
	var best_dist := INF

	for node in targets:
		if node is Node3D and node.has_method("take_damage"):
			var dist := global_position.distance_to(node.global_position)
			if dist < best_dist:
				best_dist = dist
				nearest = node
	return nearest


func _update_hit_flash() -> void:
	if not mesh:
		return
	if _flash_timer > 0.0:
		mesh.scale = Vector3(1.12, 0.88, 1.12)
	else:
		mesh.scale = Vector3.ONE
