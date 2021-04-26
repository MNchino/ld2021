extends Node2D

const max_offset = Vector2(1,1)

func _physics_process(delta):
	if not $Timer.is_stopped():
		position.x = max_offset.x * rand_range(-1, 1)
		position.y = max_offset.y * rand_range(-1, 1)

func shake_start():
	$Timer.start()

func _on_Timer_timeout():
	position = Vector2.ZERO
