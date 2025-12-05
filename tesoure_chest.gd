extends StaticBody2D
@onready var anim = $AnimatedSprite2D as AnimatedSprite2D
var enter = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select") and enter == true:
		anim.play('Unlocked')


func _on_unlock_area_body_entered(body: Node2D) -> void:
	enter = true
