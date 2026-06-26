extends Control

const GlbVisualScript = preload("res://scripts/glb_visual.gd")

const MAIN_SCENE := "res://scenes/main.tscn"

@onready var sub_viewport_container: SubViewportContainer = $HBox/PreviewPanel/Margin/VBox/SubViewportContainer
@onready var preview_label: Label = $HBox/PreviewPanel/Margin/VBox/PreviewLabel
@onready var preview_panel: PanelContainer = $HBox/PreviewPanel
@onready var options_panel: PanelContainer = $HBox/OptionsPanel
@onready var preview_visual: CharacterVisual = $HBox/PreviewPanel/Margin/VBox/SubViewportContainer/SubViewport/PreviewRoot/PreviewPivot/CharacterVisual
@onready var partner_visual: CharacterVisual = $HBox/PreviewPanel/Margin/VBox/SubViewportContainer/SubViewport/PreviewRoot/PreviewPivot/PartnerVisual
@onready var preview_pivot: Node3D = $HBox/PreviewPanel/Margin/VBox/SubViewportContainer/SubViewport/PreviewRoot/PreviewPivot
@onready var preview_floor: MeshInstance3D = $HBox/PreviewPanel/Margin/VBox/SubViewportContainer/SubViewport/PreviewRoot/Floor
@onready var hero_description: Label = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/HeroSection/HeroDescription
@onready var franchise_buttons: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/HeroSection/FranchiseButtons
@onready var hero_buttons: GridContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/HeroSection/HeroButtons
@onready var duo_buttons: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/HeroSection/DuoButtons
@onready var partner_buttons: GridContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/PartnerSection/PartnerButtons
@onready var partner_status: Label = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/PartnerSection/PartnerStatus
@onready var name_input: LineEdit = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/NameRow/NameInput
@onready var gender_buttons: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/GenderSection/GenderButtons
@onready var body_buttons: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/BodySection/BodyButtons
@onready var helmet_buttons: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/HelmetSection/HelmetButtons
@onready var weapon_buttons: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/WeaponSection/WeaponButtons
@onready var skin_swatches: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/SkinSection/Swatches
@onready var hair_swatches: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/HairSection/Swatches
@onready var armor_swatches: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/ArmorSection/Swatches
@onready var accent_swatches: HBoxContainer = $HBox/OptionsPanel/PanelVBox/Scroll/Margin/VBox/AccentSection/Swatches
@onready var begin_button: Button = $HBox/OptionsPanel/PanelVBox/ActionBar/ButtonRow/BeginButton
@onready var random_button: Button = $HBox/OptionsPanel/PanelVBox/ActionBar/ButtonRow/RandomButton
@onready var quick_join_button: Button = $HBox/OptionsPanel/PanelVBox/TopActionBar/QuickJoinButton
@onready var preview_camera: Camera3D = $HBox/PreviewPanel/Margin/VBox/SubViewportContainer/SubViewport/PreviewRoot/Camera3D

var _appearance: CharacterAppearance
var _preview_rotation: float = 0.0
var _active_franchise: HeroPresets.Franchise = HeroPresets.Franchise.LOTR
var _hero_button_group: ButtonGroup
var _selected_hero_id: String = ""
var _selected_partner_id: String = ""
var _partner_button_group: ButtonGroup
var _starting_game: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HBox.mouse_filter = Control.MOUSE_FILTER_STOP
	_setup_preview_floor()
	if preview_camera:
		preview_camera.current = true
	sub_viewport_container.visible = true
	sub_viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_label.text = "Click a hero to see your fighter!"
	preview_panel.clip_contents = true
	options_panel.clip_contents = true
	_appearance = PlayerData.appearance.duplicate_appearance()
	_selected_hero_id = _appearance.hero_preset_id
	_selected_partner_id = _appearance.partner_hero_preset_id
	if not _selected_hero_id.is_empty() and HeroPresets.HEROES.has(_selected_hero_id):
		_active_franchise = HeroPresets.HEROES[_selected_hero_id]["franchise"]
	name_input.text = _appearance.player_name
	_build_duo_buttons()
	_build_franchise_buttons()
	_build_hero_buttons()
	_build_partner_buttons()
	_build_option_buttons()
	_build_color_swatches()
	_setup_action_buttons()
	call_deferred("_deferred_startup")


