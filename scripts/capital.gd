class_name Capital
extends Node3D

signal health_changed(current: float, maximum: float)
signal destroyed
signal wave_spawned(wave_number: int)

@export var max_health: float = 800.0
@export var spawn_interval: float = 9.0
@export var guards_per_wave: int = 3

var health: float
var _spawn_timer: float = 4.0
var _wave_number: int = 0

const GUARD_SCENE: PackedScene = preload("res://scenes/capital_guard.tscn")


func _ready() -> void:
	add_to_group("capital")
	health = max_health
	_build_fortress()
	RebellionManager.register_capital(self)


func _process(delta: float) -> void:
	if health <= 0.0:
		return

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		_spawn_guard_wave()


func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)
	_pulse_damage()
	if health <= 0.0:
		_on_fallen()


func get_assault_point() -> Vector3:
	return global_position + Vector3(0, 0, -4.0)


func _spawn_guard_wave() -> void:
	_wave_number += 1
	wave_spawned.emit(_wave_number)
	var enemies_parent := get_parent().get_node_or_null("Enemies")
	if not enemies_parent:
		return

	for i in guards_per_wave:
		var guard: Node3D = GUARD_SCENE.instantiate()
		var angle := (float(i) / float(guards_per_wave)) * TAU
		var offset := Vector3(cos(angle) * 5.0, 0.0, sin(angle) * 3.0 - 2.0)
		guard.global_position = global_position + offset
		enemies_parent.add_child(guard)


func _on_fallen() -> void:
	destroyed.emit()
	if has_node("Fortress"):
		$Fortress.visible = false
	if has_node("Ruins"):
		$Ruins.visible = true


func _pulse_damage() -> void:
	if not has_node("Fortress/Tower"):
		return
	var tower: MeshInstance3D = $Fortress/Tower
	var tween := create_tween()
	tween.tween_property(tower, "scale", Vector3(1.04, 0.96, 1.04), 0.08)
	tween.tween_property(tower, "scale", Vector3.ONE, 0.12)


func _build_fortress() -> void:
	var stone := _mat(Color(0.28, 0.26, 0.3))
	var dark_stone := _mat(Color(0.15, 0.14, 0.18))
	var banner := _mat(Color(0.55, 0.08, 0.08))

	var fortress := Node3D.new()
	fortress.name = "Fortress"
	add_child(fortress)

	_add_box(fortress, "WallLeft", Vector3(-7.0, 2.5, 0), Vector3(2.0, 5.0, 14.0), stone)
	_add_box(fortress, "WallRight", Vector3(7.0, 2.5, 0), Vector3(2.0, 5.0, 14.0), stone)
	_add_box(fortress, "WallBack", Vector3(0, 2.5, 7.0), Vector3(16.0, 5.0, 2.0), stone)
	_add_box(fortress, "GateArch", Vector3(0, 3.5, -6.5), Vector3(6.0, 7.0, 2.0), dark_stone)
	_add_box(fortress, "GateDoor", Vector3(0, 2.0, -6.2), Vector3(4.0, 4.0, 0.6), _mat(Color(0.22, 0.2, 0.24)))

	var tower := _add_box(fortress, "Tower", Vector3(0, 6.0, 2.0), Vector3(5.0, 12.0, 5.0), dark_stone)
	tower.name = "Tower"
	_add_box(fortress, "TowerTop", Vector3(0, 12.5, 2.0), Vector3(6.0, 1.5, 6.0), stone)
	_add_box(fortress, "Banner", Vector3(0, 10.0, 5.2), Vector3(3.0, 2.0, 0.15), banner)

	var ruins := Node3D.new()
	ruins.name = "Ruins"
	ruins.visible = false
	add_child(ruins)
	_add_box(ruins, "RubbleA", Vector3(-2.0, 0.6, 0), Vector3(4.0, 1.2, 3.0), stone)
	_add_box(ruins, "RubbleB", Vector3(3.0, 0.4, 1.5), Vector3(3.0, 0.8, 2.5), dark_stone)
	_add_box(ruins, "RubbleC", Vector3(0, 0.3, -2.0), Vector3(5.0, 0.6, 2.0), stone)


func _add_box(parent: Node3D, name: String, pos: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	parent.add_child(node)
	return node


func _mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	return mat
