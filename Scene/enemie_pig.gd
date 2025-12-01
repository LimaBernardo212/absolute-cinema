extends CharacterBody2D
@onready var detector := $RayCast2D as RayCast2D 
@onready var anim := $AnimatedSprite2D as AnimatedSprite2D
@onready var atackerDetectorL = $AttackerL as RayCast2D
@onready var attackerDetectorR = $AtackerR as RayCast2D
@onready var damageDetectorR = $DamageR as RayCast2D
@onready var damageDetectorL = $DamageL as RayCast2D
const SPEED = 750.0
const JUMP_VELOCITY = -400.0
var currentAnimation = 0
var direction := -1
var state = "run"  # Estados: run, attack, damage

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if detector.is_colliding():
		direction = direction * -1
		detector.scale.x *= -1
		anim.flip_h = (direction == 1)
	
	velocity.x = direction * SPEED * delta
	if Input.is_action_just_pressed("ui_select"):
		if damageDetectorL.is_colliding():
			
			velocity.x = 0
			anim.play("Damage")
			
			currentAnimation = 1
		if Input.is_action_just_pressed("ui_select"):
			if damageDetectorR.is_colliding():
				velocity.x = 0
				anim.play("Damage")
				
				currentAnimation = 1
	# Lógica de estados
	match state:
		"run":
			if atackerDetectorL.is_colliding():
				anim.flip_h = false
				direction = -1
				change_state("Attack")
			elif attackerDetectorR.is_colliding():
				direction = 1
				anim.flip_h = true
				change_state("Attack")
			elif anim.animation != "Run":
				anim.play("Run")
		
		"attack", "damage":
			# Não faz nada, espera a animação terminar
			pass
	
	move_and_slide()

func change_state(new_animation: String):
	state = new_animation.to_lower()
	anim.play(new_animation)

func _on_animated_sprite_2d_animation_finished() -> void:
	# Volta para run quando animação termina
	if state in ["attack", "damage"]:
		state = "run"
		anim.play("Run")
	if currentAnimation == 1:
		queue_free()
