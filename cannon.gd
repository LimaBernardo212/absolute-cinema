extends Area2D

@onready var sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var collision = $CollisionShape2D as CollisionShape2D

const SPEED = 300.0
const DAMAGE = 1
const LIFETIME = 5.0

var direction := Vector2.RIGHT
var velocity := Vector2.ZERO
var is_exploding = false
var can_collide = false
var my_cannon: StaticBody2D = null

func set_cannon(cannon: StaticBody2D) -> void:
	my_cannon = cannon
	print("🎯 Bala recebeu canhão: ", cannon.name)

func _ready() -> void:
	collision.disabled = true
	
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	collision.disabled = false
	can_collide = true
	
	var timer = Timer.new()
	timer.wait_time = LIFETIME
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_expired)
	add_child(timer)
	timer.start()

func _process(delta: float) -> void:
	if not is_exploding:
		velocity = direction * SPEED
		position += velocity * delta

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	if is_exploding or not can_collide:
		return
	
	if body == my_cannon:
		print("🚫 Ignorando canhão de origem: ", body.name)
		return
	
	if body is StaticBody2D and body.name.to_lower().contains("cannon"):
		print("🚫 Ignorando outro canhão: ", body.name)
		return
	
	is_exploding = true
	velocity = Vector2.ZERO
	
	print("💥 Bala colidiu com: ", body.name)
	
	# ✅ Verifica se é o player ANTES de explodir
	var hit_player = false
	if body.is_in_group("player") or body.name.contains("Knight"):
		hit_player = true
		print("💀 PLAYER FOI ATINGIDO!")
		
		# Chama a função de morte do player se existir
		if body.has_method("take_damage"):
			body.take_damage()
	
	# Explode e depois muda de cena
	await explode()
	
	# ✅ Muda de cena DEPOIS da explosão
	if hit_player:
		print("🔄 Mudando para tela de morte...")
		get_tree().change_scene_to_file("res://Scene/history_1.tscn")

func _on_area_entered(area: Area2D) -> void:
	if is_exploding or not can_collide:
		return
	
	is_exploding = true
	velocity = Vector2.ZERO
	
	print("💥 Bala colidiu com área: ", area.name)
	
	# ✅ Verifica se é a HurtBox do player
	var hit_player = false
	if area.name == "HurtBox":
		hit_player = true
		print("💀 HURTBOX DO PLAYER FOI ATINGIDA!")
		
		# Tenta acessar o player e chamar take_damage
		var player = area.get_parent()
		if player and player.has_method("take_damage"):
			player.take_damage()
	
	await explode()
	
	# ✅ Muda de cena DEPOIS da explosão
	if hit_player:
		print("🔄 Mudando para tela de morte...")
		get_tree().change_scene_to_file("res://Scene/history_1.tscn")

func _on_lifetime_expired() -> void:
	if is_exploding:
		return
	
	is_exploding = true
	sprite.play("Explosion")
	await sprite.animation_finished
	queue_free()

func explode() -> void:
	collision.set_deferred("disabled", true)
	sprite.play("Explosion")
	await sprite.animation_finished
	queue_free()
