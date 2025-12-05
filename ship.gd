extends CharacterBody2D
const SPEED = 100.0
var direction = 1
@onready var flag = $Flag/AnimatedSprite2D as AnimatedSprite2D
@onready var shipB = $StaticBody2D/AnimatedSprite2D2 as AnimatedSprite2D
@onready var ray = $RayCast2D as RayCast2D
var wind = false
var transition_done = false
var transition_to_no_wind_done = false
var player_parent = null
var is_destroyed = false  # ✅ Evita processar após destruição

func _ready() -> void:
	flag.animation_finished.connect(_on_flag_animation_finished)

func _physics_process(delta: float) -> void:
	if is_destroyed:  # ✅ Para tudo se já foi destruído
		return
	
	if wind:
		if ray.is_colliding():
			velocity.x = 0
			velocity.y = 0
			is_destroyed = true  # ✅ Marca como destruído
			
			# ✅ SOLTA O PLAYER ANTES DE DESTRUIR
			release_player()
			
			flag.play("ToNoWind")
			shipB.play("hit")
			await shipB.animation_finished
			flag.play("NoWind")
			return  # ✅ Para o código aqui
		
		velocity.y = 0
		
		if not transition_done:
			flag.play("ToWind")
		elif direction:
			velocity.x = direction * SPEED
			if flag.animation != "Wind":
				flag.play("Wind")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.y = 0
		velocity.x = 0
		
		if not transition_to_no_wind_done:
			flag.play("ToNoWind")
		else:
			if flag.animation != "NoWind":
				flag.play("NoWind")
	
	move_and_slide()

func _on_flag_animation_finished() -> void:
	if flag.animation == "ToWind":
		transition_done = true
	
	if flag.animation == "ToNoWind":
		transition_to_no_wind_done = true

# ✅ NOVA FUNÇÃO para soltar o player
func release_player():
	# Procura o player entre os filhos
	for child in get_children():
		if child.is_in_group("player") or child.name.contains("Knight"):
			if player_parent:
				child.reparent(player_parent)
				player_parent = null
			print("Player solto antes da destruição!")
			break

func _on_wind_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.contains("Knight"):
		wind = true
		transition_done = false
		transition_to_no_wind_done = false
		
		player_parent = body.get_parent()
		body.reparent(self)
		print("Player entrou no barco!")

func _on_wind_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name.contains("Knight"):
		wind = false
		transition_to_no_wind_done = false
		
		if player_parent:
			body.reparent(player_parent)
			player_parent = null
		print("Player saiu do barco!")
