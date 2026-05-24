extends Control

# ============================================================
# KAOS EMBERS — Character Creation (Compact ~5×5in)
# ============================================================

const STATS      = ["Str", "Int", "Agi", "End", "Wis", "Chr"]
const STAT_NAMES = {
	"Str": "Strength", "Int": "Intelligence", "Agi": "Agility",
	"End": "Endurance", "Wis": "Wisdom",      "Chr": "Charisma",
}
const STAT_DESC = {
	"Str": "Physical damage, carry weight, melee hit chance",
	"Int": "Spell damage, MP pool, trap detection",
	"Agi": "Dodge chance, backstab eligibility, stealth",
	"End": "HP pool, physical resistance, stamina",
	"Wis": "MP regen, spell resistance, healing power",
	"Chr": "Dialogue, companion loyalty, taunt",
}

const STAT_MIN         = 8
const STAT_MAX         = 15
const POINT_BUY_BUDGET = 27
const POINT_COST       = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9}

# ---- Race data ------------------------------------------------------------------

const RACES = {
	"Human": {
		"desc": "Versatile survivors of the Kaos Wars. Suited to any class.",
		"bonuses": {},
		"passive": "Adaptable: +1 to all stats at levels 5 / 10 / 15 / 20 / 25",
	},
	"Elf": {
		"desc": "Ancient people attuned to ember magic. Frail but devastatingly intelligent.",
		"bonuses": {"Str": -1, "Int": 3, "Agi": 1, "End": -1, "Wis": 2, "Chr": 1},
		"passive": "Ember Attuned: +10% spell damage",
	},
	"Half-Elf": {
		"desc": "Born of two worlds, excelling where full-bloods cannot.",
		"bonuses": {"Str": 1, "Int": 2, "Wis": 1, "Chr": 1},
		"passive": "Balanced Blood: No class stat restrictions",
	},
	"Dark Elf": {
		"desc": "Cunning and dangerous. Excel as rogues and mages.",
		"bonuses": {"Str": -1, "Int": 3, "Agi": 2, "End": -1, "Wis": 1, "Chr": -1},
		"passive": "Shadow Step: +15% backstab damage, cheaper autosneak",
	},
	"Halfling": {
		"desc": "Small but hardy. Natural thieves and druids.",
		"bonuses": {"Str": -1, "Int": 1, "Agi": 3, "End": 1, "Wis": 1},
		"passive": "Lucky: 5% chance to avoid any attack entirely",
	},
	"Gnome": {
		"desc": "Most intelligent of the small races. Master spellcasters and thieves.",
		"bonuses": {"Str": -2, "Int": 4, "Agi": 2, "End": -1, "Wis": 2},
		"passive": "Tinkerer: +20% trap disarm success rate",
	},
	"Dwarf": {
		"desc": "Strong and stout. Exceptional warriors, weak spellcasters.",
		"bonuses": {"Str": 3, "Int": -1, "Agi": -2, "End": 4},
		"passive": "Forgeborn: +15% physical resistance, immune to poison duration reduction",
	},
	"Goblin": {
		"desc": "Agile scavengers. Natural thieves. More survivable than they look.",
		"bonuses": {"Str": -1, "Agi": 4, "End": 1, "Wis": -1, "Chr": -1},
		"passive": "Scrappy: +20% item drop rate",
	},
	"Saurian": {
		"desc": "Large reptilian humanoids. Slow but devastating in melee.",
		"bonuses": {"Str": 4, "Int": -2, "Agi": -1, "End": 3, "Wis": -1, "Chr": -1},
		"passive": "Scales: +20 base armor, natural weapon (claws)",
	},
	"Half-Orc": {
		"desc": "Immense physical power. Best for fighter roles.",
		"bonuses": {"Str": 4, "Int": -2, "Agi": -1, "End": 3, "Wis": -1, "Chr": -2},
		"passive": "Brutish: +10% melee damage, Rage builds 25% faster",
	},
	"Ashborn": {
		"desc": "Humans touched by Kaos flame. Corrupted and empowered.",
		"bonuses": {"Str": 2, "Int": 1, "End": 2, "Wis": -2, "Chr": -1},
		"passive": "Ember Scarred: +10% fire damage, -10% ice damage",
	},
	"Wraithkin": {
		"desc": "Undead-adjacent beings. Powerful mages and necromancers.",
		"bonuses": {"Str": -1, "Int": 4, "Agi": 1, "End": -2, "Wis": 3, "Chr": -2},
		"passive": "Undying: Death sickness fades twice as fast",
	},
}

