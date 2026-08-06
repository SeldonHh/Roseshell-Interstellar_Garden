extends Node2D

var anchor : Vector2 = Vector2(.5,.5)
var radius : float = 300
@export var speed := 96.0
@onready var rotation_factor := PI
@onready var body: CharacterBody2D = $body

func _ready() -> void:
	Global.player = self

func _process(delta: float) -> void:
	if Global.black_hole:
		position  = Global.black_hole.position
	if Input.is_action_pressed("left"):
		rotation_factor = lerp(rotation_factor,rotation_factor-speed*2*delta,delta)
	if Input.is_action_pressed("right"):
		rotation_factor = lerp(rotation_factor,rotation_factor+speed*2*delta,delta)
	
	var end = Vector2(0, radius).rotated(rotation_factor)
	body.position = end
