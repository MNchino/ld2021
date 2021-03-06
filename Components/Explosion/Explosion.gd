extends Node2D

#Tiles that we remove later to prevent crashing since we deal with the physics process
var tiles_to_remove = []
var tiles_to_process = 0
var target_body = null

const snd_explode_low = preload("res://Sound/explosion-low.wav")
const snd_explode_hi = preload("res://Sound/explosion-high.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = 3.0*(float(global.power)/global.max_power)*Vector2(1,1)
	#scale = 4*Vector2(1,1)
	
	var amount = max(global.power, 1)
	$Bubbles.amount = amount * $Bubbles.amount
	$Debris.amount = amount * $Debris.amount
	$Bubbles.emitting = true
	$Debris.emitting = true
	$Bubbles.scale = $Bubbles.scale / scale.x
	$Debris.scale = $Debris.scale / scale.x
	$Debris.emission_sphere_radius = $Debris.emission_sphere_radius * scale.x
	
	$AnimationPlayer.play("Explode")
	
	if global.power > 0:
		$AudioExplode.stream = snd_explode_low if global.power < 8 else snd_explode_hi
		$AudioExplode.volume_db = -3 + scale.x
		$AudioExplode.pitch_scale = rand_range(0.9, 1.2)
		$AudioExplode.play()


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
	pass # Replace with function body.
	
#Deletes all tiles at once so physics doesn't get confused
func process_tiles_to_remove():
	var cookieTiles = target_body.get_node("CookieTiles")
	for cell in tiles_to_remove:
		cookieTiles.set_cellv(cell, -1)
		#Make it look nice :3 (or cheese happens...)
		cookieTiles.update_bitmask_area(cell)
		#Update the stats of the dirt
		target_body.remove_tile()

func overlap_tile(body, body_shape):
	if !target_body:
		target_body = body
		
	var _cookieTiles = body.get_node("CookieTiles")
	#HACK to set the cookie tiles that overlapped correctly
	#https://github.com/godotengine/godot-proposals/issues/2543
	var cell = Physics2DServer.body_get_shape_metadata(body.get_rid(), body_shape)
	tiles_to_remove.push_back(cell)
	tiles_to_process -= 1
	if tiles_to_process <= 0:
		process_tiles_to_remove()

#This is when the explosion circle overlaps a cluster of tiles
func _on_Area2D_body_shape_entered(_body_id, body, body_shape, _local_shape):
	if !body.has_node("CookieTiles"):
		return
	tiles_to_process += 1
	call_deferred("overlap_tile", body, body_shape)
