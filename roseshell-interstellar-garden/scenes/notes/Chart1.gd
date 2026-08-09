extends Node2D

signal song_ended

@onready var spawner = $"../Notes"
@onready var music = $"Music"
@onready var dust_fogs = $"../DustFogs"
@export var song := preload("uid://bj4l508i6ovjs")

func play_song():
	music.volume_db = 1.0 - song.decibel_reduction
	music.stream = song.song_file
	music.play()
	
	if Global.black_hole:
		Global.black_hole.set_blackhole_index(song.black_hole_index)
	
	if dust_fogs:
		dust_fogs.set_dust_fog_index(song.dust_fog_index)
	else:
		print("DustFogs node not found!")

	var start_time = song.start_time
	var angles = song.angles
	var intervals = song.intervals
	var asteroid_types = song.asteroid_types
	
	var time = start_time
	var note_index = 0
	var interval_index = 0
	var music_duration = song.song_file.get_length()
	var max_until = intervals[-1]["until"] if intervals.size() > 0 else music_duration
	var last_interval = intervals[-1]["interval"] if intervals.size() > 0 else 1.0
	
	while time < music_duration and time < max_until + last_interval:
		var interval = last_interval
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
	
	await music.finished
	music_ended()

func music_ended():
	song_ended.emit()
