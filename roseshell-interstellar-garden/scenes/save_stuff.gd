extends Node
var tutorial_rank := "???"
var ohmy_rank := "???"
var cytoplasm_rank := "???"
var fallenempire_rank := "???"
var stickyeyes_rank := "???"
var stellarballad_rank := "???"
var spacetimerift_rank := "???"
var lastsingularity_rank := "???"
var Music_Volume = Global.music_volume
var Sfx_Volume = Global.sfx_volume
var Menu_Music_Volume = Global.menu_music_volume

func save():
	Music_Volume = Global.music_volume
	Sfx_Volume = Global.sfx_volume
	Menu_Music_Volume = Global.menu_music_volume
	for child in Global.ui.purple_s_advenure.get_children() + Global.ui.neru_s_kingdom.get_children():
		if child.has_meta("rank"):
			if child.has_meta("song"):
				match child.get_meta("song").song_name:
					"Tutorial":
						tutorial_rank = child.get_meta("rank")
					"Oh My!":
						ohmy_rank = child.get_meta("rank")
					"Cytoplasm":
						cytoplasm_rank = child.get_meta("rank")
					"Fallen Empire":
						fallenempire_rank = child.get_meta("rank")
					"Sticky Eyes":
						stickyeyes_rank = child.get_meta("rank")
					"Stellar ballad":
						stellarballad_rank = child.get_meta("rank")
					"Spacetime Rift":
						spacetimerift_rank = child.get_meta("rank")
					"Last Singularity":
						lastsingularity_rank = child.get_meta("rank")
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"Music_Volume":Music_Volume,
		"Sfx_Volume":Sfx_Volume,
		"Menu_Music_Volume":Menu_Music_Volume,
		"tutorial_rank": tutorial_rank,
		"ohmy_rank":ohmy_rank,
		"cytoplasm_rank":cytoplasm_rank,
		"fallenempire_rank":fallenempire_rank,
		"stickyeyes_rank":stickyeyes_rank,
		"stellarballad_rank":stellarballad_rank,
		"spacetimerift_rank":spacetimerift_rank,
		"lastsingularity_rank":lastsingularity_rank,
	}
	return save_dict


