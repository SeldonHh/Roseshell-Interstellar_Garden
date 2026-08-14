extends Node2D

var dust_fog_index: int = 0
var transparency_multiplier: float = 0.3
var chart_data = null
var current_asteroid_type: String = ""
var is_dust_index_10: bool = false
var audio_player: AudioStreamPlayer = null

var color_tween: Tween = null
var active_gradient: Gradient = null
var target_colors: Array[Color] = []
var transition_progress: float = 1.0

const COLOR_TRANSITION_TIME := 3.3

@onready var fog_particles = $FogParticles

func _ready():
	load_chart_data()
	audio_player = find_music_player()

func _process(_delta):
	if color_tween == null or not color_tween.is_valid():
		return

	if active_gradient == null or target_colors.is_empty():
		return

	var current_colors = active_gradient.colors

	for i in range(min(current_colors.size(), target_colors.size())):
		var start_color = current_colors[i]
		var target_color = target_colors[i]
		active_gradient.set_color(
			i,
			start_color.lerp(target_color, transition_progress)
		)

func _physics_process(_delta):
	if not is_dust_index_10:
		return

	if chart_data == null:
		return

	if audio_player == null:
		return

	if not audio_player.playing:
		return

	var elapsed := audio_player.get_playback_position()
	var new_type := get_asteroid_type_at_time(elapsed)

	if new_type != current_asteroid_type:
		current_asteroid_type = new_type
		apply_asteroid_color(new_type, true)

func find_music_player() -> AudioStreamPlayer:
	var music_node = get_tree().current_scene.find_child("Music", true, false)

	if music_node is AudioStreamPlayer:
		return music_node

	var audio_players = get_tree().get_nodes_in_group("music")

	for node in audio_players:
		if node is AudioStreamPlayer:
			return node

	return null

func set_dust_fog_index(value: int):
	dust_fog_index = value
	is_dust_index_10 = (dust_fog_index == 10)

	if (dust_fog_index >= 1 and dust_fog_index <= 5) or is_dust_index_10:
		fog_particles.visible = true
		fog_particles.emitting = true

		if is_dust_index_10:
			current_asteroid_type = ""

			if audio_player != null and audio_player.playing:
				var elapsed := audio_player.get_playback_position()
				var asteroid_type := get_asteroid_type_at_time(elapsed)

				current_asteroid_type = asteroid_type
				apply_asteroid_color(asteroid_type, false)
			else:
				apply_asteroid_color("Regular", false)
		else:
			current_asteroid_type = ""
			apply_original_color(dust_fog_index)
	else:
		fog_particles.visible = false
		fog_particles.emitting = false

func load_chart_data():
	setup_fallback_data()

func setup_fallback_data():
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
			"Regular",
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

func get_asteroid_colors(asteroid_type: String) -> Array[Color]:
	var alpha_mult = transparency_multiplier

	match asteroid_type:
		"Regular":
			return [
				Color(0.2, 0.05, 0.0, 0.0),
				Color(1.0, 0.5, 0.0, 0.8 * alpha_mult),
				Color(1.0, 0.7, 0.0, 1.0 * alpha_mult),
				Color(0.8, 0.4, 0.0, 0.9 * alpha_mult),
				Color(0.5, 0.2, 0.0, 0.6 * alpha_mult),
				Color(0.2, 0.05, 0.0, 0.0)
			]

		"Green":
			return [
				Color(0.0, 0.2, 0.0, 0.0),
				Color(0.0, 1.0, 0.0, 0.8 * alpha_mult),
				Color(0.2, 1.0, 0.0, 1.0 * alpha_mult),
				Color(0.0, 0.9, 0.0, 0.9 * alpha_mult),
				Color(0.0, 0.6, 0.0, 0.6 * alpha_mult),
				Color(0.0, 0.2, 0.0, 0.0)
			]

		"Yellow":
			return [
				Color(0.2, 0.15, 0.0, 0.0),
				Color(1.0, 0.9, 0.0, 0.8 * alpha_mult),
				Color(1.0, 1.0, 0.0, 1.0 * alpha_mult),
				Color(0.8, 0.8, 0.0, 0.9 * alpha_mult),
				Color(0.6, 0.6, 0.0, 0.6 * alpha_mult),
				Color(0.2, 0.15, 0.0, 0.0)
			]

		"Red":
			return [
				Color(0.2, 0.0, 0.0, 0.0),
				Color(0.9, 0.0, 0.0, 0.8 * alpha_mult),
				Color(1.0, 0.0, 0.0, 1.0 * alpha_mult),
				Color(0.8, 0.0, 0.0, 0.9 * alpha_mult),
				Color(0.5, 0.0, 0.0, 0.6 * alpha_mult),
				Color(0.2, 0.0, 0.0, 0.0)
			]

		_:
			return [
				Color(0.2, 0.05, 0.0, 0.0),
				Color(1.0, 0.5, 0.0, 0.8 * alpha_mult),
				Color(1.0, 0.7, 0.0, 1.0 * alpha_mult),
				Color(0.8, 0.4, 0.0, 0.9 * alpha_mult),
				Color(0.5, 0.2, 0.0, 0.6 * alpha_mult),
				Color(0.2, 0.05, 0.0, 0.0)
			]

