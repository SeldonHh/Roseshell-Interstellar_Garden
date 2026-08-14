@tool
extends TextureButton

@export var left := false
@export var song : SongChart = preload("uid://cja8bn21mm8o") 
@onready var level_info: RichTextLabel = %"Level Info"
@onready var requirement_label: Label = %Requirement
@onready var difficulty_texture: TextureRect = $difficulty_texture

func _ready() -> void:
	update_self()
	if song == null:
		print("ERROR: levelbase had no song resource")
	Global.song_resources.append(song)
	if not Engine.is_editor_hint():
		await get_tree().create_timer(.1).timeout
		Global.music_control.song_ended.connect(update_self)
		update_self()
func update_self():
	button_pressed = false
	if song == null:
		print("ERROR: levelbase had no song resource")
	if not Engine.is_editor_hint():
		level_info.text = song.give_level_text()
		if song.requirement != []:
			for level in song.requirement.duplicate():
				if Global.compare_rank(level.highest_rank,song.requirement_rank):
					no_requirement()
				else: yes_requirement(level)
		else: no_requirement()
	texture_normal = song.cover
	texture_hover = song.cover_hover
	if not Engine.is_editor_hint():
		difficulty_texture.texture = song.give_difficulty_texture()

func yes_requirement(level):
	requirement_label.show()
	if left:
		requirement_label.anchor_left = -2.25
		requirement_label.anchor_right = -.5
	requirement_label.text = "Must get %s or higher in %s"%[song.requirement_rank,level.song_name]
	if ! Global.IS_DEBUG:
		disabled = true
		self_modulate = Color(1.0,1.0,1.0,.6)
	difficulty_texture.self_modulate = self_modulate

func no_requirement():
	requirement_label.hide()
	disabled =  false
	self_modulate = Color(1.0,1.0,1.0,1.0)
	difficulty_texture.self_modulate = self_modulate

func _on_pressed() -> void:
	Global.music_control.song = song
	Global.music_control.play_song()
