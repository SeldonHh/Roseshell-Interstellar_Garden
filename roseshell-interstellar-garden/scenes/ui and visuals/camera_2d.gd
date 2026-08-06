extends Camera2D

@onready var og_pos : Vector2 = position
@export var player_zwoom_factor := 50
@export var zoom_offset := .7

func _process(_delta: float) -> void:
	var offset_dir = (Global.player.body.global_position-og_pos).normalized()
	position = og_pos + offset_dir * player_zwoom_factor
	if Input.is_action_just_pressed("scroll_down"):
		zoom_offset = max(zoom_offset - .03,.5)
	if Input.is_action_just_pressed("scroll_up"):
		zoom_offset = min(1,zoom_offset+.03)
	zoom = Vector2(zoom_offset,zoom_offset)
