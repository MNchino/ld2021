extends KinematicBody2D

signal score_changed
signal power_changed
signal life_changed
signal power_reset
signal grapple_called
signal player_damaged

const EXPECTED_FPS = 60
const move_incr = 0.2
const move_speed = 3
const LAUNCH_SPEED = 10
const gravity_in_grapple_mult = 0.25
const velocity_grappling_mult = 0.1
const AIM_COLOR = "915AD5"
const AIM_BAD_COLOR = "ff6666"
const COLLECT_COLOR = "6680ff"
const AIM_SIZE = 2
const COLLECT_SIZE = 1
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
var invulnerable = false
var is_grabbing_debris = false
var spontaneously_explode_when_stuck = false
	
func _process(_delta):
	#Play sprite animation on state change
	if not player_has_initial_touch:
		cur_state = "default"
	elif is_diving:
		cur_state = "dive"
	elif grapple_started:
		cur_state = "aim"
	elif can_grapple:
		cur_state = "air"
	elif velocity.y > 0:
		cur_state = "down"
	else:
		cur_state = "up"
	$AnimatedSprite.play(cur_state)
		
	#Flip the sprite for direction moved
	if sign(velocity.x) != 0:
		$AnimatedSprite.flip_h = velocity.x > 0
		
	#Change color of line depending on mode
	if Input.is_action_pressed("aim_left"):
		$AimLine.default_color = COLLECT_COLOR
		$AimLine.width = COLLECT_SIZE
	elif Input.is_action_pressed("aim_right"):
		$AimLine.default_color = AIM_COLOR if global.power > 0 else AIM_BAD_COLOR
		$AimLine.width = AIM_SIZE
	
func _physics_process(delta):
	var delta_move = EXPECTED_FPS * delta
	var delta_move_speed = move_speed*delta_move 
	#UNCOMMENT this out if you want to slow movement speed in air while grappling
	#*(velocity_grappling_mult if grapple_started else 1)
	#var gravity_speed = gravity * delta_move
	
	# Show Aiming line while launching downwards
	if can_input:
		if Input.is_action_pressed("aim"):
			#$GrappleLine.points[1] = $GrappleLine.points[0]
			#if can_grapple && Input.is_action_just_pressed("aim"):
			if cur_state != "up" && Input.is_action_just_pressed("aim"):
				grapple_started = true
				if can_grapple:
					velocity = velocity*velocity_grappling_mult
			if grapple_started:
				$AimLine.points[1] = get_local_mouse_position()
		else:
			$AimLine.points[1] = $AimLine.points[0]
			if Input.is_action_just_released("aim"):
				if grapple_started:
					is_grabbing_debris = Input.is_action_just_released("aim_left")
					if Input.is_action_just_released("aim_right"):
						player_has_initial_touch = true
					
					emit_signal("grapple_called")
					$GrappleLine.points[1] = $GrappleLine.points[0]
					
				grapple_started = false
	else:
		#No line drawing
		$AimLine.points[0] = $AimLine.points[0]
		$GrappleLine.points[1] = $GrappleLine.points[0]
	
	if can_input and player_has_initial_touch:
		#Moving left/right
		var dir = Vector2()
		dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		
		if dir.x != 0:
			velocity.x = velocity.x + (dir.x * (move_incr * delta_move))
			velocity.x = global.custom_clamp(velocity.x, -delta_move_speed, delta_move_speed)
		if dir.y != 0:
			if not is_diving:
				if dir.y < 0:
					if velocity.y > (delta_move * velocity_grappling_mult) and can_grapple:
						velocity.y = velocity.y - (move_incr * delta_move)
				else:
					velocity.y = velocity.y + (move_incr * delta_move)
			
	#Apply gravity
	#no gravity if player hasn't touched the char just yet
	if (player_has_initial_touch && can_grapple):
		#Reduced gravity in air while grappling
		if (grapple_started):
			velocity.y = velocity.y + gravity_in_grapple_mult * gravity
		#Full gravity
		else:
			velocity.y = velocity.y + gravity
	
	# Go down faster when outside of grapple area
	elif not can_grapple:
		if velocity.y > 0:
			velocity.y = velocity.y + gravity
	
	var collision = move_and_collide(velocity)
	if collision:
		var last_vel = velocity
		var did_bounce = false
		velocity = velocity.bounce(collision.normal)
		
		#Check if we did bounce against the wall
		did_bounce = abs(last_vel.x - velocity.x) > abs(last_vel.y - velocity.y)

		if collision.collider.has_node("CookieTiles"):
			
			if is_diving or spontaneously_explode_when_stuck:
				if spontaneously_explode_when_stuck:
					var temp_power = global.power
					global.power = -1
					collision.collider.get_node("CookieTiles").explode(collision.position)
					global.power = temp_power
				else:	
					collision.collider.get_node("CookieTiles").explode(collision.position)
					emit_signal("power_reset")
				
				#End of dive
				is_diving = false
				
				#Launch up
				velocity.y -= LAUNCH_SPEED
			
			#Keep launching up (so you don't go up slow)
			if velocity.y < 0:
				velocity.y -= LAUNCH_SPEED
			
			#Release key
			Input.action_release("ui_down")
			
		#Damp the x value
		if did_bounce:
			velocity.x = 0.25*velocity.x
		
	
	#Clamp velocity
	velocity = Vector2(global.custom_clamp(velocity.x, -delta_move_speed, delta_move_speed), 
		global.custom_clamp(velocity.y, -delta_move_speed, delta_move_speed * 2))

	#Apply friction
	#velocity = velocity - delta_move*velocity/friction_divider
	
	if invulnerable:
		self_modulate.a = rand_range(0.7,0.9)

func _on_GrappleDetector_area_entered(area):
	if area.name == "CanGrappleArea":
		can_grapple = true
		invulnerable = false
		self_modulate.a = 1
		
		if player_has_initial_touch:
			$Particles/Splash.restart()
			$Particles/Splash.emitting = true
			$Particles/Bubbles.emitting = false
			$AudioSplash.play()
			$AudioSplash.pitch_scale = rand_range(0.9,1)
			
	if area.name == "CanSpontaneouslyExplodeArea":
		spontaneously_explode_when_stuck = true

func _on_GrappleDetector_area_exited(area):
	if area.name == "CanGrappleArea":
		can_grapple = false
		$Particles/Splash.restart()
		$Particles/Splash.emitting = true
		$Particles/Bubbles.emitting = true
		$AudioSplash.play()
		$AudioSplash.pitch_scale = rand_range(1,1.1)
		
	if area.name == "CanSpontaneouslyExplodeArea":
		spontaneously_explode_when_stuck = false

func _on_ItemCollector_area_entered(item : Grabber):
	item_collected(item)

func item_collected(item : Grabber):
	var collected_item = item.collect()
	if collected_item.life != 0:
		emit_signal("life_changed", collected_item.life)
		$Particles/Hearts.emitting = true
		$AudioHeal.play()
	else:
		$AudioCollect.pitch_scale = rand_range(0.8,0.9) + (collected_item.power * 0.2)
		$AudioCollect.play()
		
		if global.power < global.max_power:
			if global.power + collected_item.power >= global.max_power:
				$AudioCollectMax.play()
	
	emit_signal("score_changed", collected_item.points)
	emit_signal("power_changed", collected_item.power)

func _on_Playspace_game_over():
	can_input = false

func _on_DamageDetector_area_entered(_area):
	if not invulnerable:
		invulnerable = true
		emit_signal("player_damaged")
	#print("PLAYER DAMAGED ", area.name)
	#TODO: PUT DEBUFFS HERE
