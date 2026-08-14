extends Node

var songs_dict := {} 
var Music_Volume = Global.music_volume
var Sfx_Volume = Global.sfx_volume
var Menu_Music_Volume = Global.menu_music_volume
var Blackhole_Disables_Player = Global.center_black_hole_disabling_player

func save():
	Music_Volume = Global.music_volume
	Sfx_Volume = Global.sfx_volume
	Menu_Music_Volume = Global.menu_music_volume
	Blackhole_Disables_Player = Global.center_black_hole_disabling_player
	for song_resource in Global.song_resources:
		songs_dict[song_resource.song_name] = [song_resource.highest_rank,song_resource.highest_percentage]
	var save_dict = {
			"filename" : get_scene_file_path(),
			"parent" : get_parent().get_path(),
			"Music_Volume":Music_Volume,
			"Sfx_Volume":Sfx_Volume,
			"Menu_Music_Volume":Menu_Music_Volume,
			"Blackhole_Disables_Player": Blackhole_Disables_Player,
			"songs_dict" : songs_dict,
		}
	return save_dict

func assign_data():
	Global.music_volume = Music_Volume
	Global.sfx_volume = Sfx_Volume
	Global.menu_music_volume = Menu_Music_Volume
	Global.main_menu.music_volume.value = Music_Volume
	Global.main_menu.menu_music_volume.value = Menu_Music_Volume
	Global.main_menu.sfx_volume.value = Sfx_Volume
	Global.center_black_hole_disabling_player = Blackhole_Disables_Player
	Global.main_menu.black_hole_disable_player.button_pressed = Blackhole_Disables_Player
	for song_key in songs_dict.keys():
		for song_resource in Global.song_resources:
			if song_key == song_resource.song_name:
				song_resource.highest_percentage = songs_dict[song_key][1]
				song_resource.highest_rank = songs_dict[song_key][0]
