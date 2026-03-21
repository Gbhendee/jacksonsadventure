extends "res://Scenes/Level1/TutorialNPC.gd"

func _on_Snickers_body_entered(body):
	show_dialog(body)
