extends Node2D
class_name Dirt

signal next_dirt
signal next_count
var explosionResource = preload("res://Components/Explosion/Explosion.tscn")
var debrisCookieResource = preload("res://Components/Explosion/Debris/DebrisCookie.tscn")
var item_candy_resource = preload("res://Components/Items/CandyItem.tscn")
var cross_bomb_resource = preload("res://Components/Items/CrossBombItem.tscn")
var item_resources = [item_candy_resource, cross_bomb_resource]
var percent_remaining = 100
var tiles_remaining = 0
var min_cookie_until_next = 50
var total_tile_num
var tiles_floor = 15
const TILES_WIDE = 20
const TILES_TALL_PER_ITERATION = 6
const TILES_TOP_WIPE = 23
var noise = OpenSimplexNoise.new() # For generating candy spawns
const NOISE_PERIOD = 4
#The amount between -1 to -1 of noise we want to keep
#Note any noise > .5 is very rare
const NOISE_THRESHOLD = 0.4
const MAX_ITEMS_PER_LEVEL = 15 # The amount of candy we spawn at a time
#Set the number above to a really big num to spawn for all the noise coords
const MIN_ITEMS_PER_LEVEL = 10

func _ready():
	total_tile_num = TILES_WIDE*TILES_TALL_PER_ITERATION
	tiles_remaining = total_tile_num
	percent_remaining = 100
	
	#Configure item spawning mechanics
	noise.seed = randi()
	noise.period = NOISE_PERIOD
	spawn_items_over_tiles($CookieTiles.get_used_cells())

func spawn_items_over_tiles(tiles : Array):
	var item_targets = []
	for tile in tiles:
		if noise.get_noise_2dv(tile) > NOISE_THRESHOLD:
			item_targets.push_back(tile)
	
	for i in MIN_ITEMS_PER_LEVEL + randi()%(MAX_ITEMS_PER_LEVEL - MIN_ITEMS_PER_LEVEL):
		var num_potential_targets = item_targets.size()
		if !!num_potential_targets:
			var target_tile = item_targets[randi()%num_potential_targets]
			var target_resource = item_resources[randi()%item_resources.size()]
			var new_item = target_resource.instance()
			call_deferred("add_child_at_location", new_item, $CookieTiles.map_to_world(target_tile) + Vector2(4,4))
			item_targets.erase(target_tile)
			
			#Erase Ground under tile
#			$CookieTiles.set_cellv(target_tile, -1)
#			$CookieTiles.update_bitmask_area(target_tile)
		else:
			break
			
func add_child_at_location(child, location):
	add_child(child)
	child.position = location

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
	emit_signal("next_count", 100-percent_remaining)
	
	if percent_remaining <= min_cookie_until_next:
		emit_signal("next_dirt")

#Assumes there are cells defined at every integer coord in between
func get_cells_in_region(start,end):
	var cells = []
	for x in range(end.x - start.x):
		for y in range(end.y - start.y):
			cells.push_back(Vector2(start.x + x,start.y + y))
	return cells
	
func generate_tiles():
	var count = 0
	for i in range(TILES_WIDE):
		for j in range(TILES_TALL_PER_ITERATION):
			# Generate floor
			$CookieTiles.set_cellv(Vector2(i,j+tiles_floor), 0)
			count += 1
			# Wipe on top
			var pos = Vector2(i,j+tiles_floor-TILES_TOP_WIPE)
			if $CookieTiles.get_cellv(pos) != -1:
				$CookieTiles.set_cellv(pos, -1)
				tiles_remaining -= 1
	
	var start = Vector2(0, tiles_floor)
	var end = Vector2(TILES_WIDE-1, tiles_floor + TILES_TALL_PER_ITERATION)
	
	percent_remaining = 100
	total_tile_num = tiles_remaining + count
	#print(count, " | ", tiles_remaining, " | ", count + tiles_remaining)
	
	tiles_remaining = total_tile_num
	
	spawn_items_over_tiles(get_cells_in_region(start,end))
	$CookieTiles.update_bitmask_region(start, end)
	tiles_floor += TILES_TALL_PER_ITERATION
