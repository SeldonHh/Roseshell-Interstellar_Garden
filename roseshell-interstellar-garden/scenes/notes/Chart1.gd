extends Node2D

@onready var spawner = $"../Notes"
@onready var music = $"Music"

func _ready():
	music.volume_db = -10
	music.play()

	var start_time = 3.9
	var angles = [0, 180, 90, -90, 180]
	var beat_counter = 0
	var current_time = start_time
	
	var intervals = [
		{"until": 10.0, "interval": 1.333},
		{"until": 31.0, "interval": 0.66},
	]

	var time = start_time
	var note_index = 0
	
	while time < intervals[-1]["until"]:
		var interval = 1
		for interval_data in intervals:
			if time < interval_data["until"]:
				interval = interval_data["interval"]
				break
		
		time += interval
		var angle = angles[note_index % angles.size()]
		spawner.request_asteroid(time, deg_to_rad(angle))
		note_index += 1
