extends Node2D

signal combo_break
signal combo_success
signal note_spawned 

@onready var asteroid = $Asteroid
@onready var black_hole = $"../BlackHole"
@onready var player = $"../Player/body"
@onready var break_sound = $Break1
@onready var absorb_sound = $Absorb1
@onready var bad_boom_sound = $BadBoom

@export var spawn_interval: float = 2
@export var lifetime: float = 3
@export var sprite_scale_min: float = 6
@export var sprite_scale_max: float = 7
@export var revolutions: float = 0.3
@export var spiral_curve: float = 6.0
@export var final_suck_curve: float = 1
@export var player_hit_distance: float = 50.0
@export var bounce_distance: float = 300.0
@export var bounce_time: float = 0.5
@export var sync_radius: float = 120.0
@export var green_final_suck_curve: float = 6

var timer: float = 0.0
var combo: int = 0
var combo_active: bool = false
var scheduled_asteroids: Array = []

func _ready():
	randomize()
	asteroid.hide()
	bad_boom_sound.volume_db = -3.0

func _process(delta):
	var i = scheduled_asteroids.size() - 1
	while i >= 0:
		var entry = scheduled_asteroids[i]
		entry["time"] -= delta
		if entry["time"] <= 0:
			spawn_asteroid(entry["angle"], entry["type"])
			scheduled_asteroids.remove_at(i)
		i -= 1

	for rock in get_children():
		if not rock is Node2D:
			continue
		if rock == asteroid:
			continue
		if rock.has_meta("consuming") or rock.has_meta("bouncing") or rock.has_meta("destroyed"):
			continue
		
		if not rock.has_meta("age"):
			continue
		
		var is_red = rock.has_meta("is_red") and rock.get_meta("is_red") == true
		var is_green = rock.has_meta("is_green") and rock.get_meta("is_green") == true
		
		if rock.global_position.distance_to(player.global_position) <= player_hit_distance:
			rock.set_meta("bouncing", true)
			rock.set_meta("destroyed", true)
			
			if is_red:
				combo = 0
				combo_active = false
				combo_break.emit()
				bad_boom_sound.pitch_scale = randf_range(0.80, 1.15)
				bad_boom_sound.play()
				
				var rock_scale = rock.scale.x
				var particle_count = int(12 * clamp(rock_scale / 0.35, 0.5, 2.0))
				var particle_size_mult = clamp(rock_scale / 0.35, 0.5, 2.0)
				
				for piece in rock.get_children():
					if piece is Polygon2D:
						var piece_global = rock.global_position + piece.position
						var piece_direction = (piece.position + Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))).normalized()
						var target = piece.position + piece_direction * randf_range(40.0, 80.0)
						
						var explosion_color = Color(0.9, 0.1, 0.05)
						spawn_dust(piece_global, explosion_color, particle_count, particle_size_mult * 1.5, piece_direction, target.length())
						spawn_dust(piece_global, Color(1.0, 0.6, 0.0), particle_count / 2, particle_size_mult * 0.8, piece_direction, target.length() * 0.7)
						
						var tween = create_tween()
						tween.tween_property(piece, "position", target, bounce_time)
						tween.parallel().tween_property(piece, "rotation", randf_range(-3.0, 3.0), bounce_time)
						tween.parallel().tween_property(piece, "modulate:a", 0.0, bounce_time)
				var body_tween = create_tween()
				body_tween.tween_property(rock, "global_position", rock.global_position + (rock.global_position - player.global_position).normalized() * bounce_distance * 0.3, bounce_time)
				body_tween.tween_callback(rock.queue_free)
			else:
				combo += 1
				if combo == 1:
					combo_active = true
				combo_success.emit()
				break_sound.pitch_scale = randf_range(0.80, 1.15)
				break_sound.play()
				var away = (rock.global_position - player.global_position).normalized()
				
				var rock_scale = rock.scale.x
				var particle_count = int(8 * clamp(rock_scale / 0.35, 0.5, 2.0))
				var particle_size_mult = clamp(rock_scale / 0.35, 0.5, 2.0)
				
				for piece in rock.get_children():
					if piece is Polygon2D:
						var piece_global = rock.global_position + piece.position
						var piece_direction = (piece.position + Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))).normalized()
						var target = piece.position + piece_direction * randf_range(40.0, 80.0)
						
						spawn_dust(piece_global, piece.color, particle_count, particle_size_mult, piece_direction, target.length())
						
						var tween = create_tween()
						tween.tween_property(piece, "position", target, bounce_time)
						tween.parallel().tween_property(piece, "rotation", randf_range(-3.0, 3.0), bounce_time)
						tween.parallel().tween_property(piece, "modulate:a", 0.0, bounce_time)
				var body_tween = create_tween()
				body_tween.tween_property(rock, "global_position", rock.global_position + away * bounce_distance * 0.5, bounce_time)
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
		
		if is_green:
			if t < 0.75:
				radius_progress = pow(t / 0.75, spiral_curve) * 0.3
			else:
				var x: float = (t - 0.75) / 0.25
				radius_progress = 0.3 + 0.7 * pow(x, green_final_suck_curve)
		else:
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
			rock.set_meta("consuming", true)
			
			if is_red:
				combo += 1
				if combo == 1:
					combo_active = true
				combo_success.emit()
				absorb_sound.pitch_scale = randf_range(0.85, 1.15)
				absorb_sound.play()
			else:
				if combo_active:
					combo = 0
					combo_active = false
				combo_break.emit()
			
			var tween = create_tween()
			tween.tween_property(rock, "global_position", black_hole.global_position, 0.12)
			tween.parallel().tween_property(rock, "scale", Vector2.ZERO, 0.12)
			tween.parallel().tween_property(rock, "modulate:a", 0.0, 0.12)
			tween.tween_callback(rock.queue_free)

