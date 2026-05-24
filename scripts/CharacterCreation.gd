extends Control

# ============================================================
# KAOS EMBERS — Character Creation Screen
# Sections: Race (12) | Class (4 base) | Divinity (6)
# Point-buy stat allocation, derived stat preview
# ============================================================

const STATS       = ["Str", "Int", "Agi", "End", "Wis", "Chr"]
const STAT_NAMES  = {"Str": "Strength", "Int": "Intelligence", "Agi": "Agility",
                     "End": "Endurance", "Wis": "Wisdom", "Chr": "Charisma"}
const STAT_DESC   = {
	"Str": "Physical damage, carry weight, melee hit chance",
	"Int": "Spell damage, MP pool, trap detection, search success",
	"Agi": "Dodge chance, backstab eligibility, stealth movement",
	"End": "HP pool, physical resistance, stamina resilience",
	"Wis": "MP regen, spell resistance, healing effectiveness",
	"Chr": "NPC dialogue, companion loyalty, taunt effectiveness",
}

const STAT_MIN          = 8
const STAT_MAX          = 15
const POINT_BUY_BUDGET  = 27
# Point cost from base 8 to reach a given value
const POINT_COST = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9}

# ---- Race data ------------------------------------------------------------------

const RACES = {
	"Human": {
		"desc": "The most versatile race. Survivors of the Kaos Wars. Suited to any class.",
		"bonuses": {},
		"passive": "Adaptable: +1 to all stats at levels 5, 10, 15, 20, 25",
		"lore": "Survivors of the Kaos Wars, humans carry no ember heritage — only will.",
	},
	"Elf": {
		"desc": "Ancient people attuned to ember magic. Frail but devastatingly intelligent.",
		"bonuses": {"Str": -1, "Int": 3, "Agi": 1, "End": -1, "Wis": 2, "Chr": 1},
		"passive": "Ember Attuned: +10% spell damage",
		"lore": "Elves carry ember fire in their blood — inherited from Pyron's first age.",
	},
	"Half-Elf": {
		"desc": "Born of two worlds, excelling where full-bloods cannot.",
		"bonuses": {"Str": 1, "Int": 2, "Wis": 1, "Chr": 1},
		"passive": "Balanced Blood: No class stat restrictions",
		"lore": "Half-elves navigate both worlds with rare adaptability.",
	},
	"Dark Elf": {
		"desc": "Cunning and dangerous. Dwell in vast underground cities. Excel as rogues and mages.",
		"bonuses": {"Str": -1, "Int": 3, "Agi": 2, "End": -1, "Wis": 1, "Chr": -1},
		"passive": "Shadow Step: +15% backstab damage, autosneak costs less stamina",
		"lore": "Dark elves were exiled from the surface after the Nox Accord. They thrived.",
	},
	"Halfling": {
		"desc": "Small but hardy. Natural thieves and druids. Surprising fighters.",
		"bonuses": {"Str": -1, "Int": 1, "Agi": 3, "End": 1, "Wis": 1},
		"passive": "Lucky: 5% chance to avoid any attack entirely",
		"lore": "Halflings survived the Kaos Wars by being too small to matter. Then everything changed.",
	},
	"Gnome": {
		"desc": "Most agile and intelligent of the small races. Master spellcasters and thieves.",
		"bonuses": {"Str": -2, "Int": 4, "Agi": 2, "End": -1, "Wis": 2},
		"passive": "Tinkerer: +20% trap disarm success rate",
		"lore": "Gnomes chart ember currents like rivers. They understand what others merely observe.",
	},
	"Dwarf": {
		"desc": "Strong and stout. Exceptional warriors. Weak spellcasters but nearly unbreakable.",
		"bonuses": {"Str": 3, "Int": -1, "Agi": -2, "End": 4},
		"passive": "Forgeborn: +15% physical resistance, immune to poison duration reduction",
		"lore": "Dwarves carved their cities from ember rock. They are the rock.",
	},
	"Goblin": {
		"desc": "Agile and cunning scavengers. Natural thieves. More survivable than they look.",
		"bonuses": {"Str": -1, "Agi": 4, "End": 1, "Wis": -1, "Chr": -1},
		"passive": "Scrappy: +20% item drop rate",
		"lore": "Nobody expects much from a Goblin. That's exactly the point.",
	},
	"Saurian": {
		"desc": "Large reptilian humanoids. Slow but devastating in melee. Rare and feared.",
		"bonuses": {"Str": 4, "Int": -2, "Agi": -1, "End": 3, "Wis": -1, "Chr": -1},
		"passive": "Scales: +20 base armor, natural weapon (claws, no unarmed penalty)",
		"lore": "Saurians predate the Kaos Wars. They remember when the sky was whole.",
	},
	"Half-Orc": {
		"desc": "Half-human, half-orc. Immense physical power. Best for fighter roles. Difficult socially.",
		"bonuses": {"Str": 4, "Int": -2, "Agi": -1, "End": 3, "Wis": -1, "Chr": -2},
		"passive": "Brutish: +10% melee damage, Rage builds 25% faster",
		"lore": "Half-orcs fight because fighting is the only language the world taught them.",
	},
	"Ashborn": {
		"desc": "Humans touched by Kaos flame during the wars. Partially corrupted, partially empowered.",
		"bonuses": {"Str": 2, "Int": 1, "End": 2, "Wis": -2, "Chr": -1},
		"passive": "Ember Scarred: +10% fire damage, -10% ice damage",
		"lore": "The flame that should have killed them rewrote them instead.",
	},
	"Wraithkin": {
		"desc": "Undead-adjacent beings of shadow origin. Powerful mages and necromancers.",
		"bonuses": {"Str": -1, "Int": 4, "Agi": 1, "End": -2, "Wis": 3, "Chr": -2},
		"passive": "Undying: Death sickness fades twice as fast",
		"lore": "Wraithkin stand at the border between alive and not. They find it comfortable there.",
	},
}

