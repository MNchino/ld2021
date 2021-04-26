extends Node2D
class_name Dirt

signal next_dirt
signal next_count
var explosionResource = preload("res://Components/Explosion/Explosion.tscn")
var debrisCookieResource = preload("res://Components/Explosion/Debris/DebrisCookie.tscn")
var item_candy_resource = preload("res://Components/Items/CandyItem.tscn")
var item_health_resource = preload("res://Components/Items/HealthItem.tscn")
var cross_bomb_resource = preload("res://Components/Items/CrossBombItem.tscn")
var item_resources = [item_candy_resource, item_health_resource, cross_bomb_resource]
var percent_remaining = 100
var tiles_remaining = 0
var min_cookie_until_next = 50
var total_tile_num
var tiles_floor = 15
var next_floor_to_clear = []
const TILES_WIDE = 20
const TILES_TALL_PER_ITERATION = 6
const TILES_TOP_WIPE = 23
var noise = OpenSimplexNoise.new() # For generating candy spawns
const NOISE_PERIOD = 4
#The amount between -1 to -1 of noise we want to keep
#Note any noise > .5 is very rare
var INIT_NOISE_THRESHOLD = 0.4
var noise_threshold = INIT_NOISE_THRESHOLD
var max_items_per_level = 15 # The amount of candy we spawn at a time
#Set the number above to a really big num to spawn for all the noise coords
var min_items_per_level = 10
const LEVEL_RARITIES = [
	#Candy, health, bomb
	#Shufflebag
	#UNCOMMENT to use levels
#	[100,3,0],
#	[110,3,0],
#	[110,3,2],
#	[110,3,6],
	[120,3,16],
#	[120,3,32],
#	[120,3,64],
#	[120,6,128],
#	[120,6,256],
#	[120,6,512],
#	[120,36,1024],
#	[0,0,1],
]

func _ready():
	total_tile_num = TILES_WIDE*TILES_TALL_PER_ITERATION
	tiles_remaining = total_tile_num
	percent_remaining = 100
	
	#Configure item spawning mechanics
	noise.seed = randi()
	noise.period = NOISE_PERIOD
	global.reset_depth()
	spawn_items_over_tiles($CookieTiles.get_used_cells())

func spawn_items_over_tiles(tiles : Array):
	
	#Adjust difficulty based on depth
	var level = (global.depth%12)
	#noise_threshold = max(-1, INIT_NOISE_THRESHOLD - level*0.02)
	
	var item_targets = []
	for tile in tiles:
		if noise.get_noise_2dv(tile) > noise_threshold:
			item_targets.push_back(tile)
	
	for i in min_items_per_level + level*10 + randi()%(max_items_per_level - min_items_per_level):
		var num_potential_targets = item_targets.size()
		if !!num_potential_targets:
			var target_tile = item_targets[randi()%num_potential_targets]
			var target_resource = get_rand_resource_by_level(level)
			var new_item = target_resource.instance()
			call_deferred("add_child_at_location", new_item, $CookieTiles.map_to_world(target_tile) + Vector2(4,4))
			item_targets.erase(target_tile)
			
			#Erase Ground under tile
#			$CookieTiles.set_cellv(target_tile, -1)
#			$CookieTiles.update_bitmask_area(target_tile)
		else:
			break

func arr_sum(arr : Array):
	var sum = 0
	for el in arr:
		sum += el
	return sum
	
func find_cont_index_in_arr(arr : Array, point : float):
	var cur_sum = 0
	for i in range(arr.size()):
		if clamp(point, cur_sum, cur_sum + arr[i]) == point:
			return i
		cur_sum = cur_sum + arr[i]
	return arr.size() - 1
			
func get_rand_resource_by_level(level : int):
	var actual_level = clamp(level,0,LEVEL_RARITIES.size() - 1)
	var choice = randf()*arr_sum(LEVEL_RARITIES[actual_level])
	var choice_index = find_cont_index_in_arr(LEVEL_RARITIES[actual_level], choice)
	return item_resources[choice_index]
			
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
	
	var min_percent = 0.01 * min_cookie_until_next
	var tiles_until_next = total_tile_num * min_percent
	var tiles_left_until_next = tiles_remaining - tiles_until_next
	var percent_needed = 100 - ceil(100 * tiles_left_until_next / tiles_until_next)
	
	emit_signal("next_count", percent_needed)
	
	if percent_remaining <= min_cookie_until_next:
		emit_signal("next_dirt")

#Assumes there are cells defined at every integer coord in between
func get_cells_in_region(start,end):
	var cells = []
	for x in range(end.x - start.x):
		for y in range(end.y - start.y):
			cells.push_back(Vector2(start.x + x,start.y + y))
	return cells
	
func clear_excess_tiles_on_top():
	var cur_floor_to_cleanup = next_floor_to_clear.pop_front()
	if cur_floor_to_cleanup:
		for i in range(TILES_WIDE):
			for j in range(TILES_TALL_PER_ITERATION):
				# Wipe on top
				var pos = Vector2(i,j+cur_floor_to_cleanup)
				if $CookieTiles.get_cellv(pos) != -1:
					$CookieTiles.set_cellv(pos, -1)
				
	
func generate_tiles():
	next_floor_to_clear.push_back(tiles_floor-TILES_TOP_WIPE)
	var count = 0
	for i in range(TILES_WIDE):
		for j in range(TILES_TALL_PER_ITERATION):
			# Generate floor
			$CookieTiles.set_cellv(Vector2(i,j+tiles_floor), 0)
			count += 1
			# Wipe on top
			var pos = Vector2(i,j+tiles_floor-TILES_TOP_WIPE)
			if $CookieTiles.get_cellv(pos) != -1:
				#$CookieTiles.set_cellv(pos, -1) #Deprecated, moved to separate func
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
