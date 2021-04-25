extends Control

signal game_restart
signal game_quit
const life_width = 13

func _ready():
	_on_Playspace_score_changed(global.points)
	_on_Playspace_depth_changed(global.depth)
	_on_Playspace_power_changed(global.power)
	_on_Playspace_life_changed(global.life)
	
func _on_Playspace_score_changed(new_score : int):
	$BottomRight/PointsCount.text = String(new_score)

func _on_Playspace_depth_changed(new_depth : int):
	$TopRight/DepthCount.text = String(new_depth) + " m"

func _on_Playspace_power_changed(new_power : int):
	$TopRight/PowerBar.value = new_power

func _on_Playspace_life_changed(new_life : int):
	var has_life = new_life > 0
	$TopLeft/LifeRect/LifeRectOn.visible = has_life
	if has_life:
		$TopLeft/LifeRect/LifeRectOn.rect_size.x = life_width * new_life

func _on_Playspace_game_over():
	$GameOver.visible = true

func _on_RestartButton_pressed():
	emit_signal("game_restart")

func _on_QuitButton_pressed():
	emit_signal("game_quit")
