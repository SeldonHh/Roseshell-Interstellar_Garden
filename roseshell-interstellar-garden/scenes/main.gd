extends Control

@onready var beginning: VBoxContainer = $Beginning
@onready var settings: Control = $Settings
@onready var credits: Control = $Credits

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
