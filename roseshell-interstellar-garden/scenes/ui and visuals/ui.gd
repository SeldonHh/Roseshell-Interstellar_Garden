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
			tween.tween_property(combo,"scale",Vector2(max(.3,.8+notes.combo*.03),max(.3,.8+notes.combo*.03)),.15)
			tween.tween_callback(
				func():
					var back_tween  = get_tree().create_tween()
					back_tween.tween_property(combo,"scale",Vector2(min(2,1.2+notes.combo*.03),min(2,1.2+notes.combo*.03)),.2)
					back_tween.tween_callback(
						func():
						var inception_tween  = get_tree().create_tween()
						inception_tween.tween_property(combo,"scale",Vector2(min(2.2,1+notes.combo*.09),min(2.2,1+notes.combo*.09)),.1)
					)
					)
		combo.text = "[wave amp=%s,freq=%s][shake rate=%s][rainbow freq=%s,sat=.6]Combo x%s"%[min(27,20+notes.combo*.5),min(10,5+notes.combo*.5),min(35,20+notes.combo),min(1.5,.6 + notes.combo*.05),notes.combo]
		previous_combo = notes.combo
	else:
		if combo_stable:
			combo_stable = false
			var tween = get_tree().create_tween()
			tween.tween_property(combo,"modulate",Color(1.0,1.0,1.0,0.0),.2)
