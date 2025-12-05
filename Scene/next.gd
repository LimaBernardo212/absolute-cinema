extends Area2D
@onready var anim = $AnimatedSprite2D as AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous fr


func _on_animated_sprite_2d_animation_finished() -> void:
	get_tree().change_scene_to_file("res://Scene/absolute_cinema_base_1.tscn")


func _on_body_entered(body: Node2D) -> void:
	anim.play('piking')
