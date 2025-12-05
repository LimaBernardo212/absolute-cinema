extends CharacterBody2D
@onready var detector := $RayCast2D as RayCast2D 
@onready var anim := $AnimatedSprite2D as AnimatedSprite2D
@onready var atackerDetectorL = $AttackerL as RayCast2D
@onready var attackerDetectorR = $AtackerR as RayCast2D
@onready var damageDetectorR = $DamageR as RayCast2D
@onready var damageDetectorL = $DamageL as RayCast2D
@onready var enemiePig = $"." as CharacterBody2D
@onready var HitBox = $"CollisionShape2D" as CollisionShape2D
const SPEED = 750.0
const JUMP_VELOCITY = -400.0
const KNOCKBACK_FORCE = 300.0
const KNOCKBACK_UP = -200.0
var currentAnimation = 0
var direction := -1
var state = "run"
var can_attack = false
var is_dead = false
var player_in_hitbox = false
var knockback_velocity = Vector2.ZERO
func _physics_process(delta: float) -> void:
	if is_dead:
		HitBox.disabled = true
		velocity.y = 0
		velocity.x = 0
	
		move_and_slide()
		return
	# Verifica input do player
	if player_in_hitbox and Input.is_action_just_pressed("ui_select"):
		take_damage()
	if not is_on_floor():
		velocity += get_gravity() * delta
	if detector.is_colliding():
		direction = direction * -1
		detector.scale.x *= -1
		anim.flip_h = (direction == -1)  # ✅✅✅ MUDEI AQUI: -1 em vez de 1
	velocity.x = direction * SPEED * delta
	match state:
		"run":
			if can_attack:
				if atackerDetectorL.is_colliding():
					anim.flip_h = true  # ✅✅✅ MUDEI AQUI: true em vez de false
					direction = -1
					change_state("Attack")
				elif attackerDetectorR.is_colliding():
					direction = 1
					anim.flip_h = false  # ✅✅✅ MUDEI AQUI: false em vez de true
					change_state("Attack")
			if anim.animation != "Run":
				anim.play("Run")
		"attack", "damage":
			velocity.x = 0
	move_and_slide()
func take_damage():
	if is_dead:
		HitBox.disabled = true
		velocity.y = 0
		velocity.x = 0
		return
	print("🐷 Pig levou dano!")
	# Calcula knockback baseado na direção do player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var player_position = player.global_position
		var enemy_position = global_position
		var knockback_direction = 1 if enemy_position.x > player_position.x else -1
		knockback_velocity = Vector2(knockback_direction * KNOCKBACK_FORCE, KNOCKBACK_UP)
	velocity.x = 0
	change_state("Damage")
	currentAnimation = 1
	is_dead = true
func change_state(new_animation: String):
	state = new_animation.to_lower()
	anim.play(new_animation)
func _on_animated_sprite_2d_animation_finished() -> void:
	if state in ["attack", "damage"]:
		if currentAnimation == 1:
			print("🐷 Pig destruído!")
			queue_free()
		else:
			state = "run"
			anim.play("Run")
func _on_player_danger_zone_body_entered(body: Node2D) -> void:
	if is_dead:
		HitBox.disabled = true
		velocity.y = 0
		velocity.x = 0
		return
	var timer = Timer.new()
	timer.wait_time = 0.6
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	if is_dead:
		timer.queue_free()
		HitBox.disabled = true
		velocity.y = 0
		velocity.x = 0
		return
	print("Timer terminou! Ativando ataque...")
	atackerDetectorL.enabled = true
	attackerDetectorR.enabled = true
	can_attack = true
	velocity.x = 0
	var player_position = body.global_position
	var enemy_position = global_position
	if player_position.x < enemy_position.x:
		direction = -1
		anim.flip_h = true  # ✅✅✅ MUDEI AQUI: true em vez de false
	else:
		direction = 1
		anim.flip_h = false  # ✅✅✅ MUDEI AQUI: false em vez de true
	change_state("Attack")
	timer.queue_free()
func _on_hit_box_body_entered(body: Node2D) -> void:
	print("🎯 HitBox detectou: ", body.name)
	if body.is_in_group("player") or body.name.contains("Knight"):
		player_in_hitbox = true
		print("Player entrou na hitbox!")
	# ✅ CORRIGIDO: Agora chama take_damage() para matar o pig
	if body.is_in_group("arrow") or body.name.to_lower().contains("arrow"):
		take_damage()  # ✅✅✅ MUDEI AQUI: take_damage() em vez de queue_free()
func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.contains("Knight"):
		player_in_hitbox = false
		print("Player saiu da hitbox!")
