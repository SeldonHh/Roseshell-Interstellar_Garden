extends Node

var player : Node2D
var black_hole : Node2D
var keyboard := false
@onready var IS_DEBUG = "debug" in OS.get_cmdline_args() 
var main_menu : Control
var sfx_volume := .9
var music_volume := .9
var menu_music_volume := .7
var song_music : AudioStreamPlayer
var ui : CanvasLayer
var music_control : Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if song_music.playing or get_tree().paused == true:
			get_tree().paused = !get_tree().paused
			if get_tree().paused == true:
				main_menu.show()
				main_menu.show_settings()
			else:
				save_game()
				main_menu.hide()
				main_menu.hide_settings()

func _ready() -> void:
	await get_tree().create_timer(.1).timeout
	load_game()

##return true if rank1 is superior to rank 2, i rank1 is equal to rank 2 return true
func compare_rank(rank1 : String,rank2:String):
	if rank1 not in ["???","F","D","C","B","A","S","SS","P"] or rank2 not in ["???","F","D","C","B","A","S","SS","P"]:
		print("ERROR, rank is not the write format")
		return false
	match rank1:
		"???": return false
		"F": return rank2 == "???"
		"D": return rank2 in ["???","F","D"]
		"C": return rank2 in ["???","F","D","C"]
		"B": return rank2 in ["???","F","D","C","B"]
		"A": return rank2 in ["???","F","D","C","B","A"]
		"S": return rank2 in ["???","F","D","C","B","A","S"]
		"SS": return rank2 in ["???","F","D","C","B","A","S","SS"]
		"P": return true


func save_game():
	return
	@warning_ignore("unreachable_code")
	if OS.get_name() == "Web":
		return
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)




func load_game():
	return
	@warning_ignore("unreachable_code")
	if OS.get_name() == "Web":
		return
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent":
				continue
			new_object.set(i, node_data[i])
		new_object.assign_data()
