extends Node2D

@export var breathe_speed := 1.2
@export var breathe_amount := 0.015
@export var float_amount := 3.0

const COLOR_TRANSITION_TIME := 3.3

var origin_position: Vector2
var origin_scale: Vector2
var t := 0.0
var blackhole_index := 1

var chart_data = null
var audio_player: AudioStreamPlayer = null
var current_asteroid_type := ""

var transition_progress := 1.0
var transition_start_a := Color.WHITE
var transition_start_b := Color.WHITE
var transition_start_comet := Color.WHITE

var transition_target_a := Color.WHITE
var transition_target_b := Color.WHITE
var transition_target_comet := Color.WHITE

var color_tween: Tween = null

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
	}
}

func _ready() -> void:
	Global.black_hole = self

	origin_position = get_viewport().get_visible_rect().size / 2.0
	origin_scale = scale

	audio_player = find_music_player()
	load_chart_data()

	apply_blackhole_index(blackhole_index)

func _process(delta: float) -> void:
	origin_position = get_viewport().get_visible_rect().size / 2.0

	t += delta

	var breath = sin(t * breathe_speed)
	var sway_x = sin(t * breathe_speed * 0.6) * float_amount
	var sway_y = cos(t * breathe_speed * 0.8) * float_amount

	scale = origin_scale * (1.0 + breath * breathe_amount)
	position = origin_position + Vector2(sway_x, sway_y)

	if blackhole_index == 30:
		update_chart_color()

	if color_tween != null and color_tween.is_valid():
		update_color_transition()

func find_music_player() -> AudioStreamPlayer:
	var music_node = get_tree().current_scene.find_child("Music", true, false)

	if music_node is AudioStreamPlayer:
		return music_node

	var audio_players = get_tree().get_nodes_in_group("music")

	for node in audio_players:
		if node is AudioStreamPlayer:
			return node

	return null

func load_chart_data() -> void:
	var chart_path = "res://Charts/song_chart.tres"

	if ResourceLoader.exists(chart_path):
		chart_data = load(chart_path)
	else:
		setup_fallback_data()

func setup_fallback_data() -> void:
	chart_data = {
		"intervals": [
			{"until": 22.2},
			{"until": 66.0},
			{"until": 90.0},
			{"until": 121.0},
			{"until": 138.0},
			{"until": 189.0},
			{"until": 200.0},
			{"until": 221.0},
			{"until": 244.0},
			{"until": 254.0},
			{"until": 266.0},
			{"until": 288.0},
			{"until": 300.0},
			{"until": 310.0},
			{"until": 322.0},
			{"until": 330.0}
		],
		"asteroid_types": [
			"Green",
			"Regular",
			"Yellow",
			"Regular",
			"Regular",
			"Green",
			"Yellow",
			"Red",
			"Red",
			"Regular",
			"Yellow",
			"Green",
			"Green",
			"Regular",
			"Yellow",
			"Red"
		]
	}

func get_asteroid_type_at_time(time: float) -> String:
	if chart_data == null:
		return "Regular"

	var intervals = chart_data.get("intervals", [])
	var asteroid_types = chart_data.get("asteroid_types", [])

	if intervals.is_empty() or asteroid_types.is_empty():
		return "Regular"

	var count = min(intervals.size(), asteroid_types.size())

	for i in range(count):
		var until = intervals[i].get("until", 0.0)

		if time <= until:
			return asteroid_types[i]

	return asteroid_types[count - 1]

func update_chart_color() -> void:
	if audio_player == null:
		return

	if not audio_player.playing:
		return

	var elapsed := audio_player.get_playback_position()
	var new_type := get_asteroid_type_at_time(elapsed)

	if new_type == current_asteroid_type:
		return

	current_asteroid_type = new_type

	var colors = get_chart_colors(new_type)

	start_color_transition(
		colors["color_a"],
		colors["color_b"],
		colors["comet_color"]
	)

func get_chart_colors(asteroid_type: String) -> Dictionary:
	match asteroid_type:
		"Green":
			return {
				"color_a": Color("00d02dff"),
				"color_b": Color("7dff5fff"),
				"comet_color": Color("42d047ff")
			}

		"Yellow":
			return {
				"color_a": Color("#ffe600"),
				"color_b": Color("#fff59d"),
				"comet_color": Color("#ffe600")
			}

		"Red":
			return {
				"color_a": Color("#ff1744"),
				"color_b": Color("#ff758f"),
				"comet_color": Color("#ff1744")
			}

		_:
			return {
				"color_a": Color("#ff6a00"),
				"color_b": Color("#ffb000"),
				"comet_color": Color("#ff6a00")
			}

func set_blackhole_index(index) -> void:
	blackhole_index = int(index)
	apply_blackhole_index(blackhole_index)

