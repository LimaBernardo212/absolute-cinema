extends CharacterBody2D
@onready var animation_player = $AnimatedSprite2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0


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
	if direction:
		if direction > 0:
			animation_player.flip_h = false
		elif direction < 0:
			animation_player.flip_h = true
		velocity.x = direction * SPEED
		animation_player.play("knight-run")
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation_player.play("knight-idle")
	move_and_slide()
