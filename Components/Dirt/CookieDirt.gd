extends Node2D
class_name Dirt

signal next_dirt
var explosionResource = preload("res://Components/Explosion/Explosion.tscn")
var debrisCandyResource = preload("res://Components/Explosion/Debris/DebrisCandy.tscn")
var debrisCookieResource = preload("res://Components/Explosion/Debris/DebrisCookie.tscn")
var percent_remaining = 100
var min_cookie_until_next = 40
var total_tile_num

func _ready():
	total_tile_num = $CookieTiles.get_used_cells().size()
	
func _on_CookieTiles_exploded(pos : Vector2):
	#Create explosion instance
	var explode = explosionResource.instance()
	add_child(explode)
	explode.global_position = pos
	
	#Create debris
	var debris = debrisCookieResource.instance()
	add_child(debris)
	debris.global_position = pos
	
func update_stats():
	percent_remaining = 100*$CookieTiles.get_used_cells().size()/total_tile_num
	if percent_remaining <= min_cookie_until_next:
		emit_signal("next_dirt")
