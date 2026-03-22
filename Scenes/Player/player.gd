extends KinematicBody2D

var velocity = Vector2.ZERO
onready var move_speed : float = 130 * scale.x
onready var crawl_speed: float = 70 * scale.x

const GRAVITY = 25
const JUMP_FORCE := 400
const DASH_SPEED := 280.0
const DASH_DURATION := 0.2
const DASH_COOLDOWN := 1.0

var frozen := false
var jump_unlocked := false
var crouch_unlocked := false
var dash_unlocked := false
var ledge_grab_unlocked := false
var wall_climb_unlocked := false

# Landing animation state
var was_airborne := false
var landing := false

# Dash state
var dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 1

# Wall climb state
var wall_climbing := false

# Ledge grab state
var ledge_grabbing := false

func _ready():
	add_to_group("player")
	$AnimatedSprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "land":
		landing = false

func freeze():
	frozen = true
	velocity.x = 0

func unfreeze():
	frozen = false

func unlock_jump():
	jump_unlocked = true

func unlock_crouch():
	crouch_unlocked = true

func unlock_dash():
	dash_unlocked = true

func unlock_ledge_grab():
	ledge_grab_unlocked = true

func unlock_wall_climb():
	wall_climb_unlocked = true

func _physics_process(delta):
	if frozen:
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, Vector2.UP)
		$AnimatedSprite.play("idle")
		was_airborne = false
		landing = false
		return

	var move_left = Input.get_action_strength("ui_left")
	var move_right = Input.get_action_strength("ui_right")
	var crouching = Input.get_action_strength("ui_down") if crouch_unlocked else 0.0

	# Dash timers
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false

	if dashing:
		velocity.x = dash_direction * DASH_SPEED
	elif crouching > 0:
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

	# Landing detection: transitioned from airborne to on-floor
	if was_airborne and is_on_floor():
		landing = true
		$AnimatedSprite.play("land")
	elif landing and not is_on_floor():
		# Safety: player walked off an edge mid-land-animation — don't stay stuck
		landing = false

	# Wall climb and ledge grab stubs
	_handle_wall_climb(move_left, move_right)
	_handle_ledge_grab()

	# Animation selection — always runs every frame, no early returns
	if dashing:
		$AnimatedSprite.play("dash")
	elif landing:
		pass  # land animation is playing; don't interrupt it
	elif ledge_grabbing:
		$AnimatedSprite.play("ledge_grab")
	elif wall_climbing:
		$AnimatedSprite.play("wall_climb")
	elif velocity.y < 0:
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

	# Keep was_airborne false while landing to prevent re-triggering the animation
	if landing:
		was_airborne = false
	else:
		was_airborne = not is_on_floor()


func _handle_wall_climb(move_left, move_right):
	if not wall_climb_unlocked:
		wall_climbing = false
		return
	if is_on_floor() or not is_on_wall():
		wall_climbing = false
		return
	var toward_wall = (move_right > 0 and not $AnimatedSprite.flip_h) or \
					  (move_left > 0 and $AnimatedSprite.flip_h)
	if toward_wall:
		wall_climbing = true
		velocity.y = clamp(velocity.y, -GRAVITY, 30)
	else:
		wall_climbing = false


func _handle_ledge_grab():
	if not ledge_grab_unlocked:
		ledge_grabbing = false
		return
	# Stub: full ledge edge detection and snap logic goes here
	ledge_grabbing = false


func _input(event):
	if frozen:
		return
	if event.is_action_pressed("ui_up") and is_on_floor() and jump_unlocked:
		velocity.y -= JUMP_FORCE
	if event.is_action_pressed("ui_select") and dash_unlocked:
		_do_dash()


func _do_dash():
	if dash_cooldown_timer > 0:
		return
	dashing = true
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	dash_direction = -1 if $AnimatedSprite.flip_h else 1


var respawn_checkpoint_node_ref : Node2D

func update_checkpoint(new_checkpoint: Node2D):
	if respawn_checkpoint_node_ref == new_checkpoint:
		return
	if respawn_checkpoint_node_ref != null:
		respawn_checkpoint_node_ref.set_active(false)

	respawn_checkpoint_node_ref = new_checkpoint
	respawn_checkpoint_node_ref.set_active(true)