# ---- Class data ------------------------------------------------------------------

const CLASSES = {
	"Fighter": {
		"desc": "Warriors forged in the fires of the Kaos Wars. Masters of physical combat and survival.",
		"primary": ["Str", "End"],
		"bonuses": {"Str": 2, "End": 1},
		"hit_die": "d10",
		"role": "Melee DPS and Tanking",
		"paths": "Knight / Barbarian / Paladin / Ranger / Monk",
	},
	"Rogue": {
		"desc": "Shadows made flesh. Masters of the unseen strike, utility, and thievery.",
		"primary": ["Agi", "Int"],
		"bonuses": {"Agi": 2, "Int": 1},
		"hit_die": "d8",
		"role": "Stealth DPS and Utility",
		"paths": "Thief / Assassin / Bard",
	},
	"Mage": {
		"desc": "Scholars of Kaos energy. Volatile, powerful, and potentially catastrophic.",
		"primary": ["Int", "Wis"],
		"bonuses": {"Int": 2, "Wis": 1},
		"hit_die": "d6",
		"role": "Spell DPS and Summoning",
		"paths": "Sorcerer / Necromancer",
	},
	"Healer": {
		"desc": "Servants of the divine. Keepers of life against the ever-rising Kaos tide.",
		"primary": ["Wis", "Chr"],
		"bonuses": {"Wis": 2, "Chr": 1},
		"hit_die": "d8",
		"role": "Healing and Support",
		"paths": "Cleric / Druid",
	},
}

# ---- Divinity data ---------------------------------------------------------------

