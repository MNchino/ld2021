extends KinematicBody2D

const EXPECTED_FPS = 60
const move_incr = 1*EXPECTED_FPS
const move_speed = 10*EXPECTED_FPS
var velocity = Vector2(0,0)
var gravity = 0.1*EXPECTED_FPS
var friction_divider = 5
var bounce_friction_divider = 3
var STATE = "default"
var player_has_touched = false
var explosionResource = preload("res://Explosion.tscn")
	
func _process(delta):
	#Play sprite animation on state change
	if velocity.y > 0:
		$AnimatedSprite.play("down")
	else:
		$AnimatedSprite.play("up")
		
	#Flip the sprite for direction moved
	if sign(velocity.x) > 0:
		$AnimatedSprite.flip_h = true
	elif sign(velocity.x) < 0:
		$AnimatedSprite.flip_h = false
	
func _physics_process(delta):
	# Show Aiming line while launching downwards
	if Input.is_action_pressed("ui_click"):
		if Input.is_action_just_pressed("ui_click"):
			velocity = Vector2(0,0)
		$AimLine.points[1] = get_local_mouse_position()
	else:
		$AimLine.points[1] = $AimLine.points[0]
		if Input.is_action_just_released("ui_click"):
			player_has_touched = true
			var line = get_local_mouse_position()
			print("mouse", get_local_mouse_position(), position, line)
			var line_dir = line.normalized()
			var line_length = line.length()
			velocity += line_length*delta*EXPECTED_FPS*(line_dir)

	#Moving left/right
	if Input.is_action_pressed("ui_left"):
			velocity.x = min(velocity.x - move_incr, -move_speed)
	elif Input.is_action_pressed("ui_right"):
			velocity.x = max(velocity.x + move_incr, move_speed)
			
	#Apply gravity
	#no gravity if player hasn't touched the char just yet
	if (player_has_touched):
		velocity.y = velocity.y + gravity
	
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)
		#TODO: change this lazy chino
		if collision.collider.is_class("TileMap"):
			var tileMap : TileMap = collision.collider
			var explode = explosionResource.instance()
			#TODO: handle from tilemap
			tileMap.add_child(explode)
			explode.global_position = collision.position
			
			var tilePos = tileMap.world_to_map(tileMap.to_local(collision.position))
			print("deleting ", tilePos, collision.position)
			#From Kaiera: set_cellv uses local position for world_to_map
			tileMap.set_cellv(tilePos,-1)
			#Make it look nice :3
			tileMap.update_bitmask_area(tilePos)

	#Apply friction
	velocity = velocity - delta*EXPECTED_FPS*velocity/friction_divider
		
