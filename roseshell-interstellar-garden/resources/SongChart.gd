extends Resource
class_name SongChart

@export_category("identification")
@export var song_name := "Purple's first"

@export_category("parameters")
@export var song_file := preload("uid://tuhk64r4l4us")
@export var decibel_reduction := 10
@export var start_time := 3.9
@export var angles : Array[int]= [0, 180, 90, -90, 180]
	
@export var intervals : Array[Dictionary]= [
		{"until": 10.0, "interval": 1.333},
		{"until": 31.0, "interval": 0.66},
	]
@export var asteroid_types :Array[String]= ["Regular"]
## 1 = Orange 2 = Blue 3 = Purple 4 = Green 5 = Red 6 = Yellow 7 = Cyan 8 = Pink 9 = Lime 10 = White
@export var black_hole_index : int = 1
@export var dust_fog_index : int = 0
