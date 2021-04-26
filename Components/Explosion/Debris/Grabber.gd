extends Area2D
class_name Grabber

signal collected
export var num_points = 100
export var num_power = 1
export var num_life = 0

func collect():
	emit_signal("collected")
	return {"points": num_points, "power": num_power, "life": num_life}

func disable():
	if !$Shape.disabled:
		$Shape.disabled = true

func enable():
	if $Shape.disabled:
		$Shape.disabled = false
