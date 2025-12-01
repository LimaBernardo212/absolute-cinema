extends CharacterBody2D

@onready var animation_player = $AnimatedSprite2D
@onready var DamageR = $DamageR as RayCast2D
@onready var DamageL = $DamageL as RayCast2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

var attacking = false
var dead = false


func _physics_process(delta: float) -> void:

	if dead:
		velocity.x = 0
		move_and_slide()
		return

	if attacking:
		move_and_slide()
		return

	# DETECTOU MORTE
	if DamageL.is_colliding() or DamageR.is_colliding():
		dead = true
		animation_player.play("knight-death")
		return

	# ATAQUE
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		attacking = true
		animation_player.play("knight-Attack")
		return

	# GRAVIDADE
	if not is_on_floor():
		velocity += get_gravity() * delta

	# PULO
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# MOVIMENTO
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		animation_player.flip_h = direction < 0
		velocity.x = direction * SPEED
		animation_player.play("knight-run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation_player.play("knight-idle")

	move_and_slide()



func _on_animated_sprite_2d_animation_finished() -> void:
	if animation_player.animation == "knight-Attack":
		attacking = false

	if animation_player.animation == "knight-death":
		queue_free()
