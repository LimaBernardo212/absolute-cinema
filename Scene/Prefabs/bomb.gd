extends StaticBody2D
@onready var anim = $AnimatedSprite2D as AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_explode_body_entered(body: Node2D) -> void:
	anim.play("BombOn")
	await anim.animation_finished
	anim.play("BOOM")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scene/history_1.tscn")