# ---- Class data ------------------------------------------------------------------

const CLASSES = {
	"Fighter": {
		"role": "Melee DPS / Tank",
		"hit_die": "d10",
		"bonuses": {"Str": 2, "End": 1},
		"primary": ["Str", "End"],
		"paths": "Knight / Barbarian / Paladin / Ranger / Monk",
	},
	"Rogue": {
		"role": "Stealth DPS / Utility",
		"hit_die": "d8",
		"bonuses": {"Agi": 2, "Int": 1},
		"primary": ["Agi", "Int"],
		"paths": "Thief / Assassin / Bard",
	},
	"Mage": {
		"role": "Spell DPS / Summoning",
		"hit_die": "d6",
		"bonuses": {"Int": 2, "Wis": 1},
		"primary": ["Int", "Wis"],
		"paths": "Sorcerer / Necromancer",
	},
	"Healer": {
		"role": "Healing / Support",
		"hit_die": "d8",
		"bonuses": {"Wis": 2, "Chr": 1},
		"primary": ["Wis", "Chr"],
		"paths": "Cleric / Druid",
	},
}

# ---- Divinity data ---------------------------------------------------------------

const DIVINITIES = {
	"Pyron":  {"element": "Fire",      "color": Color(1.0, 0.35, 0.1),  "bonus_vs": "Night",    "weak_vs": "Water"},
	"Nox":    {"element": "Night",     "color": Color(0.55, 0.15, 0.8), "bonus_vs": "Earth",    "weak_vs": "Fire"},
	"Terra":  {"element": "Earth",     "color": Color(0.5, 0.38, 0.15), "bonus_vs": "Lightning","weak_vs": "Night"},
	"Voltus": {"element": "Lightning", "color": Color(0.95, 0.9, 0.1),  "bonus_vs": "Water",    "weak_vs": "Earth"},
	"Riva":   {"element": "Water",     "color": Color(0.2, 0.55, 1.0),  "bonus_vs": "Fire",     "weak_vs": "Lightning"},
	"Nethys": {"element": "Neutral",   "color": Color(0.55, 0.55, 0.6), "bonus_vs": "Neutral",  "weak_vs": "None"},
}

# ============================================================
# STATE
# ============================================================

var selected_race:     String = ""
var selected_class:    String = ""
var selected_divinity: String = ""
var base_stats:        Dictionary = {}
var points_remaining:  int = POINT_BUY_BUDGET

# UI refs
var name_input:    LineEdit
var race_opt:      OptionButton
var class_opt:     OptionButton
var div_opt:       OptionButton
var info_label:    Label
var points_label:  Label
var derived_label: Label
var summary_label: Label
var confirm_btn:   Button
var stat_rows:     Dictionary = {}

# ============================================================
# INIT
# ============================================================

func _ready() -> void:
	for stat: String in STATS:
		base_stats[stat] = STAT_MIN
	_build_ui()
	_refresh()