const DIVINITIES = {
	"Pyron": {
		"element": "Fire",
		"color": Color(1.0, 0.35, 0.1),
		"bonus_vs": "Night",
		"weak_vs": "Water",
		"desc": "The Flame. Fire deals +15% damage vs Night, -10% vs Water.",
		"lore": "Pyron's ember burns at the core of every fire mage's power.",
	},
	"Nox": {
		"element": "Night",
		"color": Color(0.55, 0.15, 0.8),
		"bonus_vs": "Earth",
		"weak_vs": "Fire",
		"desc": "The Shadow. Night deals +15% damage vs Earth, -10% vs Fire.",
		"lore": "Nox retreated at the end of the Kaos Wars. The darkness remained.",
	},
	"Terra": {
		"element": "Earth",
		"color": Color(0.5, 0.35, 0.15),
		"bonus_vs": "Lightning",
		"weak_vs": "Night",
		"desc": "The Stone. Earth deals +15% damage vs Lightning, -10% vs Night.",
		"lore": "Terra's children raise walls against the void. Not all walls hold.",
	},
	"Voltus": {
		"element": "Lightning",
		"color": Color(0.95, 0.9, 0.1),
		"bonus_vs": "Water",
		"weak_vs": "Earth",
		"desc": "The Storm. Lightning deals +15% damage vs Water, -10% vs Earth.",
		"lore": "Voltus struck the Kaos citadel twice before the age ended. It still smells of ozone.",
	},
	"Riva": {
		"element": "Water",
		"color": Color(0.2, 0.55, 1.0),
		"bonus_vs": "Fire",
		"weak_vs": "Lightning",
		"desc": "The Tide. Water deals +15% damage vs Fire, -10% vs Lightning.",
		"lore": "Riva's waters rise at the edges of the world. The drowned walk Riva's shores.",
	},
	"Nethys": {
		"element": "Neutral",
		"color": Color(0.55, 0.55, 0.6),
		"bonus_vs": "Neutral",
		"weak_vs": "None",
		"desc": "The Balance. No elemental bonuses or weaknesses. Temple access anywhere for gold.",
		"lore": "Nethys watches all sides. This is either wisdom or cowardice — Nethys doesn't say.",
	},
}

# ============================================================
# STATE
# ============================================================

var selected_race:     String = ""
var selected_class:    String = ""
var selected_divinity: String = ""
var base_stats:        Dictionary = {}
var points_remaining:  int = POINT_BUY_BUDGET

# UI node references
var race_buttons:    Dictionary = {}
var class_buttons:   Dictionary = {}
var div_buttons:     Dictionary = {}
var stat_rows:       Dictionary = {}

var points_label:      Label
var race_info_box:     VBoxContainer
var class_info_box:    VBoxContainer
var div_info_box:      VBoxContainer
var derived_box:       VBoxContainer
var confirm_btn:       Button
var summary_label:     Label
var name_input:        LineEdit

# ============================================================
# INIT
# ============================================================

func _ready() -> void:
	for stat in STATS:
		base_stats[stat] = STAT_MIN
	_build_ui()
	_refresh_stat_display()

# ============================================================
# UI CONSTRUCTION
# ============================================================

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.09)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	scroll.add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	# Title
	var title := Label.new()
	title.text = "KAOS EMBERS  —  CHARACTER CREATION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.9, 0.65, 0.15))
	root.add_child(title)

	root.add_child(_hsep())
	_build_name_row(root)
	root.add_child(_hsep())

	# Three selection columns
	var top_row := HBoxContainer.new()
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_theme_constant_override("separation", 12)
	root.add_child(top_row)
	top_row.add_child(_build_race_col())
	top_row.add_child(VSeparator.new())
	top_row.add_child(_build_class_col())
	top_row.add_child(VSeparator.new())
	top_row.add_child(_build_divinity_col())

	root.add_child(_hsep())

	# Stats + derived side by side
	var stat_row := HBoxContainer.new()
	stat_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_row.add_theme_constant_override("separation", 12)
	root.add_child(stat_row)
	stat_row.add_child(_build_stats_col())
	stat_row.add_child(VSeparator.new())
	stat_row.add_child(_build_derived_col())

	root.add_child(_hsep())
	_build_confirm_bar(root)