func apply_asteroid_color(asteroid_type: String, smooth: bool = true):
	var proc_material = fog_particles.process_material

	if proc_material == null:
		return

	var colors = get_asteroid_colors(asteroid_type)

	if active_gradient == null:
		active_gradient = Gradient.new()
		active_gradient.colors = colors
		active_gradient.offsets = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]

		var gradient_texture = GradientTexture1D.new()
		gradient_texture.gradient = active_gradient

		proc_material.color_ramp = gradient_texture
		fog_particles.process_material = proc_material

		target_colors = colors
		transition_progress = 1.0
		return

	if not smooth:
		if color_tween != null and color_tween.is_valid():
			color_tween.kill()

		active_gradient.colors = colors
		target_colors = colors
		transition_progress = 1.0
		return

	if color_tween != null and color_tween.is_valid():
		color_tween.kill()

	var starting_colors: Array[Color] = []

	for color in active_gradient.colors:
		starting_colors.append(color)

	target_colors = colors
	transition_progress = 0.0

	color_tween = create_tween()
	color_tween.set_trans(Tween.TRANS_SINE)
	color_tween.set_ease(Tween.EASE_IN_OUT)
	color_tween.tween_property(self, "transition_progress", 1.0, COLOR_TRANSITION_TIME)

	color_tween.finished.connect(func():
		if active_gradient != null:
			active_gradient.colors = target_colors
		transition_progress = 1.0
	)

func apply_original_color(index: int):
	var proc_material = fog_particles.process_material

	if proc_material == null:
		return

	if color_tween != null and color_tween.is_valid():
		color_tween.kill()

	var gradient = Gradient.new()
	var alpha_mult = transparency_multiplier

	match index:
		1:
			gradient.colors = [
				Color(0.0, 0.8, 0.0, 0.0),
				Color(0.68, 0.829, 0.638, 0.8 * alpha_mult),
				Color(0.441, 0.664, 0.149, 1.0 * alpha_mult),
				Color(0.8, 0.9, 0.1, 0.8 * alpha_mult),
				Color(0.6, 0.8, 0.9, 0.6 * alpha_mult),
				Color(0.0, 0.5, 0.8, 0.0)
			]

		2:
			gradient.colors = [
				Color(0.8, 0.0, 0.4, 0.0),
				Color(1.0, 0.2, 0.6, 0.8 * alpha_mult),
				Color(0.983, 0.358, 0.79, 1.0 * alpha_mult),
				Color(0.638, 0.146, 0.851, 0.9 * alpha_mult),
				Color(0.5, 0.0, 0.8, 0.6 * alpha_mult),
				Color(0.3, 0.0, 0.6, 0.0)
			]

		3:
			gradient.colors = [
				Color(0.0, 0.3, 0.8, 0.0),
				Color(0.0, 0.6, 1.0, 0.8 * alpha_mult),
				Color(0.0, 0.8, 1.0, 1.0 * alpha_mult),
				Color(0.3, 0.9, 1.0, 0.9 * alpha_mult),
				Color(0.8, 0.9, 1.0, 0.6 * alpha_mult),
				Color(0.9, 0.9, 1.0, 0.0)
			]

		4:
			gradient.colors = [
				Color(0.8, 0.2, 0.0, 0.0),
				Color(1.0, 0.3, 0.0, 0.8 * alpha_mult),
				Color(1.0, 0.5, 0.0, 1.0 * alpha_mult),
				Color(1.0, 0.7, 0.1, 0.9 * alpha_mult),
				Color(0.9, 0.8, 0.2, 0.6 * alpha_mult),
				Color(0.8, 0.7, 0.1, 0.0)
			]

		5:
			gradient.colors = [
				Color(0.1, 0.0, 0.2, 0.0),
				Color(0.3, 0.0, 0.5, 0.8 * alpha_mult),
				Color(0.5, 0.0, 0.7, 1.0 * alpha_mult),
				Color(0.7, 0.1, 0.9, 0.9 * alpha_mult),
				Color(0.5, 0.0, 0.6, 0.6 * alpha_mult),
				Color(0.2, 0.0, 0.3, 0.0)
			]

	gradient.offsets = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]

	active_gradient = gradient

	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = active_gradient

	proc_material.color_ramp = gradient_texture
	fog_particles.process_material = proc_material
