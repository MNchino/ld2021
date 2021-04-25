extends Node2D
class_name Dirt

signal next_dirt
var explosionResource = preload("res://Components/Explosion/Explosion.tscn")
var debrisCandyResource = preload("res://Components/Explosion/Debris/DebrisCandy.tscn")
var debrisCookieResource = preload("res://Components/Explosion/Debris/DebrisCookie.tscn")
var percent_remaining = 100
var tiles_remaining = 0
var min_cookie_until_next = 0
var total_tile_num
const TILES_WIDE = 20
const TILES_TALL_PER_ITERATION = 6

func _ready():
	total_tile_num = TILES_WIDE*TILES_TALL_PER_ITERATION
	tiles_remaining = total_tile_num
	percent_remaining = 100
	
func _on_CookieTiles_exploded(pos : Vector2):
	#Create explosion instance
	var explode = explosionResource.instance()
	add_child(explode)
	explode.global_position = pos
	
	#Create debris
	
	#Don't question it, it just works
	var num_debris = 2 + abs(global.gaussian(0, 3.3))
	for i in num_debris:
		var debris = debrisCookieResource.instance()
		add_child(debris)
		debris.global_position = pos
	
func remove_tile():
	tiles_remaining -= 1
	percent_remaining = 100*tiles_remaining/total_tile_num
	print("remaining tiles", tiles_remaining," ", percent_remaining, "%")
	if percent_remaining <= min_cookie_until_next:
		emit_signal("next_dirt")
		percent_remaining = 100
		total_tile_num += TILES_WIDE*TILES_TALL_PER_ITERATION
		tiles_remaining = total_tile_num
