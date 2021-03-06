extends Control

signal game_restart
signal game_quit
const life_width = 13
const glow = preload("res://Sprites/Theme/theme-stylebox-fgglow.tres")

func _ready():
	_on_Playspace_score_changed(global.points)
	_on_Playspace_depth_changed(global.depth)
	_on_Playspace_power_changed(global.power)
	_on_Playspace_life_changed(global.life)
	_on_Playspace_best_changed(global.best)
	
func _on_Playspace_score_changed(new_score : int):
	$BottomRight/PointsCount.text = String(new_score)

func _on_Playspace_best_changed(new_score : int):
	$BottomLeft/BestCount.text = String(new_score)

func _on_Playspace_depth_changed(new_depth : int):
	$TopRight/DepthCount.text = String(new_depth) + " m"

func _on_Playspace_power_changed(new_power : int):
	$TopLeft/PowerBar.value = new_power
	if $TopLeft/PowerBar.value >= $TopLeft/PowerBar.max_value:
		$TopLeft/PowerBar.set("custom_styles/fg", glow)
	else:
		$TopLeft/PowerBar.set("custom_styles/fg", null)

func _on_Playspace_life_changed(new_life : int):
	var has_life = new_life > 0
	$TopLeft/LifeRect/LifeRectOn.visible = has_life
	if has_life:
		$TopLeft/LifeRect/LifeRectOn.rect_size.x = life_width * new_life
		
func _on_Playspace_next_changed(new_next : int):
	$TopRight/NextBar.value = new_next
	if $TopRight/NextBar.value >= ($TopRight/NextBar.max_value * .5):
		$TopRight/NextBar.set("custom_styles/fg", glow)
	else:
		$TopRight/NextBar.set("custom_styles/fg", null)

func _on_Playspace_game_over():
	$GameOver.visible = true

func _on_RestartButton_pressed():
	emit_signal("game_restart")

func _on_QuitButton_pressed():
	emit_signal("game_quit")
