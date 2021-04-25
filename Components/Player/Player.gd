extends KinematicBody2D

signal score_changed
signal power_changed
signal power_reset
signal grapple_called

const EXPECTED_FPS = 60
const move_incr = 0.2
const move_speed = 3
const LAUNCH_SPEED = 10
const gravity_in_grapple_mult = 0.25
const velocity_grappling_mult = 0.1
var velocity = Vector2(0,0)
var gravity = .1
var friction_divider = 5
var bounce_friction_divider = 3
var cur_state = "default"
var player_has_initial_touch = false
var can_grapple = false
var grapple_started = false
var grapple_target_pos : Vector2
var is_diving = false
var can_input = true
	
func _process(delta):
	#Play sprite animation on state change
	if is_diving:
		cur_state = "dive"
	elif can_grapple:
		cur_state = "air"
	elif velocity.y > 0:
		cur_state = "down"
	else:
		cur_state = "up"
	$AnimatedSprite.play(cur_state)
		
	#Flip the sprite for direction moved
	# if sign(velocity.x) != 0:
	#	$AnimatedSprite.flip_h = velocity.x > 0
	if sign(velocity.x) > 0:
		$AnimatedSprite.flip_h = true
	elif sign(velocity.x) < 0:
		$AnimatedSprite.flip_h = false
	
func _physics_process(delta):
	var delta_move = EXPECTED_FPS * delta
	var delta_move_speed = move_speed*delta_move 
	#UNCOMMENT this out if you want to slow movement speed in air while grappling
	#*(velocity_grappling_mult if grapple_started else 1)
	var gravity_speed = gravity * delta_move
	
	# Show Aiming line while launching downwards
	if can_input:
		if Input.is_action_pressed("ui_click"):
			#$GrappleLine.points[1] = $GrappleLine.points[0]
			if can_grapple && Input.is_action_just_pressed("ui_click"):
				grapple_started = true
				velocity = velocity*velocity_grappling_mult
			if grapple_started:
				$AimLine.points[1] = get_local_mouse_position()
		else:
			$AimLine.points[1] = $AimLine.points[0]
			if Input.is_action_just_released("ui_click"):
				if grapple_started:
					player_has_initial_touch = true
					#is_diving = true
					
					emit_signal("grapple_called")
					$GrappleLine.points[1] = $GrappleLine.points[0]
	#				var line = get_local_mouse_position()
	#				grapple_target_pos = get_global_mouse_position()
	#				$GrappleLine.visible = true
	#				#print("mouse", get_local_mouse_position(), position, line)
	#				var line_dir = line.normalized()
	#				var line_length = line.length()
	#				velocity += LAUNCH_SPEED*delta_move*(line_dir)

				grapple_started = false
			#$GrappleLine.points[1] = to_local(grapple_target_pos)
	else:
		$AimLine.points[0] = $AimLine.points[0]
		$GrappleLine.points[1] = $GrappleLine.points[0]
	
	if can_input:
		#Moving left/right
		if Input.is_action_pressed("ui_left"):
				velocity.x = max(velocity.x - move_incr*delta_move, -delta_move_speed)
		elif Input.is_action_pressed("ui_right"):
				velocity.x = min(velocity.x + move_incr*delta_move, delta_move_speed)
			
	#Apply gravity
	#no gravity if player hasn't touched the char just yet
	if (player_has_initial_touch && can_grapple):
		#Reduced gravity in air while grappling
		if (grapple_started):
			velocity.y = velocity.y + gravity_in_grapple_mult*gravity
		#Full gravity
		else:
			velocity.y = velocity.y + gravity
	
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)

		if collision.collider.has_node("CookieTiles"):
			if is_diving:
				collision.collider.get_node("CookieTiles").explode(collision.position)
				
				#End of dive
				is_diving = false
				#Reset power
				emit_signal("power_reset")
				
				#Launch up
				velocity.y -= LAUNCH_SPEED
			
			#Keep launching up (so you don't go up slow)
			if velocity.y < 0:
				velocity.y -= LAUNCH_SPEED
			
			#Explosition should propulse char in opposite direction
			#velocity = 2*velocity
			
			#Erase Grapple target pos
#			grapple_target_pos = $GrappleLine.points[0]
#			$GrappleLine.points[1] = $GrappleLine.points[0]
	
	#Clamp velocity
	velocity = Vector2(clamp(velocity.x, -delta_move_speed, delta_move_speed), 
		clamp(velocity.y, -delta_move_speed, delta_move_speed))

	#Apply friction
	#velocity = velocity - delta_move*velocity/friction_divider


func _on_GrappleDetector_area_entered(area):
	if area.name == "CanGrappleArea":
		can_grapple = true

func _on_GrappleDetector_area_exited(area):
	if area.name == "CanGrappleArea":
		can_grapple = false

func _on_ItemCollector_area_entered(item : Grabber):
	if cur_state == "dive" || cur_state == "air" || cur_state == "down":
		var collected_item = item.collect()
		emit_signal("score_changed", collected_item.points)
		emit_signal("power_changed", collected_item.power)


func _on_Playspace_game_over():
	can_input = false