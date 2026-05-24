extends Control

# ================================================================
# KAOS EMBERS — Main Game
# Two zones: Ashenveil Tavern + Tavern Basement
# ================================================================

const ZONE_TAVERN   := 0
const ZONE_BASEMENT := 1
const STAMINA_MAX   := 10
const QUEST_RAT_GOAL := 3

const T_STAM_COMBAT := 3.0   # seconds per pip regen while fighting
const T_STAM_REST   := 1.5   # seconds per pip regen while resting
const T_ENEMY_ATK   := 2.5   # seconds between enemy attacks

const ZONES: Dictionary = {
	0: {
		"name":      "Ashenveil Tavern",
		"art_color": Color(0.28, 0.17, 0.06),
		"desc": [
			"The [color=#d4a84b]Ember & Flagon[/color] smells of woodsmoke and cheap ale.",
			"Grizzled locals drink in silence around battered oak tables.",
			"Behind the bar, a stocky innkeeper methodically polishes a mug.",
		],
		"npcs":  ["Innkeeper Bram"],
		"exits": {"down": 1},
	},
	1: {
		"name":      "Tavern Basement",
		"art_color": Color(0.09, 0.07, 0.05),
		"desc": [
			"Stone steps descend into a [color=#888888]cold, musty cellar[/color].",
			"Barrels and crates line the damp walls. A torch sputters on an iron hook.",
			"You hear the [color=#cc4444]skitter of claws[/color] somewhere in the dark.",
		],
		"npcs":  [],
		"exits": {"up": 0},
	},
}

const RAT: Dictionary = {
	"name": "Cellar Rat", "max_hp": 8, "atk_min": 1, "atk_max": 3, "xp": 5, "gold": 0,
}

# ── Player state ─────────────────────────────────────────────────
var current_zone: int    = ZONE_TAVERN
var player_hp: int       = 0
var player_max_hp: int   = 0
var player_mp: int       = 0
var player_max_mp: int   = 0
var player_xp: int       = 0
var player_xp_next: int  = 100
var player_level: int    = 1
var player_gold: int     = 10
var player_stamina: int  = STAMINA_MAX
var final_stats: Dictionary = {}

# ── Combat state ─────────────────────────────────────────────────
var in_combat: bool         = false
var combat_enemy: Dictionary = {}

# ── Quest / world state ──────────────────────────────────────────
var innkeeper_greeted: bool = false
var quest_accepted: bool    = false
var quest_completed: bool   = false
var quest_rats_killed: int  = 0
var rats_alive: Array[bool] = [true, true, true]

# ── Timers ───────────────────────────────────────────────────────
var stamina_timer: Timer
var enemy_timer:   Timer

# ── UI refs ──────────────────────────────────────────────────────
var zone_name_lbl:    Label
var zone_art_rect:    ColorRect
var game_log:         RichTextLabel
var action_container: VBoxContainer

var hp_bar:       ProgressBar
var mp_bar:       ProgressBar
var xp_bar:       ProgressBar
var stamina_pips: Array[ColorRect] = []
var cmd_input:    LineEdit

var hp_stat_lbl:  Label
var mp_stat_lbl:  Label
var sta_stat_lbl: Label
var gold_lbl:     Label
var level_lbl:    Label
var xp_stat_lbl:  Label


# ================================================================
# READY
# ================================================================

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_init_player()
	_build_ui()
	_setup_timers()
	_enter_zone(ZONE_TAVERN, true)


func _init_player() -> void:
	final_stats = GameData.final_stats.duplicate()
	if final_stats.is_empty():
		final_stats = {"Str": 10, "Int": 10, "Agi": 10, "End": 10, "Wis": 10, "Chr": 10}
	player_max_hp = final_stats["End"] * 10 + 5
	player_hp     = player_max_hp
	player_max_mp = final_stats["Int"] * 8 + final_stats["Wis"] * 4 + 3
	player_mp     = player_max_mp


