class_name HumanProportions
extends RefCounted

var total_height: float = 1.75
var head_height: float = 0.23
var head_width: float = 0.15
var head_depth: float = 0.19
var neck_radius: float = 0.065
var neck_height: float = 0.1
var shoulder_width: float = 0.42
var chest_depth: float = 0.22
var waist_width: float = 0.3
var hip_width: float = 0.34
var upper_arm_length: float = 0.32
var forearm_length: float = 0.28
var hand_length: float = 0.1
var thigh_length: float = 0.42
var calf_length: float = 0.4
var foot_length: float = 0.24
var limb_radius: float = 0.065
var chest_bulge: float = 0.0
var beard: bool = false


static func from_appearance(app: CharacterAppearance) -> HumanProportions:
	var p := HumanProportions.new()

	match app.body_type:
		CharacterAppearance.BodyType.HUMAN:
			p.total_height = 1.75
		CharacterAppearance.BodyType.ELF:
			p.total_height = 1.88
			p.head_width *= 0.92
			p.limb_radius *= 0.9
		CharacterAppearance.BodyType.DWARF:
			p.total_height = 1.35
			p.shoulder_width *= 1.18
			p.limb_radius *= 1.12
			p.head_width *= 1.08
		CharacterAppearance.BodyType.OUTLANDER:
			p.total_height = 1.82
			p.limb_radius *= 0.92

	match app.gender:
		CharacterAppearance.Gender.MALE:
			p.shoulder_width *= 1.14
			p.hip_width *= 0.9
			p.waist_width *= 1.05
			p.chest_bulge = 0.03
			p.beard = app.helmet_style == CharacterAppearance.HelmetStyle.NONE
		CharacterAppearance.Gender.FEMALE:
			p.shoulder_width *= 0.86
			p.hip_width *= 1.14
			p.waist_width *= 0.88
			p.chest_bulge = 0.05
			p.head_width *= 0.94
			p.beard = false

	var scale := p.total_height / 1.75
	p.head_height *= scale
	p.neck_height *= scale
	p.upper_arm_length *= scale
	p.forearm_length *= scale
	p.thigh_length *= scale
	p.calf_length *= scale

	return p

func head_center_y() -> float:
	return total_height - head_height * 0.5

func foot_height() -> float:
	return 0.07

func leg_top() -> float:
	return foot_height() + calf_length + thigh_length

func shoulder_y() -> float:
	return total_height - head_height - neck_height - 0.02

func pelvis_y() -> float:
	return leg_top() - 0.04

func hip_y() -> float:
	return leg_top()
