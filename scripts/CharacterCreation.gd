extends Control

# ============================================================
# KAOS EMBERS — Character Creation
# ============================================================

const STATS      = ["Str", "Int", "Agi", "End", "Wis", "Chr"]
const STAT_NAMES = {
	"Str": "Strength", "Int": "Intelligence", "Agi": "Agility",
	"End": "Endurance", "Wis": "Wisdom",      "Chr": "Charisma",
}
const STAT_DESC = {
	"Str": "Physical damage, carry weight, melee hit chance",
	"Int": "Spell damage, MP pool, trap detection, search success",
	"Agi": "Dodge chance, backstab eligibility, movement stealth",
	"End": "HP pool, physical resistance, stamina resilience",
	"Wis": "MP regen, spell resistance, healing effectiveness",
	"Chr": "NPC dialogue, companion loyalty, taunt effectiveness",
}

const STAT_MIN         = 8
const STAT_MAX         = 15
const POINT_BUY_BUDGET = 27
const POINT_COST       = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9}

const PORTRAIT_COUNT = 10
const PORTRAIT_DIR   = "res://assets/portraits/"

# ---- Race data ------------------------------------------------------------------

const RACES = {
	"Human": {
		"bonuses": {},
		"passive": "Adaptable: +1 to all stats at levels 5, 10, 15, 20, 25",
		"lore": "Survivors of the Kaos Wars. Humans carry no ember heritage — only will.",
	},
	"Elf": {
		"bonuses": {"Str": -1, "Int": 3, "Agi": 1, "End": -1, "Wis": 2, "Chr": 1},
		"passive": "Ember Attuned: +10% spell damage",
		"lore": "Ancient people attuned to ember magic. Frail but devastatingly intelligent.",
	},
	"Half-Elf": {
		"bonuses": {"Str": 1, "Int": 2, "Wis": 1, "Chr": 1},
		"passive": "Balanced Blood: No class stat restrictions",
		"lore": "Born of two worlds, excelling where full-bloods cannot.",
	},
	"Dark Elf": {
		"bonuses": {"Str": -1, "Int": 3, "Agi": 2, "End": -1, "Wis": 1, "Chr": -1},
		"passive": "Shadow Step: +15% backstab damage, autosneak costs less",
		"lore": "Cunning and dangerous. Dwell in vast underground cities.",
	},
	"Halfling": {
		"bonuses": {"Str": -1, "Int": 1, "Agi": 3, "End": 1, "Wis": 1},
		"passive": "Lucky: 5% chance to avoid any attack entirely",
		"lore": "Small but hardy. Natural thieves and druids. Surprising fighters.",
	},
	"Gnome": {
		"bonuses": {"Str": -2, "Int": 4, "Agi": 2, "End": -1, "Wis": 2},
		"passive": "Tinkerer: +20% trap disarm success rate",
		"lore": "Most agile and intelligent of the small races. Master spellcasters.",
	},
	"Dwarf": {
		"bonuses": {"Str": 3, "Int": -1, "Agi": -2, "End": 4},
		"passive": "Forgeborn: +15% physical resistance, immune to poison duration reduction",
		"lore": "Strong and stout. Exceptional warriors. Nearly unbreakable.",
	},
	"Goblin": {
		"bonuses": {"Str": -1, "Agi": 4, "End": 1, "Wis": -1, "Chr": -1},
		"passive": "Scrappy: +20% item drop rate",
		"lore": "Agile and cunning scavengers. Natural thieves. More survivable than they look.",
	},
	"Saurian": {
		"bonuses": {"Str": 4, "Int": -2, "Agi": -1, "End": 3, "Wis": -1, "Chr": -1},
		"passive": "Scales: +20 base armor, natural weapon (claws)",
		"lore": "Large reptilian humanoids. Slow but devastating in melee. Rare and feared.",
	},
	"Half-Orc": {
		"bonuses": {"Str": 4, "Int": -2, "Agi": -1, "End": 3, "Wis": -1, "Chr": -2},
		"passive": "Brutish: +10% melee damage, Rage builds 25% faster",
		"lore": "Immense physical power. Best for fighter roles. Difficult socially.",
	},
	"Ashborn": {
		"bonuses": {"Str": 2, "Int": 1, "End": 2, "Wis": -2, "Chr": -1},
		"passive": "Ember Scarred: +10% fire damage, -10% ice damage",
		"lore": "Humans touched by Kaos flame during the wars. Corrupted and empowered.",
	},
	"Wraithkin": {
		"bonuses": {"Str": -1, "Int": 4, "Agi": 1, "End": -2, "Wis": 3, "Chr": -2},
		"passive": "Undying: Death sickness fades twice as fast",
		"lore": "Undead-adjacent beings of shadow origin. Powerful mages and necromancers.",
	},
}

