extends CharacterBody2D
@onready var detector := $RayCast2D as RayCast2D 
@onready var anim := $AnimatedSprite2D as AnimatedSprite2D
@onready var atackerDetectorL = $AttackerL as RayCast2D
@onready var attackerDetectorR = $AtackerR as RayCast2D
@onready var damageDetectorR = $DamageR as RayCast2D
@onready var damageDetectorL = $DamageL as RayCast2D
@onready var enemiePig = $"." as CharacterBody2D

const SPEED = 750.0
const JUMP_VELOCITY = -400.0

var currentAnimation = 0
var direction := -1
var state = "run"
var can_attack = false
var is_dead = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if detector.is_colliding():
		direction = direction * -1
		detector.scale.x *= -1
		anim.flip_h = (direction == 1)
	
	velocity.x = direction * SPEED * delta
	
	if Input.is_action_just_pressed("ui_select"):
		if damageDetectorL.is_colliding() or damageDetectorR.is_colliding():
			velocity.x = 0
			change_state("Damage")
			currentAnimation = 1
			is_dead = true
	
	match state:
		"run":
			if can_attack:
				if atackerDetectorL.is_colliding():
					anim.flip_h = false
					direction = -1
					change_state("Attack")
				elif attackerDetectorR.is_colliding():
					direction = 1
					anim.flip_h = true
					change_state("Attack")
			
			if anim.animation != "Run":
				anim.play("Run")
		
		"attack", "damage":
			velocity.x = 0
	
	move_and_slide()

func change_state(new_animation: String):
	state = new_animation.to_lower()
	anim.play(new_animation)

func _on_animated_sprite_2d_animation_finished() -> void:
	if state in ["attack", "damage"]:
		if currentAnimation == 1:
			queue_free()
		else:
			state = "run"
			anim.play("Run")

func _on_player_danger_zone_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	
	var timer = Timer.new()
	timer.wait_time = 0.6
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	await timer.timeout
	
	if is_dead:
		timer.queue_free()
		return
	
	print("Timer terminou! Ativando ataque...")
	
	# Habilita os detectores de ataque
	atackerDetectorL.enabled = true
	attackerDetectorR.enabled = true
	
	# Permite atacar
	can_attack = true
	
	# Para o movimento
	velocity.x = 0
	
	# Determina para qual lado atacar baseado na posição do player
	var player_position = body.global_position
	var enemy_position = global_position
	
	if player_position.x < enemy_position.x:
		# Player está à esquerda
		direction = -1
		detector.scale.x *= -1
		anim.flip_h = false
	else:
		# Player está à direita
		direction = 1
		detector.scale.x *= -1
		anim.flip_h = true
	
	# Executa a animação de ataque
	change_state("Attack")
	
	timer.queue_free()
