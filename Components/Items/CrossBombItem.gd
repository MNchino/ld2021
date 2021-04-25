extends Node2D

func _on_ExplosionSensor_area_entered(area):
	$AnimationPlayer.play("laser")
