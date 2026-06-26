class_name CharacterVisual
extends Node3D

const MESH_QUALITY := 24
const PREVIEW_MESH_QUALITY := 10

var _active_mesh_quality: int = MESH_QUALITY


func apply_appearance(app: CharacterAppearance, preview_mode: bool = false) -> void:
	_active_mesh_quality = PREVIEW_MESH_QUALITY if preview_mode else MESH_QUALITY
	_clear_visuals()
	if preview_mode:
		call_deferred("_build_human", app)
	else:
		_build_human(app)


func _build_human(app: CharacterAppearance) -> void:
	var p := HumanProportions.from_appearance(app)
	var skin := _skin_mat(app.skin_color)
	var cloth := _cloth_mat(app.armor_color)
	var hair_mat := _hair_mat(app.hair_color)

	_build_legs(p, skin, cloth)
	_build_torso(p, skin, cloth, app)
	_build_arms(p, skin, app)
	_build_head(p, skin, app)
	_add_cape(app, p)
	_add_helmet(app, p, app)
	_add_weapon(app, p)


func _clear_visuals() -> void:
	for child in get_children():
		child.free()


func _build_legs(p: HumanProportions, skin: StandardMaterial3D, cloth: StandardMaterial3D) -> void:
	var hip_offset := p.hip_width * 0.22
	var foot_h := p.foot_height()
	var foot_y := foot_h * 0.5
	var calf_y := foot_h + p.calf_length * 0.5
	var thigh_y := foot_h + p.calf_length + p.thigh_length * 0.5

	for side: float in [-1.0, 1.0]:
		var x: float = hip_offset * side
		_add_limb("Thigh_%d" % side, Vector3(x, thigh_y, 0), p.limb_radius * 1.08, p.thigh_length, cloth)
		_add_limb("Calf_%d" % side, Vector3(x, calf_y, 0), p.limb_radius * 0.88, p.calf_length, skin)
		_add_box("Foot_%d" % side, Vector3(x, foot_y, p.foot_length * 0.12),
				Vector3(p.limb_radius * 1.6, foot_h, p.foot_length), skin)


func _build_torso(p: HumanProportions, skin: StandardMaterial3D, cloth: StandardMaterial3D, app: CharacterAppearance) -> void:
	var shoulder_y := p.shoulder_y()
	var pelvis_y := p.pelvis_y()
	var torso_mid := (shoulder_y + pelvis_y) * 0.5
	var torso_h := shoulder_y - pelvis_y

	_add_box("Torso", Vector3(0, torso_mid, 0),
			Vector3(p.shoulder_width, torso_h, p.chest_depth), cloth)

	_add_box("Chest", Vector3(0, shoulder_y - torso_h * 0.22, p.chest_bulge * 0.5),
			Vector3(p.shoulder_width * 0.82, torso_h * 0.38, p.chest_depth * 0.75 + p.chest_bulge), cloth)

	_add_box("Waist", Vector3(0, pelvis_y + torso_h * 0.18, 0),
			Vector3(p.waist_width, torso_h * 0.28, p.chest_depth * 0.72), cloth)

	_add_ellipsoid("Pelvis", Vector3(0, pelvis_y, 0),
			Vector3(p.hip_width * 0.5, 0.12, p.chest_depth * 0.45), cloth)

	_add_limb("Neck", Vector3(0, shoulder_y + p.neck_height * 0.45, 0),
			p.neck_radius, p.neck_height, skin)


func _build_arms(p: HumanProportions, skin: StandardMaterial3D, app: CharacterAppearance) -> void:
	var shoulder_y := p.shoulder_y() - 0.04
	var upper_y := shoulder_y - p.upper_arm_length * 0.5
	var fore_y := shoulder_y - p.upper_arm_length - p.forearm_length * 0.5
	var hand_y := shoulder_y - p.upper_arm_length - p.forearm_length - 0.05
	var shoulder_x := p.shoulder_width * 0.5 + 0.02

	for side: float in [-1.0, 1.0]:
		var x: float = shoulder_x * side
		_add_ellipsoid("Shoulder_%d" % side, Vector3(x, shoulder_y, 0),
				Vector3(0.09, 0.07, 0.08), skin)
		_add_limb("UpperArm_%d" % side, Vector3(x, upper_y, 0),
				p.limb_radius, p.upper_arm_length, skin)
		_add_limb("Forearm_%d" % side, Vector3(x, fore_y, 0),
				p.limb_radius * 0.82, p.forearm_length, skin)
		_add_box("Hand_%d" % side, Vector3(x, hand_y, 0.02),
				Vector3(0.07, 0.1, 0.04), skin)