# ================================================================
# UI BUILD
# ================================================================

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.06, 0.05)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	var top_row := HBoxContainer.new()
	top_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_row.add_theme_constant_override("separation", 0)
	root.add_child(top_row)

	top_row.add_child(_build_left_panel())
	top_row.add_child(_build_center_panel())
	top_row.add_child(_build_right_panel())
	root.add_child(_build_bottom_bar())
	root.add_child(_build_cmd_row())


# ── Left Panel ───────────────────────────────────────────────────

func _build_left_panel() -> Control:
	var pc := _make_panel(Color(0.10, 0.08, 0.06), Color(0.22, 0.17, 0.09))
	pc.custom_minimum_size = Vector2(200, 0)
	pc.size_flags_vertical  = Control.SIZE_EXPAND_FILL

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	pc.add_child(vbox)

	_panel_hdr(vbox, "CHARACTER")

	var nm  := GameData.player_name     if GameData.player_name     != "" else "Adventurer"
	var rc  := GameData.player_race     if GameData.player_race     != "" else "Unknown"
	var cl  := GameData.player_class    if GameData.player_class    != "" else "Unknown"
	var div := GameData.player_divinity if GameData.player_divinity != "" else "Unknown"

	vbox.add_child(_kv("Name",     nm,  Color(0.90, 0.85, 0.70)))
	level_lbl   = _val_lbl("Lv 1");        vbox.add_child(_kv_ref("Level",   level_lbl))
	xp_stat_lbl = _val_lbl("0 / 100 XP"); vbox.add_child(_kv_ref("XP",      xp_stat_lbl))
	vbox.add_child(_kv("Race",     rc,  Color(0.68, 0.88, 0.68)))
	vbox.add_child(_kv("Class",    cl,  Color(0.68, 0.70, 0.92)))
	vbox.add_child(_kv("Divinity", div, Color(0.88, 0.68, 0.88)))

	vbox.add_child(_hsep_dark())
	_panel_hdr(vbox, "ATTRIBUTES")

	for s: String in ["Str", "Int", "Agi", "End", "Wis", "Chr"]:
		vbox.add_child(_kv_ref(s, _val_lbl(str(final_stats.get(s, 10)))))

	vbox.add_child(_hsep_dark())
	_panel_hdr(vbox, "VITALS")

	hp_stat_lbl  = _val_lbl("%d / %d" % [player_hp,      player_max_hp])
	mp_stat_lbl  = _val_lbl("%d / %d" % [player_mp,      player_max_mp])
	sta_stat_lbl = _val_lbl("%d / %d" % [player_stamina, STAMINA_MAX])
	gold_lbl     = _val_lbl("%d gp"   % player_gold)
	vbox.add_child(_kv_ref("HP",      hp_stat_lbl))
	vbox.add_child(_kv_ref("MP",      mp_stat_lbl))
	vbox.add_child(_kv_ref("Stamina", sta_stat_lbl))
	vbox.add_child(_kv_ref("Gold",    gold_lbl))

	return pc


# ── Center Panel ─────────────────────────────────────────────────

func _build_center_panel() -> Control:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 0)

	# Zone name bar
	var name_pc := _make_panel(Color(0.14, 0.10, 0.05), Color(0.28, 0.20, 0.08))
	var nm_margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		nm_margin.add_theme_constant_override("margin_" + side, 5)
	name_pc.add_child(nm_margin)
	zone_name_lbl = Label.new()
	zone_name_lbl.text = "Ashenveil Tavern"
	zone_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_name_lbl.add_theme_font_size_override("font_size", 16)
	zone_name_lbl.add_theme_color_override("font_color", Color(0.92, 0.73, 0.28))
	nm_margin.add_child(zone_name_lbl)
	vbox.add_child(name_pc)

	# Zone art placeholder
	var art_wrap := Control.new()
	art_wrap.custom_minimum_size   = Vector2(0, 155)
	art_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_wrap.clip_contents         = true
	vbox.add_child(art_wrap)

	zone_art_rect = ColorRect.new()
	zone_art_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	zone_art_rect.color = ZONES[0]["art_color"]
	art_wrap.add_child(zone_art_rect)

	var art_lbl := Label.new()
	art_lbl.text = "[ Zone Art — Placeholder ]"
	art_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	art_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_lbl.add_theme_font_size_override("font_size", 11)
	art_lbl.add_theme_color_override("font_color", Color(0.32, 0.25, 0.12))
	art_wrap.add_child(art_lbl)

	# Game log
	var log_pc := _make_panel(Color(0.055, 0.045, 0.035), Color(0.18, 0.14, 0.07))
	log_pc.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	log_pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(log_pc)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal  = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical    = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	log_pc.add_child(scroll)

	game_log = RichTextLabel.new()
	game_log.bbcode_enabled       = true
	game_log.fit_content          = true
	game_log.scroll_following     = true
	game_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game_log.add_theme_font_size_override("normal_font_size", 12)
	game_log.add_theme_color_override("default_color", Color(0.82, 0.78, 0.65))
	scroll.add_child(game_log)

	return vbox


