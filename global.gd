extends Node

var points : int = 0
var depth : int = 0
var power : int = 1
const max_power : int = 10
var life : int = 3
const max_life : int = 5
var best : int = 0
var hard_mode = false

func _ready():
	randomize()
	OS.min_window_size = Vector2(320, 180)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(0.8))

func reset_stats():
	points = 0
	depth = 0
	power = 6
	life = 3
	
#It's 2 AM ok I'm allowed to be inconsistent
func reset_depth():
	depth = 0
	
func custom_clamp(target, minV, maxV):
	if target < minV:
		return minV
	elif target > maxV:
		return maxV
	else:
		return target

#totally not copied pls dont' call the police kai
func gaussian(mean, deviation):

	var x1 = null
	var x2 = null
	var w = null

	while true:

		x1 = rand_range(0, 2) - 1
		x2 = rand_range(0, 2) - 1
		w = x1*x1 + x2*x2

		if 0 < w && w < 1:
			break

	w = sqrt(-2 * log(w)/w)

	return floor(mean + deviation * x1 * w)
