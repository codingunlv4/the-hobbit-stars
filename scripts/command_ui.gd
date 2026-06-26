extends Control

@onready var battle_cry_label: Label = $Panel/Margin/VBox/BattleCry
@onready var commander_label: Label = $Panel/Margin/VBox/CommanderTitle
@onready var status_label: Label = $Panel/Margin/VBox/Status
@onready var command_buttons: HBoxContainer = $Panel/Margin/VBox/CommandButtons
@onready var rebellion_title: Label = $RebellionHUD/Margin/VBox/RebellionTitle
@onready var objective_label: Label = $RebellionHUD/Margin/VBox/Objective
@onready var capital_bar: ProgressBar = $RebellionHUD/Margin/VBox/CapitalBar
@onready var capital_label: Label = $RebellionHUD/Margin/VBox/CapitalLabel
@onready var player_bar: ProgressBar = $PlayerHUD/Margin/VBox/PlayerBar
@onready var player_label: Label = $PlayerHUD/Margin/VBox/PlayerLabel
@onready var combo_label: Label = $PlayerHUD/Margin/VBox/ComboLabel
@onready var squad_label: Label = $PlayerHUD/Margin/VBox/SquadLabel
@onready var briefing_panel: PanelContainer = $BriefingPanel
@onready var briefing_text: Label = $BriefingPanel/Margin/BriefingText
@onready var victory_panel: PanelContainer = $VictoryPanel
@onready var victory_text: Label = $VictoryPanel/Margin/VBox/VictoryText
@onready var defeat_panel: PanelContainer = $DefeatPanel
@onready var defeat_text: Label = $DefeatPanel/Margin/VBox/DefeatText
@onready var restart_button: Button = $DefeatPanel/Margin/VBox/RestartButton
@onready var help_label: Label = $HelpLabel

var _cry_timer: float = 0.0
var _briefing_timer: float = 0.0
var _commander: Commander
var _game_over: bool = false


func _ready() -> void:
	_build_command_buttons()
	CommandSystem.battle_cry.connect(_on_battle_cry)
	CommandSystem.command_issued.connect(_on_command_issued)
	CommandSystem.selection_changed.connect(_on_selection_changed)
	RebellionManager.capital_health_changed.connect(_on_capital_health_changed)
	RebellionManager.mission_briefing.connect(_on_mission_briefing)
	RebellionManager.rebellion_victory.connect(_on_rebellion_victory)
	RebellionManager.wave_deployed.connect(_on_wave_deployed)

	battle_cry_label.text = ""
	rebellion_title.text = "REBELLION BRAWL"
	objective_label.text = "Fight to the Capital — destroy the fortress!"
	capital_label.text = "Capital Fortress"
	capital_bar.max_value = 100.0
	capital_bar.value = 100.0
	player_bar.max_value = 100.0
	player_bar.value = 100.0
	combo_label.text = ""
	victory_panel.visible = false
	defeat_panel.visible = false
	briefing_panel.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	process_mode = Node.PROCESS_MODE_ALWAYS

	help_label.text = (
		"FIGHTING CONTROLS\n"
		+ "J / LMB — Light attack\n"
		+ "K — Heavy attack (combo finisher)\n"
		+ "E — Block\n"
		+ "Space — Dodge roll\n"
		+ "WASD — Move\n"
		+ "TAB + 3 — Rally allies to charge"
	)

	var leader := PlayerData.appearance.player_name
	var hero_id := PlayerData.appearance.hero_preset_id
	var partner_id := PlayerData.appearance.partner_hero_preset_id

	if not hero_id.is_empty():
		leader = "%s — %s" % [HeroPresets.get_display_name(hero_id), HeroPresets.get_title(hero_id)]
	if not partner_id.is_empty():
		leader += " & %s" % HeroPresets.get_display_name(partner_id)

	commander_label.text = "Fighter: %s" % leader
	player_label.text = leader

	if not hero_id.is_empty() and not partner_id.is_empty():
		battle_cry_label.text = "\"%s\" — \"%s\"" % [
			HeroPresets.get_intro_quote(hero_id),
			HeroPresets.get_intro_quote(partner_id),
		]
		_cry_timer = 7.0
	elif not hero_id.is_empty():
		var quote := HeroPresets.get_intro_quote(hero_id)
		if not quote.is_empty():
			battle_cry_label.text = "\"%s\" (%s)" % [quote, HeroPresets.get_movie_source(hero_id)]
			_cry_timer = 6.0
	status_label.text = "Fight your way forward — light attacks build combos!"

	call_deferred("_connect_commander")


func _connect_commander() -> void:
	var nodes := get_tree().get_nodes_in_group("commander")
	if nodes.is_empty():
		return
	_commander = nodes[0] as Commander
	if not _commander:
		return
	_commander.health_changed.connect(_on_player_health_changed)
	_commander.combo_changed.connect(_on_combo_changed)
	_commander.attack_landed.connect(_on_attack_landed)
	_commander.fighter_defeated.connect(_on_fighter_defeated)
	_on_player_health_changed(_commander.health, _commander.max_health)


