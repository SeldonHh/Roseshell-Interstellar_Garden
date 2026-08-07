extends Node2D

@onready var spawner = $"../Notes"
@onready var music = $"Music"

func _ready():
	music.volume_db = -10
	music.play()

	var start_time = 5.0
	var angles = [0, 180, 90, -90, 180]
	var beat_counter = 0
	var current_time = start_time
	
	var intervals = [
		{"until": 10.0, "interval": 1.356},
		{"until": 36.0, "interval": 0.678},
	]

	for i in range(36):
		for interval_data in intervals:
			if current_time < interval_data["until"]:
				current_time += interval_data["interval"]
				break
		
		var angle = angles[i % angles.size()]
		spawner.request_asteroid(current_time, deg_to_rad(angle))
