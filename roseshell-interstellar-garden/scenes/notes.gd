extends Node2D

@onready var asteroid = $Asteroid
@onready var black_hole = $"../BlackHole"
@onready var player = $"../Player/body"

@export var spawn_interval: float = 2

@export var lifetime: float = 3.0

@export var sprite_scale_min: float = 0.02
@export var sprite_scale_max: float = 0.05

@export var revolutions: float = 0.3
@export var spiral_curve: float = 6.0

@export var final_suck_curve: float = 1.0

@export var player_hit_distance: float = 30.0
@export var bounce_distance: float = 300.0
@export var bounce_time: float = 0.5

var timer: float = 0.0

func _ready():
	randomize()
	asteroid.hide()

func _process(delta):
	timer += delta

	while timer >= spawn_interval:
		timer -= spawn_interval
		spawn_asteroid()

	for rock in get_children():
		if rock == asteroid:
			continue

		if rock.has_meta("consuming") or rock.has_meta("bouncing"):
			continue

		if rock.global_position.distance_to(player.global_position) <= player_hit_distance:
			rock.set_meta("bouncing", true)

			var away = (rock.global_position - player.global_position).normalized()
			var target = rock.global_position + away * bounce_distance

			var tween = create_tween()
			tween.tween_property(rock, "global_position", target, bounce_time)
			tween.parallel().tween_property(rock, "scale", Vector2.ZERO, bounce_time)
			tween.parallel().tween_property(rock, "modulate:a", 0.0, bounce_time)
			tween.tween_callback(rock.queue_free)

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
		rock.rotation = angle + PI * 0.5

		if t >= 1.0:
			rock.set_meta("consuming", true)

			var tween = create_tween()
			tween.tween_property(rock, "global_position", black_hole.global_position, 0.12)
			tween.parallel().tween_property(rock, "scale", Vector2.ZERO, 0.12)
			tween.parallel().tween_property(rock, "modulate:a", 0.0, 0.12)
			tween.tween_callback(rock.queue_free)

func spawn_asteroid():
	var rock: Sprite2D = asteroid.duplicate()
	rock.show()
	rock.modulate.a = 1.0

	var s: float = randf_range(sprite_scale_min, sprite_scale_max)
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

	add_child(rock)
