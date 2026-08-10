extends Control

@onready var beginning: VBoxContainer = $Beginning
@onready var settings: Control = $Settings
@onready var credits: Control = $Credits
func _ready() -> void:
	Global.main_menu = self

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


func _on_sfx_volume_value_changed(value: float) -> void:
	Global.sfx_volume = value


func _on_music_volume_value_changed(value: float) -> void:
	Global.music_volume = value


func _on_menu_music_volume_value_changed(value: float) -> void:
	Global.menu_music_volume =value
