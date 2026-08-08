extends Node2D

var anchor : Vector2 = Vector2(.5,.5)
@export var radius : float = 120
@export var speed := .08
@export var previous_rotation := PI
@onready var rotation_factor := PI
@onready var body: CharacterBody2D = $body
@onready var trail: Line2D = $body/trail
@export var trail_lenght := 100.0

func _ready() -> void:
	$body/Sprite2D.play("default")
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
		if (mouse_position - global_position).length() > 50:
			var target_angle = get_angle_to(mouse_position)
			rotation_factor = lerp_angle(rotation_factor,target_angle,speed)
	if previous_rotation <= rotation_factor-PI/100 or previous_rotation >= rotation_factor+PI/100:
		trail.show()
		trail_lenght = lerp(trail_lenght,(previous_rotation-rotation_factor)*1000,delta*16)
	else:
		trail.hide()
	trail.points = [Vector2.ZERO,Vector2(0,trail_lenght)]
	body.rotation = rotation_factor
	body.position = Vector2(radius, 0).rotated(rotation_factor)
	previous_rotation = rotation_factor
