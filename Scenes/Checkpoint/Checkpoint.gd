extends Area2D

# optional “setget” keyword = set_func[, get_func]
export (bool) var is_active := false setget set_active

func set_active(new_value):
	is_active = new_value

	if is_active:
		$AnimatedSprite.play("activating")
	else:
		# second arg is an optional “play backwards” flag	$AnimatedSprite.play("activating", true)
		$AnimatedSprite.play("activating", true)

func _on_Checkpoint_body_entered(body):
	if body.has_method("update_checkpoint"):
		body.update_checkpoint(self)

func _on_AnimatedSprite_animation_finished():
	if is_active:
		$AnimatedSprite.play("active")
	else:
		$AnimatedSprite.play("idle")
