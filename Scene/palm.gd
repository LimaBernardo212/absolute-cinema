extends StaticBody2D
@onready var detector = $RayCast2D as RayCast2D
@onready var coll = $CollisionShape2D as CollisionShape2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if detector.is_colliding():
		coll.disabled = false
	else:
		coll.disabled = true