func _build_name_row(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	var lbl := Label.new()
	lbl.text = "Character Name:"
	lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	row.add_child(lbl)

	name_input = LineEdit.new()
	name_input.placeholder_text = "Enter name..."
	name_input.custom_minimum_size = Vector2(280, 36)
	name_input.text_changed.connect(func(_t): _update_confirm())
	row.add_child(name_input)


func _build_race_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 4)
	col.add_child(_header("RACE", Color(0.55, 0.85, 1.0)))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 4)
	col.add_child(grid)

	for rname: String in RACES.keys():
		var btn := _select_btn(rname)
		btn.pressed.connect(_on_race.bind(rname))
		grid.add_child(btn)
		race_buttons[rname] = btn

	col.add_child(_hsep())

	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(panel)

	race_info_box = VBoxContainer.new()
	race_info_box.add_theme_constant_override("separation", 5)
	panel.add_child(race_info_box)
	_placeholder(race_info_box, "Select a race to see details.")

	return col


func _build_class_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.custom_minimum_size = Vector2(220, 0)
	col.add_theme_constant_override("separation", 4)
	col.add_child(_header("CLASS", Color(1.0, 0.75, 0.45)))

	for cname: String in CLASSES.keys():
		var btn := _select_btn(cname)
		btn.pressed.connect(_on_class.bind(cname))
		col.add_child(btn)
		class_buttons[cname] = btn

	col.add_child(_hsep())

	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(panel)

	class_info_box = VBoxContainer.new()
	class_info_box.add_theme_constant_override("separation", 5)
	panel.add_child(class_info_box)
	_placeholder(class_info_box, "Select a class to see details.")

	return col


func _build_divinity_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.custom_minimum_size = Vector2(220, 0)
	col.add_theme_constant_override("separation", 4)
	col.add_child(_header("DIVINITY", Color(0.85, 0.65, 1.0)))

	for dname: String in DIVINITIES.keys():
		var d: Dictionary = DIVINITIES[dname]
		var btn := _select_btn(dname + "  (" + d["element"] + ")")
		btn.pressed.connect(_on_divinity.bind(dname))
		col.add_child(btn)
		div_buttons[dname] = btn

	col.add_child(_hsep())

	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(panel)

	div_info_box = VBoxContainer.new()
	div_info_box.add_theme_constant_override("separation", 5)
	panel.add_child(div_info_box)
	_placeholder(div_info_box, "Select a divinity.\nAffects elemental damage and temple access.")

	return col


func _build_stats_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)

	# Header + remaining points
	var hdr_row := HBoxContainer.new()
	col.add_child(hdr_row)
	hdr_row.add_child(_header("STATS", Color(0.9, 0.55, 0.55)))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_row.add_child(spacer)
	points_label = Label.new()
	points_label.text = "Points: %d" % POINT_BUY_BUDGET
	points_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.5))
	hdr_row.add_child(points_label)

	# Column labels
	var col_hdr := HBoxContainer.new()
	col_hdr.add_theme_constant_override("separation", 4)
	col.add_child(col_hdr)
	for pair: Array in [["Stat / Full Name", 140], ["−", 28], ["Base", 32], ["+", 28],
			["Race", 45], ["Class", 45], ["Total", 48]]:
		var l := Label.new()
		l.text = pair[0]
		l.custom_minimum_size = Vector2(pair[1], 0)
		l.add_theme_font_size_override("font_size", 11)
		l.add_theme_color_override("font_color", Color(0.42, 0.42, 0.42))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col_hdr.add_child(l)

	col.add_child(_hsep())

	for stat: String in STATS:
		col.add_child(_build_stat_row(stat))

	col.add_child(_hsep())

	var hint := Label.new()
	hint.text = "Point cost: 8–13 = 1 pt each  |  14 = 2 pts  |  15 = 3 pts  |  Base range: 8–15"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.38, 0.38, 0.38))
	col.add_child(hint)

	return col


