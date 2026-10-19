extends CharacterBody2D

@onready var timer: Timer = %DeathTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var start_position: Marker2D = %StartPosition
@onready var scoreboard: CanvasLayer = %Scoreboard

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const NUM_LIVES = 3
const KILL_SPEED = 1000
const CLIMB_SPEED = 100

var lives
var reset_pos
var player_locked

var on_ladder = false
var climbing = false
var num_ladders = 0

func _init() -> void:
	lives = NUM_LIVES
	player_locked = false

func _on_ready() -> void:
	reset_pos = start_position.global_position
	position = reset_pos

func _physics_process(delta: float) -> void:
	# die if falling too fast
	if (velocity.y > KILL_SPEED):
		take_damage()
	
	if (on_ladder && Input.is_action_just_pressed("ui_up")):
		climbing = true

	if (!climbing):
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
	else:
		# Handle Climbing
		var y_direction := Input.get_axis("ui_up", "ui_down")
		if (!player_locked):
			if y_direction:
				velocity.y = y_direction * CLIMB_SPEED
			else:
				velocity.y = move_toward(velocity.y, 0, CLIMB_SPEED)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() || climbing):
		velocity.y = JUMP_VELOCITY
		climbing = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x_direction := Input.get_axis("ui_left", "ui_right")
	if (!player_locked):
		if x_direction:
			velocity.x = x_direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Respawn after death animation
func _on_death_timer_timeout() -> void:
	lives -= 1
	if (lives == 0):
		get_tree().reload_current_scene()

	collision_shape.set_deferred("disabled", false)
	velocity = Vector2(0, 0)
	global_position = reset_pos
	player_locked = false
	scoreboard.update_score(lives)

# Start death animation
func take_damage() -> void:
	# Don't take damage twice in a row
	if (player_locked):
		return
	collision_shape.set_deferred("disabled", true)
	velocity.y = JUMP_VELOCITY/4
	velocity.x = 0
	player_locked = true
	timer.start()

func update_respawn(pos: Vector2):
	reset_pos = pos

func enter_ladder():
	on_ladder = true
	num_ladders += 1

func exit_ladder():
	num_ladders -= 1
	if (num_ladders <= 0):
		on_ladder = false
		climbing = false