# ---- Class data ------------------------------------------------------------------

const CLASSES = {
	"Fighter": {
		"role": "Melee DPS / Tanking",
		"hit_die": "d10",
		"bonuses": {"Str": 2, "End": 1},
		"primary": "Str, End",
		"paths": "Knight / Barbarian / Paladin / Ranger / Monk",
	},
	"Rogue": {
		"role": "Stealth DPS / Utility",
		"hit_die": "d8",
		"bonuses": {"Agi": 2, "Int": 1},
		"primary": "Agi, Int",
		"paths": "Thief / Assassin / Bard",
	},
	"Mage": {
		"role": "Spell DPS / Summoning",
		"hit_die": "d6",
		"bonuses": {"Int": 2, "Wis": 1},
		"primary": "Int, Wis",
		"paths": "Sorcerer / Necromancer",
	},
	"Healer": {
		"role": "Healing / Support",
		"hit_die": "d8",
		"bonuses": {"Wis": 2, "Chr": 1},
		"primary": "Wis, Chr",
		"paths": "Cleric / Druid",
	},
}

# ---- Divinity data ---------------------------------------------------------------

const DIVINITIES = {
	"Pyron":  {"element": "Fire",      "color": Color(1.0, 0.35, 0.1),  "bonus_vs": "Night",     "weak_vs": "Water",
				"lore": "Pyron's ember burns at the core of every fire mage's power."},
	"Nox":    {"element": "Night",     "color": Color(0.55, 0.15, 0.8), "bonus_vs": "Earth",     "weak_vs": "Fire",
				"lore": "Nox retreated at the end of the Kaos Wars. The darkness remained."},
	"Terra":  {"element": "Earth",     "color": Color(0.5, 0.38, 0.15), "bonus_vs": "Lightning", "weak_vs": "Night",
				"lore": "Terra's children raise walls against the void. Not all walls hold."},
	"Voltus": {"element": "Lightning", "color": Color(0.95, 0.9, 0.1),  "bonus_vs": "Water",     "weak_vs": "Earth",
				"lore": "Voltus struck the Kaos citadel twice. It still smells of ozone."},
	"Riva":   {"element": "Water",     "color": Color(0.2, 0.55, 1.0),  "bonus_vs": "Fire",      "weak_vs": "Lightning",
				"lore": "Riva's waters rise at the edges of the world. The drowned walk its shores."},
	"Nethys": {"element": "Neutral",   "color": Color(0.55, 0.55, 0.6), "bonus_vs": "Neutral",   "weak_vs": "None",
				"lore": "Nethys watches all sides. This is either wisdom or cowardice — Nethys doesn't say."},
}

# ============================================================
# STATE
# ============================================================

var selected_race:     String = ""
var selected_class:    String = ""
var selected_divinity: String = ""
var selected_portrait: int    = -1
var base_stats:        Dictionary = {}
var points_remaining:  int = POINT_BUY_BUDGET

# ============================================================
# UI REFERENCES
# ============================================================

# Portrait
var portrait_preview_tex: TextureRect
var portrait_preview_lbl: Label
var portrait_buttons:     Array[Button] = []

# Selections
var race_buttons:  Dictionary = {}
var class_buttons: Dictionary = {}
var div_buttons:   Dictionary = {}

# Race info (pre-built, updated in-place)
var race_title_lbl:   Label
var race_bonuses_lbl: Label
var race_passive_lbl: Label
var race_lore_lbl:    Label

# Class info
var class_title_lbl:   Label
var class_role_lbl:    Label
var class_bonuses_lbl: Label
var class_paths_lbl:   Label

# Divinity info
var div_title_lbl: Label
var div_lore_lbl:  Label
var div_cycle_lbl: Label

# Stats
var stat_rows:    Dictionary = {}
var points_label: Label

# Derived
var derived_vals: Dictionary = {}

# Bottom
var name_input:    LineEdit
var summary_label: Label
var confirm_btn:   Button

# ============================================================
# INIT
# ============================================================