func _deferred_startup() -> void:
	_show_knight_preview()
	_refresh_preview()
	_update_hero_description()
	_update_partner_status()


func _show_knight_preview() -> void:
	sub_viewport_container.visible = true
	preview_label.text = "Knight — your hero in battle"
	GlbVisualScript.hide_procedural(preview_visual)
	GlbVisualScript.attach(preview_visual, GlbVisualScript.KNIGHT, 1.0, 0.0, 180.0)
	partner_visual.visible = false
	var dragon_preview := GlbVisualScript.attach(preview_pivot, GlbVisualScript.DRAGON, 0.28, 0.4, 180.0)
	if dragon_preview:
		dragon_preview.position.x = 2.2


func _setup_action_buttons() -> void:
	begin_button.disabled = false
	random_button.disabled = false
	quick_join_button.disabled = false
	begin_button.focus_mode = Control.FOCUS_ALL
	random_button.focus_mode = Control.FOCUS_ALL
	quick_join_button.focus_mode = Control.FOCUS_ALL
	if not begin_button.pressed.is_connected(_on_begin_pressed):
		begin_button.pressed.connect(_on_begin_pressed)
	if not random_button.pressed.is_connected(_on_random_pressed):
		random_button.pressed.connect(_on_random_pressed)
	if not quick_join_button.pressed.is_connected(_on_begin_pressed):
		quick_join_button.pressed.connect(_on_begin_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if _starting_game:
		return
	if event.is_action_pressed("ui_accept"):
		if name_input.has_focus():
			return
		_on_begin_pressed()


func _make_hero_button(text: String, hero_id: String, group: ButtonGroup, pressed: bool, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.toggle_mode = true
	btn.button_group = group
	btn.button_pressed = pressed
	btn.custom_minimum_size = Vector2(118, 36)
	btn.set_meta("hero_id", hero_id)
	btn.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.7))
	btn.pressed.connect(callback)
	return btn


func _flash_selection(message: String) -> void:
	preview_label.text = message
	preview_label.add_theme_color_override("font_color", Color(0.55, 0.95, 0.65))


func _setup_preview_floor() -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.1
	mesh.bottom_radius = 1.1
	mesh.height = 0.08
	preview_floor.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.2, 0.26)
	preview_floor.material_override = mat


func _process(delta: float) -> void:
	if not sub_viewport_container.visible:
		return
	_preview_rotation += delta * 0.5
	preview_pivot.rotation.y = _preview_rotation


func _build_franchise_buttons() -> void:
	for child in franchise_buttons.get_children():
		child.queue_free()

	var group := ButtonGroup.new()
	for i in HeroPresets.Franchise.size():
		var franchise: HeroPresets.Franchise = i
		var btn := Button.new()
		btn.text = HeroPresets.franchise_label(franchise)
		btn.toggle_mode = true
		btn.button_group = group
		btn.button_pressed = franchise == _active_franchise
		btn.pressed.connect(_on_franchise_selected.bind(franchise))
		franchise_buttons.add_child(btn)


func _build_hero_buttons() -> void:
	for child in hero_buttons.get_children():
		child.queue_free()

	hero_buttons.columns = 3
	_hero_button_group = ButtonGroup.new()
	hero_buttons.add_child(_make_hero_button(
		"Custom Hero",
		"",
		_hero_button_group,
		_selected_hero_id.is_empty(),
		_on_custom_hero_selected
	))

	for hero_id in HeroPresets.get_hero_ids_for_franchise(_active_franchise):
		hero_buttons.add_child(_make_hero_button(
			HeroPresets.get_display_name(hero_id),
			hero_id,
			_hero_button_group,
			hero_id == _selected_hero_id,
			_on_hero_selected.bind(hero_id)
		))
		var btn: Button = hero_buttons.get_child(hero_buttons.get_child_count() - 1)
		btn.tooltip_text = "%s — %s" % [HeroPresets.get_title(hero_id), HeroPresets.get_movie_source(hero_id)]