# ============================================================
# UI BUILD
# ============================================================

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.07, 0.10)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 5)
	margin.add_child(root)

	# ── Title ──────────────────────────────────────────────
	var title := Label.new()
	title.text = "KAOS EMBERS — CHARACTER CREATION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color(0.9, 0.65, 0.15))
	root.add_child(title)

	root.add_child(_hsep())

	# ── Name ───────────────────────────────────────────────
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 6)
	root.add_child(name_row)
	name_row.add_child(_lbl("Name:", 12, Color(0.6, 0.6, 0.6)))
	name_input = LineEdit.new()
	name_input.placeholder_text = "Enter character name..."
	name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_input.custom_minimum_size.y = 28
	name_input.text_changed.connect(func(_t: String) -> void: _update_confirm())
	name_row.add_child(name_input)

	root.add_child(_hsep())

	# ── Race + Class dropdowns ──────────────────────────────
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 6)
	root.add_child(row1)

	row1.add_child(_lbl("Race:", 12, Color(0.58, 0.58, 0.58)))
	race_opt = _dropdown()
	race_opt.add_item("— Select Race —")
	for r: String in RACES.keys():
		race_opt.add_item(r)
	race_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	race_opt.item_selected.connect(_on_race_idx)
	row1.add_child(race_opt)

	row1.add_child(_lbl("Class:", 12, Color(0.58, 0.58, 0.58)))
	class_opt = _dropdown()
	class_opt.add_item("— Select Class —")
	for c: String in CLASSES.keys():
		class_opt.add_item(c)
	class_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	class_opt.item_selected.connect(_on_class_idx)
	row1.add_child(class_opt)

	# ── Divinity dropdown ────────────────────────────────────
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 6)
	root.add_child(row2)

	row2.add_child(_lbl("Divinity:", 12, Color(0.58, 0.58, 0.58)))
	div_opt = _dropdown()
	div_opt.add_item("— Select Divinity —")
	for d: String in DIVINITIES.keys():
		div_opt.add_item("%s  (%s)" % [d, DIVINITIES[d]["element"]])
	div_opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	div_opt.item_selected.connect(_on_div_idx)
	row2.add_child(div_opt)

	root.add_child(_hsep())

	# ── Info panel (3 live lines) ────────────────────────────
	info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 11)
	info_label.add_theme_color_override("font_color", Color(0.48, 0.48, 0.48))
	info_label.custom_minimum_size = Vector2(0, 56)
	root.add_child(info_label)

	root.add_child(_hsep())

	# ── Stats header ─────────────────────────────────────────
	var stat_hdr := HBoxContainer.new()
	root.add_child(stat_hdr)

	var sh := _lbl("STATS", 12, Color(0.85, 0.5, 0.5))
	sh.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_hdr.add_child(sh)

	# Column labels aligned with stat rows below
	for pair: Array in [["−", 22], ["Base", 26], ["+", 22], ["Race", 34], ["Class", 36], ["Total", 38]]:
		var h := _lbl(pair[0], 10, Color(0.38, 0.38, 0.38))
		h.custom_minimum_size = Vector2(pair[1], 0)
		h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stat_hdr.add_child(h)

	# ── Stat rows ─────────────────────────────────────────────
	for stat: String in STATS:
		root.add_child(_build_stat_row(stat))

	# ── Points remaining ──────────────────────────────────────
	points_label = Label.new()
	points_label.add_theme_font_size_override("font_size", 11)
	points_label.add_theme_color_override("font_color", Color(0.5, 0.88, 0.4))
	root.add_child(points_label)

	root.add_child(_hsep())

	# ── Derived stats (one line) ──────────────────────────────
	derived_label = Label.new()
	derived_label.add_theme_font_size_override("font_size", 11)
	derived_label.add_theme_color_override("font_color", Color(0.55, 0.8, 0.55))
	root.add_child(derived_label)

	root.add_child(_hsep())

	# ── Confirm bar ───────────────────────────────────────────
	var bot := HBoxContainer.new()
	bot.add_theme_constant_override("separation", 10)
	root.add_child(bot)

	summary_label = Label.new()
	summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_label.add_theme_font_size_override("font_size", 11)
	summary_label.add_theme_color_override("font_color", Color(0.42, 0.42, 0.42))
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bot.add_child(summary_label)

	confirm_btn = Button.new()
	confirm_btn.text = "BEGIN JOURNEY"
	confirm_btn.custom_minimum_size = Vector2(140, 34)
	confirm_btn.disabled = true
	confirm_btn.pressed.connect(_on_confirm)
	bot.add_child(confirm_btn)


