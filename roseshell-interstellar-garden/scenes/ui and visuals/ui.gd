extends CanvasLayer

@onready var combo: RichTextLabel = $combo
@onready var notes: Node2D = $"../Notes"
@onready var chart = $"../Chart"
@onready var menu: Control = $Menu
@onready var recap_screen: RichTextLabel = $recap_screen
@onready var lvl_1: TextureButton = %lvl1
@onready var lvl_2: TextureButton = %lvl2
@onready var lvl_3: TextureButton = %lvl3
@onready var tutorial: TextureButton = %Tutorial
@onready var neru_1: TextureButton = $"Menu/Neru's kingdom/Neru1"
@onready var neru_2: TextureButton = $"Menu/Neru's kingdom/Neru2"
@onready var neru_3: TextureButton = $"Menu/Neru's kingdom/Neru3"
@onready var neru_4: TextureButton = $"Menu/Neru's kingdom/Neru4"
@onready var purple_s_advenure: Control = $"Menu/Purple's advenure"
@onready var neru_s_kingdom: Control = $"Menu/Neru's kingdom"

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

func _ready():
	if Global.IS_DEBUG:
		lvl_1.disabled = false
		lvl_2.disabled = false
		lvl_3.disabled = false
		neru_1.disabled = false
		neru_2.disabled = false
		neru_3.disabled = false
		neru_4.disabled = false
	tutorial.set_meta("song",preload("uid://cja8bn21mm8o"))
	lvl_1.set_meta("song",preload("uid://bj4l508i6ovjs"))
	lvl_2.set_meta("song",preload("uid://5yaur3b2grrd"))
	lvl_3.set_meta("song",preload("uid://dfitmdopxvif2"))
	neru_1.set_meta("song",preload("uid://et45168hj3r3"))
	neru_2.set_meta("song",preload("uid://rcxiw3bhmpqn"))
	neru_3.set_meta("song",preload("uid://b6eddy0eewpxb"))
	neru_4.set_meta("song",preload("uid://brlpjmmoxfmni"))
	chart.song_ended.connect(_on_song_ended)
	notes.combo_success.connect(_on_combo_success)
	notes.combo_break.connect(_on_combo_break)
	notes.note_spawned.connect(_on_note_spawned)

func _process(_delta: float) -> void:
	
	if song_ended:
		return
	
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

func _on_note_spawned():
	total_notes += 1

func _on_combo_success():
	total_score += 100 * notes.combo
	if notes.combo > max_combo:
		max_combo = notes.combo
	hit_notes += 1

func _on_combo_break():
	misses += 1

