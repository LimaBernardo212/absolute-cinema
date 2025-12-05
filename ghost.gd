extends CharacterBody2D

@onready var coll = $CollisionShape2D as CollisionShape2D
@onready var anim = $AnimatedSprite2D as AnimatedSprite2D
@onready var lif = $LifeStatus/AnimatedSprite2D as AnimatedSprite2D
@onready var hitbox_coll = $HitBox/CollisionShape2D as CollisionShape2D

const SPEED = 5.0
const KNOCKBACK_FORCE = 300.0
const KNOCKBACK_UP = -200.0

var direction := 1
var start_position: Vector2
var patrol_distance := 200.0
var life = 2
var can_be_hit = true
var player_in_hitbox = false
var is_dead = false
var knockback_velocity = Vector2.ZERO

func _ready():
	start_position = global_position
	# Se começar com vida 1, esconde o lif
	if life == 1:
		lif.visible = false

func _physics_process(delta: float) -> void:
	if is_dead:
		coll.disabled = true
		velocity.y = 0
		velocity.x = 0
		move_and_slide()
		return
	
	# Verifica ataque enquanto player está na hitbox
	if Input.is_action_just_pressed("ui_select") and player_in_hitbox and can_be_hit:
		take_damage()
	
	var distance_from_start = global_position.x - start_position.x
	
	# Patrulha
	if distance_from_start >= patrol_distance and direction == 1:
		direction = -1
		anim.flip_h = false
	elif distance_from_start <= 0 and direction == -1:
		direction = 1
		anim.flip_h = true
	
	velocity.x = direction * SPEED
	velocity.y = 0
	
	move_and_slide()

func _on_appear_area_body_entered(body: Node2D) -> void:
	anim.visible = true
	
	# Só mostra o lif se a vida for maior que 1
	if life > 1:
		lif.visible = true
		lif.play("hi")
	
	anim.play("Appear")
	await anim.animation_finished
	anim.play("Idle")
	
	# Só toca a animação default se a vida for maior que 1
	if life > 1:
		lif.play("default")

func _on_appear_area_body_exited(body: Node2D) -> void:
	anim.play("Desapear")
	
	# Só toca animação bye se estiver visível
	if life > 1:
		lif.play("bye")
	
	await anim.animation_finished
	anim.visible = false
	lif.visible = false

# Quando o player ENTRA na hitbox
func _on_hit_box_body_entered(body: Node2D) -> void:
	print("🎯 HitBox detectou: ", body.name)
	
	if body.is_in_group("player") or body.name.contains("Knight"):
		player_in_hitbox = true
		print("Player entrou na hitbox!")
	
	# Se for flecha, toma dano direto
	if body.is_in_group("arrow") or body.name.to_lower().contains("arrow"):
		take_damage()

# Quando o player SAI da hitbox
func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.contains("Knight"):
		player_in_hitbox = false
		print("Player saiu da hitbox!")

func take_damage():
	if is_dead:
		coll.disabled = true
		velocity.y = 0
		velocity.x = 0
		return
	
	print("👻 Fantasma levou dano!")
	
	# Calcula knockback baseado na direção do player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var player_position = player.global_position
		var enemy_position = global_position
		var knockback_direction = 1 if enemy_position.x > player_position.x else -1
		knockback_velocity = Vector2(knockback_direction * KNOCKBACK_FORCE, KNOCKBACK_UP)
	
	can_be_hit = false
	velocity.x = 0
	anim.play("Hit")
	life -= 1
	
	# Só toca animação do lif se ele estiver visível
	if lif.visible:
		lif.play("bye")
		await lif.animation_finished
		lif.visible = false
	
	anim.play("Idle")
	
	# Desabilita colisão
	if hitbox_coll:
		hitbox_coll.disabled = true
	coll.disabled = true
	
	# Checa se morreu
	if life <= 0:
		is_dead = true
		die()
	else:
		# Timeout de 2 segundos antes de reabilitar
		await get_tree().create_timer(2.0).timeout
		coll.disabled = false
		if hitbox_coll:
			hitbox_coll.disabled = false
		
		# Só mostra o lif novamente se a vida for maior que 1
		if life > 1:
			lif.visible = true
			lif.play("default")
		
		can_be_hit = true

func die():
	print("👻 Fantasma destruído!")
	anim.play("Hit")
	await anim.animation_finished
	queue_free()
