extends KinematicBody2D

const EXPECTED_FPS = 60
const move_incr = 1*EXPECTED_FPS
const move_speed = .1*EXPECTED_FPS
var velocity = Vector2(0,0)
var gravity = 0.0*EXPECTED_FPS
var friction_divider = 5
var bounce_friction_divider = 3
var STATE = "default"
var player_has_touched = false
var can_grapple = false
var grapple_started = false
	
func _process(delta):
	#Play sprite animation on state change
	if velocity.y > 0:
		$AnimatedSprite.play("down")
	else:
		$AnimatedSprite.play("up")
		
	#Flip the sprite for direction moved
	# if sign(velocity.x) != 0:
	#	$AnimatedSprite.flip_h = velocity.x > 0
	if sign(velocity.x) > 0:
		$AnimatedSprite.flip_h = true
	elif sign(velocity.x) < 0:
		$AnimatedSprite.flip_h = false
	
func _physics_process(delta):
	# Show Aiming line while launching downwards
	if Input.is_action_pressed("ui_click"):
		if can_grapple && Input.is_action_just_pressed("ui_click"):
			grapple_started = true
			velocity = Vector2(0,0)
		if grapple_started:
			$AimLine.points[1] = get_local_mouse_position()
	else:
		$AimLine.points[1] = $AimLine.points[0]
		if Input.is_action_just_released("ui_click"):
			if grapple_started:
				player_has_touched = true
				var line = get_local_mouse_position()
				print("mouse", get_local_mouse_position(), position, line)
				var line_dir = line.normalized()
				var line_length = line.length()
				velocity += line_length*delta*EXPECTED_FPS*(line_dir)
			grapple_started = false

	#Moving left/right
	if Input.is_action_pressed("ui_left"):
			velocity.x = max(velocity.x - move_incr, -move_speed)
	elif Input.is_action_pressed("ui_right"):
			velocity.x = min(velocity.x + move_incr, move_speed)
			
	#Apply gravity
	#no gravity if player hasn't touched the char just yet
	if (player_has_touched):
		velocity.y = velocity.y + gravity
	
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)

		if collision.collider.get_node("CookieTiles"):
			collision.collider.get_node("CookieTiles").explode(collision.position)
			
			#Explosition should propulse char in opposite direction
			velocity = 2*velocity
			
	velocity = Vector2(clamp(velocity.x, -move_speed, move_speed), clamp(velocity.y, -move_speed, move_speed))

	#Apply friction
#	velocity = velocity - delta*EXPECTED_FPS*velocity/friction_divider
		


func _on_GrappleDetector_area_entered(area):
	can_grapple = true

func _on_GrappleDetector_area_exited(area):
	can_grapple = false

func _on_ItemCollector_area_entered(item : Grabber):
	item.collect()