func _build_partner_buttons() -> void:
	for child in partner_buttons.get_children():
		child.queue_free()

	partner_buttons.columns = 3
	_partner_button_group = ButtonGroup.new()
	partner_buttons.add_child(_make_hero_button(
		"No Partner",
		"",
		_partner_button_group,
		_selected_partner_id.is_empty(),
		_on_partner_cleared
	))

	for hero_id in HeroPresets.HEROES:
		if hero_id == _selected_hero_id:
			continue
		var movie := HeroPresets.get_movie_source(hero_id)
		partner_buttons.add_child(_make_hero_button(
			"%s\n(%s)" % [HeroPresets.get_display_name(hero_id), movie],
			hero_id,
			_partner_button_group,
			hero_id == _selected_partner_id,
			_on_partner_selected.bind(hero_id)
		))


func _build_option_buttons() -> void:
	_fill_enum_buttons(gender_buttons, CharacterAppearance.Gender.size(), _on_gender_selected, CharacterAppearance.gender_label)
	_fill_enum_buttons(body_buttons, CharacterAppearance.BodyType.size(), _on_body_selected, CharacterAppearance.body_label)
	_fill_enum_buttons(helmet_buttons, CharacterAppearance.HelmetStyle.size(), _on_helmet_selected, CharacterAppearance.helmet_label)
	_fill_enum_buttons(weapon_buttons, CharacterAppearance.WeaponStyle.size(), _on_weapon_selected, CharacterAppearance.weapon_label)


func _fill_enum_buttons(container: HBoxContainer, count: int, callback: Callable, label_fn: Callable) -> void:
	for child in container.get_children():
		child.queue_free()
	var group := ButtonGroup.new()
	for i in count:
		var btn := Button.new()
		btn.text = label_fn.call(i)
		btn.toggle_mode = true
		btn.button_group = group
		btn.custom_minimum_size = Vector2(100, 34)
		btn.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))
		var idx := i
		btn.pressed.connect(callback.bind(idx))
		container.add_child(btn)


func _build_color_swatches() -> void:
	_populate_swatches(skin_swatches, CharacterAppearance.SKIN_PRESETS, _on_skin_selected)
	_populate_swatches(hair_swatches, CharacterAppearance.HAIR_PRESETS, _on_hair_selected)
	_populate_swatches(armor_swatches, CharacterAppearance.ARMOR_PRESETS, _on_armor_selected)
	_populate_swatches(accent_swatches, CharacterAppearance.ACCENT_PRESETS, _on_accent_selected)


func _populate_swatches(container: HBoxContainer, colors: Array[Color], callback: Callable) -> void:
	for child in container.get_children():
		child.queue_free()
	for color in colors:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(36, 36)
		var style := StyleBoxFlat.new()
		style.bg_color = color
		style.set_border_width_all(2)
		style.border_color = Color(0.9, 0.85, 0.6)
		style.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.pressed.connect(callback.bind(color))
		container.add_child(btn)


func _refresh_preview(full := true) -> void:
	if full and sub_viewport_container.visible:
		preview_visual.apply_appearance(_appearance, true)
		_flash_selection("Previewing: %s" % _appearance.player_name)
	if full:
		_update_toggle_states(gender_buttons, _appearance.gender)
		_update_toggle_states(body_buttons, _appearance.body_type)
		_update_toggle_states(helmet_buttons, _appearance.helmet_style)
		_update_toggle_states(weapon_buttons, _appearance.weapon_style)
	_refresh_partner_preview()
	_update_hero_description()
	_update_partner_status()


