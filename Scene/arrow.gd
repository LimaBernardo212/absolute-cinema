extends Area2D

# Variáveis de física
var velocity = Vector2(800, 0)  # Velocidade inicial horizontal
var direction = Vector2.RIGHT

func _ready() -> void:
	# Configura a velocidade inicial baseada na direção
	velocity = direction.normalized() * velocity.length()
	
	# Define a rotação inicial para a direção correta
	rotation = direction.angle()

func _process(delta: float) -> void:
	# Move o projétil apenas na direção definida (sem gravidade)
	position += velocity * delta
	
	# Remove o projétil se sair muito da tela (otimização)
	if position.y > 2000 or position.y < -500 or position.x < -500 or position.x > get_viewport_rect().size.x + 500:
		queue_free()

func set_direction(dir: Vector2) -> void:
	# Define a direção do tiro quando criado
	direction = dir.normalized()
	velocity = direction * velocity.length()
	rotation = direction.angle()
