extends "res://Scenes/Level1/TutorialNPC.gd"

func _on_tutorial_complete():
	pass

func _on_SnickersCliff_body_entered(body):
	show_dialog(body)
