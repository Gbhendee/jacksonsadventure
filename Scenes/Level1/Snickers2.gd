extends Area2D


func _ready():
	$Dialog.visible = false


func _on_Snickers2_body_entered(body):
	$Dialog.visible = true
