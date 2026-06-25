class_name HeroPresets
extends RefCounted

enum Franchise { LOTR, STAR_WARS, HUNGER_GAMES }

const FRANCHISE_LABELS: Dictionary = {
	Franchise.LOTR: "Lord of the Rings",
	Franchise.STAR_WARS: "Star Wars",
	Franchise.HUNGER_GAMES: "The Hunger Games",
}

const HEROES: Dictionary = {
	"legolas": {
		"franchise": Franchise.LOTR,
		"title": "Prince of the Woodland Realm",
		"appearance": {
			"player_name": "Legolas",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.ELF,
			"skin_color": Color(0.92, 0.82, 0.72),
			"hair_color": Color(0.78, 0.62, 0.28),
			"armor_color": Color(0.18, 0.38, 0.22),
			"accent_color": Color(0.32, 0.52, 0.28),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 120.0, "move_speed": 6.5, "attack_damage": 18.0},
	},
	"aragorn": {
		"franchise": Franchise.LOTR,
		"title": "Ranger of the North",
		"appearance": {
			"player_name": "Aragorn",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.72, 0.55, 0.42),
			"hair_color": Color(0.12, 0.08, 0.06),
			"armor_color": Color(0.22, 0.28, 0.2),
			"accent_color": Color(0.38, 0.22, 0.12),
			"helmet_style": CharacterAppearance.HelmetStyle.HOOD,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 150.0, "move_speed": 5.5, "attack_damage": 22.0},
	},
	"gandalf": {
		"franchise": Franchise.LOTR,
		"movie": "The Hobbit / The Lord of the Rings",
		"title": "Gandalf the Grey",
		"appearance": {
			"player_name": "Gandalf",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.OUTLANDER,
			"skin_color": Color(0.82, 0.72, 0.62),
			"hair_color": Color(0.9, 0.9, 0.92),
			"armor_color": Color(0.48, 0.48, 0.52),
			"accent_color": Color(0.62, 0.62, 0.68),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.STAFF,
		},
		"stats": {"max_health": 130.0, "move_speed": 5.0, "attack_damage": 25.0},
	},
	"gimli": {
		"franchise": Franchise.LOTR,
		"title": "Son of Gloin",
		"appearance": {
			"player_name": "Gimli",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.DWARF,
			"skin_color": Color(0.78, 0.58, 0.45),
			"hair_color": Color(0.65, 0.22, 0.12),
			"armor_color": Color(0.42, 0.42, 0.45),
			"accent_color": Color(0.55, 0.18, 0.1),
			"helmet_style": CharacterAppearance.HelmetStyle.HELM,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 140.0, "move_speed": 4.5, "attack_damage": 24.0},
	},
	"galadriel": {
		"franchise": Franchise.LOTR,
		"title": "Lady of Light",
		"appearance": {
			"player_name": "Galadriel",
			"gender": CharacterAppearance.Gender.FEMALE,
			"body_type": CharacterAppearance.BodyType.ELF,
			"skin_color": Color(0.95, 0.88, 0.82),
			"hair_color": Color(0.92, 0.85, 0.55),
			"armor_color": Color(0.82, 0.84, 0.88),
			"accent_color": Color(0.95, 0.95, 1.0),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.STAFF,
		},
		"stats": {"max_health": 110.0, "move_speed": 5.5, "attack_damage": 20.0},
	},
	"arowin": {
		"franchise": Franchise.LOTR,
		"title": "Evenstar of Rivendell",
		"appearance": {
			"player_name": "Arwen",
			"gender": CharacterAppearance.Gender.FEMALE,
			"body_type": CharacterAppearance.BodyType.ELF,
			"skin_color": Color(0.94, 0.86, 0.8),
			"hair_color": Color(0.1, 0.08, 0.12),
			"armor_color": Color(0.15, 0.22, 0.42),
			"accent_color": Color(0.72, 0.78, 0.92),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 105.0, "move_speed": 5.6, "attack_damage": 16.0},
	},
	"aowin": {
		"franchise": Franchise.LOTR,
		"title": "Shieldmaiden of Rohan",
		"appearance": {
			"player_name": "Éowyn",
			"gender": CharacterAppearance.Gender.FEMALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.88, 0.74, 0.62),
			"hair_color": Color(0.82, 0.68, 0.38),
			"armor_color": Color(0.48, 0.42, 0.32),
			"accent_color": Color(0.62, 0.18, 0.14),
			"helmet_style": CharacterAppearance.HelmetStyle.HELM,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 118.0, "move_speed": 6.0, "attack_damage": 20.0},
	},
	"luke": {
		"franchise": Franchise.STAR_WARS,
		"movie": "Star Wars",
		"title": "Jedi Knight",
		"appearance": {
			"player_name": "Luke Skywalker",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.88, 0.75, 0.62),
			"hair_color": Color(0.75, 0.72, 0.65),
			"armor_color": Color(0.72, 0.62, 0.45),
			"accent_color": Color(0.15, 0.65, 0.25),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.BLADE,
		},
		"stats": {"max_health": 125.0, "move_speed": 6.0, "attack_damage": 21.0},
	},
	"leia": {
		"franchise": Franchise.STAR_WARS,
		"movie": "Star Wars",
		"title": "Princess of Alderaan",
		"appearance": {
			"player_name": "Leia",
			"gender": CharacterAppearance.Gender.FEMALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.9, 0.78, 0.65),
			"hair_color": Color(0.18, 0.1, 0.06),
			"armor_color": Color(0.95, 0.95, 0.98),
			"accent_color": Color(0.85, 0.85, 0.9),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 115.0, "move_speed": 5.8, "attack_damage": 17.0},
	},
	"han": {
		"franchise": Franchise.STAR_WARS,
		"movie": "Star Wars",
		"title": "Smuggler Captain",
		"appearance": {
			"player_name": "Han Solo",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.82, 0.65, 0.5),
			"hair_color": Color(0.15, 0.1, 0.08),
			"armor_color": Color(0.22, 0.2, 0.18),
			"accent_color": Color(0.88, 0.88, 0.9),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 120.0, "move_speed": 6.2, "attack_damage": 19.0},
	},
	"obiwan": {
		"franchise": Franchise.STAR_WARS,
		"movie": "Star Wars",
		"title": "Jedi Master",
		"appearance": {
			"player_name": "Obi-Wan",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.85, 0.7, 0.55),
			"hair_color": Color(0.72, 0.55, 0.32),
			"armor_color": Color(0.62, 0.52, 0.38),
			"accent_color": Color(0.2, 0.35, 0.65),
			"helmet_style": CharacterAppearance.HelmetStyle.COWL,
			"weapon_style": CharacterAppearance.WeaponStyle.BLADE,
		},
		"stats": {"max_health": 135.0, "move_speed": 5.5, "attack_damage": 23.0},
	},
	"katniss": {
		"franchise": Franchise.HUNGER_GAMES,
		"movie": "The Hunger Games",
		"title": "The Mockingjay",
		"appearance": {
			"player_name": "Katniss",
			"gender": CharacterAppearance.Gender.FEMALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.78, 0.62, 0.48),
			"hair_color": Color(0.12, 0.08, 0.06),
			"armor_color": Color(0.06, 0.06, 0.08),
			"accent_color": Color(0.88, 0.68, 0.18),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 112.0, "move_speed": 6.4, "attack_damage": 19.0},
	},
	"peeta": {
		"franchise": Franchise.HUNGER_GAMES,
		"title": "The Boy with the Bread",
		"appearance": {
			"player_name": "Peeta",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.9, 0.78, 0.65),
			"hair_color": Color(0.78, 0.62, 0.35),
			"armor_color": Color(0.62, 0.48, 0.32),
			"accent_color": Color(0.85, 0.72, 0.45),
			"helmet_style": CharacterAppearance.HelmetStyle.NONE,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 128.0, "move_speed": 5.4, "attack_damage": 18.0},
	},
	"gale": {
		"franchise": Franchise.HUNGER_GAMES,
		"title": "Hunter of District 12",
		"appearance": {
			"player_name": "Gale",
			"gender": CharacterAppearance.Gender.MALE,
			"body_type": CharacterAppearance.BodyType.HUMAN,
			"skin_color": Color(0.75, 0.58, 0.42),
			"hair_color": Color(0.12, 0.1, 0.08),
			"armor_color": Color(0.22, 0.3, 0.22),
			"accent_color": Color(0.35, 0.28, 0.18),
			"helmet_style": CharacterAppearance.HelmetStyle.HOOD,
			"weapon_style": CharacterAppearance.WeaponStyle.SWORD,
		},
		"stats": {"max_health": 122.0, "move_speed": 6.1, "attack_damage": 21.0},
	},
}


