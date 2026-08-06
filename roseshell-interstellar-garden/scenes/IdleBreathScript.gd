extends Node2D

@export var breathe_speed := 1.2
@export var breathe_amount := 0.015
@export var float_amount := 3.0

var origin_position: Vector2
var origin_scale: Vector2
var t := 0.0

func _ready() -> void:
	origin_position = position
	origin_scale = scale

func _process(delta: float) -> void:
	t += delta

	var breath = sin(t * breathe_speed)
	var sway_x = sin(t * breathe_speed * 0.6) * float_amount
	var sway_y = cos(t * breathe_speed * 0.8) * float_amount

	scale = origin_scale * (1.0 + breath * breathe_amount)
	position = origin_position + Vector2(sway_x, sway_y)