# ── Right Panel ──────────────────────────────────────────────────

func _build_right_panel() -> Control:
	var pc := _make_panel(Color(0.10, 0.08, 0.06), Color(0.22, 0.17, 0.09))
	pc.custom_minimum_size = Vector2(180, 0)
	pc.size_flags_vertical  = Control.SIZE_EXPAND_FILL

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	pc.add_child(vbox)

	_panel_hdr(vbox, "ACTIONS")
	action_container = VBoxContainer.new()
	action_container.add_theme_constant_override("separation", 4)
	vbox.add_child(action_container)

	return pc


# ── Bottom Bars ──────────────────────────────────────────────────

func _build_bottom_bar() -> Control:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 34)
	hbox.add_theme_constant_override("separation", 3)

	hp_bar = _make_bar(Color(0.72, 0.15, 0.15))
	hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_bar.max_value = player_max_hp
	hp_bar.value     = player_hp
	hbox.add_child(hp_bar)

	mp_bar = _make_bar(Color(0.15, 0.28, 0.78))
	mp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mp_bar.max_value = player_max_mp
	mp_bar.value     = player_mp
	hbox.add_child(mp_bar)

	# Stamina pips
	var sta_row := HBoxContainer.new()
	sta_row.custom_minimum_size = Vector2(128, 0)
	sta_row.add_theme_constant_override("separation", 2)
	var sta_lbl := Label.new()
	sta_lbl.text = "STA:"
	sta_lbl.add_theme_font_size_override("font_size", 10)
	sta_lbl.add_theme_color_override("font_color", Color(0.42, 0.72, 0.42))
	sta_row.add_child(sta_lbl)
	stamina_pips.clear()
	for _i: int in STAMINA_MAX:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(9, 18)
		pip.color = Color(0.20, 0.62, 0.20)
		sta_row.add_child(pip)
		stamina_pips.append(pip)
	hbox.add_child(sta_row)

	xp_bar = _make_bar(Color(0.58, 0.44, 0.10))
	xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_bar.max_value = player_xp_next
	xp_bar.value     = player_xp
	hbox.add_child(xp_bar)

	return hbox


# ── Command Input ────────────────────────────────────────────────

func _build_cmd_row() -> Control:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 32)
	hbox.add_theme_constant_override("separation", 4)

	var prompt := Label.new()
	prompt.text = ">"
	prompt.add_theme_font_size_override("font_size", 14)
	prompt.add_theme_color_override("font_color", Color(0.52, 0.80, 0.38))
	prompt.custom_minimum_size = Vector2(20, 0)
	hbox.add_child(prompt)

	cmd_input = LineEdit.new()
	cmd_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cmd_input.placeholder_text = "Type a command  (help, look, go down, talk, attack, flee, stats, quest…)"
	cmd_input.add_theme_font_size_override("font_size", 12)
	cmd_input.add_theme_color_override("font_color", Color(0.88, 0.84, 0.70))
	cmd_input.add_theme_color_override("font_placeholder_color", Color(0.32, 0.30, 0.22))
	var ci_style := StyleBoxFlat.new()
	ci_style.bg_color = Color(0.06, 0.05, 0.04)
	ci_style.set_border_width_all(1)
	ci_style.border_color = Color(0.28, 0.22, 0.10)
	ci_style.content_margin_left   = 6
	ci_style.content_margin_right  = 6
	ci_style.content_margin_top    = 4
	ci_style.content_margin_bottom = 4
	cmd_input.add_theme_stylebox_override("normal", ci_style)
	cmd_input.text_submitted.connect(_on_command)
	hbox.add_child(cmd_input)

	return hbox


