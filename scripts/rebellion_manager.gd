extends Node

signal capital_health_changed(current: float, maximum: float)
signal rebellion_victory
signal mission_briefing(text: String)
signal wave_deployed(wave_number: int)

var capital: Capital
var is_active: bool = false
var waves_spawned: int = 0

const MISSION_OPENING := (
	"FIGHT YOUR WAY TO THE CAPITAL! Punch, kick, and slash through waves of guards. "
	+ "Legends fight beside you — but YOU are the brawler who breaks the gate."
)


func register_capital(cap: Capital) -> void:
	capital = cap
	is_active = true
	cap.health_changed.connect(_on_capital_health_changed)
	cap.destroyed.connect(_on_capital_destroyed)
	cap.wave_spawned.connect(_on_wave_spawned)

	var briefing := MISSION_OPENING
	var hero_id := PlayerData.appearance.hero_preset_id
	var partner_id := PlayerData.appearance.partner_hero_preset_id

	if not hero_id.is_empty() and not partner_id.is_empty():
		briefing += "\n\n%s (%s) and %s (%s) lead the Rebellion together." % [
			HeroPresets.get_display_name(hero_id),
			HeroPresets.get_movie_source(hero_id),
			HeroPresets.get_display_name(partner_id),
			HeroPresets.get_movie_source(partner_id),
		]
	elif not hero_id.is_empty():
		var quote := HeroPresets.get_intro_quote(hero_id)
		if not quote.is_empty():
			briefing += "\n\n\"%s\" — %s" % [quote, HeroPresets.get_movie_source(hero_id)]
	mission_briefing.emit(briefing)
	capital_health_changed.emit(cap.health, cap.max_health)


func get_capital_target() -> Node3D:
	if capital and capital.health > 0.0:
		return capital
	return null


func get_charge_direction_toward_capital(from_position: Vector3) -> Vector3:
	if not capital:
		return Vector3.FORWARD
	var dir := capital.global_position - from_position
	dir.y = 0.0
	if dir.length() < 0.01:
		return Vector3.FORWARD
	return dir.normalized()


func _on_capital_health_changed(current: float, maximum: float) -> void:
	capital_health_changed.emit(current, maximum)


func _on_capital_destroyed() -> void:
	is_active = false
	rebellion_victory.emit()


func _on_wave_spawned(wave_number: int) -> void:
	waves_spawned = wave_number
	wave_deployed.emit(wave_number)
