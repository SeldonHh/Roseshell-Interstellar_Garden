extends CanvasLayer

@onready var combo: RichTextLabel = $combo
@onready var notes: Node2D = $"../Notes"

var combo_stable := false
var previous_combo := 0

func _process(_delta: float) -> void:
	if notes.combo > 0:
		if !combo_stable:
			combo_stable = true
			var tween = get_tree().create_tween()
			tween.tween_property(combo, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

		if previous_combo != notes.combo:
			var tween = get_tree().create_tween()
			tween.tween_property(combo, "scale", Vector2(1.3, 1.3), 0.08)
			tween.tween_callback(
				func():
					var back_tween = get_tree().create_tween()
					back_tween.tween_property(combo, "scale", Vector2.ONE, 0.12)
			)

		var shake_rate := 0
		var shake_level := 0

		if notes.combo >= 6:
			shake_rate = min(120, 18 + notes.combo * 4)
			shake_level = min(18, int(notes.combo * 0.6))

		if notes.combo <= 5:
			combo.text = "[center][color=#FFFFFF]COMBO x%s[/color][/center]" % notes.combo
		elif notes.combo <= 10:
			combo.text = "[center][color=#FF0000][shake rate=%d level=%d]COMBO x%s[/shake][/color][/center]" % [
				shake_rate,
				shake_level,
				notes.combo
			]
		elif notes.combo <= 29:
			combo.text = "[center][color=#8000FF][shake rate=%d level=%d]COMBO x%s[/shake][/color][/center]" % [
				shake_rate,
				shake_level,
				notes.combo
			]
		else:
			combo.text = "[center][rainbow freq=0.35 sat=1.0][shake rate=%d level=%d]COMBO x%s[/shake][/rainbow][/center]" % [
				shake_rate,
				shake_level,
				notes.combo
			]

		previous_combo = notes.combo
	else:
		if combo_stable:
			combo_stable = false
			var tween = get_tree().create_tween()
			tween.tween_property(combo, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2)
			previous_combo = 0
			combo.scale = Vector2.ONE
