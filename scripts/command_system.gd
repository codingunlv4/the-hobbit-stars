extends Node

signal command_issued(type: CommandType.Type, units: Array)
signal selection_changed(units: Array)
signal battle_cry(text: String)

var selected_units: Array[CommandableUnit] = []
var commander: Commander

const HERO_BATTLE_CRIES: Dictionary = {
	"legolas": {
		CommandType.Type.FOLLOW: [
			"The road goes ever on — stay with me.",
			"Keep close. My bow covers your flank.",
		],
		CommandType.Type.HOLD: [
			"Not one step back from this line.",
			"They shall not pass this ground.",
		],
		CommandType.Type.CHARGE: [
			"A red sun rises — let the hunt begin!",
			"Swift as the wind — charge!",
		],
		CommandType.Type.ATTACK: [
			"Five hundred foes — and I have run out of arrows!",
			"Bring them down before they reach the Capital!",
		],
		CommandType.Type.DEFEND: [
			"I will guard this post with every arrow left.",
			"Protect the Rebellion — I have your back.",
		],
		CommandType.Type.RALLY: [
			"Night may be dark, but dawn is coming.",
			"Stand up — the fight is not over yet!",
		],
	},
	"aragorn": {
		CommandType.Type.FOLLOW: [
			"Stay close. I will not lead you astray.",
			"Walk with me — the Rebellion needs unity.",
		],
		CommandType.Type.HOLD: [
			"Hold your ground!",
			"None shall pass while I still stand!",
		],
		CommandType.Type.CHARGE: [
			"For Frodo! For the King!",
			"Ride with me — take the Capital!",
		],
		CommandType.Type.ATTACK: [
			"By sword and honor — attack!",
			"Bring down every soldier of the Capital!",
		],
		CommandType.Type.DEFEND: [
			"I will shield the free peoples with my life.",
			"Defend this line — for all we hold dear!",
		],
		CommandType.Type.RALLY: [
			"A day may come when courage fails — this is not that day!",
			"There is still hope. Rise and fight with me!",
		],
	},
	"gandalf": {
		CommandType.Type.FOLLOW: [
			"Come along — there is much to do.",
			"Far over the misty mountains cold — stay with me.",
		],
		CommandType.Type.HOLD: [
			"You shall not pass!",
			"Keep it secret — keep it safe. And hold this line!",
		],
		CommandType.Type.CHARGE: [
			"Fly, you fools — after me!",
			"So do all who live to see such times — charge!",
		],
		CommandType.Type.ATTACK: [
			"I am a servant of the Secret Fire — strike now!",
			"All we have to decide is what to do with the time given.",
		],
		CommandType.Type.DEFEND: [
			"I will stand between you and the shadow.",
			"Defend the Rebellion — a wizard guards this post.",
		],
		CommandType.Type.RALLY: [
			"Even the smallest person can change the course of the future.",
			"A wizard is never late — nor early. Rise and fight!",
		],
	},
	"gimli": {
		CommandType.Type.FOLLOW: [
			"Stay close — a dwarf does not abandon friends.",
			"Keep up, elf… I mean, keep up, everyone!",
		],
		CommandType.Type.HOLD: [
			"None shall pass — and that's a promise!",
			"Hold the line! My axe is thirsty!",
		],
		CommandType.Type.CHARGE: [
			"Axes up — for the Rebellion!",
			"Charge! And mind my beard!",
		],
		CommandType.Type.ATTACK: [
			"Today my axe drinks deep!",
			"Come on, you sluggards — hit them hard!",
		],
		CommandType.Type.DEFEND: [
			"You'll not breach this wall while I draw breath!",
			"Defend! I was born for battle!",
		],
		CommandType.Type.RALLY: [
			"Never thought I'd die fighting beside an elf — but here we are!",
			"Get up! There's killing to be done for freedom!",
		],
	},
	"galadriel": {
		CommandType.Type.FOLLOW: [
			"Walk in the light — follow me.",
			"Stay close. The night is treacherous.",
		],
		CommandType.Type.HOLD: [
			"Stand firm. The Capital's shadow will not claim this ground.",
			"Hold — even the mighty must sometimes wait.",
		],
		CommandType.Type.CHARGE: [
			"Let the light drive back the darkness — charge!",
			"Forward, for all who suffer under tyranny!",
		],
		CommandType.Type.ATTACK: [
			"The quest stands upon the edge of a knife — strike true!",
			"Attack — and do not waver.",
		],
		CommandType.Type.DEFEND: [
			"I will shelter the Rebellion with all the power I possess.",
			"Defend the innocent — that is our calling.",
		],
		CommandType.Type.RALLY: [
			"Even the smallest light can banish great darkness.",
			"Courage, hearts of the free — the dawn approaches.",
		],
	},
	"arowin": {
		CommandType.Type.FOLLOW: [
			"Walk beside me — we face this together.",
			"Stay close. I chose this path with open eyes.",
		],
		CommandType.Type.HOLD: [
			"Stand fast — I will not let the Capital prevail.",
			"Hold this ground for those who cannot fight.",
		],
		CommandType.Type.CHARGE: [
			"For love, for freedom — charge!",
			"Ride with me against the darkness!",
		],
		CommandType.Type.ATTACK: [
			"Strike now — the Rebellion depends on it!",
			"Attack — for all who hope for peace.",
		],
		CommandType.Type.DEFEND: [
			"I will guard you with my life.",
			"Defend the line — hope still lives.",
		],
		CommandType.Type.RALLY: [
			"There is still hope for the Rebellion.",
			"Do not give in to fear — stand with me.",
		],
	},
	"aowin": {
		CommandType.Type.FOLLOW: [
			"Stay with me — we ride to glory.",
			"Follow close. Rohan does not flee.",
		],
		CommandType.Type.HOLD: [
			"Hold! None shall break this shield wall!",
			"Stand your ground — I am with you!",
		],
		CommandType.Type.CHARGE: [
			"I am no man — charge with me!",
			"For Rohan! For the Rebellion!",
		],
		CommandType.Type.ATTACK: [
			"Those who threaten the free peoples will fall!",
			"Strike them down — I fear no darkness!",
		],
		CommandType.Type.DEFEND: [
			"I will stand between you and harm.",
			"Defend — courage is found in the doing!",
		],
		CommandType.Type.RALLY: [
			"Courage is not the absence of fear — stand anyway!",
			"Rise! The Capital is not invincible!",
		],
	},
	"luke": {
		CommandType.Type.FOLLOW: [
			"Stick with me — I've got a bad feeling about this.",
			"Stay close. Trust the Force.",
		],
		CommandType.Type.HOLD: [
			"Hold the line — I'm not leaving anyone behind.",
			"Stay put. I'll cover you.",
		],
		CommandType.Type.CHARGE: [
			"The Force is with us!",
			"For the Rebellion — charge the Capital!",
		],
		CommandType.Type.ATTACK: [
			"Trust your feelings — attack!",
			"Bring them down — for the galaxy!",
		],
		CommandType.Type.DEFEND: [
			"I'll defend this position — believe in the Force.",
			"Protect the squad — I won't fail you.",
		],
		CommandType.Type.RALLY: [
			"I am a Jedi, like my father before me.",
			"May the Force be with us — rise and fight!",
		],
	},
	"leia": {
		CommandType.Type.FOLLOW: [
			"Stay with me — we have a Rebellion to win.",
			"Keep up. There's no time for hesitation.",
		],
		CommandType.Type.HOLD: [
			"Into the garbage chute, fly boy — hold the line!",
			"Hold this position — the Capital won't break us!",
		],
		CommandType.Type.CHARGE: [
			"For Alderaan — for every world they've crushed!",
			"Charge! The Empire of the Capital ends today!",
		],
		CommandType.Type.ATTACK: [
			"Aren't you a little short for a stormtrooper? Attack!",
			"Bring the fight to them — now!",
		],
		CommandType.Type.DEFEND: [
			"I'd just as soon kiss a Wookiee — but I'll defend this line!",
			"Protect the Rebellion — I believe in us.",
		],
		CommandType.Type.RALLY: [
			"Hope is not lost today — stand with me!",
			"The more they tighten their grip, the more we rise!",
		],
	},
	"han": {
		CommandType.Type.FOLLOW: [
			"Stay close — I'm not doing this twice.",
			"Follow me. Try to keep up, your worship.",
		],
		CommandType.Type.HOLD: [
			"Hold here. I've got a good feeling about this spot.",
			"Don't move — I'll handle the ugly part.",
		],
		CommandType.Type.CHARGE: [
			"Never tell me the odds — charge!",
			"Let's blow this Capital and go home!",
		],
		CommandType.Type.ATTACK: [
			"Shoot first — ask questions never!",
			"Attack! I know a few tricks they don't.",
		],
		CommandType.Type.DEFEND: [
			"I'll cover you — somebody has to be the hero.",
			"Defend the line. Chewie would've wanted that.",
		],
		CommandType.Type.RALLY: [
			"Great, kid — don't get cocky. But don't give up either!",
			"We're still standing — that's worth fighting for!",
		],
	},
	"obiwan": {
		CommandType.Type.FOLLOW: [
			"Stay close, young one — the Force guides us.",
			"Walk with me. Patience wins battles.",
		],
		CommandType.Type.HOLD: [
			"Hold your ground — the Force is with you.",
			"Stand firm. Calm your mind.",
		],
		CommandType.Type.CHARGE: [
			"For the Republic — for the Rebellion!",
			"Charge — but keep your focus!",
		],
		CommandType.Type.ATTACK: [
			"If you strike me down, I shall become more powerful.",
			"Attack with purpose — not anger.",
		],
		CommandType.Type.DEFEND: [
			"The Force will be with you — defend!",
			"I will guard this post. Trust in the Force.",
		],
		CommandType.Type.RALLY: [
			"The Force will be with you — always.",
			"Rise. Fear leads to defeat — hope leads to victory.",
		],
	},
	"katniss": {
		CommandType.Type.FOLLOW: [
			"Stay with me — we survive together.",
			"Keep close. This isn't the Hunger Games — but I'll guide you.",
		],
		CommandType.Type.HOLD: [
			"Hold here. They won't take us without a fight.",
			"Don't move — I've got this.",
		],
		CommandType.Type.CHARGE: [
			"If we burn, you burn with us!",
			"Fire is catching — charge the Capital!",
		],
		CommandType.Type.ATTACK: [
			"Every revolution begins with a spark!",
			"Shoot straight — they started this!",
		],
		CommandType.Type.DEFEND: [
			"I'll protect the Rebellion — they took enough from us.",
			"Defend the line. I won't lose anyone else.",
		],
		CommandType.Type.RALLY: [
			"I am the Mockingjay — and I am not afraid!",
			"Remember who the real enemy is!",
		],
	},
	"peeta": {
		CommandType.Type.FOLLOW: [
			"Stay with me — that's how we make it through.",
			"Follow close. We're stronger together.",
		],
		CommandType.Type.HOLD: [
			"I'll hold them — protect the Rebellion!",
			"Stand your ground. I won't let them through.",
		],
		CommandType.Type.CHARGE: [
			"For the people they starved — charge!",
			"Run with me — we finish this together!",
		],
		CommandType.Type.ATTACK: [
			"They don't get to win — attack!",
			"Fight back! We deserve to be free!",
		],
		CommandType.Type.DEFEND: [
			"I'll shield you — that's what I do.",
			"Defend! I haven't come this far to quit.",
		],
		CommandType.Type.RALLY: [
			"We survive together — stay with me!",
			"You're worth fighting for — all of you!",
		],
	},
	"gale": {
		CommandType.Type.FOLLOW: [
			"Stay close — I know these kinds of traps.",
			"Follow me through the wire.",
		],
		CommandType.Type.HOLD: [
			"Hold the line. I've hunted worse than this.",
			"Don't budge — I've got eyes on them.",
		],
		CommandType.Type.CHARGE: [
			"Take the Capital — for District 12!",
			"Charge! They poisoned our home!",
		],
		CommandType.Type.ATTACK: [
			"Hunt them down!",
			"Strike hard — show them we're not prey!",
		],
		CommandType.Type.DEFEND: [
			"I'll cover you — nothing gets through.",
			"Defend! They took enough from the districts!",
		],
		CommandType.Type.RALLY: [
			"Remember the meadow — fight for it!",
			"Get up! The Rebellion doesn't die in the woods!",
		],
	},
}