const MOVIE_SOURCES: Dictionary = {
	"legolas": "The Lord of the Rings",
	"aragorn": "The Lord of the Rings",
	"gandalf": "The Hobbit / The Lord of the Rings",
	"gimli": "The Lord of the Rings",
	"galadriel": "The Lord of the Rings",
	"arowin": "The Lord of the Rings",
	"aowin": "The Lord of the Rings",
	"luke": "Star Wars",
	"leia": "Star Wars",
	"han": "Star Wars",
	"obiwan": "Star Wars",
	"katniss": "The Hunger Games",
	"peeta": "The Hunger Games",
	"gale": "The Hunger Games",
}


static func franchise_label(franchise: Franchise) -> String:
	return FRANCHISE_LABELS.get(franchise, "")


static func get_hero_ids_for_franchise(franchise: Franchise) -> Array[String]:
	var ids: Array[String] = []
	for hero_id in HEROES:
		if HEROES[hero_id]["franchise"] == franchise:
			ids.append(hero_id)
	return ids


static func get_display_name(hero_id: String) -> String:
	if not HEROES.has(hero_id):
		return "Unknown"
	return HEROES[hero_id]["appearance"]["player_name"]


static func get_movie_source(hero_id: String) -> String:
	if HEROES.has(hero_id) and HEROES[hero_id].has("movie"):
		return HEROES[hero_id]["movie"]
	return MOVIE_SOURCES.get(hero_id, "")