func _refresh_partner_preview() -> void:
	if _selected_partner_id.is_empty() or not sub_viewport_container.visible:
		partner_visual.visible = false
		return
	partner_visual.visible = true
	partner_visual.apply_appearance(HeroPresets.build_appearance(_selected_partner_id), true)


func _update_partner_status() -> void:
	if _selected_partner_id.is_empty():
		partner_status.text = "Selected partner: none (pick one below)"
		partner_status.add_theme_color_override("font_color", Color(0.75, 0.78, 0.85))
	else:
		partner_status.text = "Selected partner: %s — %s" % [
			HeroPresets.get_display_name(_selected_partner_id),
			HeroPresets.get_title(_selected_partner_id),
		]
		partner_status.add_theme_color_override("font_color", Color(0.55, 0.95, 0.65))


func _update_toggle_states(container: HBoxContainer, selected: int) -> void:
	var i := 0
	for child in container.get_children():
		if child is Button:
			child.button_pressed = (i == selected)
			i += 1


func _update_hero_description() -> void:
	if _selected_hero_id.is_empty():
		hero_description.text = "Custom hero — tune every detail below, or pick a legendary character."
	elif not _selected_partner_id.is_empty():
		hero_description.text = (
			"Dual leaders:\n%s — %s (%s)\n%s — %s (%s)"
			% [
				HeroPresets.get_display_name(_selected_hero_id),
				HeroPresets.get_title(_selected_hero_id),
				HeroPresets.get_movie_source(_selected_hero_id),
				HeroPresets.get_display_name(_selected_partner_id),
				HeroPresets.get_title(_selected_partner_id),
				HeroPresets.get_movie_source(_selected_partner_id),
			]
		)
	else:
		var quote := HeroPresets.get_intro_quote(_selected_hero_id)
		hero_description.text = "%s — %s (%s)" % [
			HeroPresets.get_display_name(_selected_hero_id),
			HeroPresets.get_title(_selected_hero_id),
			HeroPresets.get_movie_source(_selected_hero_id),
		]
		if not quote.is_empty():
			hero_description.text += "\n\"%s\"" % quote


func _clear_hero_selection() -> void:
	_selected_hero_id = ""
	_appearance.hero_preset_id = ""
	_build_hero_buttons()
	_build_partner_buttons()


func _build_duo_buttons() -> void:
	for child in duo_buttons.get_children():
		child.queue_free()

	for team in HeroPresets.DUO_TEAMS:
		var btn := Button.new()
		btn.text = team["label"]
		btn.custom_minimum_size = Vector2(160, 34)
		var lead: String = team["lead"]
		var partner: String = team["partner"]
		btn.pressed.connect(_apply_duo_team.bind(lead, partner))
		duo_buttons.add_child(btn)


func _apply_duo_team(lead_id: String, partner_id: String) -> void:
	_selected_hero_id = lead_id
	_selected_partner_id = partner_id
	_appearance = HeroPresets.build_appearance(lead_id)
	_appearance.partner_hero_preset_id = partner_id
	name_input.text = _appearance.player_name
	if HeroPresets.HEROES.has(lead_id):
		_active_franchise = HeroPresets.HEROES[lead_id]["franchise"]
	_build_franchise_buttons()
	_build_hero_buttons()
	_build_partner_buttons()
	_refresh_preview()
	_update_hero_description()


func _on_partner_selected(hero_id: String) -> void:
	_selected_partner_id = hero_id
	_appearance.partner_hero_preset_id = hero_id
	_refresh_preview(false)
	_update_partner_button_states()


func _on_partner_cleared() -> void:
	_selected_partner_id = ""
	_appearance.partner_hero_preset_id = ""
	_refresh_preview(false)
	_update_partner_button_states()


func _update_partner_button_states() -> void:
	for child in partner_buttons.get_children():
		if child is Button:
			var hero_id: String = child.get_meta("hero_id", "")
			child.button_pressed = hero_id == _selected_partner_id