func _process(delta: float) -> void:
	if _cry_timer > 0.0:
		_cry_timer -= delta
		if _cry_timer <= 0.0:
			battle_cry_label.text = ""

	if _briefing_timer > 0.0:
		_briefing_timer -= delta
		if _briefing_timer <= 0.0:
			briefing_panel.visible = false

	if not _game_over:
		_update_squad_display()


func _update_squad_display() -> void:
	var ally_lines: PackedStringArray = []
	for node in get_tree().get_nodes_in_group("allies"):
		if node is CommandableUnit:
			var ally: CommandableUnit = node
			var tag := " (partner)" if node is HeroAlly and node.is_co_leader else ""
			ally_lines.append("• %s%s" % [ally.unit_name, tag])

	var enemy_count := get_tree().get_nodes_in_group("enemies").size()
	var squad_text := "Fighting WITH:\n"
	if ally_lines.is_empty():
		squad_text += "  (no allies — press TAB)\n"
	else:
		squad_text += "  %s\n" % "\n  ".join(ally_lines)
	squad_text += "Fighting AGAINST: %d guard(s)" % enemy_count
	squad_label.text = squad_text


func _build_command_buttons() -> void:
	for type in CommandType.Type.size():
		var cmd_type: CommandType.Type = type
		var btn := Button.new()
		btn.text = "%d — %s" % [type + 1, CommandType.label_for(cmd_type)]
		btn.tooltip_text = CommandType.description_for(cmd_type)
		btn.custom_minimum_size = Vector2(120, 32)
		btn.pressed.connect(func(): CommandSystem.issue_command(cmd_type))
		command_buttons.add_child(btn)


func _on_player_health_changed(current: float, maximum: float) -> void:
	var percent := 0.0 if maximum <= 0.0 else (current / maximum) * 100.0
	player_bar.value = percent
	if percent < 30.0:
		player_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	else:
		player_label.add_theme_color_override("font_color", Color(0.55, 0.95, 0.65))


func _on_combo_changed(combo: int) -> void:
	if combo <= 1:
		combo_label.text = ""
	elif combo < 4:
		combo_label.text = "%d-hit combo!" % combo
	elif combo < 8:
		combo_label.text = "%d-hit COMBO!" % combo
	else:
		combo_label.text = "%d-hit UNSTOPPABLE!" % combo


func _on_attack_landed(_target_name: String) -> void:
	if _commander and _commander.combo_count >= 3:
		status_label.text = "Keep the pressure on — chain heavy attacks for finishers!"


func _on_fighter_defeated() -> void:
	if _game_over:
		return
	_game_over = true
	objective_label.text = "Defeated"
	status_label.text = "You fell in battle — press Try Again"
	player_bar.value = 0.0
	defeat_text.text = (
		"The Capital guards overwhelmed you.\n"
		+ "Use E to block, Space to dodge, and J to fight back!"
	)
	defeat_panel.visible = true
	get_tree().paused = true


func _on_battle_cry(text: String) -> void:
	battle_cry_label.text = "\"%s\"" % text
	_cry_timer = 4.0


func _on_command_issued(type: CommandType.Type, _units: Array) -> void:
	status_label.text = "Allies: %s" % CommandType.label_for(type)


func _on_selection_changed(units: Array) -> void:
	if units.is_empty():
		status_label.text = "TAB selects allies — press 3 to charge into the fight"
	else:
		status_label.text = "%d allies ready — press 3 to charge!" % units.size()


func _on_capital_health_changed(current: float, maximum: float) -> void:
	var percent := 0.0 if maximum <= 0.0 else (current / maximum) * 100.0
	capital_bar.value = percent
	capital_label.text = "Capital Fortress — %.0f%%" % percent


func _on_mission_briefing(text: String) -> void:
	briefing_text.text = text + "\n\n(Click anywhere to continue)"
	briefing_panel.visible = true
	_briefing_timer = 12.0


func _gui_input(event: InputEvent) -> void:
	if briefing_panel.visible and event is InputEventMouseButton and event.pressed:
		briefing_panel.visible = false
		_briefing_timer = 0.0


func _on_wave_deployed(wave_number: int) -> void:
	if _game_over:
		return
	status_label.text = "Wave %d incoming — fight through the guards!" % wave_number


func _on_rebellion_victory() -> void:
	_game_over = true
	get_tree().paused = true
	victory_panel.visible = true
	victory_text.text = (
		"THE CAPITAL HAS FALLEN!\n\n"
		+ "Your fists and blade shattered the fortress gates. "
		+ "Jedi, elves, and Mockingjay fought at your side — the Rebellion wins!"
	)
	objective_label.text = "Victory — you brawled your way to freedom!"


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/character_creator.tscn")
