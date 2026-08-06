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
			tween.tween_property(combo,"modulate",Color(1.0,1.0,1.0,1.0),.2)
		if previous_combo != notes.combo:
			var tween  = get_tree().create_tween()
			tween.tween_property(combo,"scale",Vector2(.8,.8),.2)
			tween.tween_callback(
				func():
					var back_tween  = get_tree().create_tween()
					back_tween.tween_property(combo,"scale",Vector2(1.2,1.2),.2)
					back_tween.tween_callback(
						func():
						var inception_tween  = get_tree().create_tween()
						inception_tween.tween_property(combo,"scale",Vector2(1,1),.2)
					)
					)
		combo.text = "[wave][shake][rainbow freq=.7,sat=.6]Combo x%s"%notes.combo
		previous_combo = notes.combo
	else:
		if combo_stable:
			combo_stable = false
			var tween = get_tree().create_tween()
			tween.tween_property(combo,"modulate",Color(1.0,1.0,1.0,0.0),.2)