func _on_franchise_selected(franchise: HeroPresets.Franchise) -> void:
	_active_franchise = franchise
	_build_hero_buttons()


func _on_hero_selected(hero_id: String) -> void:
	_selected_hero_id = hero_id
	_appearance = HeroPresets.build_appearance(hero_id)
	name_input.text = _appearance.player_name
	if _selected_partner_id == hero_id:
		_selected_partner_id = ""
		_appearance.partner_hero_preset_id = ""
	_build_partner_buttons()
	_refresh_preview()
	_update_hero_description()


func _on_custom_hero_selected() -> void:
	_clear_hero_selection()
	_refresh_preview()


func _on_gender_selected(index: int) -> void:
	_clear_hero_selection()
	_appearance.gender = index
	_refresh_preview()


func _on_body_selected(index: int) -> void:
	_clear_hero_selection()
	_appearance.body_type = index
	_refresh_preview()


func _on_helmet_selected(index: int) -> void:
	_clear_hero_selection()
	_appearance.helmet_style = index
	_refresh_preview()


func _on_weapon_selected(index: int) -> void:
	_clear_hero_selection()
	_appearance.weapon_style = index
	_refresh_preview()


func _on_skin_selected(color: Color) -> void:
	_clear_hero_selection()
	_appearance.skin_color = color
	_refresh_preview()


func _on_hair_selected(color: Color) -> void:
	_clear_hero_selection()
	_appearance.hair_color = color
	_refresh_preview()


func _on_armor_selected(color: Color) -> void:
	_clear_hero_selection()
	_appearance.armor_color = color
	_refresh_preview()


func _on_accent_selected(color: Color) -> void:
	_clear_hero_selection()
	_appearance.accent_color = color
	_refresh_preview()


func _on_name_changed(new_text: String) -> void:
	_appearance.player_name = new_text.strip_edges()
	if not _selected_hero_id.is_empty() and _appearance.player_name != HeroPresets.get_display_name(_selected_hero_id):
		_clear_hero_selection()


func _on_begin_pressed() -> void:
	if _starting_game:
		return
	_starting_game = true
	begin_button.disabled = true
	random_button.disabled = true
	quick_join_button.disabled = true
	_appearance.player_name = name_input.text.strip_edges()
	if _appearance.player_name.is_empty():
		_appearance.player_name = "Knight"
	_appearance.hero_preset_id = "knight"
	_appearance.partner_hero_preset_id = "dragon"
	PlayerData.set_appearance(_appearance)
	var err := get_tree().change_scene_to_file(MAIN_SCENE)
	if err != OK:
		_starting_game = false
		begin_button.disabled = false
		random_button.disabled = false
		quick_join_button.disabled = false
		push_error("Could not start game: %s" % error_string(err))


func _on_random_pressed() -> void:
	_selected_partner_id = ""
	_appearance.partner_hero_preset_id = ""
	_clear_hero_selection()
	_build_partner_buttons()
	_appearance.gender = randi() % CharacterAppearance.Gender.size() as CharacterAppearance.Gender
	_appearance.body_type = randi() % CharacterAppearance.BodyType.size() as CharacterAppearance.BodyType
	_appearance.helmet_style = randi() % CharacterAppearance.HelmetStyle.size() as CharacterAppearance.HelmetStyle
	_appearance.weapon_style = randi() % CharacterAppearance.WeaponStyle.size() as CharacterAppearance.WeaponStyle
	_appearance.skin_color = CharacterAppearance.SKIN_PRESETS.pick_random()
	_appearance.hair_color = CharacterAppearance.HAIR_PRESETS.pick_random()
	_appearance.armor_color = CharacterAppearance.ARMOR_PRESETS.pick_random()
	_appearance.accent_color = CharacterAppearance.ACCENT_PRESETS.pick_random()
	_refresh_preview()
	_update_partner_status()