func _ready() -> void:
	for stat: String in STATS:
		base_stats[stat] = STAT_MIN
	_build_ui()
	_refresh_stats()

# ============================================================
# UI BUILD
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
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	scroll.add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 6)
	margin.add_child(root)

	# Title
	var title := _lbl("KAOS EMBERS  —  CHARACTER CREATION", 20, Color(0.9, 0.65, 0.15))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	root.add_child(_hsep())

	# Portrait + name row
	root.add_child(_build_portrait_name_row())
	root.add_child(_hsep())

	# Three selection columns
	var col_row := HBoxContainer.new()
	col_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_row.add_theme_constant_override("separation", 10)
	root.add_child(col_row)
	col_row.add_child(_build_race_col())
	col_row.add_child(VSeparator.new())
	col_row.add_child(_build_class_col())
	col_row.add_child(VSeparator.new())
	col_row.add_child(_build_div_col())

	root.add_child(_hsep())

	# Stats + Derived
	var stat_row := HBoxContainer.new()
	stat_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_row.add_theme_constant_override("separation", 10)
	root.add_child(stat_row)
	stat_row.add_child(_build_stats_col())
	stat_row.add_child(VSeparator.new())
	stat_row.add_child(_build_derived_col())

	root.add_child(_hsep())

	# Confirm bar
	var bot := HBoxContainer.new()
	bot.alignment = BoxContainer.ALIGNMENT_CENTER
	bot.add_theme_constant_override("separation", 16)
	root.add_child(bot)

	summary_label = _lbl("Select race, class, and divinity to continue.", 12, Color(0.45, 0.45, 0.45))
	bot.add_child(summary_label)

	confirm_btn = Button.new()
	confirm_btn.text = "CREATE CHARACTER"
	confirm_btn.custom_minimum_size = Vector2(180, 38)
	confirm_btn.disabled = true
	confirm_btn.pressed.connect(_on_confirm)
	bot.add_child(confirm_btn)


func _build_portrait_name_row() -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)

	# Portrait preview column
	var prev_col := VBoxContainer.new()
	prev_col.add_theme_constant_override("separation", 3)
	hbox.add_child(prev_col)

	prev_col.add_child(_lbl_centered("PORTRAIT", 11, Color(0.5, 0.5, 0.5)))

	var prev_panel := PanelContainer.new()
	prev_panel.custom_minimum_size = Vector2(54, 70)
	prev_col.add_child(prev_panel)

	# Overlay: TextureRect + label stacked
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prev_panel.add_child(overlay)

	portrait_preview_tex = TextureRect.new()
	portrait_preview_tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_preview_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	overlay.add_child(portrait_preview_tex)

	portrait_preview_lbl = Label.new()
	portrait_preview_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_preview_lbl.text = "?"
	portrait_preview_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_preview_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait_preview_lbl.add_theme_font_size_override("font_size", 26)
	portrait_preview_lbl.add_theme_color_override("font_color", Color(0.28, 0.28, 0.35))
	overlay.add_child(portrait_preview_lbl)

	# Name + thumbnails column
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 5)
	hbox.add_child(right)

	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 6)
	right.add_child(name_row)
	name_row.add_child(_lbl("Name:", 12, Color(0.6, 0.6, 0.6)))

	name_input = LineEdit.new()
	name_input.placeholder_text = "Enter character name..."
	name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_input.custom_minimum_size.y = 28
	name_input.text_changed.connect(func(_t: String) -> void: _update_confirm())
	name_row.add_child(name_input)

	right.add_child(_lbl("Choose Portrait:", 11, Color(0.5, 0.5, 0.5)))

	var grid := GridContainer.new()
	grid.columns = PORTRAIT_COUNT
	grid.add_theme_constant_override("h_separation", 4)
	right.add_child(grid)

	for i: int in range(PORTRAIT_COUNT):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(44, 56)
		btn.toggle_mode = true
		var path := PORTRAIT_DIR + "portrait_%02d.png" % (i + 1)
		if ResourceLoader.exists(path):
			var tex := load(path) as Texture2D
			if tex:
				btn.icon = tex
				btn.expand_icon = true
			else:
				btn.text = str(i + 1)
		else:
			btn.text = str(i + 1)
		btn.pressed.connect(_on_portrait.bind(i))
		grid.add_child(btn)
		portrait_buttons.append(btn)

	return hbox


