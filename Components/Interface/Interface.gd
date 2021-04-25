extends Control

var ui_life : int = 0
var ui_power : int = 0
var ui_depth : int = 0
var ui_points : int = 0

func _ready():
	ui_life_set(3)
	ui_power_set(0)
	ui_depth_set(0)
	ui_points_set(0)

func ui_life_set(amount : int):
	ui_life = amount
	$TopLeft/LifeRect/LifeRectOn.rect_size = $TopLeft/LifeRect/LifeRectOn.rect_min_size * amount

func ui_power_set(amount : int):
	ui_power = amount
	$TopRight/PowerBar.value = amount

func ui_depth_set(amount : int):
	ui_depth = amount
	$TopRight/DepthCount.text = String(amount) + " m"

func ui_points_set(amount : int):
	ui_points = amount
	$BottomRight/PointsCount.text = String(amount)

func _on_Playspace_score_changed(new_score : int):
	ui_points_set(new_score)

func _on_Playspace_depth_changed(new_depth : int):
	ui_depth_set(new_depth)

func _on_Playspace_power_changed(new_power : int):
	ui_power_set(new_power)