func _build_head(p: HumanProportions, skin: StandardMaterial3D, app: CharacterAppearance) -> void:
	var head_y := p.head_center_y()
	var show_face := app.helmet_style == CharacterAppearance.HelmetStyle.NONE \
			or app.helmet_style == CharacterAppearance.HelmetStyle.HOOD

	_add_ellipsoid("Head", Vector3(0, head_y, 0),
			Vector3(p.head_width, p.head_height, p.head_depth), skin)

	if show_face:
		_add_ellipsoid("SkullTop", Vector3(0, head_y + p.head_height * 0.18, -0.01),
				Vector3(p.head_width * 0.92, p.head_height * 0.35, p.head_depth * 0.85), skin)
		_add_ellipsoid("Jaw", Vector3(0, head_y - p.head_height * 0.28, p.head_depth * 0.15),
				Vector3(p.head_width * 0.78, p.head_height * 0.28, p.head_depth * 0.55), skin)
		_add_ellipsoid("Nose", Vector3(0, head_y - p.head_height * 0.05, p.head_depth * 0.85),
				Vector3(0.025, 0.04, 0.03), skin)
		_add_ellipsoid("Brow", Vector3(0, head_y + p.head_height * 0.08, p.head_depth * 0.72),
				Vector3(p.head_width * 0.7, 0.03, 0.04), skin)

		var eye_y := head_y + p.head_height * 0.02
		var eye_z := p.head_depth * 0.72
		var eye_x := p.head_width * 0.38
		for side: float in [-1.0, 1.0]:
			_add_ellipsoid("EyeWhite_%d" % side, Vector3(eye_x * side, eye_y, eye_z),
					Vector3(0.028, 0.018, 0.012), _mat(Color(0.95, 0.95, 0.97)))
			_add_ellipsoid("Pupil_%d" % side, Vector3(eye_x * side, eye_y, eye_z + 0.012),
					Vector3(0.012, 0.012, 0.008), _mat(Color(0.12, 0.18, 0.28)))
			_add_ellipsoid("Ear_%d" % side, Vector3(p.head_width * 0.92 * side, head_y - 0.01, 0.0),
					Vector3(0.03, 0.055, 0.02), skin)

		_add_ellipsoid("Mouth", Vector3(0, head_y - p.head_height * 0.32, p.head_depth * 0.78),
				Vector3(0.045, 0.012, 0.018), _mat(app.skin_color.darkened(0.12)))

	if app.helmet_style != CharacterAppearance.HelmetStyle.HOOD \
			and app.helmet_style != CharacterAppearance.HelmetStyle.COWL:
		_add_hair(app, p, head_y)

	if p.beard and show_face:
		_add_ellipsoid("Beard", Vector3(0, head_y - p.head_height * 0.38, p.head_depth * 0.45),
				Vector3(p.head_width * 0.55, p.head_height * 0.22, p.head_depth * 0.4), _hair_mat(app.hair_color))


func _add_hair(app: CharacterAppearance, p: HumanProportions, head_y: float) -> void:
	var hair := _hair_mat(app.hair_color)
	var is_female := app.gender == CharacterAppearance.Gender.FEMALE
	var is_long := is_female or app.body_type == CharacterAppearance.BodyType.ELF

	_add_ellipsoid("HairTop", Vector3(0, head_y + p.head_height * 0.22, -0.02),
			Vector3(p.head_width * 1.02, p.head_height * 0.42, p.head_depth * 0.95), hair)

	if is_long:
		_add_ellipsoid("HairBack", Vector3(0, head_y - p.head_height * 0.05, -p.head_depth * 0.55),
				Vector3(p.head_width * 0.95, p.head_height * 0.75, p.head_depth * 0.45), hair)
		if is_female:
			_add_ellipsoid("HairSideL", Vector3(-p.head_width * 0.85, head_y - p.head_height * 0.2, 0.04),
					Vector3(0.06, p.head_height * 0.55, 0.07), hair)
			_add_ellipsoid("HairSideR", Vector3(p.head_width * 0.85, head_y - p.head_height * 0.2, 0.04),
					Vector3(0.06, p.head_height * 0.55, 0.07), hair)
	else:
		_add_ellipsoid("HairShort", Vector3(0, head_y + p.head_height * 0.1, -p.head_depth * 0.2),
				Vector3(p.head_width * 0.88, p.head_height * 0.25, p.head_depth * 0.7), hair)


func _add_cape(app: CharacterAppearance, p: HumanProportions) -> void:
	var cape := MeshInstance3D.new()
	cape.name = "Cape"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(p.shoulder_width * 2.2, p.total_height * 0.72)
	mesh.subdivide_width = 4
	mesh.subdivide_depth = 6
	cape.mesh = mesh
	cape.position = Vector3(0, p.total_height * 0.48, p.chest_depth * 0.55)
	cape.rotation_degrees = Vector3(-10, 0, 0)
	cape.material_override = _cloth_mat(app.accent_color)
	add_child(cape)


