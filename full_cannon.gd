extends StaticBody2D

@onready var cannon_ball_scene = preload("res://Scene/Prefabs/cannon_ball.tscn")
@onready var spawn_point = $SpawnPoint as Marker2D
@onready var anim = $AnimatedSprite2D as AnimatedSprite2D

var can_shoot = true
var shoot_cooldown = 2.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_player_danger_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.contains("Knight"):
		if can_shoot:
			anim.play("fire")
			await anim.animation_finished
			shoot()

func shoot() -> void:
	can_shoot = false
	print("🎯 Canhão disparou!")
	
	var ball = cannon_ball_scene.instantiate()
	ball.set_cannon(self)
	
	get_parent().add_child(ball)
	
	# ✅ Calcula a direção PRIMEIRO
	var player = get_tree().get_first_node_in_group("player")
	var shoot_direction: Vector2
	
	if player:
		# Direção do canhão para o player
		if spawn_point:
			shoot_direction = (player.global_position - spawn_point.global_position).normalized()
		else:
			shoot_direction = (player.global_position - global_position).normalized()
	else:
		shoot_direction = Vector2.RIGHT
	
	# ✅ Spawna 40px na direção do tiro
	if spawn_point:
		ball.global_position = spawn_point.global_position + (shoot_direction * 40)
	else:
		ball.global_position = global_position + (shoot_direction * 40)
	
	# Define a direção da bala
	ball.set_direction(shoot_direction)
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
