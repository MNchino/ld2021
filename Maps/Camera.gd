extends Node2D

const max_offset = Vector2(2,2)

func _physics_process(delta):
	if not $Timer.is_stopped():
		$Viewpoint.position.x = max_offset.x * rand_range(-1, 1)
		$Viewpoint.position.y = max_offset.y * rand_range(-1, 1)

func shake_start():
	$Timer.start()

func _on_Timer_timeout():
	$Viewpoint.position = Vector2.ZERO
