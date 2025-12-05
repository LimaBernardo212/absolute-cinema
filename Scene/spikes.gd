extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_spike_area_body_entered(body: Node2D) -> void:
	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	await timer.timeout
	
	get_tree().change_scene_to_file("res://Scene/history_1.tscn")