func _build_stat_row(stat: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var name_lbl := Label.new()
	name_lbl.text = stat
	name_lbl.custom_minimum_size = Vector2(36, 30)
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.65))
	name_lbl.tooltip_text = STAT_NAMES[stat] + "\n" + STAT_DESC[stat]
	row.add_child(name_lbl)

	var full_lbl := Label.new()
	full_lbl.text = STAT_NAMES[stat]
	full_lbl.custom_minimum_size = Vector2(100, 0)
	full_lbl.add_theme_font_size_override("font_size", 10)
	full_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	full_lbl.tooltip_text = STAT_DESC[stat]
	row.add_child(full_lbl)

	var minus := Button.new()
	minus.text = "−"
	minus.custom_minimum_size = Vector2(28, 28)
	minus.pressed.connect(_on_stat_minus.bind(stat))
	row.add_child(minus)

	var base_lbl := Label.new()
	base_lbl.text = str(STAT_MIN)
	base_lbl.custom_minimum_size = Vector2(32, 0)
	base_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base_lbl.add_theme_font_size_override("font_size", 15)
	base_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	row.add_child(base_lbl)

	var plus := Button.new()
	plus.text = "+"
	plus.custom_minimum_size = Vector2(28, 28)
	plus.pressed.connect(_on_stat_plus.bind(stat))
	row.add_child(plus)

	var race_lbl := Label.new()
	race_lbl.text = "—"
	race_lbl.custom_minimum_size = Vector2(45, 0)
	race_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	race_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	row.add_child(race_lbl)

	var class_lbl := Label.new()
	class_lbl.text = "—"
	class_lbl.custom_minimum_size = Vector2(45, 0)
	class_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	class_lbl.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	row.add_child(class_lbl)

	var total_lbl := Label.new()
	total_lbl.text = str(STAT_MIN)
	total_lbl.custom_minimum_size = Vector2(48, 0)
	total_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_lbl.add_theme_font_size_override("font_size", 18)
	total_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	row.add_child(total_lbl)

	stat_rows[stat] = {
		"minus": minus, "plus": plus,
		"base": base_lbl, "race": race_lbl, "class": class_lbl, "total": total_lbl,
	}
	return row


func _build_derived_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(260, 0)
	col.add_theme_constant_override("separation", 6)
	col.add_child(_header("DERIVED STATS", Color(0.55, 1.0, 0.75)))

	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(panel)

	derived_box = VBoxContainer.new()
	derived_box.add_theme_constant_override("separation", 6)
	panel.add_child(derived_box)

	_rebuild_derived()
	return col