func _build_race_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.custom_minimum_size = Vector2(210, 0)
	col.add_theme_constant_override("separation", 5)
	col.add_child(_col_hdr("RACE", Color(0.55, 0.85, 1.0)))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 3)
	col.add_child(grid)

	for rname: String in RACES.keys():
		var btn := _sel_btn(rname)
		btn.pressed.connect(_on_race.bind(rname))
		grid.add_child(btn)
		race_buttons[rname] = btn

	col.add_child(_hsep())

	var info := PanelContainer.new()
	info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(info)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	info.add_child(vb)

	race_title_lbl   = _lbl("Select a race", 13, Color(0.4, 0.4, 0.4))
	race_bonuses_lbl = _wrap_lbl("", 11, Color(0.42, 0.88, 0.42))
	race_passive_lbl = _wrap_lbl("", 11, Color(0.62, 0.82, 1.0))
	race_lore_lbl    = _wrap_lbl("", 10, Color(0.38, 0.38, 0.46))

	vb.add_child(race_title_lbl)
	vb.add_child(race_bonuses_lbl)
	vb.add_child(_hsep())
	vb.add_child(race_passive_lbl)
	vb.add_child(race_lore_lbl)

	return col


func _build_class_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.custom_minimum_size = Vector2(185, 0)
	col.add_theme_constant_override("separation", 5)
	col.add_child(_col_hdr("CLASS", Color(1.0, 0.75, 0.45)))

	for cname: String in CLASSES.keys():
		var btn := _sel_btn(cname)
		btn.pressed.connect(_on_class.bind(cname))
		col.add_child(btn)
		class_buttons[cname] = btn

	col.add_child(_hsep())

	var info := PanelContainer.new()
	info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(info)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	info.add_child(vb)

	class_title_lbl   = _lbl("Select a class", 13, Color(0.4, 0.4, 0.4))
	class_role_lbl    = _wrap_lbl("", 11, Color(0.82, 0.62, 0.38))
	class_bonuses_lbl = _wrap_lbl("", 11, Color(1.0, 0.68, 0.32))
	class_paths_lbl   = _wrap_lbl("", 11, Color(0.72, 0.58, 1.0))

	vb.add_child(class_title_lbl)
	vb.add_child(class_role_lbl)
	vb.add_child(_hsep())
	vb.add_child(class_bonuses_lbl)
	vb.add_child(_hsep())
	vb.add_child(class_paths_lbl)

	return col


func _build_div_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.custom_minimum_size = Vector2(185, 0)
	col.add_theme_constant_override("separation", 5)
	col.add_child(_col_hdr("DIVINITY", Color(0.85, 0.65, 1.0)))

	for dname: String in DIVINITIES.keys():
		var d: Dictionary = DIVINITIES[dname]
		var btn := _sel_btn("%s  (%s)" % [dname, d["element"]])
		btn.pressed.connect(_on_divinity.bind(dname))
		col.add_child(btn)
		div_buttons[dname] = btn

	col.add_child(_hsep())

	var info := PanelContainer.new()
	info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(info)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	info.add_child(vb)

	div_title_lbl = _lbl("Select a divinity", 13, Color(0.4, 0.4, 0.4))
	div_lore_lbl  = _wrap_lbl("", 11, Color(0.62, 0.62, 0.68))
	div_cycle_lbl = _wrap_lbl("", 11, Color(0.62, 0.62, 0.68))

	vb.add_child(div_title_lbl)
	vb.add_child(div_lore_lbl)
	vb.add_child(_hsep())
	vb.add_child(div_cycle_lbl)

	return col


func _build_stats_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 5)

	var hdr_row := HBoxContainer.new()
	col.add_child(hdr_row)
	var sh := _col_hdr("STATS", Color(0.9, 0.55, 0.55))
	sh.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_row.add_child(sh)
	points_label = _lbl("Points: %d" % POINT_BUY_BUDGET, 11, Color(0.5, 0.9, 0.42))
	hdr_row.add_child(points_label)

	# Column labels — widths must match _build_stat_row below
	var chdr := HBoxContainer.new()
	chdr.add_theme_constant_override("separation", 3)
	col.add_child(chdr)
	for pair: Array in [["Stat / Full Name", 128], ["−", 24], ["Base", 26], ["+", 24],
			["Race", 36], ["Class", 38], ["Total", 42]]:
		var h := _lbl(pair[0], 10, Color(0.38, 0.38, 0.38))
		h.custom_minimum_size = Vector2(pair[1], 0)
		h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		chdr.add_child(h)

	col.add_child(_hsep())

	for stat: String in STATS:
		col.add_child(_build_stat_row(stat))

	col.add_child(_hsep())

	col.add_child(_lbl(
		"Range 8–15  |  Cost: 13 = 5 pts  |  14 = 7 pts  |  15 = 9 pts",
		10, Color(0.36, 0.36, 0.36)))

	return col


