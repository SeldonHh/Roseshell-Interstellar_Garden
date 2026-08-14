@tool
extends Control

@onready var beginning: VBoxContainer = $Beginning
@onready var settings: Control = $Settings
@onready var credits: Control = $Credits
@onready var music_volume: HSlider = %music_volume
@onready var menu_music_volume: HSlider = %menu_music_volume
@onready var sfx_volume: HSlider = %sfx_volume
func _ready() -> void:
	if not Engine.is_editor_hint():
		Global.main_menu = self

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		visible = false
	
func show_settings():
	$"..".show()
	beginning.hide()
	credits.hide()
	settings.show()
	$Settings/back_to_menu.hide()

func hide_settings():
	$"..".hide()
	beginning.show()
	credits.hide()
	settings.hide()
	$Settings/back_to_menu.show()

func _on_play_pressed() -> void:
	hide()


func _on_settings_pressed() -> void:
	beginning.hide()
	credits.hide()
	settings.show()


func _on_credits_pressed() -> void:
	beginning.hide()
	credits.show()
	settings.hide()


func _on_back_to_menu_pressed() -> void:
	beginning.show()
	credits.hide()
	settings.hide()
	Global.save_game()

func _on_sfx_volume_value_changed(value: float) -> void:
	Global.sfx_volume = value


func _on_music_volume_value_changed(value: float) -> void:
	Global.music_volume = value


func _on_menu_music_volume_value_changed(value: float) -> void:
	Global.menu_music_volume =value
