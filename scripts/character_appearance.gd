class_name CharacterAppearance
extends Resource

enum BodyType { HUMAN, ELF, DWARF, OUTLANDER }
enum Gender { MALE, FEMALE }
enum HelmetStyle { NONE, HOOD, HELM, COWL }
enum WeaponStyle { SWORD, STAFF, BLADE }

@export var player_name: String = "Hero"
@export var hero_preset_id: String = ""
@export var partner_hero_preset_id: String = ""
@export var gender: Gender = Gender.MALE
@export var body_type: BodyType = BodyType.HUMAN
@export var skin_color: Color = Color(0.82, 0.65, 0.52)
@export var hair_color: Color = Color(0.25, 0.15, 0.08)
@export var armor_color: Color = Color(0.35, 0.38, 0.45)
@export var accent_color: Color = Color(0.55, 0.12, 0.12)
@export var helmet_style: HelmetStyle = HelmetStyle.NONE
@export var weapon_style: WeaponStyle = WeaponStyle.SWORD

const GENDER_LABELS: Dictionary = {
	Gender.MALE: "Male",
	Gender.FEMALE: "Female",
}

const BODY_LABELS: Dictionary = {
	BodyType.HUMAN: "Human",
	BodyType.ELF: "Elf",
	BodyType.DWARF: "Dwarf",
	BodyType.OUTLANDER: "Outlander",
}

const HELMET_LABELS: Dictionary = {
	HelmetStyle.NONE: "No Headgear",
	HelmetStyle.HOOD: "Hooded Cloak",
	HelmetStyle.HELM: "Battle Helm",
	HelmetStyle.COWL: "Jedi Cowl",
}

const WEAPON_LABELS: Dictionary = {
	WeaponStyle.SWORD: "Sword",
	WeaponStyle.STAFF: "Wizard Staff",
	WeaponStyle.BLADE: "Energy Blade",
}

const SKIN_PRESETS: Array[Color] = [
	Color(0.95, 0.82, 0.72),
	Color(0.82, 0.65, 0.52),
	Color(0.62, 0.46, 0.34),
	Color(0.42, 0.30, 0.22),
	Color(0.78, 0.55, 0.45),
]

const HAIR_PRESETS: Array[Color] = [
	Color(0.08, 0.06, 0.05),
	Color(0.25, 0.15, 0.08),
	Color(0.55, 0.38, 0.18),
	Color(0.75, 0.72, 0.65),
	Color(0.15, 0.22, 0.45),
	Color(0.55, 0.12, 0.12),
]

const ARMOR_PRESETS: Array[Color] = [
	Color(0.35, 0.38, 0.45),
	Color(0.25, 0.45, 0.35),
	Color(0.45, 0.38, 0.22),
	Color(0.20, 0.28, 0.55),
	Color(0.55, 0.55, 0.58),
	Color(0.15, 0.15, 0.18),
]

const ACCENT_PRESETS: Array[Color] = [
	Color(0.55, 0.12, 0.12),
	Color(0.15, 0.22, 0.55),
	Color(0.12, 0.38, 0.22),
	Color(0.55, 0.42, 0.12),
	Color(0.35, 0.12, 0.45),
	Color(0.85, 0.85, 0.90),
]

static func gender_label(gender_type: Gender) -> String:
	return GENDER_LABELS.get(gender_type, "Unknown")

static func body_label(type: BodyType) -> String:
	return BODY_LABELS.get(type, "Unknown")

static func helmet_label(style: HelmetStyle) -> String:
	return HELMET_LABELS.get(style, "Unknown")

static func weapon_label(style: WeaponStyle) -> String:
	return WEAPON_LABELS.get(style, "Unknown")

func duplicate_appearance() -> CharacterAppearance:
	var copy := CharacterAppearance.new()
	copy.player_name = player_name
	copy.hero_preset_id = hero_preset_id
	copy.partner_hero_preset_id = partner_hero_preset_id
	copy.gender = gender
	copy.body_type = body_type
	copy.skin_color = skin_color
	copy.hair_color = hair_color
	copy.armor_color = armor_color
	copy.accent_color = accent_color
	copy.helmet_style = helmet_style
	copy.weapon_style = weapon_style
	return copy
