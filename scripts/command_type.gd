class_name CommandType
extends RefCounted

## Military orders inspired by Lord of the Rings and Star Wars battle leadership.

enum Type {
	FOLLOW,
	HOLD,
	CHARGE,
	ATTACK,
	DEFEND,
	RALLY,
}

const LABELS: Dictionary = {
	Type.FOLLOW: "Follow Me",
	Type.HOLD: "Hold Position",
	Type.CHARGE: "Charge!",
	Type.ATTACK: "Attack!",
	Type.DEFEND: "Defend!",
	Type.RALLY: "Rally!",
}

const DESCRIPTIONS: Dictionary = {
	Type.FOLLOW: "Stay close and trail the commander — like the Fellowship on the road.",
	Type.HOLD: "Stand your ground. None shall pass.",
	Type.CHARGE: "Full assault! For the King! For the Republic!",
	Type.ATTACK: "Engage the nearest enemy.",
	Type.DEFEND: "Protect this position and hold the line.",
	Type.RALLY: "Inspire the troops — restore morale and regroup.",
}

const HOTKEYS: Dictionary = {
	Type.FOLLOW: KEY_1,
	Type.HOLD: KEY_2,
	Type.CHARGE: KEY_3,
	Type.ATTACK: KEY_4,
	Type.DEFEND: KEY_5,
	Type.RALLY: KEY_6,
}

const COLORS: Dictionary = {
	Type.FOLLOW: Color(0.35, 0.75, 1.0),
	Type.HOLD: Color(0.9, 0.85, 0.3),
	Type.CHARGE: Color(1.0, 0.35, 0.2),
	Type.ATTACK: Color(1.0, 0.55, 0.2),
	Type.DEFEND: Color(0.4, 0.85, 0.45),
	Type.RALLY: Color(0.85, 0.55, 1.0),
}

static func label_for(type: Type) -> String:
	return LABELS.get(type, "Unknown")

static func description_for(type: Type) -> String:
	return DESCRIPTIONS.get(type, "")

static func color_for(type: Type) -> Color:
	return COLORS.get(type, Color.WHITE)

static func type_from_key(keycode: Key) -> Type:
	for type in HOTKEYS:
		if HOTKEYS[type] == keycode:
			return type
	return -1
