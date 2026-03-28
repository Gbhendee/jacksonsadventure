extends Area2D

var _transitioning = false

func _on_LevelEnd_body_entered(body):
	if _transitioning or not body.is_in_group("player"):
		return
	_transitioning = true
	_fade_and_transition()

func _fade_and_transition():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	get_tree().root.add_child(canvas_layer)

	var rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.rect_min_size = Vector2(1600, 768)
	canvas_layer.add_child(rect)

	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(rect, "color:a", 0.0, 1.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")

	call_deferred("_do_change")

func _do_change():
	get_tree().change_scene("res://Scenes/Level2/Level2.tscn")
