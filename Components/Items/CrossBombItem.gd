extends Node2D

var debuff_enabled = true

func _on_ExplosionSensor_area_entered(_area):
	if !debuff_enabled:
		$AnimationPlayer.play("laser")


func _on_Timer_timeout():
	debuff_enabled = false