func _build_confirm_bar(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	parent.add_child(row)

	summary_label = Label.new()
	summary_label.text = "Select race, class, and divinity to continue."
	summary_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	row.add_child(summary_label)

	confirm_btn = Button.new()
	confirm_btn.text = "BEGIN YOUR JOURNEY"
	confirm_btn.custom_minimum_size = Vector2(230, 50)
	confirm_btn.disabled = true
	confirm_btn.pressed.connect(_on_confirm)
	row.add_child(confirm_btn)

# ============================================================
# EVENT HANDLERS
# ============================================================

func _on_race(rname: String) -> void:
	for n: String in race_buttons:
		race_buttons[n].button_pressed = (n == rname)
	selected_race = rname
	_fill_race_info(rname)
	_refresh_stat_display()
	_update_confirm()


func _on_class(cname: String) -> void:
	for n: String in class_buttons:
		class_buttons[n].button_pressed = (n == cname)
	selected_class = cname
	_fill_class_info(cname)
	_refresh_stat_display()
	_update_confirm()


func _on_divinity(dname: String) -> void:
	for n: String in div_buttons:
		div_buttons[n].button_pressed = (n == dname)
	selected_divinity = dname
	_fill_divinity_info(dname)
	_rebuild_derived()
	_update_confirm()


func _on_stat_plus(stat: String) -> void:
	var cur: int = base_stats[stat]
	if cur >= STAT_MAX:
		return
	var cost: int = POINT_COST.get(cur + 1, 99) - POINT_COST.get(cur, 0)
	if points_remaining < cost:
		return
	base_stats[stat] += 1
	points_remaining -= cost
	_refresh_stat_display()


func _on_stat_minus(stat: String) -> void:
	var cur: int = base_stats[stat]
	if cur <= STAT_MIN:
		return
	var refund: int = POINT_COST.get(cur, 0) - POINT_COST.get(cur - 1, 0)
	base_stats[stat] -= 1
	points_remaining += refund
	_refresh_stat_display()


func _on_confirm() -> void:
	var cname: String = name_input.text.strip_edges()
	if cname.is_empty():
		cname = "Unnamed"

	var totals := _totals()
	var text := "Your adventurer wakes in Ashenveil.\n\n"
	text += "Name: %s\nRace: %s\nClass: %s\nDivinity: %s (%s)\n\n" % [
		cname, selected_race, selected_class,
		selected_divinity, DIVINITIES[selected_divinity]["element"],
	]
	text += "Final Stats:\n"
	for stat: String in STATS:
		text += "  %s %s: %d\n" % [stat, STAT_NAMES[stat], totals[stat]]
	text += "\nHP: %d   MP: %d   Dodge: %.0f%%   Mag Resist: %.0f%%" % [
		_hp(totals), _mp(totals), _dodge(totals), _mresist(totals),
	]

	var dlg := AcceptDialog.new()
	dlg.title = cname + " — " + selected_race + " " + selected_class
	dlg.dialog_text = text
	dlg.min_size = Vector2(420, 360)
	add_child(dlg)
	dlg.popup_centered()

# ============================================================
# INFO PANEL FILLS
# ============================================================

func _fill_race_info(rname: String) -> void:
	_clear(race_info_box)
	var d: Dictionary = RACES[rname]

	race_info_box.add_child(_info_title(rname))
	race_info_box.add_child(_info_body(d["desc"], Color(0.68, 0.68, 0.68)))
	race_info_box.add_child(_hsep())

	var bonus_lines := "Stat Bonuses:\n"
	var has_bonus := false
	for stat: String in STATS:
		var val: int = d["bonuses"].get(stat, 0)
		if val != 0:
			has_bonus = true
			bonus_lines += "  %s %s  %s%d\n" % [
				stat, STAT_NAMES[stat],
				"+" if val > 0 else "", val,
			]
	if not has_bonus:
		bonus_lines += "  None — all stats 0\n  (Gains +1 all at levels 5/10/15/20/25)"
	race_info_box.add_child(_info_body(bonus_lines.strip_edges(), Color(0.45, 0.88, 0.45)))
	race_info_box.add_child(_hsep())
	race_info_box.add_child(_info_body("Passive: " + d["passive"], Color(0.65, 0.82, 1.0)))
	race_info_box.add_child(_info_body(d["lore"], Color(0.38, 0.38, 0.46)))


func _fill_class_info(cname: String) -> void:
	_clear(class_info_box)
	var d: Dictionary = CLASSES[cname]

	class_info_box.add_child(_info_title(cname))
	class_info_box.add_child(_info_body(d["role"] + "  —  Hit Die: " + d["hit_die"], Color(0.82, 0.6, 0.38)))
	class_info_box.add_child(_info_body(d["desc"], Color(0.68, 0.68, 0.68)))
	class_info_box.add_child(_hsep())

	var bonus_lines := "Class Bonuses:\n"
	for stat: String in STATS:
		var val: int = d["bonuses"].get(stat, 0)
		if val != 0:
			bonus_lines += "  %s %s  +%d\n" % [stat, STAT_NAMES[stat], val]
	var primaries: Array = d["primary"].map(func(s: String) -> String: return s + " " + STAT_NAMES[s])
	bonus_lines += "\nPrimary Stats: " + ", ".join(primaries)
	class_info_box.add_child(_info_body(bonus_lines.strip_edges(), Color(1.0, 0.68, 0.35)))
	class_info_box.add_child(_hsep())
	class_info_box.add_child(_info_body("Level 10 paths:\n" + d["paths"], Color(0.72, 0.58, 1.0)))


func _fill_divinity_info(dname: String) -> void:
	_clear(div_info_box)
	var d: Dictionary = DIVINITIES[dname]

	var name_lbl := _info_title(dname + "  —  " + d["element"])
	name_lbl.add_theme_color_override("font_color", d["color"])
	div_info_box.add_child(name_lbl)
	div_info_box.add_child(_info_body(d["desc"], Color(0.68, 0.68, 0.68)))
	div_info_box.add_child(_hsep())
	div_info_box.add_child(_info_body(d["lore"], Color(0.38, 0.38, 0.46)))
	div_info_box.add_child(_hsep())

	var cycle := "Elemental Cycle:\nFire → Night → Earth → Lightning → Water → Fire\n"
	cycle += "Conquers: %s  (+15%% dmg)\n" % d["bonus_vs"]
	cycle += "Weak to: %s  (-10%% dmg)" % (d["weak_vs"] if d["weak_vs"] != "None" else "—")
	var cyc_lbl := _info_body(cycle, d["color"].lightened(0.15))
	div_info_box.add_child(cyc_lbl)

# ============================================================
# STAT REFRESH
# ============================================================

func _refresh_stat_display() -> void:
	# Points label color
	if points_remaining <= 4:
		points_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.3))
	elif points_remaining <= 10:
		points_label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.2))
	else:
		points_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.45))
	points_label.text = "Points: %d / %d" % [points_remaining, POINT_BUY_BUDGET]

	for stat: String in STATS:
		var r: Dictionary = stat_rows[stat]
		var base: int       = base_stats[stat]
		var rb: int         = _race_bonus(stat)
		var cb: int         = _class_bonus(stat)
		var total: int      = base + rb + cb

		r["base"].text = str(base)

		# Race bonus colouring
		if rb == 0:
			r["race"].text = "—"
			r["race"].add_theme_color_override("font_color", Color(0.32, 0.32, 0.32))
		elif rb > 0:
			r["race"].text = "+%d" % rb
			r["race"].add_theme_color_override("font_color", Color(0.38, 0.9, 0.38))
		else:
			r["race"].text = str(rb)
			r["race"].add_theme_color_override("font_color", Color(0.9, 0.32, 0.32))

		# Class bonus colouring
		if cb == 0:
			r["class"].text = "—"
			r["class"].add_theme_color_override("font_color", Color(0.32, 0.32, 0.32))
		else:
			r["class"].text = "+%d" % cb
			r["class"].add_theme_color_override("font_color", Color(1.0, 0.65, 0.28))

		# Total colouring
		r["total"].text = str(total)
		if total >= 20:
			r["total"].add_theme_color_override("font_color", Color(0.25, 1.0, 0.35))
		elif total >= 17:
			r["total"].add_theme_color_override("font_color", Color(0.85, 0.95, 0.25))
		elif total <= 6:
			r["total"].add_theme_color_override("font_color", Color(0.9, 0.28, 0.28))
		else:
			r["total"].add_theme_color_override("font_color", Color(0.82, 0.82, 0.82))

		# Button states
		r["minus"].disabled = (base <= STAT_MIN)
		var next_cost: int = POINT_COST.get(base + 1, 99) - POINT_COST.get(base, 0)
		r["plus"].disabled  = (base >= STAT_MAX or points_remaining < next_cost)

	_rebuild_derived()


