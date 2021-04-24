extends Node2D
var explosionResource = preload("res://Components/Explosion/Explosion.tscn")
var debrisCandyResource = preload("res://Components/Explosion/Debris/DebrisCandy.tscn")
var debrisCookieResource = preload("res://Components/Explosion/Debris/DebrisCookie.tscn")


func _on_CookieTiles_exploded(pos : Vector2):
	#Create explosion instance
	var explode = explosionResource.instance()
	add_child(explode)
	explode.global_position = pos
	
	#Create debris
	var debris = debrisCookieResource.instance()
	add_child(debris)
	debris.global_position = pos

