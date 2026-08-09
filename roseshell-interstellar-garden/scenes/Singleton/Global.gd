extends Node

var player : Node2D
var black_hole : Node2D
var keyboard := false
@onready var IS_DEBUG = "debug" in OS.get_cmdline_args()