func _add_helmet(app: CharacterAppearance, p: HumanProportions, _appearance: CharacterAppearance) -> void:
	var head_y := p.head_center_y()
	match app.helmet_style:
		CharacterAppearance.HelmetStyle.HOOD:
			_add_ellipsoid("Hood", Vector3(0, head_y + 0.02, 0),
					Vector3(p.head_width * 1.35, p.head_height * 1.1, p.head_depth * 1.2),
					_cloth_mat(app.accent_color.darkened(0.08)))
		CharacterAppearance.HelmetStyle.HELM:
			_add_ellipsoid("Helm", Vector3(0, head_y + 0.02, 0),
					Vector3(p.head_width * 1.25, p.head_height * 1.05, p.head_depth * 1.15),
					_cloth_mat(app.armor_color.lightened(0.2)))
			_add_box("Visor", Vector3(0, head_y - p.head_height * 0.05, p.head_depth * 0.75),
					Vector3(p.head_width * 1.1, p.head_height * 0.18, 0.04), _mat(Color(0.08, 0.08, 0.1)))
		CharacterAppearance.HelmetStyle.COWL:
			var cowl_mat := _cloth_mat(app.accent_color)
			cowl_mat.emission_enabled = true
			cowl_mat.emission = app.accent_color * 0.12
			_add_ellipsoid("Cowl", Vector3(0, head_y, 0),
					Vector3(p.head_width * 1.2, p.head_height * 1.15, p.head_depth * 1.1), cowl_mat)


func _add_weapon(app: CharacterAppearance, p: HumanProportions) -> void:
	var hand_x := p.shoulder_width * 0.5 + 0.02
	var hand_y := p.shoulder_y() - p.upper_arm_length - p.forearm_length - 0.05
	match app.weapon_style:
		CharacterAppearance.WeaponStyle.SWORD:
			_add_box("SwordBlade", Vector3(hand_x + 0.08, hand_y + 0.22, 0.12),
					Vector3(0.05, 0.52, 0.018), _mat(Color(0.78, 0.8, 0.85), 0.25, 0.4))
			_add_box("SwordGuard", Vector3(hand_x + 0.08, hand_y + 0.02, 0.12),
					Vector3(0.14, 0.03, 0.05), _mat(Color(0.7, 0.7, 0.75), 0.5, 0.5))
			_add_box("SwordHilt", Vector3(hand_x + 0.08, hand_y - 0.04, 0.12),
					Vector3(0.05, 0.1, 0.05), _mat(Color(0.3, 0.18, 0.08)))
		CharacterAppearance.WeaponStyle.STAFF:
			_add_limb("Staff", Vector3(hand_x + 0.1, hand_y + 0.45, 0),
					0.035, 1.15, _mat(Color(0.38, 0.26, 0.14)))
			_add_ellipsoid("StaffOrb", Vector3(hand_x + 0.1, hand_y + 1.02, 0),
					Vector3(0.07, 0.07, 0.07), _mat(app.accent_color, 0.0, 0.3, true))
		CharacterAppearance.WeaponStyle.BLADE:
			var blade_mat := _mat(Color(0.45, 0.9, 1.0), 0.0, 0.2, true)
			_add_box("Blade", Vector3(hand_x + 0.08, hand_y + 0.24, 0.12),
					Vector3(0.035, 0.48, 0.035), blade_mat)
			_add_box("BladeHilt", Vector3(hand_x + 0.08, hand_y - 0.02, 0.12),
					Vector3(0.07, 0.12, 0.07), _mat(Color(0.18, 0.18, 0.22)))


func _add_limb(name: String, pos: Vector3, radius: float, length: float, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = length
	mesh.radial_segments = _active_mesh_quality
	mesh.rings = maxi(_active_mesh_quality / 2, 6)
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	add_child(node)
	return node


func _add_ellipsoid(name: String, pos: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = _active_mesh_quality
	mesh.rings = maxi(_active_mesh_quality / 2, 6)
	node.mesh = mesh
	node.position = pos
	node.scale = size
	node.material_override = material
	add_child(node)
	return node


func _add_box(name: String, pos: Vector3, size: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	add_child(node)
	return node


func _skin_mat(color: Color) -> StandardMaterial3D:
	return _mat(color, 0.0, 0.62)


func _hair_mat(color: Color) -> StandardMaterial3D:
	return _mat(color.darkened(0.05), 0.0, 0.85)


func _cloth_mat(color: Color) -> StandardMaterial3D:
	return _mat(color, 0.0, 0.78)


func _mat(color: Color, metallic := 0.0, roughness := 0.5, glow := false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	if glow:
		mat.emission_enabled = true
		mat.emission = color * 0.55
	return mat
