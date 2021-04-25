extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	#scale = 3.0*(float(global.power)/global.max_power)*Vector2(1,1)
	scale = 2*Vector2(1,1)
	
	$AnimationPlayer.play("Explode")
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
	pass # Replace with function body.


#This is when the explosion circle overlaps a cluster of tiles
func _on_Area2D_body_shape_entered(body_id, body, body_shape, local_shape):
	if !body.has_node("CookieTiles"):
		return
	
	var cookieTiles = body.get_node("CookieTiles")
	#HACK to set the cookie tiles that overlapped correctly
	#https://github.com/godotengine/godot-proposals/issues/2543
	var cell = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape)
	cookieTiles.set_cellv(cell, -1)
	
	#Make it look nice :3 (or cheese happens...)
	cookieTiles.update_bitmask_area(cell)
	
	#Update the stats of the dirt
	body.remove_tile()
