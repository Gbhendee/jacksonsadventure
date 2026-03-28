extends Node2D

func _ready():
	GameState.jump_unlocked = true
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].unlock_jump()
