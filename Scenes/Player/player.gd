extends KinematicBody2D

var velocity = Vector2.ZERO
onready var move_speed : float = 130 * scale.x
onready var crawl_speed: float = 70 * scale.x

const GRAVITY = 25
const JUMP_FORCE := 400

var frozen := false
var jump_unlocked := false
var crouch_unlocked := false

func _ready():
	add_to_group("player")

func freeze():
	frozen = true
	velocity.x = 0

func unfreeze():
	frozen = false

func unlock_jump():
	jump_unlocked = true

func unlock_crouch():
	crouch_unlocked = true

func _physics_process(delta):
	if frozen:
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, Vector2.UP)
		$AnimatedSprite.play("idle")
		return

	var move_left = Input.get_action_strength("ui_left")
	var move_right = Input.get_action_strength("ui_right")
	var crouching = Input.get_action_strength("ui_down") if crouch_unlocked else 0.0

	if crouching > 0:
		velocity.x = (move_right - move_left) * crawl_speed
	else:
		velocity.x = (move_right - move_left) * move_speed

	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector2.UP)

	if crouching > 0:
		$CollisionShape2D.shape.extents = Vector2(3, 6)
	else:
		$CollisionShape2D.shape.extents = Vector2(5, 6)

	if move_left > 0:
		$AnimatedSprite.flip_h = true
	elif move_right > 0:
		$AnimatedSprite.flip_h = false

	if velocity.y < 0:
		$AnimatedSprite.play("jump")
	elif velocity.y > 0:
		$AnimatedSprite.play("fall")
	elif velocity.x != 0 and crouching > 0:
		$AnimatedSprite.play("crawl")
	elif velocity.x != 0:
		$AnimatedSprite.play("run")
	elif crouching > 0:
		$AnimatedSprite.play("crouch")
	else:
		$AnimatedSprite.play("idle")


func _input(event):
	if frozen:
		return
	if event.is_action_pressed("ui_accept") and is_on_floor() and jump_unlocked:
		velocity.y -= JUMP_FORCE



var respawn_checkpoint_node_ref : Node2D

func update_checkpoint(new_checkpoint: Node2D):
	if respawn_checkpoint_node_ref == new_checkpoint:
		return
	if respawn_checkpoint_node_ref != null:
		respawn_checkpoint_node_ref.set_active(false)

	respawn_checkpoint_node_ref = new_checkpoint
	respawn_checkpoint_node_ref.set_active(true)
