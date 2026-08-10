extends Node

var player : Node2D
var black_hole : Node2D
var keyboard := false
@onready var IS_DEBUG = "debug" in OS.get_cmdline_args()
var main_menu : Control
var sfx_volume := 1.0
var music_volume := 1.0
var song_music : AudioStreamPlayer
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if song_music.playing or get_tree().paused == true:
			get_tree().paused = !get_tree().paused
		#main_menu.show()
		#main_menu.show_settings()