func _build_stat_row(stat: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)

	# Abbrev
	var abbr := _lbl(stat, 12, Color(0.85, 0.82, 0.65))
	abbr.custom_minimum_size = Vector2(28, 22)
	abbr.tooltip_text = STAT_NAMES[stat] + "\n" + STAT_DESC[stat]
	row.add_child(abbr)

	# Full name — expands to fill gap
	var full := _lbl(STAT_NAMES[stat], 10, Color(0.35, 0.35, 0.35))
	full.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	full.tooltip_text = STAT_DESC[stat]
	row.add_child(full)

	# − button
	var minus := Button.new()
	minus.text = "−"
	minus.custom_minimum_size = Vector2(22, 22)
	minus.pressed.connect(_on_stat_minus.bind(stat))
	row.add_child(minus)

	# Base value
	var base_lbl := _lbl(str(STAT_MIN), 13, Color(1, 1, 1))
	base_lbl.custom_minimum_size = Vector2(26, 0)
	base_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(base_lbl)

	# + button
	var plus := Button.new()
	plus.text = "+"
	plus.custom_minimum_size = Vector2(22, 22)
	plus.pressed.connect(_on_stat_plus.bind(stat))
	row.add_child(plus)

	# Race bonus
	var race_lbl := _lbl("—", 11, Color(0.3, 0.3, 0.3))
	race_lbl.custom_minimum_size = Vector2(34, 0)
	race_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(race_lbl)

	# Class bonus
	var class_lbl := _lbl("—", 11, Color(0.3, 0.3, 0.3))
	class_lbl.custom_minimum_size = Vector2(36, 0)
	class_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(class_lbl)

	# Total
	var total_lbl := _lbl(str(STAT_MIN), 15, Color(0.82, 0.82, 0.82))
	total_lbl.custom_minimum_size = Vector2(38, 0)
	total_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(total_lbl)

	stat_rows[stat] = {
		"minus": minus, "plus": plus,
		"base": base_lbl, "race": race_lbl, "class": class_lbl, "total": total_lbl,
	}
	return row

# ============================================================
# EVENT HANDLERS
# ============================================================

func _on_race_idx(idx: int) -> void:
	selected_race = "" if idx == 0 else RACES.keys()[idx - 1]
	_refresh()
	_update_confirm()

func _on_class_idx(idx: int) -> void:
	selected_class = "" if idx == 0 else CLASSES.keys()[idx - 1]
	_refresh()
	_update_confirm()

func _on_div_idx(idx: int) -> void:
	selected_divinity = "" if idx == 0 else DIVINITIES.keys()[idx - 1]
	_refresh()
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
	_refresh()

func _on_stat_minus(stat: String) -> void:
	var cur: int = base_stats[stat]
	if cur <= STAT_MIN:
		return
	var refund: int = POINT_COST.get(cur, 0) - POINT_COST.get(cur - 1, 0)
	base_stats[stat] -= 1
	points_remaining += refund
	_refresh()

func _on_confirm() -> void:
	var cname: String = name_input.text.strip_edges()
	if cname.is_empty():
		cname = "Unnamed"
	var t := _totals()
	var text := "%s — %s %s of %s\n\n" % [cname, selected_race, selected_class, selected_divinity]
	for stat: String in STATS:
		text += "  %s %s: %d\n" % [stat, STAT_NAMES[stat], t[stat]]
	text += "\nHP %d  |  MP %d  |  Hit %.0f%%  |  Dodge %.0f%%  |  M.Res %.0f%%" % [
		_hp(t), _mp(t), _melee_hit(t), _dodge(t), _mresist(t),
	]
	var dlg := AcceptDialog.new()
	dlg.title = "Character Created"
	dlg.dialog_text = text
	dlg.min_size = Vector2(360, 280)
	add_child(dlg)
	dlg.popup_centered()

