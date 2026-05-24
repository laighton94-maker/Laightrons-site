extends Control

# Placeholder — real game scene built in the next phase.

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.09)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 18)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	var title := Label.new()
	title.text = "KAOS EMBERS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color(0.9, 0.65, 0.15))
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "The world of Kaerath awaits.\n\n[ Game scene — coming soon ]"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	vbox.add_child(sub)

	var back := Button.new()
	back.text = "← Back to Character Creation"
	back.custom_minimum_size = Vector2(280, 42)
	back.alignment = HORIZONTAL_ALIGNMENT_CENTER
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/CharacterCreation.tscn")
	)
	vbox.add_child(back)
