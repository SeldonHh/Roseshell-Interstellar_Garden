extends Sprite2D



func _process(_delta: float) -> void:
	Input.set_custom_mouse_cursor(texture.get_frame_texture(texture.current_frame), Input.CURSOR_ARROW, Vector2(texture.get_width(), texture.get_height()) / 2)