func apply_blackhole_index(index: int) -> void:
	if index == 30:
		apply_chart_blackhole()
		return

	if not variants.has(index):
		index = 1

	if color_tween != null and color_tween.is_valid():
		color_tween.kill()

	var variant = variants[index]

	breathe_speed = variant["breathe_speed"]
	breathe_amount = variant["breathe_amount"]

	scale = origin_scale * variant["size"]

	var color_a: Color = variant["color_a"]
	var color_b: Color = variant["color_b"]
	var comet_color: Color = variant["comet_color"]

	transition_start_a = color_a
	transition_start_b = color_b
	transition_start_comet = comet_color

	transition_target_a = color_a
	transition_target_b = color_b
	transition_target_comet = comet_color

	transition_progress = 1.0

	apply_disk_colors(color_a, color_b)
	update_glow_colors(color_a)
	update_comet_colors(comet_color)

func apply_chart_blackhole() -> void:
	var regular_variant = variants[1]

	breathe_speed = regular_variant["breathe_speed"]
	breathe_amount = regular_variant["breathe_amount"]

	scale = origin_scale * regular_variant["size"]

	current_asteroid_type = ""

	var asteroid_type := "Regular"

	if audio_player != null and audio_player.playing:
		asteroid_type = get_asteroid_type_at_time(
			audio_player.get_playback_position()
		)

	current_asteroid_type = asteroid_type

	var colors = get_chart_colors(asteroid_type)

	transition_start_a = colors["color_a"]
	transition_start_b = colors["color_b"]
	transition_start_comet = colors["comet_color"]

	transition_target_a = colors["color_a"]
	transition_target_b = colors["color_b"]
	transition_target_comet = colors["comet_color"]

	transition_progress = 1.0

	apply_disk_colors(
		colors["color_a"],
		colors["color_b"]
	)

	update_glow_colors(colors["color_a"])
	update_comet_colors(colors["comet_color"])

func start_color_transition(
	new_color_a: Color,
	new_color_b: Color,
	new_comet_color: Color
) -> void:
	if color_tween != null and color_tween.is_valid():
		var current_a = transition_start_a.lerp(
			transition_target_a,
			transition_progress
		)

		var current_b = transition_start_b.lerp(
			transition_target_b,
			transition_progress
		)

		var current_comet = transition_start_comet.lerp(
			transition_target_comet,
			transition_progress
		)

		transition_start_a = current_a
		transition_start_b = current_b
		transition_start_comet = current_comet

		color_tween.kill()
	else:
		transition_start_a = transition_target_a
		transition_start_b = transition_target_b
		transition_start_comet = transition_target_comet

	transition_target_a = new_color_a
	transition_target_b = new_color_b
	transition_target_comet = new_comet_color

	transition_progress = 0.0

	color_tween = create_tween()
	color_tween.set_trans(Tween.TRANS_SINE)
	color_tween.set_ease(Tween.EASE_IN_OUT)

	color_tween.tween_property(
		self,
		"transition_progress",
		1.0,
		COLOR_TRANSITION_TIME
	)

func update_color_transition() -> void:
	var color_a = transition_start_a.lerp(
		transition_target_a,
		transition_progress
	)

	var color_b = transition_start_b.lerp(
		transition_target_b,
		transition_progress
	)

	var comet_color = transition_start_comet.lerp(
		transition_target_comet,
		transition_progress
	)

	apply_disk_colors(color_a, color_b)
	update_glow_colors(color_a)
	update_comet_colors(comet_color)

func apply_disk_colors(color_a: Color, color_b: Color) -> void:
	var material = disk.process_material

	if material == null:
		return

	material = material.duplicate()

	var gradient = Gradient.new()

	gradient.colors = PackedColorArray([
		Color(color_a, 0.0),
		color_a,
		color_b,
		Color(color_b, 0.0)
	])

	gradient.offsets = PackedFloat32Array([
		0.0,
		0.3,
		0.7,
		1.0
	])

	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient

	material.color_ramp = gradient_texture
	disk.process_material = material

func update_glow_colors(base_color: Color) -> void:
	if glow0:
		glow0.modulate = Color(
			base_color.r,
			base_color.g,
			base_color.b,
			0.8
		)

	if glow1:
		glow1.modulate = Color(
			base_color.r,
			base_color.g,
			base_color.b,
			0.6
		)

	if glow2:
		glow2.modulate = Color(
			base_color.r,
			base_color.g,
			base_color.b,
			0.4
		)

	if glow3:
		glow3.modulate = Color(
			base_color.r,
			base_color.g,
			base_color.b,
			0.2
		)

func update_comet_colors(comet_color: Color) -> void:
	var comets = get_tree().get_nodes_in_group("comet")

	for comet in comets:
		if comet.has_method("set_comet_color"):
			comet.set_comet_color(comet_color)

func _on_neru_1_pressed() -> void:
	pass
