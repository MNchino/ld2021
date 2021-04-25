extends Node
signal score_changed
signal depth_changed
signal power_changed
signal life_changed

func _on_Player_score_changed(new_score : int):
	global.points = new_score + global.points
	emit_signal("score_changed", global.points)

func _physics_process(delta):
	#Update Depth as we reach it
	var new_depth = floor(max(0, ($Player.position.y - $CookieDirt.position.y)/8))
	if new_depth > global.depth:
		emit_signal("depth_changed", new_depth)
		global.depth = new_depth

func _on_Player_power_changed(new_power : int):
	global.power = global.power + new_power
	emit_signal("power_changed", global.power)

func _on_Player_power_reset():
	global.power = 0
	emit_signal("power_changed", global.power)


func _on_CookieDirt_next_dirt():
	print("calling next dirt")
	$CookieDirt.position.y -= 48
	$Player.position.y -= 48
	pass # Replace with function body.