func _build_stat_row(stat: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)

	var abbr := _lbl(stat, 12, Color(0.88, 0.82, 0.65))
	abbr.custom_minimum_size = Vector2(28, 26)
	abbr.tooltip_text = STAT_NAMES[stat] + "\n" + STAT_DESC[stat]
	row.add_child(abbr)

	var full := _lbl(STAT_NAMES[stat], 10, Color(0.36, 0.36, 0.36))
	full.custom_minimum_size = Vector2(98, 0)
	full.tooltip_text = STAT_DESC[stat]
	row.add_child(full)

	var minus := Button.new()
	minus.text = "−"
	minus.custom_minimum_size = Vector2(24, 24)
	minus.pressed.connect(_on_stat_minus.bind(stat))
	row.add_child(minus)

	var base_lbl := _lbl(str(STAT_MIN), 13, Color(1, 1, 1))
	base_lbl.custom_minimum_size = Vector2(26, 0)
	base_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(base_lbl)

	var plus := Button.new()
	plus.text = "+"
	plus.custom_minimum_size = Vector2(24, 24)
	plus.pressed.connect(_on_stat_plus.bind(stat))
	row.add_child(plus)

	var race_lbl := _lbl("—", 11, Color(0.3, 0.3, 0.3))
	race_lbl.custom_minimum_size = Vector2(36, 0)
	race_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(race_lbl)

	var class_lbl := _lbl("—", 11, Color(0.3, 0.3, 0.3))
	class_lbl.custom_minimum_size = Vector2(38, 0)
	class_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(class_lbl)

	var total_lbl := _lbl(str(STAT_MIN), 15, Color(0.82, 0.82, 0.82))
	total_lbl.custom_minimum_size = Vector2(42, 0)
	total_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(total_lbl)

	stat_rows[stat] = {
		"minus": minus, "plus": plus,
		"base": base_lbl, "race": race_lbl, "class": class_lbl, "total": total_lbl,
	}
	return row


func _build_derived_col() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(200, 0)
	col.add_theme_constant_override("separation", 5)
	col.add_child(_col_hdr("DERIVED STATS", Color(0.52, 1.0, 0.72)))

	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 5)
	panel.add_child(vb)

	for pair: Array in [
		["HP", "—"], ["MP", "—"], ["Melee Hit", "—"], ["Spell Hit", "—"],
		["Dodge", "—"], ["Phys Dmg", "—"], ["Spell Dmg", "—"], ["Mag Resist", "—"],
	]:
		var row := HBoxContainer.new()
		vb.add_child(row)
		var nl := _lbl(pair[0], 12, Color(0.55, 0.55, 0.55))
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(nl)
		var vl := _lbl(pair[1], 12, Color(0.8, 0.95, 0.8))
		row.add_child(vl)
		derived_vals[pair[0]] = vl

	vb.add_child(_hsep())

	var div_row := HBoxContainer.new()
	vb.add_child(div_row)
	var dnl := _lbl("Divinity:", 11, Color(0.5, 0.5, 0.5))
	dnl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	div_row.add_child(dnl)
	var dvl := _lbl("—", 11, Color(0.5, 0.5, 0.55))
	div_row.add_child(dvl)
	derived_vals["Divinity"] = dvl

	return col

# ============================================================
# EVENT HANDLERS
# ============================================================

func _on_race(rname: String) -> void:
	for n: String in race_buttons:
		race_buttons[n].button_pressed = (n == rname)
	selected_race = rname
	_update_race_info(rname)
	_refresh_stats()
	_update_confirm()

func _on_class(cname: String) -> void:
	for n: String in class_buttons:
		class_buttons[n].button_pressed = (n == cname)
	selected_class = cname
	_update_class_info(cname)
	_refresh_stats()
	_update_confirm()

func _on_divinity(dname: String) -> void:
	for n: String in div_buttons:
		div_buttons[n].button_pressed = (n == dname)
	selected_divinity = dname
	_update_div_info(dname)
	_refresh_stats()
	_update_confirm()

