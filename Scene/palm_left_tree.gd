extends StaticBody2D
@onready var palmRay = $RayCast2D as RayCast2D
@onready var colision = $CollisionShape2D as CollisionShape2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if palmRay.is_colliding():
		queue_free()
