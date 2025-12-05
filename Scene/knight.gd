extends CharacterBody2D
@onready var animation_player = $AnimatedSprite2D
@onready var DamageR = $DamageR as RayCast2D
@onready var DamageL = $DamageL as RayCast2D
@onready var knockBack = $knockBackBottom as RayCast2D
const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const DASH_DOWN_SPEED = 150.0
var attacking = false
var bottomDash = false
var dead = false

func _physics_process(delta: float) -> void:
	if dead:
		velocity.x = 0
		velocity.y += get_gravity().y * delta
		move_and_slide()
		return
	
	if knockBack.is_colliding():
		velocity.y = JUMP_VELOCITY / 1.2
	
	# Se está fazendo dash para baixo
	if bottomDash:
		velocity.y = DASH_DOWN_SPEED
		velocity.x = 0
		
		if is_on_floor():
			bottomDash = false
			attacking = false
		
		move_and_slide()
		return
	
	if attacking:
		move_and_slide()
		return
	
	# ATAQUE NO CHÃO
	if Input.is_action_just_pressed("ui_select") and is_on_floor():
		attacking = true
		animation_player.play("knight-Attack")
		return
	
	# DASH PARA BAIXO NO AR
	if Input.is_action_just_pressed("ui_select") and not is_on_floor():
		bottomDash = true
		attacking = true
		animation_player.play("kinght-second-attack")
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
	
	if animation_player.animation == "kinght-second-attack":
		bottomDash = false
		attacking = false
	
	if animation_player.animation == "knight-death":
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scene/history_1.tscn")

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if dead:
		return
	dead = true
	velocity.x = 0
	animation_player.play("knight-death")
