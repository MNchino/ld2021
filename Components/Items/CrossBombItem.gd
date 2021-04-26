extends Node2D

func _on_ExplosionSensor_area_entered(_area):
	$AnimationPlayer.play("laser")
