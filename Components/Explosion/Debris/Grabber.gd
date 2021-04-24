extends Area2D
class_name Grabber

signal collected

func collect():
	emit_signal("collected")

func disable():
	if !$Shape.disabled:
		$Shape.disabled = true

func enable():
	if $Shape.disabled:
		$Shape.disabled = false
