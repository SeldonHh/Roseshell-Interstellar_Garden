extends Node2D

# 1 = Orange
# 2 = Blue
# 3 = Purple
# 4 = Green
# 5 = Red
# 6 = Yellow
# 7 = Cyan
# 8 = Pink
# 9 = Lime
# 10 = White
# 11 = More blue

@export var breathe_speed := 1.2
@export var breathe_amount := 0.015
@export var float_amount := 3.0

var origin_position: Vector2
var origin_scale: Vector2
var t := 0.0
var blackhole_index := 1

@onready var disk: GPUParticles2D = $Disk
@onready var glow0: Sprite2D = $Glow0
@onready var glow1: Sprite2D = $Glow1
@onready var glow2: Sprite2D = $Glow2
@onready var glow3: Sprite2D = $Glow3

var variants = {
	1: {
		"color_a": Color("#ff6a00"),
		"color_b": Color("#ffb000"),
		"size": 1.00,
		"breathe_speed": 1.20,
		"breathe_amount": 0.015,
		"comet_color": Color("#ff6a00")
	},
	2: {
		"color_a": Color("#00aaff"),
		"color_b": Color("#66ddff"),
		"size": 0.94,
		"breathe_speed": 1.35,
		"breathe_amount": 0.018,
		"comet_color": Color("#00aaff")
	},
	3: {
		"color_a": Color("#8a2be2"),
		"color_b": Color("#d86cff"),
		"size": 1.06,
		"breathe_speed": 1.05,
		"breathe_amount": 0.020,
		"comet_color": Color("#8a2be2")
	},
	4: {
		"color_a": Color("#00d084"),
		"color_b": Color("#7dffbf"),
		"size": 0.98,
		"breathe_speed": 1.45,
		"breathe_amount": 0.013,
		"comet_color": Color("#00d084")
	},
	5: {
		"color_a": Color("#ff1744"),
		"color_b": Color("#ff758f"),
		"size": 1.08,
		"breathe_speed": 1.10,
		"breathe_amount": 0.022,
		"comet_color": Color("#ff1744")
	},
	6: {
		"color_a": Color("#ffe600"),
		"color_b": Color("#fff59d"),
		"size": 0.92,
		"breathe_speed": 1.55,
		"breathe_amount": 0.012,
		"comet_color": Color("#ffe600")
	},
	7: {
		"color_a": Color("#00e5ff"),
		"color_b": Color("#9cffff"),
		"size": 1.03,
		"breathe_speed": 0.95,
		"breathe_amount": 0.025,
		"comet_color": Color("#00e5ff")
	},
	8: {
		"color_a": Color("#ff00aa"),
		"color_b": Color("#ff80d5"),
		"size": 0.97,
		"breathe_speed": 1.30,
		"breathe_amount": 0.017,
		"comet_color": Color("#ff00aa")
	},
	9: {
		"color_a": Color("#7cff00"),
		"color_b": Color("#d4ff80"),
		"size": 1.05,
		"breathe_speed": 1.60,
		"breathe_amount": 0.014,
		"comet_color": Color("#7cff00")
	},
	10: {
		"color_a": Color("#ffffff"),
		"color_b": Color("#ff4d00"),
		"size": 1.10,
		"breathe_speed": 0.85,
		"breathe_amount": 0.028,
		"comet_color": Color("#ffffff")
	},
	11: {
		"color_a": Color("004cffff"),
		"color_b": Color("6679ffff"),
		"size": 0.94,
		"breathe_speed": 1.35,
		"breathe_amount": 0.018,
		"comet_color": Color("007cffff")
	},
}

func _ready() -> void:
	Global.black_hole = self
	origin_position = get_viewport().get_visible_rect().size / 2.0
	origin_scale = scale
	apply_blackhole_index(blackhole_index)

func _process(delta: float) -> void:
	origin_position = get_viewport().get_visible_rect().size / 2.0
	t += delta
	var breath = sin(t * breathe_speed)
	var sway_x = sin(t * breathe_speed * 0.6) * float_amount
	var sway_y = cos(t * breathe_speed * 0.8) * float_amount
	scale = origin_scale * (1.0 + breath * breathe_amount)
	position = origin_position + Vector2(sway_x, sway_y)

func set_blackhole_index(index) -> void:
	blackhole_index = int(index)
	apply_blackhole_index(blackhole_index)

func apply_blackhole_index(index: int) -> void:
	if not variants.has(index):
		index = 1
	var variant = variants[index]
	breathe_speed = variant["breathe_speed"]
	breathe_amount = variant["breathe_amount"]
	scale = origin_scale * variant["size"]
	
	var material = disk.process_material
	if material:
		material = material.duplicate()
		disk.process_material = material
		var gradient = Gradient.new()
		gradient.colors = PackedColorArray([
			Color(variant["color_a"], 0.0),
			variant["color_a"],
			variant["color_b"],
			Color(variant["color_b"], 0.0)
		])
		gradient.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
		var gradient_texture = GradientTexture1D.new()
		gradient_texture.gradient = gradient
		material.color_ramp = gradient_texture
	
	update_glow_colors(variant["color_a"])
	update_comet_colors(variant["comet_color"])

func update_glow_colors(base_color: Color) -> void:
	if glow0:
		glow0.modulate = Color(base_color.r, base_color.g, base_color.b, 0.8)
	if glow1:
		glow1.modulate = Color(base_color.r, base_color.g, base_color.b, 0.6)
	if glow2:
		glow2.modulate = Color(base_color.r, base_color.g, base_color.b, 0.4)
	if glow3:
		glow3.modulate = Color(base_color.r, base_color.g, base_color.b, 0.2)

func update_comet_colors(comet_color: Color) -> void:
	var comets = get_tree().get_nodes_in_group("comet")
	for comet in comets:
		if comet.has_method("set_comet_color"):
			comet.set_comet_color(comet_color)


func _on_neru_1_pressed() -> void:
	pass # Replace with function body.