func _update_confirm() -> void:
	var all_set: bool = selected_race != "" and selected_class != "" and selected_divinity != ""
	confirm_btn.disabled = not all_set

	if all_set:
		var cname: String = name_input.text.strip_edges()
		if cname.is_empty():
			cname = "Your hero"
		summary_label.text = "%s the %s %s of %s is ready." % [
			cname, selected_race, selected_class, selected_divinity
		]
		summary_label.add_theme_color_override("font_color", Color(0.65, 0.82, 0.65))
	else:
		var missing: Array = []
		if selected_race      == "": missing.append("race")
		if selected_class     == "": missing.append("class")
		if selected_divinity  == "": missing.append("divinity")
		summary_label.text = "Still needed: " + ", ".join(missing)
		summary_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))


func _rebuild_derived() -> void:
	_clear(derived_box)
	var t := _totals()

	var rows: Array = [
		["HP",          str(_hp(t))],
		["MP",          str(_mp(t))],
		["Melee Hit",   "%.0f%%" % _melee_hit(t)],
		["Spell Hit",   "%.0f%%" % _spell_hit(t)],
		["Dodge",       "%.0f%%" % _dodge(t)],
		["Phys Damage", "+%d" % _phys_dmg(t)],
		["Spell Damage","+%d" % _spell_dmg(t)],
		["Mag Resist",  "%.0f%%" % _mresist(t)],
	]
	for pair: Array in rows:
		var row := HBoxContainer.new()
		derived_box.add_child(row)
		var n := Label.new()
		n.text = pair[0]
		n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n.add_theme_font_size_override("font_size", 12)
		n.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		row.add_child(n)
		var v := Label.new()
		v.text = pair[1]
		v.add_theme_font_size_override("font_size", 13)
		v.add_theme_color_override("font_color", Color(0.82, 0.95, 0.82))
		row.add_child(v)

	if selected_divinity != "":
		derived_box.add_child(_hsep())
		var d: Dictionary = DIVINITIES[selected_divinity]
		var dlbl := Label.new()
		dlbl.text = "[%s — %s]\n+15%% vs %s  |  −10%% vs %s" % [
			selected_divinity, d["element"],
			d["bonus_vs"],
			d["weak_vs"] if d["weak_vs"] != "None" else "—",
		]
		dlbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dlbl.add_theme_font_size_override("font_size", 12)
		dlbl.add_theme_color_override("font_color", d["color"])
		derived_box.add_child(dlbl)

