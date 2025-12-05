extends CharacterBody2D

@onready var detector = $RayCast2D as RayCast2D
@onready var anim = $AnimatedSprite2D as AnimatedSprite2D
@onready var colision = $CollisionShape2D as CollisionShape2D
const SPEED = 750.0
const JUMP_VELOCITY = -400.0
var direction := -1
var dead = false
func _physics_process(delta: float) -> void:
	velocity.y = 0
	if detector.is_colliding():
		direction = direction * -1
		detector.scale.x *= -1
		anim.flip_h = (direction == 1)
	
	velocity.x = direction * SPEED * delta
	move_and_slide()


func _on_hit_box_body_entered(body: Node2D) -> void:
	anim.play("Hit")
	dead = true
	remove_child(colision)

func _on_animated_sprite_2d_animation_finished() -> void:
	if dead:
		queue_free()


func _on_hit_box_2_body_entered(body: Node2D) -> void:
	if Input.is_action_just_pressed("ui_select"):
		anim.play("Hit")
		dead = true
		remove_child(colision)
