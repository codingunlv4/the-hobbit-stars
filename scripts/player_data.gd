extends Node

const SAVE_PATH := "user://character_appearance.tres"

var appearance: CharacterAppearance = CharacterAppearance.new()
var has_customized: bool = false


func _ready() -> void:
	load_appearance()


func set_appearance(new_appearance: CharacterAppearance) -> void:
	appearance = new_appearance.duplicate_appearance()
	has_customized = true
	save_appearance()


func save_appearance() -> void:
	var err := ResourceSaver.save(appearance, SAVE_PATH)
	if err != OK:
		push_warning("Could not save character: %s" % error_string(err))


func load_appearance() -> void:
	if not ResourceLoader.exists(SAVE_PATH):
		return
	var loaded := ResourceLoader.load(SAVE_PATH)
	if loaded is CharacterAppearance:
		appearance = loaded
		has_customized = true
