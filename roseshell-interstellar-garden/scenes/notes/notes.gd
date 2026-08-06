extends Node2D

@onready var asteroid = $Asteroid
@onready var black_hole = $"../BlackHole"
@onready var player = $"../Player/body"
@onready var break_sound = $Break1
@onready var absorb_sound = $Absorb1

@export var spawn_interval: float = 2

@export var lifetime: float = 3.0

@export var sprite_scale_min: float = 6
@export var sprite_scale_max: float = 10

@export var revolutions: float = 0.3
@export var spiral_curve: float = 6.0

@export var final_suck_curve: float = 1.0

@export var player_hit_distance: float = 30.0
@export var bounce_distance: float = 300.0
@export var bounce_time: float = 0.5

var timer: float = 0.0
var combo: int = 0
var combo_active: bool = false

func _ready():
	randomize()
	asteroid.hide()

func _process(delta):
	timer += delta

	while timer >= spawn_interval:
		timer -= spawn_interval
		spawn_asteroid()

	for rock in get_children():
		if not rock is Node2D:
			continue

		if rock == asteroid:
			continue

		if rock.has_meta("consuming") or rock.has_meta("bouncing"):
			continue

		if rock.global_position.distance_to(player.global_position) <= player_hit_distance:
			rock.set_meta("bouncing", true)

			combo += 1
			combo_active = true
			print("Combo: x" + str(combo))

			break_sound.pitch_scale = randf_range(0.80, 1.15)
			break_sound.play()

			var away = (rock.global_position - player.global_position).normalized()

			for piece in rock.get_children():
				var direction = (piece.position + Vector2(
					randf_range(-20.0, 20.0),
					randf_range(-20.0, 20.0)
				)).normalized()

				var target = piece.position + direction * randf_range(80.0, 150.0)

				var tween = create_tween()
				tween.tween_property(piece, "position", target, bounce_time)
				tween.parallel().tween_property(piece, "rotation", randf_range(-3.0, 3.0), bounce_time)
				tween.parallel().tween_property(piece, "modulate:a", 0.0, bounce_time)

			var body_tween = create_tween()
			body_tween.tween_property(rock, "global_position", rock.global_position + away * bounce_distance, bounce_time)
			body_tween.tween_callback(rock.queue_free)

			continue

		var age: float = rock.get_meta("age")
		age += delta
		rock.set_meta("age", age)

		var t: float = clamp(age / lifetime, 0.0, 1.0)

		var start_radius: float = rock.get_meta("start_radius")
		var start_angle: float = rock.get_meta("start_angle")
		var spin: float = rock.get_meta("spin")

		var radius_progress: float

		if t < 0.75:
			radius_progress = pow(t / 0.75, spiral_curve) * 0.3
		else:
			var x: float = (t - 0.75) / 0.25
			radius_progress = 0.3 + 0.7 * pow(x, final_suck_curve)

		var radius: float = lerp(start_radius, 0.0, radius_progress)
		var angle: float = start_angle + spin * revolutions * TAU * t

		rock.global_position = black_hole.global_position + Vector2(cos(angle), sin(angle)) * radius
		rock.rotation += delta * 0.8

		if t >= 1.0:
			if combo_active:
				print("Combo broken")
				combo = 0
				combo_active = false

			rock.set_meta("consuming", true)

			absorb_sound.pitch_scale = randf_range(0.85, 1.15)
			absorb_sound.play()

			var tween = create_tween()
			tween.tween_property(rock, "global_position", black_hole.global_position, 0.12)
			tween.parallel().tween_property(rock, "scale", Vector2.ZERO, 0.12)
			tween.parallel().tween_property(rock, "modulate:a", 0.0, 0.12)
			tween.tween_callback(rock.queue_free)

func spawn_asteroid():
	var rock := Node2D.new()

	var colors = [
		Color(0.5, 0.55, 0.65),
		Color(0.6, 0.62, 0.68),
		Color(0.62, 0.55, 0.45),
		Color(0.55, 0.48, 0.38),
		Color(0.45, 0.52, 0.6)
	]

	var asteroid_color = colors[randi() % colors.size()]

	var size = randf_range(55.0, 90.0)
	var circles = randi_range(3, 6)

	for i in circles:
		var circle := Polygon2D.new()
		var points := PackedVector2Array()

		var radius = size * randf_range(0.7, 1.0)

		var offset := Vector2.ZERO

		if i > 0:
			offset = Vector2(
				randf_range(-size * 0.9, size * 0.9),
				randf_range(-size * 0.9, size * 0.9)
			)

		for p in 32:
			var angle = TAU * p / 32.0
			var wobble = randf_range(0.9, 1.1)
			points.append(offset + Vector2(cos(angle), sin(angle)) * radius * wobble)

		circle.polygon = points

		var shade = randf_range(0.75, 1.25)
		circle.color = Color(
			clamp(asteroid_color.r * shade, 0.0, 1.0),
			clamp(asteroid_color.g * shade, 0.0, 1.0),
			clamp(asteroid_color.b * shade, 0.0, 1.0)
		)

		circle.rotation = randf_range(0.0, TAU)
		rock.add_child(circle)

	var s: float = randf_range(0.28, 0.42)
	rock.scale = Vector2.ONE * s

	var view: Vector2 = get_viewport().get_visible_rect().size

	match randi() % 4:
		0:
			rock.global_position = Vector2(-40.0, randf_range(0.0, view.y))
		1:
			rock.global_position = Vector2(view.x + 40.0, randf_range(0.0, view.y))
		2:
			rock.global_position = Vector2(randf_range(0.0, view.x), -40.0)
		3:
			rock.global_position = Vector2(randf_range(0.0, view.x), view.y + 40.0)

	var offset: Vector2 = rock.global_position - black_hole.global_position

	rock.set_meta("age", 0.0)
	rock.set_meta("start_radius", offset.length())
	rock.set_meta("start_angle", offset.angle())
	rock.set_meta("spin", -1.0 if randf() < 0.5 else 1.0)

	rock.modulate.a = 0.0
	add_child(rock)

	var fade = create_tween()
	fade.tween_property(rock, "modulate:a", 1.0, 2)
