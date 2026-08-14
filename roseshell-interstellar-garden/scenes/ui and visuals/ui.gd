extends CanvasLayer

@onready var combo: RichTextLabel = $combo
@onready var notes: Node2D = $"../Notes"
@onready var music_control = %MusicControl
@onready var menu: Control = $Menu
@onready var recap_screen: RichTextLabel = $recap_screen
@onready var purple_s_advenure: Control = $"Menu/Purple's advenure"
@onready var neru_s_kingdom: Control = $"Menu/Neru's kingdom"
@onready var menu_music: AudioStreamPlayer = $menu_music
@export var critical_mass_mistakes := 0

var current_level_selection_index := 0 
var level_selections := [purple_s_advenure,neru_s_kingdom]

var combo_stable := false
var previous_combo := 0
var song_ended := false
var max_combo := 0
var misses := 0
var total_score := 0
var max_possible_score := 0
var total_notes := 0
var hit_notes := 0

var critical_mass_active := false
var critical_mass_stabilized_timer := 0.0
var critical_mass_stabilized := false
var critical_mass_label: RichTextLabel
var was_in_danger_zone := false
var game_over := false

func _ready():
	Global.ui = self
	music_control.song_ended.connect(_on_song_ended)
	notes.combo_success.connect(_on_combo_success)
	notes.combo_break.connect(_on_combo_break)
	notes.note_spawned.connect(_on_note_spawned)
	
	critical_mass_label = RichTextLabel.new()
	add_child(critical_mass_label)
	critical_mass_label.hide()
	critical_mass_label.bbcode_enabled = true
	critical_mass_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	critical_mass_label.position = Vector2(
		get_viewport().get_visible_rect().size.x * 0.645,
		get_viewport().get_visible_rect().size.y * 0.88
	)
	critical_mass_label.size = Vector2(400, 80)
	critical_mass_label.add_theme_font_size_override("normal_font_size", 22)
	critical_mass_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	critical_mass_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _process(_delta: float) -> void:
	menu_music.volume_linear = Global.menu_music_volume
	if song_ended or game_over:
		return
	
	_update_critical_mass_ui(_delta)
	
	if critical_mass_mistakes >= 10:
		_fail_game()
	
	if notes.combo > 0:
		if !combo_stable:
			combo_stable = true
			var tween = get_tree().create_tween()
			tween.tween_property(combo, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

		if previous_combo != notes.combo:
			var tween = get_tree().create_tween()
			tween.tween_property(combo, "scale", Vector2(1.3, 1.3), 0.08)
			tween.tween_callback(
				func():
					var back_tween = get_tree().create_tween()
					back_tween.tween_property(combo, "scale", Vector2.ONE, 0.12)
			)

		var shake_rate := 0
		var shake_level := 0

		if notes.combo >= 6:
			shake_rate = min(120, 18 + notes.combo * 4)
			shake_level = min(18, int(notes.combo * 0.6))

		if notes.combo <= 5:
			combo.text = "[center][color=#FFFFFF]COMBO x%s[/color][/center]" % notes.combo
		elif notes.combo <= 10:
			combo.text = "[center][color=#FF0000][shake rate=%d level=%d]COMBO x%s[/shake][/color][/center]" % [
				shake_rate,
				shake_level,
				notes.combo
			]
		elif notes.combo <= 29:
			combo.text = "[center][color=#8000FF][shake rate=%d level=%d]COMBO x%s[/shake][/color][/center]" % [
				shake_rate,
				shake_level,
				notes.combo
			]
		else:
			combo.text = "[center][rainbow freq=0.35 sat=1.0][shake rate=%d level=%d]COMBO x%s[/shake][/rainbow][/center]" % [
				shake_rate,
				shake_level,
				notes.combo
			]

		previous_combo = notes.combo
	else:
		if combo_stable:
			combo_stable = false
			var tween = get_tree().create_tween()
			tween.tween_property(combo, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2)
			previous_combo = 0
			combo.scale = Vector2.ONE

func _update_critical_mass_ui(delta: float):
	if song_ended or game_over:
		critical_mass_label.hide()
		return
	
	var in_danger_zone = critical_mass_mistakes >= 5 and critical_mass_mistakes < 10
	var mistakes_left = 10 - critical_mass_mistakes

	if in_danger_zone:
		if not was_in_danger_zone:
			critical_mass_active = true
			critical_mass_stabilized = false
			critical_mass_stabilized_timer = 0.0
			was_in_danger_zone = true

		critical_mass_label.show()

		var shake_rate := 0
		var shake_level := 0

		if mistakes_left <= 3:
			shake_rate = 40 + (3 - mistakes_left) * 30
			shake_level = 8 + (3 - mistakes_left) * 8

		var text = "[center][color=#FF0000]"

		if shake_level > 0:
			text += "[shake rate=%d level=%d]" % [shake_rate, shake_level]

		text += "APPROACHING CRITICAL MASS: %d" % mistakes_left

		if shake_level > 0:
			text += "[/shake]"

		text += "[/color][/center]"

		critical_mass_label.text = text
		critical_mass_label.modulate = Color(1.0, 1.0, 1.0, 1.0)

	else:
		if was_in_danger_zone:
			if not critical_mass_stabilized:
				critical_mass_stabilized = true
				critical_mass_stabilized_timer = 0.0
				critical_mass_label.text = "[center][color=#00FF00]CRITICAL MASS STABILIZED[/color][/center]"
				critical_mass_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
				critical_mass_label.show()

			critical_mass_stabilized_timer += delta

			if critical_mass_stabilized_timer > 1.5:
				var alpha = 1.0 - ((critical_mass_stabilized_timer - 1.5) / 0.5)
				critical_mass_label.modulate = Color(1.0, 1.0, 1.0, alpha)

			if critical_mass_stabilized_timer >= 2.0:
				critical_mass_label.hide()
				critical_mass_active = false
				critical_mass_stabilized = false
				critical_mass_stabilized_timer = 0.0
				was_in_danger_zone = false

func _fail_game():
	game_over = true
	song_ended = true
	critical_mass_label.hide()
	music_control.force_stop()
	
	var viewport_size = get_viewport().get_visible_rect().size
	recap_screen.position = Vector2(viewport_size.x * 0.15, viewport_size.y * 0.4)
	recap_screen.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	var percentage = ((float(hit_notes) / total_notes) * 100) if total_notes > 0 else 0.0
	
	recap_screen.text = """[center][color=#FF0000]CRITICAL MASS REACHED - GAME OVER[/color]
[color=#FFFFFF]
MAX COMBO: %s
MISSES: %s
SCORE: %s
[color=#FFFFFF]RATING: F[/color]
%.1f%%
[/color][/center]""" % [
		max_combo,
		misses,
		total_score,
		percentage
	]
	
	recap_screen.show()
	recap_screen.scale = Vector2.ONE
	combo_stable = false
	
	await get_tree().create_timer(3).timeout
	_reset_game()

func _on_note_spawned():
	total_notes += 1

func _on_combo_success():
	total_score += 100 * notes.combo
	if notes.combo > max_combo:
		max_combo = notes.combo
	hit_notes += 1

func _on_combo_break():
	misses += 1
	critical_mass_mistakes += 1

func _reset_game():
	combo_stable = false
	critical_mass_mistakes = 0
	previous_combo = 0
	notes.combo = 0
	song_ended = false
	game_over = false
	max_combo = 0
	misses = 0
	total_score = 0
	max_possible_score = 0
	total_notes = 0
	hit_notes = 0
	combo.modulate = Color(1.0,1.0,1.0,0.0)
	combo.scale = Vector2.ONE
	critical_mass_label.hide()
	critical_mass_active = false
	critical_mass_stabilized = false
	critical_mass_stabilized_timer = 0.0
	was_in_danger_zone = false
	music_control.music.stop()
	menu.show()
	recap_screen.hide()
	#menu_music.play()
	Global.save_game()

func _on_song_ended():
	recap_screen.show()
	recap_screen.scale = Vector2.ONE
	combo_stable = false
	critical_mass_label.hide()
	
	var viewport_size = get_viewport().get_visible_rect().size
	recap_screen.position = Vector2(viewport_size.x * 0.15, viewport_size.y * 0.4)
	recap_screen.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	var percentage = ((float(hit_notes) / total_notes) * 100) if total_notes > 0 else 0.0
	
	var rating = "F"
	var color = "#FFFFFF"
	if percentage == 100:
		rating = "P"
		color = "#F0A500"
	elif percentage >= 97:
		rating = "SS"
		color = "#E40000"
	elif percentage >= 92:
		rating = "S"
		color = "#E40000"
	elif percentage >= 85:
		rating = "A"
		color = "#EA9700"
	elif percentage >= 75:
		rating = "B"
		color = "#EBEB00"
	elif percentage >= 50:
		rating = "C"
		color = "#00FF00"
	elif percentage >= 10:
		rating = "D"
		color = "#007FD8"
	recap_screen.text = """[center][color=#FFFFFF]
MAX COMBO: %s
MISSES: %s
SCORE: %s
[color=%s]RATING: %s[/color]
%.1f%%
[/color][/center]""" % [
		max_combo,
		misses,
		total_score,
		color,
		rating,
		percentage
	]
	music_control.song.update(rating,percentage)
	await get_tree().create_timer(3).timeout
	_reset_game()




func _on_tutorial_pressed() -> void:
	menu.hide()	
	var viewport_size = get_viewport().get_visible_rect().size
	recap_screen.position = Vector2(viewport_size.x * 0.05, viewport_size.y * 0.3) 
	recap_screen.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	recap_screen.text = "Oh an asteroid is approaching\nblock it before it goes in the black hole!"
	recap_screen.show()
	if song_ended:
		return
	await get_tree().create_timer(7.16).timeout
	if song_ended:
		return
	recap_screen.text = "If you [color=#FF0000]miss[/color] an asteroid it will be absorbed by the black hole\nIf it absorbs too much it will reach [color=#FF0000]critical mass[/color] and you'll fail"
	await get_tree().create_timer(7.16).timeout
	if song_ended:
		return
	recap_screen.text = "There are some special types of asteroids:\n[color=#FFD700]Yellow[/color] ones spin a lot"  
	await get_tree().create_timer(7.16).timeout
	if song_ended:
		return
	recap_screen.text = "[color=#00FF00]Green[/color] ones charge and dash"  
	await get_tree().create_timer(7.16).timeout
	if song_ended:
		return
	recap_screen.text = "[color=#FF0000]Red[/color] ones explode, you must avoid them and they won't feed the black hole"  
	await get_tree().create_timer(7.16).timeout
	if song_ended:
		return
	recap_screen.text = "Try to get high combo by deflecting all the asteroid and try to reach P rank for all levels, good luck, you can zoom in and out with mouse wheel"
	await get_tree().create_timer(7.16).timeout
	if song_ended:
		return
	recap_screen.hide()
	
func _on_rightarrow_pressed() -> void:
	current_level_selection_index += 1
	if current_level_selection_index > 1:
		current_level_selection_index = 0
	match current_level_selection_index:
		0:
			purple_s_advenure.show()
			neru_s_kingdom.hide()
		1:
			purple_s_advenure.hide()
			neru_s_kingdom.show()


func _on_leftarrow_pressed() -> void:
	current_level_selection_index -= 1
	if current_level_selection_index < 0:
		current_level_selection_index = 1
	match current_level_selection_index:
		0:
			purple_s_advenure.show()
			neru_s_kingdom.hide()
		1:
			purple_s_advenure.hide()
			neru_s_kingdom.show()

func _on_button_pressed() -> void:
	%Main_Menu.show()


func _on_critical_mass_recovery_timeout() -> void:
	critical_mass_mistakes = max(0,critical_mass_mistakes-1)