const BATTLE_CRIES: Dictionary = {
	CommandType.Type.FOLLOW: [
		"Stay close — the road goes ever on.",
		"Form up behind me.",
		"Stick together — the Rebellion needs every one of us.",
		"On me! We move as one.",
	],
	CommandType.Type.HOLD: [
		"Hold this ground! None shall pass!",
		"Stand firm, soldiers of the West!",
		"Dig in — the Capital won't break this line!",
		"Not one step back!",
	],
	CommandType.Type.CHARGE: [
		"For the Rebellion! Take the Capital!",
		"For Frodo! For the King!",
		"Now for wrath, now for ruin!",
		"For the Republic!",
		"For District 12! For every world they crushed!",
		"Charge — freedom or nothing!",
	],
	CommandType.Type.ATTACK: [
		"Bring them down!",
		"Engage at will!",
		"Strike the Capital's dogs!",
		"Fire at will — for the Rebellion!",
	],
	CommandType.Type.DEFEND: [
		"Protect the line!",
		"Shield wall! Hold them back!",
		"Cover the Rebellion — don't let them through!",
		"Defend — our people are counting on us!",
	],
	CommandType.Type.RALLY: [
		"The Rebellion lives!",
		"There is still hope!",
		"Rise, warriors of the light!",
		"The tide turns — stand with me!",
		"We are the spark — and the fire!",
		"Get up! The Capital hasn't won yet!",
	],
}