# ================================================================
# UI HELPERS
# ================================================================

func _make_panel(bg: Color, border: Color) -> PanelContainer:
	var pc := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color     = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.content_margin_left   = 7
	style.content_margin_right  = 7
	style.content_margin_top    = 7
	style.content_margin_bottom = 5
	pc.add_theme_stylebox_override("panel", style)
	return pc


func _panel_hdr(parent: VBoxContainer, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.52, 0.46, 0.26))
	parent.add_child(lbl)


func _kv(key: String, val: String, val_color: Color = Color(0.88, 0.84, 0.70)) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	var k := Label.new()
	k.text = key
	k.custom_minimum_size = Vector2(60, 0)
	k.add_theme_font_size_override("font_size", 11)
	k.add_theme_color_override("font_color", Color(0.42, 0.38, 0.28))
	row.add_child(k)
	var v := Label.new()
	v.text = val
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_font_size_override("font_size", 11)
	v.add_theme_color_override("font_color", val_color)
	row.add_child(v)
	return row


func _val_lbl(text: String) -> Label:
	var v := Label.new()
	v.text = text
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_font_size_override("font_size", 11)
	v.add_theme_color_override("font_color", Color(0.88, 0.84, 0.70))
	return v


func _kv_ref(key: String, val_lbl: Label) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	var k := Label.new()
	k.text = key
	k.custom_minimum_size = Vector2(60, 0)
	k.add_theme_font_size_override("font_size", 11)
	k.add_theme_color_override("font_color", Color(0.42, 0.38, 0.28))
	row.add_child(k)
	row.add_child(val_lbl)
	return row


func _hsep_dark() -> HSeparator:
	var sep := HSeparator.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.16, 0.08)
	style.content_margin_top    = 1
	style.content_margin_bottom = 1
	sep.add_theme_stylebox_override("separator", style)
	return sep


func _make_bar(fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 26)
	bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left     = 3
	fill.corner_radius_top_right    = 3
	fill.corner_radius_bottom_left  = 3
	fill.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", fill)
	var bg_s := StyleBoxFlat.new()
	bg_s.bg_color     = Color(0.07, 0.06, 0.04)
	bg_s.border_color = fill_color.darkened(0.5)
	bg_s.set_border_width_all(1)
	bar.add_theme_stylebox_override("background", bg_s)
	return bar


