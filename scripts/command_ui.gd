extends Control

const GlbVisualScript = preload("res://scripts/glb_visual.gd")

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
@onready var player_vbox: VBoxContainer = $PlayerHUD/Margin/VBox

var _cry_timer: float = 0.0
var _briefing_timer: float = 0.0
var _commander: Commander
var _game_over: bool = false


func _ready() -> void:
	_style_progress_bars()
	_setup_hero_portraits()
	_build_command_buttons()
	CommandSystem.battle_cry.connect(_on_battle_cry)
	CommandSystem.command_issued.connect(_on_command_issued)
	CommandSystem.selection_changed.connect(_on_selection_changed)
	RebellionManager.capital_health_changed.connect(_on_capital_health_changed)
	RebellionManager.mission_briefing.connect(_on_mission_briefing)
	RebellionManager.rebellion_victory.connect(_on_rebellion_victory)
	RebellionManager.wave_deployed.connect(_on_wave_deployed)

	battle_cry_label.text = ""
	rebellion_title.text = "THE HOBBIT STARS"
	objective_label.text = "Lead the Rebellion to the Capital fortress"
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

	help_label.text = "J light · K heavy · E block · Space dodge · WASD move · TAB+3 charge"
	help_label.add_theme_color_override("font_color", Color(0.75, 0.78, 0.85, 0.75))

	var leader := _resolve_leader_name()
	var hero_id := PlayerData.appearance.hero_preset_id
	var partner_id := PlayerData.appearance.partner_hero_preset_id

	commander_label.text = leader
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


func _resolve_leader_name() -> String:
	var hero_id := PlayerData.appearance.hero_preset_id
	var partner_id := PlayerData.appearance.partner_hero_preset_id
	var name := PlayerData.appearance.player_name.strip_edges()

	if not hero_id.is_empty():
		name = HeroPresets.get_display_name(hero_id)
	elif name.is_empty() or name == "Hero":
		name = "Knight"

	var leader := name
	if not hero_id.is_empty() and not HeroPresets.get_title(hero_id).is_empty():
		leader = "%s — %s" % [name, HeroPresets.get_title(hero_id)]

	if not partner_id.is_empty():
		leader += " & %s" % HeroPresets.get_display_name(partner_id)
	elif hero_id.is_empty():
		leader += " & Dragon"

	return leader


func _style_progress_bars() -> void:
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.2, 0.72, 0.38)
	fill.set_corner_radius_all(4)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.12, 0.14, 0.2, 0.9)
	bg.set_corner_radius_all(4)
	for bar in [player_bar, capital_bar]:
		bar.add_theme_stylebox_override("fill", fill)
		bar.add_theme_stylebox_override("background", bg)


func _setup_hero_portraits() -> void:
	var row := HBoxContainer.new()
	row.name = "PortraitRow"
	row.add_theme_constant_override("separation", 8)
	player_vbox.add_child(row)
	player_vbox.move_child(row, 0)

	var hero_id := PlayerData.appearance.hero_preset_id
	var partner_id := PlayerData.appearance.partner_hero_preset_id
	var hero_label := HeroPresets.get_display_name(hero_id) if not hero_id.is_empty() else "Knight"
	var partner_label := HeroPresets.get_display_name(partner_id) if not partner_id.is_empty() else "Dragon"

	_add_portrait(row, hero_label, GlbVisualScript.KNIGHT, 0.42, 0.0)
	_add_portrait(row, partner_label, GlbVisualScript.DRAGON, 0.14, 0.35)


func _add_portrait(parent: HBoxContainer, label_text: String, glb_path: String, scale: float, y_offset: float) -> void:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)

	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(72, 72)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	frame.add_child(margin)

	var viewport_container := SubViewportContainer.new()
	viewport_container.custom_minimum_size = Vector2(64, 64)
	viewport_container.stretch = true
	margin.add_child(viewport_container)

	var viewport := SubViewport.new()
	viewport.size = Vector2i(128, 128)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(viewport)

	var root := Node3D.new()
	root.name = "PreviewRoot"
	viewport.add_child(root)

	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.1, 2.4)
	cam.rotation_degrees = Vector3(-12, 180, 0)
	cam.fov = 42.0
	cam.current = true
	root.add_child(cam)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 35, 0)
	light.light_energy = 1.2
	root.add_child(light)

	var pivot := Node3D.new()
	pivot.name = "Pivot"
	root.add_child(pivot)
	GlbVisualScript.attach(pivot, glb_path, scale, y_offset, 180.0)

	var caption := Label.new()
	caption.text = label_text
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 11)
	caption.add_theme_color_override("font_color", Color(0.85, 0.82, 0.7))

	col.add_child(frame)
	col.add_child(caption)
	parent.add_child(col)


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
	var squad_text := "Allies: "
	if ally_lines.is_empty():
		squad_text += "press TAB"
	else:
		squad_text += ", ".join(ally_lines)
	squad_text += "  |  Guards: %d" % enemy_count
	squad_label.text = squad_text


func _build_command_buttons() -> void:
	for type in CommandType.Type.size():
		var cmd_type: CommandType.Type = type
		var btn := Button.new()
		btn.text = "%d %s" % [type + 1, CommandType.label_for(cmd_type)]
		btn.tooltip_text = CommandType.description_for(cmd_type)
		btn.custom_minimum_size = Vector2(108, 28)
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
