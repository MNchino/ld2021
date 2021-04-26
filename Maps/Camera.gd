extends Node2D

const damage_offset = Vector2(3,3)
const damage_timer = 0.2
const power_offset = Vector2(0.2,0.2)
const power_timer = 0.1

var offset = 0

func _physics_process(_delta):
	if not $Timer.is_stopped():
		$Viewpoint.position.x = offset.x * rand_range(-1, 1)
		$Viewpoint.position.y = offset.y * rand_range(-1, 1)

func shake_start_damage():
	offset = damage_offset
	$Timer.wait_time = damage_timer
	$Timer.start()
	
func shake_start_power():
	offset = power_offset * global.power
	$Timer.wait_time = power_timer
	$Timer.start()

func _on_Timer_timeout():
	$Viewpoint.position = Vector2.ZERO