func assign_data():
	Global.music_volume = Music_Volume
	Global.sfx_volume = Sfx_Volume
	Global.menu_music_volume = Menu_Music_Volume
	Global.main_menu.music_volume.value = Music_Volume
	Global.main_menu.menu_music_volume.value = Menu_Music_Volume
	Global.main_menu.sfx_volume.value = Sfx_Volume
	Global.ui.tutorial.set_meta("rank",tutorial_rank)
	Global.ui.tutorial.get_child(0).text = "Tutorial\n[color=%s]Rank %s[/color]"%[give_color_by_rank(tutorial_rank),tutorial_rank]
	if tutorial_rank in ["D","C","B","A","S","SS","P"]:
		Global.ui.neru_1.disabled = false
		if Global.ui.neru_1.get_child(1) != null:
			Global.ui.neru_1.get_child(1).queue_free()
		Global.ui.neru_1.self_modulate = Color(1.0,1.0,1.0,1.0)
	match tutorial_rank:
		"D": Global.ui.tutorial.set_meta("percentage",10)
		"C": Global.ui.tutorial.set_meta("percentage",50)
		"B": Global.ui.tutorial.set_meta("percentage",75)
		"A": Global.ui.tutorial.set_meta("percentage",85)
		"S": Global.ui.tutorial.set_meta("percentage",92)
		"SS": Global.ui.tutorial.set_meta("percentage",97)
		"P": Global.ui.tutorial.set_meta("percentage",100)
	Global.ui.lvl_1.set_meta("rank",stellarballad_rank)
	Global.ui.lvl_1.get_child(0).text = "Stellar ballad\n[color=%s]Rank %s[/color]"%[give_color_by_rank(stellarballad_rank),stellarballad_rank]
	if stellarballad_rank in ["D","C","B","A","S","SS","P"]:
		Global.ui.lvl_2.disabled = false
		if Global.ui.lvl_2.get_child(1) != null:
			Global.ui.lvl_2.get_child(1).queue_free()
		Global.ui.lvl_2.self_modulate = Color(1.0,1.0,1.0,1.0)
	match stellarballad_rank:
		"D": Global.ui.lvl_1.set_meta("percentage",10)
		"C": Global.ui.lvl_1.set_meta("percentage",50)
		"B": Global.ui.lvl_1.set_meta("percentage",75)
		"A": Global.ui.lvl_1.set_meta("percentage",85)
		"S": Global.ui.lvl_1.set_meta("percentage",92)
		"SS": Global.ui.lvl_1.set_meta("percentage",97)
		"P": Global.ui.lvl_1.set_meta("percentage",100)
	Global.ui.lvl_2.set_meta("rank",spacetimerift_rank)
	Global.ui.lvl_2.get_child(0).text = "Spacetime Rift\n[color=%s]Rank %s[/color]"%[give_color_by_rank(spacetimerift_rank),spacetimerift_rank]
	if spacetimerift_rank in ["D","C","B","A","S","SS","P"]:
		Global.ui.lvl_3.disabled = false
		if Global.ui.lvl_3.get_child(1) != null:
			Global.ui.lvl_3.get_child(1).queue_free()
		Global.ui.lvl_3.self_modulate = Color(1.0,1.0,1.0,1.0)
	match spacetimerift_rank:
		"D": Global.ui.lvl_2.set_meta("percentage",10)
		"C": Global.ui.lvl_2.set_meta("percentage",50)
		"B": Global.ui.lvl_2.set_meta("percentage",75)
		"A": Global.ui.lvl_2.set_meta("percentage",85)
		"S": Global.ui.lvl_2.set_meta("percentage",92)
		"SS": Global.ui.lvl_2.set_meta("percentage",97)
		"P": Global.ui.lvl_2.set_meta("percentage",100)
	Global.ui.lvl_3.set_meta("rank",lastsingularity_rank)
	Global.ui.lvl_3.get_child(0).text = "Last Singularity\n[color=%s]Rank %s[/color]"%[give_color_by_rank(lastsingularity_rank),lastsingularity_rank]
	match lastsingularity_rank:
		"D": Global.ui.lvl_3.set_meta("percentage",10)
		"C": Global.ui.lvl_3.set_meta("percentage",50)
		"B": Global.ui.lvl_3.set_meta("percentage",75)
		"A": Global.ui.lvl_3.set_meta("percentage",85)
		"S": Global.ui.lvl_3.set_meta("percentage",92)
		"SS": Global.ui.lvl_3.set_meta("percentage",97)
		"P": Global.ui.lvl_3.set_meta("percentage",100)
	Global.ui.neru_1.set_meta("rank",ohmy_rank)
	Global.ui.neru_1.get_child(0).text = "Oh My!\n[color=%s]Rank %s[/color]"%[give_color_by_rank(ohmy_rank),ohmy_rank]
	if ohmy_rank in ["D","C","B","A","S","SS","P"]:
		Global.ui.neru_2.disabled = false
		if Global.ui.neru_2.get_child(1) != null:
			Global.ui.neru_2.get_child(1).queue_free()
		Global.ui.neru_2.self_modulate = Color(1.0,1.0,1.0,1.0)
	match ohmy_rank:
		"D": Global.ui.neru_1.set_meta("percentage",10)
		"C": Global.ui.neru_1.set_meta("percentage",50)
		"B": Global.ui.neru_1.set_meta("percentage",75)
		"A": Global.ui.neru_1.set_meta("percentage",85)
		"S": Global.ui.neru_1.set_meta("percentage",92)
		"SS": Global.ui.neru_1.set_meta("percentage",97)
		"P": Global.ui.neru_1.set_meta("percentage",100)
	Global.ui.neru_2.set_meta("rank",cytoplasm_rank)
	Global.ui.neru_2.get_child(0).text = "Cytoplasm\n[color=%s]Rank %s[/color]"%[give_color_by_rank(cytoplasm_rank),cytoplasm_rank]
	if cytoplasm_rank in ["D","C","B","A","S","SS","P"]:
		Global.ui.neru_3.disabled = false
		if Global.ui.neru_3.get_child(1) != null:
			Global.ui.neru_3.get_child(1).queue_free()
		Global.ui.neru_3.self_modulate = Color(1.0,1.0,1.0,1.0)
	match cytoplasm_rank:
		"D": Global.ui.neru_2.set_meta("percentage",10)
		"C": Global.ui.neru_2.set_meta("percentage",50)
		"B": Global.ui.neru_2.set_meta("percentage",75)
		"A": Global.ui.neru_2.set_meta("percentage",85)
		"S": Global.ui.neru_2.set_meta("percentage",92)
		"SS": Global.ui.neru_2.set_meta("percentage",97)
		"P": Global.ui.neru_2.set_meta("percentage",100)
	Global.ui.neru_3.set_meta("rank",fallenempire_rank)
	Global.ui.neru_3.get_child(0).text = "Fallen Empire\n[color=%s]Rank %s[/color]"%[give_color_by_rank(fallenempire_rank),fallenempire_rank]
	if fallenempire_rank in ["D","C","B","A","S","SS","P"]:
		Global.ui.neru_4.disabled = false
		if Global.ui.neru_4.get_child(1) != null:
			Global.ui.neru_4.get_child(1).queue_free()
		Global.ui.neru_4.self_modulate = Color(1.0,1.0,1.0,1.0)
	match fallenempire_rank:
		"D": Global.ui.neru_3.set_meta("percentage",10)
		"C": Global.ui.neru_3.set_meta("percentage",50)
		"B": Global.ui.neru_3.set_meta("percentage",75)
		"A": Global.ui.neru_3.set_meta("percentage",85)
		"S": Global.ui.neru_3.set_meta("percentage",92)
		"SS": Global.ui.neru_3.set_meta("percentage",97)
		"P": Global.ui.neru_3.set_meta("percentage",100)
	Global.ui.neru_4.set_meta("rank",stickyeyes_rank)
	Global.ui.neru_4.get_child(0).text = "Sticky Eyes\n[color=%s]Rank %s[/color]"%[give_color_by_rank(stickyeyes_rank),stickyeyes_rank]
	if stickyeyes_rank in ["D","C","B","A","S","SS","P"]:
		Global.ui.lvl_1.disabled = false
		if Global.ui.lvl_1.get_child(1) != null:
			Global.ui.lvl_1.get_child(1).queue_free()
		Global.ui.lvl_1.self_modulate = Color(1.0,1.0,1.0,1.0)
	match stickyeyes_rank:
		"D": Global.ui.neru_4.set_meta("percentage",10)
		"C": Global.ui.neru_4.set_meta("percentage",50)
		"B": Global.ui.neru_4.set_meta("percentage",75)
		"A": Global.ui.neru_4.set_meta("percentage",85)
		"S": Global.ui.neru_4.set_meta("percentage",92)
		"SS": Global.ui.neru_4.set_meta("percentage",97)
		"P": Global.ui.neru_4.set_meta("percentage",100)

func give_color_by_rank(rank):
	var color = "#FFFFFF"
	match rank:
		"D":color = "#007FD8"
		"C":color = "#00FF00"
		"B":color = "#EBEB00"
		"A":color = "#EA9700"
		"S":color = "#E40000"
		"SS":color = "#E40000"
		"P": color = "#F0A500"
	return color
