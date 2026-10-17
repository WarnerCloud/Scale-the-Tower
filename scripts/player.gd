extends CharacterBody2D

@onready var timer: Timer = $"../DeathTimer"
@onready var start_position: Node2D = $"../StartPosition"
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const NUM_LIVES = 3

var lives
var reset_pos
var player_locked

func _init() -> void:
	lives = NUM_LIVES
	player_locked = false

func _on_ready() -> void:
	reset_pos = start_position.global_position
	position = reset_pos

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if (!player_locked):
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_death_timer_timeout() -> void:
	lives -= 1
	collision_shape.set_deferred("disabled", false)
	velocity = Vector2(0, 0)
	global_position = reset_pos
	player_locked = false



func take_damage() -> void:
	if (player_locked):
		return
	collision_shape.set_deferred("disabled", true)
	velocity.y = JUMP_VELOCITY/4
	velocity.x = 0
	player_locked = true
	timer.start()

func update_respawn(pos: Vector2):
	reset_pos = pos