func spawn_dust(pos: Vector2, color: Color, count: int, size_mult: float = 1.0, direction: Vector2 = Vector2.ZERO, distance: float = 60.0):
	for i in range(count):
		var dust = Polygon2D.new()
		var points := PackedVector2Array()
		var size = randf_range(1.5, 4.0) * size_mult
		var sides = randi_range(5, 8)
		for p in sides:
			var ang = TAU * p / sides
			var wobble = randf_range(0.7, 1.3)
			points.append(Vector2(cos(ang), sin(ang)) * size * wobble)
		dust.polygon = points
		var shade = randf_range(0.6, 1.4)
		dust.color = Color(
			clamp(color.r * shade, 0.0, 1.0),
			clamp(color.g * shade, 0.0, 1.0),
			clamp(color.b * shade, 0.0, 1.0),
			1.0
		)
		dust.global_position = pos + Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0)) * size_mult
		dust.rotation = randf_range(0.0, TAU)
		var start_scale = randf_range(0.4, 0.9) * size_mult
		dust.scale = Vector2.ONE * start_scale
		add_child(dust)
		
		var angle_offset = randf_range(-0.6, 0.6)
		var dir = direction.rotated(angle_offset)
		var dist = distance * randf_range(0.7, 1.3)
		var target = dust.global_position + dir * dist + Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0)) * size_mult * 0.3
		var duration = bounce_time * randf_range(0.7, 1.0)
		var end_scale = randf_range(1.5, 3.5) * size_mult
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(dust, "global_position", target, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(dust, "scale", Vector2.ONE * end_scale, duration * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(dust, "modulate:a", 0.0, duration * 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR).set_delay(duration * 0.2)
		tween.tween_property(dust, "rotation", dust.rotation + randf_range(-4.0, 4.0), duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		
		tween.tween_callback(dust.queue_free).set_delay(duration)

func request_asteroid(suck_time: float, angle: float = INF, type: String = "Regular"):
	var start_radius = 800.0
	var sync_ratio = 1.0 - (sync_radius / start_radius)
	var adjusted_lifetime = lifetime * sync_ratio
	var wait_time = suck_time - adjusted_lifetime
	if wait_time < 0:
		wait_time = 0
	scheduled_asteroids.append({"time": wait_time, "angle": angle, "type": type})

func spawn_asteroid(suck_angle: float = INF, type: String = "Regular"):
	var rock := Node2D.new()
	var colors = [Color(0.5, 0.55, 0.65), Color(0.6, 0.62, 0.68), Color(0.62, 0.55, 0.45), Color(0.55, 0.48, 0.38), Color(0.45, 0.52, 0.6)]
	var asteroid_color = colors[randi() % colors.size()]
	var is_red = false
	var is_green = false
	
	if type == "Red":
		is_red = true
		asteroid_color = Color(0.45, 0.48, 0.55)
	elif type == "Green":
		is_green = true
		asteroid_color = Color(0.45, 0.52, 0.45)
	
	rock.set_meta("is_red", is_red)
	rock.set_meta("is_green", is_green)
	
	var size = randf_range(55.0, 90.0)
	var circles = randi_range(3, 6)
	
	for i in circles:
		var circle := Polygon2D.new()
		var points := PackedVector2Array()
		var radius = size * randf_range(0.7, 1.0)
		@warning_ignore("confusable_local_declaration")
		var offset := Vector2.ZERO
		if i > 0:
			offset = Vector2(randf_range(-size * 0.9, size * 0.9), randf_range(-size * 0.9, size * 0.9))
		for p in 32:
			var ang = TAU * p / 32.0
			var wobble = randf_range(0.9, 1.1)
			points.append(offset + Vector2(cos(ang), sin(ang)) * radius * wobble)
		circle.polygon = points
		var shade = randf_range(0.75, 1.25)
		circle.color = Color(clamp(asteroid_color.r * shade, 0.0, 1.0), clamp(asteroid_color.g * shade, 0.0, 1.0), clamp(asteroid_color.b * shade, 0.0, 1.0))
		circle.rotation = randf_range(0.0, TAU)
		rock.add_child(circle)
		
		if is_red:
			var ore_count = randi_range(2, 4)
			for j in range(ore_count):
				var ore := Polygon2D.new()
				var points2 := PackedVector2Array()
				var ore_size = randf_range(14.0, 24.0)
				var sides = randi_range(4, 6)
				var ore_offset = Vector2(randf_range(-radius * 0.7, radius * 0.7), randf_range(-radius * 0.7, radius * 0.7)) + offset
				var test_dist = ore_offset.length()
				var max_dist = radius * 0.8
				if test_dist > max_dist:
					ore_offset = ore_offset.normalized() * max_dist
				for p in sides:
					var ang = TAU * p / sides
					var wobble = randf_range(0.7, 1.3)
					points2.append(ore_offset + Vector2(cos(ang), sin(ang)) * ore_size * wobble)
				ore.polygon = points2
				ore.color = Color(0.9, 0.1, 0.05, 1.0)
				ore.rotation = randf_range(0.0, TAU)
				rock.add_child(ore)
				rock.move_child(ore, -1)
		elif is_green:
			var ore_count = randi_range(2, 4)
			for j in range(ore_count):
				var ore := Polygon2D.new()
				var points2 := PackedVector2Array()
				var ore_size = randf_range(14.0, 24.0)
				var sides = randi_range(4, 6)
				var ore_offset = Vector2(randf_range(-radius * 0.7, radius * 0.7), randf_range(-radius * 0.7, radius * 0.7)) + offset
				var test_dist = ore_offset.length()
				var max_dist = radius * 0.8
				if test_dist > max_dist:
					ore_offset = ore_offset.normalized() * max_dist
				for p in sides:
					var ang = TAU * p / sides
					var wobble = randf_range(0.7, 1.3)
					points2.append(ore_offset + Vector2(cos(ang), sin(ang)) * ore_size * wobble)
				ore.polygon = points2
				ore.color = Color(0.1, 0.9, 0.05, 1.0)
				ore.rotation = randf_range(0.0, TAU)
				rock.add_child(ore)
				rock.move_child(ore, -1)
	
	var s: float = randf_range(0.28, 0.42)
	rock.scale = Vector2.ONE * s
	var view: Vector2 = get_viewport().get_visible_rect().size
	
	var spawn_pos = Vector2.ZERO
	var _final_angle = suck_angle
	
	if suck_angle == INF:
		match randi() % 4:
			0:
				spawn_pos = Vector2(-40.0, randf_range(0.0, view.y))
			1:
				spawn_pos = Vector2(view.x + 40.0, randf_range(0.0, view.y))
			2:
				spawn_pos = Vector2(randf_range(0.0, view.x), -40.0)
			3:
				spawn_pos = Vector2(randf_range(0.0, view.x), view.y + 40.0)
		_final_angle = (spawn_pos - black_hole.global_position).angle()
	else:
		var angle_deg = rad_to_deg(suck_angle)
		angle_deg = fmod(angle_deg, 360.0)
		if angle_deg < 0:
			angle_deg += 360.0
		
		if angle_deg >= 315.0 or angle_deg < 45.0:
			spawn_pos = Vector2(randf_range(0.0, view.x), -40.0)
		elif angle_deg >= 45.0 and angle_deg < 135.0:
			spawn_pos = Vector2(view.x + 40.0, randf_range(0.0, view.y))
		elif angle_deg >= 135.0 and angle_deg < 225.0:
			spawn_pos = Vector2(randf_range(0.0, view.x), view.y + 40.0)
		else:
			spawn_pos = Vector2(-40.0, randf_range(0.0, view.y))
		
		var distance = (spawn_pos - black_hole.global_position).length()
		var suck_dir = Vector2(cos(suck_angle), sin(suck_angle))
		spawn_pos = black_hole.global_position + suck_dir * distance
		_final_angle = suck_angle
	
	rock.global_position = spawn_pos
	
	var offset = rock.global_position - black_hole.global_position
	var spin = -1.0 if randf() < 0.5 else 1.0
	
	rock.set_meta("age", 0.0)
	rock.set_meta("start_radius", offset.length())
	rock.set_meta("spin", spin)
	
	if suck_angle == INF:
		rock.set_meta("start_angle", offset.angle())
	else:
		rock.set_meta("start_angle", suck_angle - (spin * revolutions * TAU))
	
	rock.modulate.a = 0.0
	add_child(rock)
	
	note_spawned.emit()
	
	var fade = create_tween()
	fade.tween_property(rock, "modulate:a", 1.0, 2)
