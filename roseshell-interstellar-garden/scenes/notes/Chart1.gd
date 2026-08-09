extends Node2D

signal song_ended

@onready var spawner = $"../Notes"
@onready var music = $"Music"
@export var song := preload("uid://bj4l508i6ovjs")

func play_song():
	music.volume_db = 1.0
	music.volume_db -= song.decibel_reduction
	music.stream = song.song_file
	music.play()
	
	if Global.black_hole:
		Global.black_hole.set_blackhole_index(song.black_hole_index)

	var start_time = song.start_time
	var angles = song.angles
	var intervals = song.intervals
	var asteroid_types = song.asteroid_types
	
	var time = start_time
	var note_index = 0
	var interval_index = 0
	
	while time < intervals[-1]["until"]:
		var interval = 1
		for i in range(intervals.size()):
			if time < intervals[i]["until"]:
				interval = intervals[i]["interval"]
				interval_index = i
				break
		
		time += interval
		var angle = angles[note_index % angles.size()]
		var type = asteroid_types[interval_index % asteroid_types.size()]
		spawner.request_asteroid(time, deg_to_rad(angle), type)
		note_index += 1
	
	await get_tree().create_timer(intervals[-1]["until"] + 2).timeout
	music_ended()

func music_ended():
	song_ended.emit()
