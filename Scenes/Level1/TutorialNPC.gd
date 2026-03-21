extends Area2D

var dialog_played := false

func _ready():
	$Dialog.visible = false
	$Dialog.connect("tree_exiting", self, "_on_dialog_finished")

func _on_dialog_finished():
	dialog_played = true
	var player = _get_player()
	if player:
		player.unfreeze()

func _get_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null

func show_dialog(body):
	if dialog_played:
		return
	if not is_instance_valid($Dialog):
		return
	var player = _get_player()
	if player:
		player.freeze()
	$Dialog.visible = true
	$Dialog.nextPhrase()
