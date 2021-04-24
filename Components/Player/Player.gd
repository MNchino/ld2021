extends KinematicBody2D

const EXPECTED_FPS = 60
const move_incr = 1
const move_speed = 3
const LAUNCH_SPEED = 10
const gravity_in_grapple_mult = 0.25
const velocity_grappling_mult = 0.5
var velocity = Vector2(0,0)
var gravity = .1
var friction_divider = 5
var bounce_friction_divider = 3
var cur_state = "default"
var player_has_initial_touch = false
var can_grapple = false
var grapple_started = false
var is_diving = false
	
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
	var gravity_speed = gravity*delta_move
	
	# Show Aiming line while launching downwards
	if Input.is_action_pressed("ui_click"):
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
				is_diving = true
				var line = get_local_mouse_position()
				print("mouse", get_local_mouse_position(), position, line)
				var line_dir = line.normalized()
				var line_length = line.length()
				velocity += LAUNCH_SPEED*delta_move*(line_dir)
			grapple_started = false

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

		if collision.collider.get_node("CookieTiles"):
			collision.collider.get_node("CookieTiles").explode(collision.position)
			
			#End of dive
			is_diving = false
			
			#Explosition should propulse char in opposite direction
			#velocity = 2*velocity
	
	
	#Clamp velocity
	velocity = Vector2(clamp(velocity.x, -delta_move_speed, delta_move_speed), 
		clamp(velocity.y, -delta_move_speed, delta_move_speed))

	#Apply friction
#	velocity = velocity - delta_move*velocity/friction_divider
		


func _on_GrappleDetector_area_entered(area):
	can_grapple = true

func _on_GrappleDetector_area_exited(area):
	can_grapple = false

func _on_ItemCollector_area_entered(item : Grabber):
	item.collect()