func _on_song_ended():
	match chart.song.song_name:
		"Tutorial":
			for lvl in [lvl_1,neru_1,neru_2,neru_3]:
				lvl.disabled = false
				if lvl.get_child(1) != null:
					lvl.get_child(1).queue_free()
				lvl.self_modulate = Color(1.0,1.0,1.0,1.0)
		"Stellar ballad":
			lvl_2.disabled = false
			if lvl_2.get_child(1) != null:
				lvl_2.get_child(1).queue_free()
			lvl_2.self_modulate = Color(1.0,1.0,1.0,1.0)
		"Spacetime Rift":
			for lvl in [lvl_3,neru_4]:
				lvl.disabled = false
				if lvl.get_child(1) != null:
					lvl.get_child(1).queue_free()
				lvl.self_modulate = Color(1.0,1.0,1.0,1.0)
		"Oh My!":
			neru_2.disabled = false
			if neru_2.get_child(1) != null:
				neru_2.get_child(1).queue_free()
			neru_2.self_modulate = Color(1.0,1.0,1.0,1.0)
		"Cytoplasm":
			neru_3.disabled = false
			if neru_3.get_child(1) != null:
				neru_3.get_child(1).queue_free()
			neru_3.self_modulate = Color(1.0,1.0,1.0,1.0)
		"Fallen Empire":
			for lvl in [lvl_3,neru_4]:
				lvl.disabled = false
				if lvl.get_child(1) != null:
					lvl.get_child(1).queue_free()
				lvl.self_modulate = Color(1.0,1.0,1.0,1.0)
	song_ended = true
	recap_screen.show()
	recap_screen.scale = Vector2.ONE
	combo_stable = false
	
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
	elif percentage >= 94:
		rating = "S"
		color = "#E40000"
	elif percentage >= 90:
		rating = "A"
		color = "#EA9700"
	elif percentage >= 80:
		rating = "B"
		color = "#EBEB00"
	elif percentage >= 65:
		rating = "C"
	elif percentage >= 50:
		rating = "D"
	
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
	for child in purple_s_advenure.get_children():
		if child.has_meta("song"):
			if child.get_meta("song") == chart.song:
				if child.has_meta("percentage"):
					if child.get_meta("percentage") < percentage:
						child.set_meta("percentage",percentage)
						child.get_child(0).text = "%s\n[color=%s]Rank: %s[/color]"%[chart.song.song_name,color,rating]
				
				else:
					child.set_meta("percentage",percentage)
					child.get_child(0).text = "%s\n[color=%s]Rank: %s[/color]"%[chart.song.song_name,color,rating]
				
			
	await get_tree().create_timer(3).timeout
	combo_stable = false
	previous_combo = 0
	notes.combo = 0
	song_ended = false
	max_combo = 0
	misses = 0
	total_score = 0
	max_possible_score = 0
	total_notes = 0
	hit_notes = 0
	combo.modulate = Color(1.0,1.0,1.0,0.0)
	combo.scale = Vector2.ONE
	chart.music.stop()
	menu.show()
	recap_screen.hide()


func _on_lvl_2_pressed() -> void:
	chart.song = lvl_2.get_meta("song")
	menu.hide()
	chart.play_song()


func _on_lvl_1_pressed() -> void:
	chart.song = lvl_1.get_meta("song")
	menu.hide()
	chart.play_song()


func _on_tutorial_pressed() -> void:
	chart.song = tutorial.get_meta("song")
	menu.hide()
	chart.play_song()
	
	var viewport_size = get_viewport().get_visible_rect().size
	recap_screen.position = Vector2(viewport_size.x * 0.05, viewport_size.y * 0.3) 
	recap_screen.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	recap_screen.text = "Oh an asteroid is approaching\nblock it before it goes in the black hole!"
	recap_screen.show()
	await get_tree().create_timer(7.16).timeout
	recap_screen.text = "If you [color=#FF0000]miss[/color] an asteroid it will be absorbed by the black hole\nIf it absorbs too much it will reach [color=#FF0000]critical mass[/color] and you'll fail"
	await get_tree().create_timer(7.16).timeout
	recap_screen.text = "There are some special types of asteroids:\n[color=#FFD700]Yellow[/color] ones spin a lot"  
	await get_tree().create_timer(7.16).timeout
	recap_screen.text = "[color=#00FF00]Green[/color] ones charge and dash"  
	await get_tree().create_timer(7.16).timeout
	recap_screen.text = "[color=#FF0000]Red[/color] ones explode, you must avoid them and they won't nourrish the black hole"  
	await get_tree().create_timer(7.16).timeout
	recap_screen.text = "Try to get high combo by deflecting all the asteroid and try to reach P rank for all levels, good luck"
	await get_tree().create_timer(7.16).timeout
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


func _on_lvl_3_pressed() -> void:
	chart.song = lvl_2.get_meta("song")
	menu.hide()
	chart.play_song()


func _on_neru_2_pressed() -> void:
	chart.song = neru_2.get_meta("song")
	menu.hide()
	chart.play_song()


func _on_neru_1_pressed() -> void:
	chart.song = neru_1.get_meta("song")
	menu.hide()
	chart.play_song()


func _on_neru_3_pressed() -> void:
	chart.song = neru_3.get_meta("song")
	menu.hide()
	chart.play_song()


func _on_neru_4_pressed() -> void:
	chart.song = neru_4.get_meta("song")
	menu.hide()
	chart.play_song()
