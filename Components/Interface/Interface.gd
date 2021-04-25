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
	$TopRight/PowerBar.value = amount

func ui_depth_set(amount : int):
	$TopRight/DepthCount.text = String(amount) + " m"

func ui_points_set(amount : int):
	$BottomRight/PointsCount.text = String(amount)
