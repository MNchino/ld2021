extends Node2D

var debuff_enabled = true

signal gaster_blaster_charge
signal gaster_blaster_time

func _on_ExplosionSensor_area_entered(_area):
	if !debuff_enabled:
		var _charge = connect("gaster_blaster_charge", get_parent(), "gaster_blaster_charge")
		var _time = connect("gaster_blaster_time", get_parent(), "gaster_blaster_time")
		$AnimationPlayer.play("laser")

func _on_Timer_timeout():
	debuff_enabled = false

func emit_charge():
	emit_signal("gaster_blaster_charge")

func emit_time():
	emit_signal("gaster_blaster_time")

func goodbye():
	disconnect("gaster_blaster_charge", get_parent(), "gaster_blaster_charge")
	disconnect("gaster_blaster_time", get_parent(), "gaster_blaster_time")
	queue_free()