func _ready() -> void:
	set_process_unhandled_input(true)


func register_commander(cmd: Commander) -> void:
	commander = cmd


func register_unit(unit: CommandableUnit) -> void:
	if not unit.follow_target and commander:
		unit.follow_target = commander
	unit.receive_command(CommandType.Type.FOLLOW, {"target": commander})


func select_all_allies() -> void:
	var allies := get_tree().get_nodes_in_group("allies")
	selected_units.clear()
	for node in allies:
		if node is CommandableUnit:
			node.set_selected(true)
			selected_units.append(node)
	selection_changed.emit(selected_units)


func clear_selection() -> void:
	for unit in selected_units:
		if is_instance_valid(unit):
			unit.set_selected(false)
	selected_units.clear()
	selection_changed.emit(selected_units)


func issue_command(type: CommandType.Type) -> void:
	if selected_units.is_empty():
		select_all_allies()

	if selected_units.is_empty():
		return

	var data: Dictionary = {}
	if type == CommandType.Type.FOLLOW and commander:
		data["target"] = commander
	elif type == CommandType.Type.CHARGE and commander:
		if RebellionManager.is_active:
			data["direction"] = RebellionManager.get_charge_direction_toward_capital(commander.global_position)
		else:
			data["direction"] = commander.get_charge_direction()
	elif type == CommandType.Type.DEFEND and commander:
		data["position"] = commander.global_position

	for unit in selected_units:
		if is_instance_valid(unit):
			unit.receive_command(type, data)

	var hero_id := PlayerData.appearance.hero_preset_id
	var partner_id := PlayerData.appearance.partner_hero_preset_id
	var cries: Array = BATTLE_CRIES.get(type, ["Command issued."])

	var quote_hero := hero_id
	if not partner_id.is_empty() and (hero_id.is_empty() or randf() > 0.45):
		quote_hero = partner_id

	if not quote_hero.is_empty() \
			and HERO_BATTLE_CRIES.has(quote_hero) \
			and HERO_BATTLE_CRIES[quote_hero].has(type):
		cries = HERO_BATTLE_CRIES[quote_hero][type]
	battle_cry.emit(cries.pick_random())
	command_issued.emit(type, selected_units.duplicate())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			select_all_allies()
			return

		var cmd_type := CommandType.type_from_key(event.keycode)
		if cmd_type != -1:
			issue_command(cmd_type)
