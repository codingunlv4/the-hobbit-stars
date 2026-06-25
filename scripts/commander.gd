class_name Commander
extends CharacterBody3D

@export var move_speed: float = 7.0
@export var commander_title: String = "Captain of the Free Peoples"
@export var max_health: float = 200.0

var health: float
var _camera_yaw: float = 0.0

@onready var character_visual: CharacterVisual = $CharacterVisual
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D


func _ready() -> void:
	add_to_group("commander")
	health = max_health
	collision_layer = 2
	collision_mask = 1


func apply_appearance(app: CharacterAppearance) -> void:
	commander_title = app.player_name
	if character_visual:
		character_visual.apply_appearance(app)


func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		queue_free()


func _physics_process(delta: float) -> void:
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

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_camera_yaw -= event.relative.x * 0.003
		camera_pivot.rotation.y = _camera_yaw

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.z = clampf(camera.position.z - 1.0, -18.0, -8.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.z = clampf(camera.position.z + 1.0, -18.0, -8.0)


func get_charge_direction() -> Vector3:
	return -global_transform.basis.z.normalized()
