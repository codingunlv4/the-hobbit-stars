extends Control

@onready var battle_cry_label: Label = $Panel/Margin/VBox/BattleCry
@onready var commander_label: Label = $Panel/Margin/VBox/CommanderTitle
@onready var status_label: Label = $Panel/Margin/VBox/Status
@onready var command_buttons: HBoxContainer = $Panel/Margin/VBox/CommandButtons
@onready var rebellion_title: Label = $RebellionHUD/Margin/VBox/RebellionTitle
@onready var objective_label: Label = $RebellionHUD/Margin/VBox/Objective
@onready var capital_bar: ProgressBar = $RebellionHUD/Margin/VBox/CapitalBar
@onready var capital_label: Label = $RebellionHUD/Margin/VBox/CapitalLabel
@onready var briefing_panel: PanelContainer = $BriefingPanel
@onready var briefing_text: Label = $BriefingPanel/Margin/BriefingText
@onready var victory_panel: PanelContainer = $VictoryPanel
@onready var victory_text: Label = $VictoryPanel/Margin/VBox/VictoryText

var _cry_timer: float = 0.0
var _briefing_timer: float = 0.0


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
	rebellion_title.text = "THE REBELLION"
	objective_label.text = "Objective: Assault the Capital"
	capital_label.text = "Capital Fortress"
	capital_bar.max_value = 100.0
	capital_bar.value = 100.0
	victory_panel.visible = false
	briefing_panel.visible = false

	var leader := PlayerData.appearance.player_name
	var hero_id := PlayerData.appearance.hero_preset_id
	var partner_id := PlayerData.appearance.partner_hero_preset_id

	if not hero_id.is_empty():
		leader = "%s — %s" % [HeroPresets.get_display_name(hero_id), HeroPresets.get_title(hero_id)]
	if not partner_id.is_empty():
		leader += " & %s" % HeroPresets.get_display_name(partner_id)

	commander_label.text = "Rebel Commander: %s" % leader

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
	status_label.text = "Press TAB to rally the legends — then press 3 to charge the Capital!"


func _process(delta: float) -> void:
	if _cry_timer > 0.0:
		_cry_timer -= delta
		if _cry_timer <= 0.0:
			battle_cry_label.text = ""

	if _briefing_timer > 0.0:
		_briefing_timer -= delta
		if _briefing_timer <= 0.0:
			briefing_panel.visible = false


func _build_command_buttons() -> void:
	for type in CommandType.Type.size():
		var cmd_type: CommandType.Type = type
		var btn := Button.new()
		btn.text = "%d — %s" % [type + 1, CommandType.label_for(cmd_type)]
		btn.tooltip_text = CommandType.description_for(cmd_type)
		btn.custom_minimum_size = Vector2(140, 36)
		btn.pressed.connect(func(): CommandSystem.issue_command(cmd_type))
		command_buttons.add_child(btn)


func _on_battle_cry(text: String) -> void:
	battle_cry_label.text = "\"%s\"" % text
	_cry_timer = 4.0


func _on_command_issued(type: CommandType.Type, _units: Array) -> void:
	status_label.text = "Rebellion order: %s" % CommandType.label_for(type)


func _on_selection_changed(units: Array) -> void:
	if units.is_empty():
		status_label.text = "Rally the legends — TAB selects all rebels"
	else:
		status_label.text = "%d rebels ready to strike the Capital" % units.size()


func _on_capital_health_changed(current: float, maximum: float) -> void:
	var percent := 0.0 if maximum <= 0.0 else (current / maximum) * 100.0
	capital_bar.value = percent
	capital_label.text = "Capital Fortress — %.0f%%" % percent


func _on_mission_briefing(text: String) -> void:
	briefing_text.text = text
	briefing_panel.visible = true
	_briefing_timer = 7.0


func _on_wave_deployed(wave_number: int) -> void:
	if wave_number % 2 == 0:
		status_label.text = "Capital reinforcements incoming — wave %d!" % wave_number


func _on_rebellion_victory() -> void:
	victory_panel.visible = true
	victory_text.text = (
		"THE CAPITAL HAS FALLEN!\n\n"
		+ "Jedi, elves, and Mockingjay — Legolas, Luke, Leia, Katniss, and every legend "
		+ "fought at your side. The people are free — long live the Rebellion!"
	)
	objective_label.text = "Victory — the Rebellion rises!"
