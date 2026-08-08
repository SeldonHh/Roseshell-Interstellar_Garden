extends CanvasLayer

@onready var combo: RichTextLabel = $combo
@onready var notes: Node2D = $"../Notes"
@onready var chart = $"../Chart"
@onready var menu: Control = $Menu
@onready var recap_screen: RichTextLabel = $recap_screen
@onready var lvl_1: TextureButton = %lvl1
@onready var lvl_2: TextureButton = %lvl2
@onready var lvl_holder: GridContainer = $Menu/Lvl_Holder
@onready var tutorial: TextureButton = %Tutorial

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
	tutorial.set_meta("song",preload("uid://cja8bn21mm8o"))
	lvl_1.set_meta("song",preload("uid://bj4l508i6ovjs"))
	lvl_2.set_meta("song",preload("uid://et45168hj3r3"))
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
	for child in lvl_holder.get_children():
		if child.has_meta("song"):
			if child.get_meta("song") == chart.song:
				child.get_child(0).text = "%s\n[color=%s]rank: %s[/color]"%[chart.song.song_name,color,rating]
				
			
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
	chart.shong = tutorial.get_meta("song")
	menu.hide()
	chart.play_song()
