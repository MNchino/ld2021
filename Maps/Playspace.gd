extends Node
signal score_changed
signal depth_changed
signal power_changed
signal life_changed
signal grapple_called

var grapple_item_object = null
var grapple_item = false
var grapple_wall = false

func _on_Player_score_changed(new_score : int):
	global.points = new_score + global.points
	emit_signal("score_changed", global.points)

func _input(_event):
	if Input.is_key_pressed(KEY_F5):
		get_tree().reload_current_scene()

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
		$Grapple.set_collision_mask_bit(2, $Player.can_grapple)
		
	if $Grapple.is_retracting:
		$Grapple.position = $Grapple.position.move_toward($Player.position, delta * $Grapple.EXPECTED_FPS * $Grapple.GRAPPLE_SPEED)
		# A silly bug fix for the rare time to save you from suddenly dealing with a floating spoon
		if $Grapple.position.distance_to($Player.position) < 5:
			$Grapple.position = $Player.position
		
	if grapple_wall:
		$Player.velocity = $Player.position.direction_to($Grapple.position) * $Player.LAUNCH_SPEED * delta * $Player.EXPECTED_FPS
	
	if grapple_item:
		if is_instance_valid(grapple_item_object):
			grapple_item_object.position = grapple_item_object.get_parent().to_local($Grapple.position)

func _on_Player_power_changed(new_power : int):
	global.power = global.power + new_power
	emit_signal("power_changed", global.power)

func _on_Player_power_reset():
	if global.power <= 0:
		global.life -= 1
		emit_signal("life_changed", global.life)
	global.power = 0
	emit_signal("power_changed", global.power)

func _on_CookieDirt_next_dirt():
	#print("calling next dirt")
	$CookieDirt.generate_tiles()
	$CookieDirt.position.y -= $CookieDirt.TILES_TALL_PER_ITERATION * 8
	$Player.position.y -= $CookieDirt.TILES_TALL_PER_ITERATION * 8

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
			#$Player.set_collision_mask_bit(1, false)

func _on_Grapple_obtained():
	$Player/GrappleLine.visible = false
	$Player.grapple_started = false
	
	if grapple_wall:
		grapple_wall = false
		#$Player.set_collision_mask_bit(1, true)
	if grapple_item:
		grapple_item = false
		# Snap to player if it fails to grab
		if is_instance_valid(grapple_item_object):
			grapple_item_object.position = grapple_item_object.get_parent().to_local($Player.position)
		
