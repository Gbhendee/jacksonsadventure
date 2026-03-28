extends Area2D

var _entered = false

func _on_LevelEnd_body_entered(body):
	if _entered or not body.is_in_group("player"):
		return
	_entered = true
	print("Level 3 complete — Level 4 TBD")