# ============================================================
# DISPLAY REFRESH
# ============================================================

func _refresh() -> void:
	_update_info_label()
	_refresh_stats()
	_update_derived()


func _update_info_label() -> void:
	var lines: Array[String] = []

	if selected_race != "":
		var d: Dictionary = RACES[selected_race]
		var parts: PackedStringArray
		for stat: String in STATS:
			var v: int = d["bonuses"].get(stat, 0)
			if v != 0:
				parts.append("%s%s%d" % [stat, ("+" if v > 0 else ""), v])
		var bonuses: String = "  |  ".join(parts) if parts.size() > 0 else "all +0"
		lines.append("Race  %s:  %s" % [selected_race, bonuses])
		lines.append("  %s" % d["passive"])
	else:
		lines.append("Race: not selected")

	if selected_class != "":
		var d: Dictionary = CLASSES[selected_class]
		lines.append("Class  %s:  %s  |  %s  |  Paths: %s" % [
			selected_class, d["role"], d["hit_die"], d["paths"],
		])
	else:
		lines.append("Class: not selected")

	if selected_divinity != "":
		var d: Dictionary = DIVINITIES[selected_divinity]
		lines.append("Divinity  %s (%s):  +15%% vs %s  |  −10%% vs %s" % [
			selected_divinity, d["element"], d["bonus_vs"],
			d["weak_vs"] if d["weak_vs"] != "None" else "—",
		])
	else:
		lines.append("Divinity: not selected")

	info_label.text = "\n".join(lines)
	var ready: bool = selected_race != "" and selected_class != "" and selected_divinity != ""
	info_label.add_theme_color_override("font_color",
		Color(0.68, 0.68, 0.55) if ready else Color(0.48, 0.48, 0.48))


func _refresh_stats() -> void:
	# Points label
	if points_remaining <= 4:
		points_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.28))
	elif points_remaining <= 12:
		points_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.2))
	else:
		points_label.add_theme_color_override("font_color", Color(0.5, 0.88, 0.4))
	points_label.text = "Points remaining: %d / %d  (8–15 base  |  cost: 13=5pts, 14=7pts, 15=9pts)" % [
		points_remaining, POINT_BUY_BUDGET,
	]

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
			r["race"].add_theme_color_override("font_color", Color(0.32, 0.88, 0.32))
		else:
			r["race"].text = str(rb)
			r["race"].add_theme_color_override("font_color", Color(0.88, 0.28, 0.28))

		if cb == 0:
			r["class"].text = "—"
			r["class"].add_theme_color_override("font_color", Color(0.28, 0.28, 0.28))
		else:
			r["class"].text = "+%d" % cb
			r["class"].add_theme_color_override("font_color", Color(1.0, 0.62, 0.22))

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
		var next_cost: int = POINT_COST.get(base + 1, 99) - POINT_COST.get(base, 0)
		r["plus"].disabled  = (base >= STAT_MAX or points_remaining < next_cost)


func _update_derived() -> void:
	var t := _totals()
	derived_label.text = (
		"HP %d  |  MP %d  |  Melee Hit %.0f%%  |  Dodge %.0f%%  |  P.Dmg +%d  |  M.Res %.0f%%"
		% [_hp(t), _mp(t), _melee_hit(t), _dodge(t), _phys_dmg(t), _mresist(t)]
	)


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
		summary_label.add_theme_color_override("font_color", Color(0.62, 0.82, 0.62))
	else:
		var missing: Array[String] = []
		if selected_race      == "": missing.append("race")
		if selected_class     == "": missing.append("class")
		if selected_divinity  == "": missing.append("divinity")
		summary_label.text = "Still needed: " + "  |  ".join(missing)
		summary_label.add_theme_color_override("font_color", Color(0.42, 0.42, 0.42))

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

func _hsep() -> HSeparator:
	return HSeparator.new()

func _dropdown() -> OptionButton:
	var o := OptionButton.new()
	o.custom_minimum_size.y = 28
	return o