func _on_portrait(idx: int) -> void:
	for i: int in range(portrait_buttons.size()):
		portrait_buttons[i].button_pressed = (i == idx)
	selected_portrait = idx
	var path := PORTRAIT_DIR + "portrait_%02d.png" % (idx + 1)
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		portrait_preview_tex.texture = tex
		portrait_preview_lbl.visible = (tex == null)
	else:
		portrait_preview_tex.texture = null
		portrait_preview_lbl.text = str(idx + 1)
		portrait_preview_lbl.visible = true

func _on_stat_plus(stat: String) -> void:
	var cur: int = base_stats[stat]
	if cur >= STAT_MAX:
		return
	var cost: int = POINT_COST.get(cur + 1, 99) - POINT_COST.get(cur, 0)
	if points_remaining < cost:
		return
	base_stats[stat] += 1
	points_remaining -= cost
	_refresh_stats()

func _on_stat_minus(stat: String) -> void:
	var cur: int = base_stats[stat]
	if cur <= STAT_MIN:
		return
	var refund: int = POINT_COST.get(cur, 0) - POINT_COST.get(cur - 1, 0)
	base_stats[stat] -= 1
	points_remaining += refund
	_refresh_stats()

func _on_confirm() -> void:
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

# ============================================================
# INFO PANEL UPDATES (in-place, no queue_free)
# ============================================================

func _update_race_info(rname: String) -> void:
	var d: Dictionary = RACES[rname]
	race_title_lbl.text = rname
	race_title_lbl.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))

	var parts: PackedStringArray
	for stat: String in STATS:
		var v: int = d["bonuses"].get(stat, 0)
		if v != 0:
			parts.append("%s%s%d" % [stat, ("+" if v > 0 else ""), v])
	race_bonuses_lbl.text = "Bonuses: " + (", ".join(parts) if parts.size() > 0 else "none — all +0 (gains +1 all at lvl 5/10/15/20/25)")
	race_passive_lbl.text = "Passive: " + d["passive"]
	race_lore_lbl.text    = d.get("lore", "")

func _update_class_info(cname: String) -> void:
	var d: Dictionary = CLASSES[cname]
	class_title_lbl.text = cname
	class_title_lbl.add_theme_color_override("font_color", Color(0.9, 0.75, 0.2))
	class_role_lbl.text  = d["role"] + "  |  Hit Die: " + d["hit_die"] + "  |  Primary: " + d["primary"]

	var parts: PackedStringArray
	for stat: String in STATS:
		var v: int = d["bonuses"].get(stat, 0)
		if v != 0:
			parts.append("%s +%d" % [stat, v])
	class_bonuses_lbl.text = "Bonuses: " + ", ".join(parts)
	class_paths_lbl.text   = "Level 10 paths:\n" + d["paths"]

func _update_div_info(dname: String) -> void:
	var d: Dictionary = DIVINITIES[dname]
	div_title_lbl.text = dname + "  —  " + d["element"]
	div_title_lbl.add_theme_color_override("font_color", d["color"])
	div_lore_lbl.text  = d["lore"]
	div_cycle_lbl.text = (
		"Cycle:  Fire → Night → Earth → Lightning → Water → Fire\n"
		+ "Conquers: %s  (+15%% dmg)\n" % d["bonus_vs"]
		+ ("Weak vs: %s  (−10%% dmg)" % d["weak_vs"] if d["weak_vs"] != "None" else "No weakness")
	)
	div_cycle_lbl.add_theme_color_override("font_color", d["color"].lightened(0.15))

# ============================================================
# STAT + DERIVED REFRESH
# ============================================================

