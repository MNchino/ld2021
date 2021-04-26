extends Node
signal score_changed
signal depth_changed
signal power_changed
signal life_changed
signal next_changed
signal grapple_called
signal game_over

var grapple_item_object = null
var grapple_item = false
var grapple_wall = false

func _ready():
	global.reset_stats()
	emit_signal("life_changed", global.life)
	emit_signal("power_changed", global.power)
	emit_signal("score_changed", global.points)
	emit_signal("depth_changed", global.depth)
	emit_signal("next_changed", 0)

func _on_Player_score_changed(new_score : int):
	global.points = new_score + global.points
	emit_signal("score_changed", global.points)

func _input(_event):
	if Input.is_key_pressed(KEY_F5):
		var _reload = get_tree().reload_current_scene()

func _physics_process(delta):
	#Update Depth as we reach it
	var new_depth = floor(max(0, ($Player.position.y - $CookieDirt.position.y)/8))
	if new_depth > global.depth:
		emit_signal("depth_changed", new_depth)
		global.depth = new_depth
		
	#Well, anchoring the grapple on the player make the grapple move
	#along the player so we're doing it here because it's a game jam
	#and we don't really have time to implement it better so we're doing jank
	if $Grapple.is_thrown:
		$Player/GrappleLine.points[1] = $Player/GrappleLine.to_local($Grapple.position)
		# Not at all efficient way to disable grabbing debris
		$Grapple.set_collision_mask_bit(2, $Player.is_grabbing_debris)
		$Grapple.set_collision_mask_bit(1, not $Player.is_grabbing_debris)
		$Grapple.set_collision_mask_bit(3, not $Player.is_grabbing_debris)
		
	if $Grapple.is_retracting:
		$Grapple.position = $Grapple.position.move_toward($Player.position, delta * $Grapple.EXPECTED_FPS * $Grapple.GRAPPLE_SPEED)
		
	if grapple_wall:
		$Player.velocity = $Player.position.direction_to($Grapple.position) * $Player.LAUNCH_SPEED * delta * $Player.EXPECTED_FPS
	
	if grapple_item:
		if is_instance_valid(grapple_item_object):
			grapple_item_object.position = grapple_item_object.get_parent().to_local($Grapple.position)

func _on_Player_power_changed(new_power : int):
	global.power = min(global.power + new_power, global.max_power)
	emit_signal("power_changed", global.power)

func _on_Player_life_changed(new_life : int):
	global.life = min(global.life + new_life, global.max_life)
	emit_signal("life_changed", global.life)

func _on_CookieDirt_next_count(new_next : int):
	emit_signal("next_changed", new_next)

func _on_Player_power_reset():
	if global.power <= 0:
		player_damaged()
	global.power = 0
	emit_signal("power_changed", global.power)

func _on_CookieDirt_next_dirt():
	$CookieDirt.generate_tiles()
	
	var anim = $AnimationPlayer.get_animation("MoveCameraDown")
	var trackId = anim.find_track("Camera:position:y")
	anim.bezier_track_set_key_value(trackId,0, $Camera.position.y)
	anim.bezier_track_set_key_value(trackId,1, $Camera.position.y + $CookieDirt.TILES_TALL_PER_ITERATION * 8)
	var trackId2 = anim.find_track("Walls:position:y")
	anim.bezier_track_set_key_value(trackId2,0, $Walls.position.y)
	anim.bezier_track_set_key_value(trackId2,1, $Walls.position.y + $CookieDirt.TILES_TALL_PER_ITERATION * 8)
	$AnimationPlayer.play("MoveCameraDown")
	
func _on_Player_grapple_called():
	emit_signal("grapple_called", $Player.position)
	$Player/GrappleLine.visible = true

func _on_Grapple_collided(collider : Node2D):
	if collider.has_node("Grabber"):
		grapple_item_object = collider
		grapple_item = true
		$Grapple.is_retracting = true
	else:
		grapple_wall = true
		if collider.has_node("CookieTiles"):
			$Player.is_diving = true

func _on_Grapple_obtained():
	$Player/GrappleLine.visible = false
	$Player.grapple_started = false
	
	if grapple_wall:
		grapple_wall = false
	if grapple_item:
		grapple_item = false
		if is_instance_valid(grapple_item_object):
			grapple_item_object.position = grapple_item_object.get_parent().to_local($Player.position)

func _on_Interface_game_quit():
	#global.reset_stats()
	var _transition = get_tree().change_scene("res://Maps/TitleScreen.tscn")

func _on_Interface_game_restart():
	#global.reset_stats()
	var _transition = get_tree().reload_current_scene()

func _on_Player_player_damaged():
	player_damaged()
	
func player_damaged():
	global.life -= 1
	$Camera.shake_start()
	emit_signal("life_changed", global.life)
	if (global.life <= 0):
		emit_signal("game_over")