func _action_btn(label: String, color: Color, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(162, 28)
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", color)
	btn.pressed.connect(cb)
	return btn


# ================================================================
# TIMERS
# ================================================================

func _setup_timers() -> void:
	stamina_timer = Timer.new()
	stamina_timer.wait_time = T_STAM_REST
	stamina_timer.autostart = true
	stamina_timer.timeout.connect(_on_stam_regen)
	add_child(stamina_timer)

	enemy_timer = Timer.new()
	enemy_timer.wait_time = T_ENEMY_ATK
	enemy_timer.autostart = false
	enemy_timer.timeout.connect(_on_enemy_attack)
	add_child(enemy_timer)


# ================================================================
# ZONE MANAGEMENT
# ================================================================

func _enter_zone(zone_id: int, _first: bool = false) -> void:
	current_zone = zone_id
	var z: Dictionary = ZONES[zone_id]

	zone_name_lbl.text  = z["name"]
	zone_art_rect.color = z["art_color"]

	_refresh_actions()
	_log_sep()
	_log("[color=#d4a84b][b]%s[/b][/color]" % z["name"])
	for line: String in z["desc"]:
		_log(line)

	# NPCs present
	if (z["npcs"] as Array).size() > 0:
		_log("[color=#88aaff]Here:[/color] " + ", ".join(PackedStringArray(z["npcs"])))

	# Enemies in basement
	if zone_id == ZONE_BASEMENT:
		var alive: int = rats_alive.count(true)
		if alive > 0:
			_log("[color=#cc5544]Enemies:[/color] %d Cellar Rat%s" % [alive, "s" if alive > 1 else ""])
		else:
			_log("[color=#44cc66]The cellar is clear of vermin.[/color]")

	# Exits
	var exit_txt := ""
	for dir: String in z["exits"]:
		exit_txt += "  [%s]" % dir
	_log("[color=#666655]Exits:[/color]%s" % exit_txt)

	# First-time innkeeper greeting
	if zone_id == ZONE_TAVERN and not innkeeper_greeted:
		innkeeper_greeted = true
		await get_tree().create_timer(0.6).timeout
		_innkeeper_greet()


# ================================================================
# NPC — INNKEEPER BRAM
# ================================================================

func _innkeeper_greet() -> void:
	_log("")
	_log("[color=#88aaff][Innkeeper Bram][/color] [i]glances up from behind the bar.[/i]")
	_log("[color=#aaccff]\"Well now. Fresh face in Ashenveil. You've got that 'just arrived' look.\"[/color]")
	_log("[color=#aaccff]\"Name's Bram. This is the Ember & Flagon. Looking for work?\"[/color]")
	_log("[color=#aaccff]\"My cellar's crawling with rats — gnawing through every barrel I own.\"[/color]")
	_log("[color=#aaccff]\"Kill %d of the little bastards and I'll pay you [b]50 gold[/b]. Deal?\"[/color]" % QUEST_RAT_GOAL)
	_log("[color=#666655](Talk to Bram to accept, or type [b]talk[/b].)[/color]")


func _talk_to_bram() -> void:
	if quest_completed:
		_log("[color=#88aaff][Innkeeper Bram][/color] [color=#aaccff]\"Lifesaver, you are. Barrels are safe now.\"[/color]")
		return

	if quest_accepted:
		var alive: int = rats_alive.count(true)
		if alive > 0:
			_log("[color=#88aaff][Innkeeper Bram][/color] [color=#aaccff]\"Still %d rats down there. Keep at it!\"[/color]" % alive)
		else:
			_complete_quest()
		return

	# Accept quest
	_log("[color=#88aaff][Innkeeper Bram][/color] [color=#aaccff]\"Cellar stairs are right behind the bar. Kill %d rats, 50 gold. Deal?\"[/color]" % QUEST_RAT_GOAL)
	_log("")
	quest_accepted = true
	_log("[color=#44cc88]Quest accepted: [b]Rat Problem[/b][/color]")
	_log("[color=#666655]Kill %d Cellar Rats in the Tavern Basement. Return to Bram for your reward.[/color]" % QUEST_RAT_GOAL)
	_refresh_actions()


func _complete_quest() -> void:
	if quest_completed:
		return
	quest_completed = true
	_log("[color=#88aaff][Innkeeper Bram][/color] [color=#aaccff]\"By the embers! You actually did it. Here's your coin, friend.\"[/color]")
	player_gold += 50
	player_xp   += 30
	_log("[color=#ffdd44]+ 50 gold   + 30 XP[/color]")
	_check_level_up()
	_update_vitals()
	_refresh_actions()


# ================================================================
# COMBAT
# ================================================================

func _start_combat(rat_index: int) -> void:
	if in_combat:
		_log("[color=#cc6644]You are already fighting![/color]")
		return
	if not rats_alive[rat_index]:
		_log("[color=#666655]That rat is already dead.[/color]")
		return

	in_combat = true
	combat_enemy = {
		"name":    RAT["name"],
		"index":   rat_index,
		"hp":      RAT["max_hp"],
		"max_hp":  RAT["max_hp"],
		"atk_min": RAT["atk_min"],
		"atk_max": RAT["atk_max"],
		"xp":      RAT["xp"],
		"gold":    RAT["gold"],
	}
	_log("")
	_log("[color=#cc4444]-- Combat --[/color]")
	_log("You engage a [color=#dd8833]Cellar Rat[/color] (HP: %d/%d)." % [
		combat_enemy["hp"], combat_enemy["max_hp"]])
	stamina_timer.wait_time = T_STAM_COMBAT
	stamina_timer.start()
	enemy_timer.start()
	_refresh_actions()


func _player_attack() -> void:
	if not in_combat:
		_log("[color=#666655]Nothing to attack.[/color]")
		return
	if player_stamina < 1:
		_log("[color=#cc8833]Out of stamina! Wait for it to recharge.[/color]")
		return

	player_stamina -= 1
	_update_stamina()

	var hit_pct: float = minf(60.0 + float(final_stats["Str"]) * 1.5, 95.0)
	if randf() * 100.0 <= hit_pct:
		var dmg: int = final_stats["Str"] * 2 + randi_range(1, 4)
		combat_enemy["hp"] -= dmg
		_log("[color=#88ee88]You hit the [b]%s[/b] for %d damage[/color] (HP: %d/%d)" % [
			combat_enemy["name"], dmg,
			maxi(combat_enemy["hp"], 0), combat_enemy["max_hp"]])
		if combat_enemy["hp"] <= 0:
			_on_enemy_die()
	else:
		_log("[color=#888866]You swing at the %s — [b]miss![/b][/color]" % combat_enemy["name"])


func _on_enemy_attack() -> void:
	if not in_combat:
		enemy_timer.stop()
		return

	var dodge: float = minf(float(final_stats["Agi"]) * 1.5, 40.0)
	if randf() * 100.0 <= dodge:
		_log("[color=#88aaee]The %s snaps at you — [b]dodged![/b][/color]" % combat_enemy["name"])
		return

	var dmg: int = randi_range(combat_enemy["atk_min"], combat_enemy["atk_max"])
	player_hp = maxi(player_hp - dmg, 0)
	_log("[color=#ee6644]The [b]%s[/b] bites you for %d damage![/color] (HP: %d/%d)" % [
		combat_enemy["name"], dmg, player_hp, player_max_hp])
	_update_vitals()
	if player_hp <= 0:
		_on_player_die()


func _on_enemy_die() -> void:
	rats_alive[combat_enemy["index"]] = false
	quest_rats_killed += 1
	var xp: int   = combat_enemy["xp"]
	var gold: int = combat_enemy["gold"]

	_end_combat()

	_log("[color=#44ee88]The %s is [b]dead![/b][/color]" % RAT["name"])
	_log("[color=#ffdd44]+ %d XP[/color]" % xp)
	if gold > 0:
		_log("[color=#ffdd44]+ %d gold[/color]" % gold)

	player_xp   += xp
	player_gold += gold
	_check_level_up()
	_update_vitals()

	if quest_accepted and not quest_completed:
		_log("[color=#aaccaa]Rats slain: %d / %d[/color]" % [quest_rats_killed, QUEST_RAT_GOAL])
		if rats_alive.count(true) == 0:
			_log("[color=#44cc88]All rats cleared! Return to [b]Innkeeper Bram[/b] for your reward.[/color]")

	_refresh_actions()


func _on_player_die() -> void:
	_end_combat()
	_log("")
	_log("[color=#ee2222][b]You have been slain![/b][/color]")
	_log("[color=#888888]Darkness takes you. You wake at the tavern, bruised but breathing.[/color]")
	player_hp = maxi(player_max_hp / 4, 1)
	_update_vitals()
	await get_tree().create_timer(1.2).timeout
	_enter_zone(ZONE_TAVERN)


func _flee_combat() -> void:
	if not in_combat:
		_log("[color=#666655]You are not in combat.[/color]")
		return
	_log("[color=#aaaaaa]You flee, scrambling back up the stairs![/color]")
	_end_combat()
	_enter_zone(ZONE_TAVERN)


func _end_combat() -> void:
	in_combat    = false
	combat_enemy = {}
	enemy_timer.stop()
	stamina_timer.wait_time = T_STAM_REST
	stamina_timer.start()
	_refresh_actions()


# ================================================================
# STAMINA / LEVEL UP
# ================================================================

func _on_stam_regen() -> void:
	if player_stamina < STAMINA_MAX:
		player_stamina += 1
		_update_stamina()


func _check_level_up() -> void:
	while player_xp >= player_xp_next:
		player_xp     -= player_xp_next
		player_level  += 1
		player_xp_next = int(float(player_xp_next) * 1.5)
		player_max_hp  += 10
		player_hp       = player_max_hp
		_log("[color=#ffee55][b]LEVEL UP! You are now level %d![/b][/color]" % player_level)
		_log("[color=#aaffaa]Max HP increased to %d.[/color]" % player_max_hp)
		level_lbl.text = "Lv %d" % player_level


# ================================================================
# UI REFRESH
# ================================================================

func _refresh_actions() -> void:
	for ch: Node in action_container.get_children():
		ch.queue_free()

	var z: Dictionary = ZONES[current_zone]
	_add_action("Look Around", Color(0.75, 0.74, 0.52), _do_look)
	_add_action("Search Area", Color(0.58, 0.76, 0.58), _do_search)

	for dir: String in z["exits"]:
		var d: String = dir
		_add_action("Go " + d.capitalize(), Color(0.52, 0.80, 0.52), func() -> void: _do_go(d))

	if "Innkeeper Bram" in (z["npcs"] as Array):
		_add_action("Talk to Bram", Color(0.60, 0.80, 0.92), _talk_to_bram)

	action_container.add_child(_hsep_dark())

	if in_combat:
		_add_action("⚔  Attack", Color(0.92, 0.38, 0.28), _player_attack)
		_add_action("→  Flee",   Color(0.72, 0.72, 0.30), _flee_combat)
	elif current_zone == ZONE_BASEMENT:
		for i: int in rats_alive.size():
			if rats_alive[i]:
				var idx := i
				_add_action("Attack Rat #%d" % (i + 1), Color(0.92, 0.38, 0.28),
					func() -> void: _start_combat(idx))

	if quest_accepted:
		action_container.add_child(_hsep_dark())
		_add_action("Quest Journal", Color(0.80, 0.76, 0.40), _do_quest_status)


func _add_action(label: String, color: Color, cb: Callable) -> void:
	action_container.add_child(_action_btn(label, color, cb))


func _update_vitals() -> void:
	hp_stat_lbl.text  = "%d / %d" % [player_hp,      player_max_hp]
	mp_stat_lbl.text  = "%d / %d" % [player_mp,      player_max_mp]
	sta_stat_lbl.text = "%d / %d" % [player_stamina, STAMINA_MAX]
	gold_lbl.text     = "%d gp"   % player_gold
	xp_stat_lbl.text  = "%d / %d XP" % [player_xp, player_xp_next]
	hp_bar.max_value  = player_max_hp;   hp_bar.value  = player_hp
	mp_bar.max_value  = player_max_mp;   mp_bar.value  = player_mp
	xp_bar.max_value  = player_xp_next;  xp_bar.value  = player_xp


func _update_stamina() -> void:
	sta_stat_lbl.text = "%d / %d" % [player_stamina, STAMINA_MAX]
	for i: int in stamina_pips.size():
		stamina_pips[i].color = Color(0.18, 0.60, 0.18) if i < player_stamina else Color(0.16, 0.20, 0.16)


# ================================================================
# COMMAND PARSING
# ================================================================

func _on_command(raw: String) -> void:
	cmd_input.clear()
	var cmd := raw.strip_edges().to_lower()
	if cmd == "":
		return
	_log("[color=#4d7040]> %s[/color]" % raw.strip_edges())

	match cmd:
		"look", "l", "look around":
			_do_look()
		"search", "s", "search area":
			_do_search()
		"talk", "talk to bram", "talk bram", "speak", "bram":
			if "Innkeeper Bram" in (ZONES[current_zone]["npcs"] as Array):
				_talk_to_bram()
			else:
				_log("[color=#666655]There is no one here to talk to.[/color]")
		"attack", "a", "fight", "kill", "attack rat", "fight rat":
			if in_combat:
				_player_attack()
			else:
				_attack_first_rat()
		"flee", "run", "escape", "retreat":
			_flee_combat()
		"go down", "down", "d", "basement", "cellar":
			_do_go("down")
		"go up", "up", "u", "tavern", "upstairs":
			_do_go("up")
		"stats", "stat", "attributes", "character":
			_do_show_stats()
		"quest", "quests", "journal", "j":
			_do_quest_status()
		"gold", "money", "coins", "inv", "inventory":
			_log("[color=#ffdd44]Gold: %d gp[/color]" % player_gold)
		"help", "h", "?", "commands":
			_do_help()
		_:
			if cmd.begins_with("go "):
				_do_go(cmd.substr(3).strip_edges())
			elif cmd.begins_with("attack ") or cmd.begins_with("kill "):
				if in_combat:
					_player_attack()
				else:
					_attack_first_rat()
			else:
				_log("[color=#444433]Unknown command. Type [b]help[/b] for a list.[/color]")


func _attack_first_rat() -> void:
	if current_zone != ZONE_BASEMENT:
		_log("[color=#666655]There is nothing to attack here.[/color]")
		return
	for i: int in rats_alive.size():
		if rats_alive[i]:
			_start_combat(i)
			return
	_log("[color=#666655]There are no enemies left to fight.[/color]")


# ================================================================
# NAMED ACTIONS
# ================================================================

func _do_look() -> void:
	_enter_zone(current_zone)


func _do_search() -> void:
	_log("[color=#aaaaaa]You carefully search the area…[/color]")
	if current_zone == ZONE_BASEMENT:
		_log("[color=#aaaaaa]Nothing of value — just gnawed wood and droppings.[/color]")
	else:
		_log("[color=#aaaaaa]Nothing unusual. The tavern smells of ale and old timber.[/color]")


func _do_go(direction: String) -> void:
	if in_combat:
		_log("[color=#cc6644]You can't leave mid-combat! [b]Flee[/b] first.[/color]")
		return
	var z: Dictionary = ZONES[current_zone]
	if direction in z["exits"]:
		_enter_zone(z["exits"][direction])
	else:
		_log("[color=#666655]You can't go that way from here.[/color]")


func _do_show_stats() -> void:
	_log("[color=#d4a84b]── Stats ──[/color]")
	for s: String in ["Str", "Int", "Agi", "End", "Wis", "Chr"]:
		_log("  [color=#888877]%s[/color]  %d" % [s, final_stats.get(s, 0)])
	_log("  [color=#888877]HP[/color]  %d/%d    [color=#888877]MP[/color]  %d/%d" % [
		player_hp, player_max_hp, player_mp, player_max_mp])
	_log("  [color=#888877]Gold[/color] %d gp    [color=#888877]Level[/color] %d" % [player_gold, player_level])


func _do_quest_status() -> void:
	if not quest_accepted:
		_log("[color=#666655]No active quests. Talk to Innkeeper Bram.[/color]")
		return
	_log("[color=#d4a84b]── Quest Journal ──[/color]")
	_log("[color=#ffee88][b]Rat Problem[/b][/color]")
	if quest_completed:
		_log("  [color=#44ee88]COMPLETED[/color]")
	else:
		_log("  Rats slain: [b]%d / %d[/b]" % [quest_rats_killed, QUEST_RAT_GOAL])
		if rats_alive.count(true) == 0:
			_log("  [color=#44cc88]Return to Bram for your reward![/color]")
		else:
			_log("  Head to the Tavern Basement to continue.")


func _do_help() -> void:
	_log("[color=#d4a84b]── Commands ──[/color]")
	_log("  [b]look[/b]      — Describe the current area")
	_log("  [b]search[/b]    — Search for hidden items")
	_log("  [b]go [dir][/b]  — Move (up / down)")
	_log("  [b]talk[/b]      — Speak to a nearby NPC")
	_log("  [b]attack[/b]    — Attack the nearest enemy")
	_log("  [b]flee[/b]      — Escape from combat")
	_log("  [b]stats[/b]     — Show your character stats")
	_log("  [b]quest[/b]     — Show your quest journal")
	_log("  [b]gold[/b]      — Check your gold")
	_log("  [b]help[/b]      — Show this help")


# ================================================================
# LOG HELPERS
# ================================================================

func _log(text: String) -> void:
	game_log.append_text(text + "\n")


func _log_sep() -> void:
	_log("[color=#2a2018]────────────────────────────────────[/color]")
