extends Area2D

func _ready():
	$Dialog.visible = false

func show_dialog(_body):
	$Dialog.visible = true
