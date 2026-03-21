extends "res://Scenes/Level1/TutorialNPC.gd"

func _on_dialog_finished():
	._on_dialog_finished()
	var player = _get_player()
	if player:
		player.unlock_jump()

func _on_Snickers_body_entered(body):
	show_dialog(body)
