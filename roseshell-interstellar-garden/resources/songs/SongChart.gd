extends Resource
class_name SongChart
signal updated

@export_category("level")
@export var song_name := "Last Singularity"
@export var cover : Texture2D = preload("uid://d1yh473tbni7g")
@export var cover_hover : Texture2D = preload("uid://bd0dk3uvwmg4f")
@export var highest_rank := "???"
@export var highest_percentage := 0
@export var difficulty := 0
@export var requirement : Array[SongChart] = []
@export var requirement_rank := "D"

@export_category("song parameters")
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

func update(rank,percentage):
	if Global.compare_rank(rank,highest_rank):
		highest_rank = rank
	if percentage > highest_percentage:
		highest_percentage = percentage
	updated.emit()

func give_difficulty_texture():
	match difficulty:
		0: return preload("uid://cpmntibk1vm2v")
		1: return preload("uid://fss7cymd6x56")
		2: return preload("uid://dxvli73licrwf")
		3: return preload("uid://dhgphx3rxxl0q")
		4: return preload("uid://ta3ujhyp83eb")
		5: return preload("uid://cb23en0mjepkn")
		6: return preload("uid://c6a8ayi7bpksu")
		7: return preload("uid://c1ekatypws4lo")
		8: return preload("uid://6t70wj3ydhke")
		9: return preload("uid://cqjnb0h6rwr4")
		10: return preload("uid://vn51ekf68dup")
		11: return preload("uid://dkwt6tl575c4n")
		12: return preload("uid://bjeffo36f00oo")
		13: return preload("uid://xrk1vqvvxngk")
		14: return preload("uid://b36lkkrflgn")
		15: return preload("uid://cxqswniciubbq")
		16: return preload("uid://d4j5ogly1ikx")

func give_level_text():
	var color = "#FFFFFF"
	match highest_rank:
		"D":color = "#007FD8"
		"C":color = "#00FF00"
		"B":color = "#EBEB00"
		"A":color = "#EA9700"
		"S":color = "#E40000"
		"SS":color = "#E40000"
		"P": color = "#F0A500"
	return "%s\n[color=%s]Rank:%s[/color]\nPercentage:%s%%"%[song_name,color,highest_rank,highest_percentage]