static func get_title(hero_id: String) -> String:
	if not HEROES.has(hero_id):
		return ""
	return HEROES[hero_id]["title"]


static func get_intro_quote(hero_id: String) -> String:
	const QUOTES: Dictionary = {
		"legolas": "The stars are veiled. The Capital stirs — yet we do not walk alone.",
		"aragorn": "This day we fight. By all that you hold dear on this good earth — stand with me.",
		"gandalf": "Far over the misty mountains cold — the Rebellion marches with me.",
		"gimli": "Let them come! There is one dwarf yet in the Rebellion who still draws breath!",
		"galadriel": "The world is changed. I feel it in the earth — and I will not stand idle.",
		"arowin": "I choose a mortal life, and a free one. The Capital will not have us.",
		"aowin": "Ride with me. Fear nothing — only those who stand against the Rebellion.",
		"luke": "I am a Jedi, like my father before me. The Capital will fall.",
		"leia": "The more they tighten their grip, the more systems will slip through our fingers.",
		"han": "Never tell me the odds. Let's blow up the Capital and go home.",
		"obiwan": "The Force will be with you — always. Trust in the Rebellion.",
		"katniss": "I volunteer as tribute — and I will burn the Capital down.",
		"peeta": "They don't own us. Not our bodies, not our hearts — not today.",
		"gale": "They bombed our home. Today we take theirs.",
	}
	return QUOTES.get(hero_id, "")


static func build_appearance(hero_id: String) -> CharacterAppearance:
	var data: Dictionary = HEROES.get(hero_id, {})
	if data.is_empty():
		return CharacterAppearance.new()

	var app_data: Dictionary = data["appearance"]
	var app := CharacterAppearance.new()
	app.hero_preset_id = hero_id
	app.player_name = app_data.get("player_name", "Hero")
	app.gender = app_data.get("gender", CharacterAppearance.Gender.MALE)
	app.body_type = app_data.get("body_type", CharacterAppearance.BodyType.HUMAN)
	app.skin_color = app_data.get("skin_color", Color.WHITE)
	app.hair_color = app_data.get("hair_color", Color.BLACK)
	app.armor_color = app_data.get("armor_color", Color.GRAY)
	app.accent_color = app_data.get("accent_color", Color.GRAY)
	app.helmet_style = app_data.get("helmet_style", CharacterAppearance.HelmetStyle.NONE)
	app.weapon_style = app_data.get("weapon_style", CharacterAppearance.WeaponStyle.SWORD)
	return app


static func get_stats(hero_id: String) -> Dictionary:
	return HEROES.get(hero_id, {}).get("stats", {})


static func get_party_ally_ids(exclude_ids: Array[String] = []) -> Array[String]:
	var lotr := _filter_excluded(get_hero_ids_for_franchise(Franchise.LOTR), exclude_ids)
	var wars := _filter_excluded(get_hero_ids_for_franchise(Franchise.STAR_WARS), exclude_ids)
	var hunger := _filter_excluded(get_hero_ids_for_franchise(Franchise.HUNGER_GAMES), exclude_ids)
	var party: Array[String] = []
	var max_count := maxi(lotr.size(), maxi(wars.size(), hunger.size()))

	for i in max_count:
		for bucket in [lotr, wars, hunger]:
			if i < bucket.size() and party.size() < 5:
				party.append(bucket[i])

	return party


static func _filter_excluded(ids: Array[String], exclude_ids: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for hero_id in ids:
		if hero_id not in exclude_ids:
			result.append(hero_id)
	return result


const DUO_TEAMS := [
	{"label": "Katniss + Gandalf", "lead": "katniss", "partner": "gandalf"},
	{"label": "Luke + Leia", "lead": "luke", "partner": "leia"},
	{"label": "Han + Obi-Wan", "lead": "han", "partner": "obiwan"},
]
