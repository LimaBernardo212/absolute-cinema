extends CharacterBody2D

@onready var detector = $RayCast2D as RayCast2D
@onready var anim = $"BIG-ANIMATION" as AnimatedSprite2D

const SPEED = 10.0
const JUMP_VELOCITY = -400.0
var direction := -1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if detector.is_colliding():
		direction *= -1
		detector.scale.x *= -1
		anim.flip_h = (direction == 1)

	velocity.x = direction * SPEED

	if direction != 0:
		print("bruh")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