# ============================================================
# STAT MATH
# ============================================================

func _race_bonus(stat: String) -> int:
	if selected_race == "": return 0
	return RACES[selected_race]["bonuses"].get(stat, 0)

func _class_bonus(stat: String) -> int:
	if selected_class == "": return 0
	return CLASSES[selected_class]["bonuses"].get(stat, 0)

func _totals() -> Dictionary:
	var t := {}
	for stat: String in STATS:
		t[stat] = base_stats[stat] + _race_bonus(stat) + _class_bonus(stat)
	return t

func _hp(t: Dictionary)         -> int:   return t["End"] * 10 + 5
func _mp(t: Dictionary)         -> int:   return t["Int"] * 8 + t["Wis"] * 4 + 3
func _melee_hit(t: Dictionary)  -> float: return 60.0 + t["Str"] * 1.5
func _spell_hit(t: Dictionary)  -> float: return 60.0 + t["Int"] * 2.0
func _dodge(t: Dictionary)      -> float: return minf(t["Agi"] * 1.5, 40.0)
func _phys_dmg(t: Dictionary)   -> int:   return t["Str"] * 2
func _spell_dmg(t: Dictionary)  -> int:   return t["Int"] * 3
func _mresist(t: Dictionary)    -> float: return minf(t["Wis"] * 2.0, 50.0)

# ============================================================
# UI HELPERS
# ============================================================

func _hsep() -> HSeparator:
	return HSeparator.new()

func _header(text: String, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", color)
	return l

func _select_btn(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, 34)
	return b

func _info_title(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	return l

func _info_body(text: String, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", color)
	return l

func _placeholder(box: VBoxContainer, text: String) -> void:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	box.add_child(l)

func _clear(box: VBoxContainer) -> void:
	for c: Node in box.get_children():
		c.queue_free()
