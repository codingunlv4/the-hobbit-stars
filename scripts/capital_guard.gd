extends CharacterBody3D

@export var max_health: float = 95.0
@export var move_speed: float = 4.5
@export var attack_damage: float = 12.0
@export var attack_range: float = 2.0

var health: float
var _attack_cooldown: float = 0.0
var _target: Node3D

@onready var mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	collision_layer = 8
	collision_mask = 1 | 2 | 4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.12, 0.15)
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.05, 0.05) * 0.15
	mesh.material_override = mat


func _physics_process(delta: float) -> void:
	if health <= 0.0:
		return

	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	_target = _find_nearest_rebel()
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
				_attack_cooldown = 1.0
				if _target.has_method("take_damage"):
					_target.take_damage(attack_damage)
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 4.0)

	move_and_slide()


func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		queue_free()


func _find_nearest_rebel() -> Node3D:
	var targets: Array = get_tree().get_nodes_in_group("allies")
	targets.append_array(get_tree().get_nodes_in_group("commander"))
	var nearest: Node3D = null
	var best_dist := INF

	for node in targets:
		if node is Node3D:
			var dist := global_position.distance_to(node.global_position)
			if dist < best_dist:
				best_dist = dist
				nearest = node
	return nearest
