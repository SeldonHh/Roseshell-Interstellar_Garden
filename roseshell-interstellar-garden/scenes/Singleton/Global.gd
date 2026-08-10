extends Node

var player : Node2D
var black_hole : Node2D
var keyboard := false
@onready var IS_DEBUG = "debug" in OS.get_cmdline_args()
var main_menu : Control
var sfx_volume := .9
var music_volume := .9
var menu_music_volume := .7
var song_music : AudioStreamPlayer
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if song_music.playing or get_tree().paused == true:
			get_tree().paused = !get_tree().paused
			if get_tree().paused == true:
				main_menu.show()
				main_menu.show_settings()
			else:
				main_menu.hide()
				main_menu.hide_settings()