func _refresh_stats() -> void:
	if points_remaining <= 4:
		points_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.28))
	elif points_remaining <= 12:
		points_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
	else:
		points_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.42))
	points_label.text = "Points: %d / %d" % [points_remaining, POINT_BUY_BUDGET]

	for stat: String in STATS:
		var r:     Dictionary = stat_rows[stat]
		var base:  int = base_stats[stat]
		var rb:    int = _race_bonus(stat)
		var cb:    int = _class_bonus(stat)
		var total: int = base + rb + cb

		r["base"].text = str(base)

		if rb == 0:
			r["race"].text = "—"
			r["race"].add_theme_color_override("font_color", Color(0.28, 0.28, 0.28))
		elif rb > 0:
			r["race"].text = "+%d" % rb
			r["race"].add_theme_color_override("font_color", Color(0.35, 0.9, 0.35))
		else:
			r["race"].text = str(rb)
			r["race"].add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))

		if cb == 0:
			r["class"].text = "—"
			r["class"].add_theme_color_override("font_color", Color(0.28, 0.28, 0.28))
		else:
			r["class"].text = "+%d" % cb
			r["class"].add_theme_color_override("font_color", Color(1.0, 0.65, 0.26))

		r["total"].text = str(total)
		if total >= 20:
			r["total"].add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
		elif total >= 17:
			r["total"].add_theme_color_override("font_color", Color(0.85, 0.92, 0.2))
		elif total <= 6:
			r["total"].add_theme_color_override("font_color", Color(0.9, 0.22, 0.22))
		else:
			r["total"].add_theme_color_override("font_color", Color(0.82, 0.82, 0.82))

		r["minus"].disabled = (base <= STAT_MIN)
		var nc: int = POINT_COST.get(base + 1, 99) - POINT_COST.get(base, 0)
		r["plus"].disabled  = (base >= STAT_MAX or points_remaining < nc)

	_refresh_derived()


func _refresh_derived() -> void:
	var t := _totals()
	derived_vals["HP"].text         = str(_hp(t))
	derived_vals["MP"].text         = str(_mp(t))
	derived_vals["Melee Hit"].text  = "%.0f%%" % _melee_hit(t)
	derived_vals["Spell Hit"].text  = "%.0f%%" % _spell_hit(t)
	derived_vals["Dodge"].text      = "%.0f%%" % _dodge(t)
	derived_vals["Phys Dmg"].text   = "+%d" % _phys_dmg(t)
	derived_vals["Spell Dmg"].text  = "+%d" % _spell_dmg(t)
	derived_vals["Mag Resist"].text = "%.0f%%" % _mresist(t)

	if selected_divinity != "":
		var d := DIVINITIES[selected_divinity]
		derived_vals["Divinity"].text = "%s (%s)" % [selected_divinity, d["element"]]
		derived_vals["Divinity"].add_theme_color_override("font_color", d["color"])
	else:
		derived_vals["Divinity"].text = "—"
		derived_vals["Divinity"].add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))


func _update_confirm() -> void:
	var ready: bool = selected_race != "" and selected_class != "" and selected_divinity != ""
	confirm_btn.disabled = not ready

	if ready:
		var cname: String = name_input.text.strip_edges()
		if cname.is_empty():
			cname = "Your hero"
		summary_label.text = "%s the %s %s of %s" % [
			cname, selected_race, selected_class, selected_divinity,
		]
		summary_label.add_theme_color_override("font_color", Color(0.65, 0.82, 0.65))
	else:
		var missing: Array[String] = []
		if selected_race      == "": missing.append("race")
		if selected_class     == "": missing.append("class")
		if selected_divinity  == "": missing.append("divinity")
		summary_label.text = "Still needed: " + ", ".join(missing)
		summary_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))

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
	var t: Dictionary = {}
	for stat: String in STATS:
		t[stat] = base_stats[stat] + _race_bonus(stat) + _class_bonus(stat)
	return t

func _hp(t: Dictionary)        -> int:   return t["End"] * 10 + 5
func _mp(t: Dictionary)        -> int:   return t["Int"] * 8 + t["Wis"] * 4 + 3
func _melee_hit(t: Dictionary) -> float: return 60.0 + t["Str"] * 1.5
func _spell_hit(t: Dictionary) -> float: return 60.0 + t["Int"] * 2.0
func _dodge(t: Dictionary)     -> float: return minf(t["Agi"] * 1.5, 40.0)
func _phys_dmg(t: Dictionary)  -> int:   return t["Str"] * 2
func _spell_dmg(t: Dictionary) -> int:   return t["Int"] * 3
func _mresist(t: Dictionary)   -> float: return minf(t["Wis"] * 2.0, 50.0)

# ============================================================
# UI HELPERS
# ============================================================

func _lbl(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _lbl_centered(text: String, size: int, color: Color) -> Label:
	var l := _lbl(text, size, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _wrap_lbl(text: String, size: int, color: Color) -> Label:
	var l := _lbl(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _col_hdr(text: String, color: Color) -> Label:
	return _lbl_centered(text, 14, color)

func _sel_btn(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, 28)
	return b

func _hsep() -> HSeparator:
	return HSeparator.new()
