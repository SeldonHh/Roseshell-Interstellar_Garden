extends Node2D

var anchor : Vector2 = Vector2(.5,.5)
@export var radius : float = 120
@export var speed := 12
@export var previous_rotation := PI
@onready var rotation_factor := PI
@onready var body: CharacterBody2D = $body
@onready var trail: Line2D = $body/trail
@export var trail_lenght := 100.0

func _ready() -> void:
	$body/Sprite2D.play("default")
	Global.player = self

func _physics_process(delta: float) -> void:
	if Global.black_hole:
		position  = Global.black_hole.position
	var mouse_position = get_global_mouse_position()
	if (mouse_position - global_position).length() > 50:
		var target_angle = get_angle_to(mouse_position)
		rotation_factor = lerp_angle(rotation_factor,target_angle,1.0 - exp(-speed * delta))
	if previous_rotation <= rotation_factor-PI/100 or previous_rotation >= rotation_factor+PI/100:
		trail.show()
		trail_lenght = lerp(trail_lenght, -angle_difference(previous_rotation,rotation_factor) * 1000.0, 16.0 * delta)
		trail_lenght = max(-200,trail_lenght)
		trail_lenght = min(200,trail_lenght)
	else:
		trail.hide()
		trail_lenght = 0
	trail.set_point_position(1,Vector2(0,trail_lenght)) 
	body.rotation = rotation_factor
	body.position = Vector2(radius, 0).rotated(rotation_factor)
	previous_rotation = rotation_factor
