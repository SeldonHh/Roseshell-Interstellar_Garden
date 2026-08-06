extends Node2D

var anchor : Vector2 = Vector2(.5,.5)
var radius : float = 200
@export var speed := .08
@onready var rotation_factor := PI
@onready var body: CharacterBody2D = $body

func _ready() -> void:
	Global.player = self

func _process(delta: float) -> void:
	if Global.black_hole:
		position  = Global.black_hole.position
	
	if Global.keyboard:
		if Input.is_action_pressed("left"):
			rotation_factor = lerp(rotation_factor,rotation_factor-speed*1000*delta,delta)
		if Input.is_action_pressed("right"):
			rotation_factor = lerp(rotation_factor,rotation_factor+speed*1000*delta,delta)
	else:
		var mouse_position = get_global_mouse_position()
		var target_angle = get_angle_to(mouse_position)
		rotation_factor = lerp_angle(rotation_factor,target_angle,speed)
	body.position = Vector2(radius, 0).rotated(rotation_factor)
