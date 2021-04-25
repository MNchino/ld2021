extends Node2D
class_name Dirt

signal next_dirt
var explosionResource = preload("res://Components/Explosion/Explosion.tscn")
var debrisCandyResource = preload("res://Components/Explosion/Debris/DebrisCandy.tscn")
var debrisCookieResource = preload("res://Components/Explosion/Debris/DebrisCookie.tscn")
var percent_remaining = 100
var tiles_remaining = 0
var min_cookie_until_next = 40
var total_tile_num
var tiles_floor = 15
const TILES_WIDE = 20
const TILES_TALL_PER_ITERATION = 6
const TILES_TOP_WIPE = 23

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
	percent_remaining = 100 * tiles_remaining / total_tile_num
	
	if percent_remaining <= min_cookie_until_next:
		emit_signal("next_dirt")
		percent_remaining = 100
		total_tile_num = tiles_remaining + (TILES_WIDE * TILES_TALL_PER_ITERATION)
		tiles_remaining = total_tile_num

func generate_tiles():
	for i in range(TILES_WIDE):
		for j in range(TILES_TALL_PER_ITERATION):
			$CookieTiles.set_cellv(Vector2(i,j+tiles_floor), 0)
			$CookieTiles.set_cellv(Vector2(i,j+tiles_floor-TILES_TOP_WIPE), -1)
	
	var start = Vector2(0, tiles_floor)
	var end = Vector2(TILES_WIDE-1, tiles_floor + TILES_TALL_PER_ITERATION)
	
	$CookieTiles.update_bitmask_region(start, end)
	tiles_floor += TILES_TALL_PER_ITERATION
