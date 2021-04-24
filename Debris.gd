extends KinematicBody2D

const EXPECTED_FPS = 60
const spawn_time_min = 20
const spawn_time_max = 80
const spawn_speed_min = 100
const spawn_speed_max = 300

var spawn_time_start = 0
var spawn_time = 0

var spawn_speed_start = 0
var spawn_speed = 0
var spawn_direction = 0

var rotation_start = 0
var rotation_end = 0
var move_rotation = 0

func _ready():
	$Sprite.frame = randi() % (($Sprite.hframes * $Sprite.vframes))
	
	spawn_time_start = rand_range(spawn_time_min, spawn_time_max)
	spawn_time = spawn_time_start
	
	spawn_speed_start = rand_range(spawn_speed_min, spawn_speed_max)
	spawn_speed = spawn_speed_start
	spawn_direction = Vector2(1,0).rotated(deg2rad(rand_range(-160, -20)))
	
	rotation_start = rand_range(-360, 360)
	rotation_end = rand_range(-360, 360)
	$Sprite.rotation_degrees = rotation_start

	
func _physics_process(delta):
	var delta_move = EXPECTED_FPS * delta
	
	# Spawning movement
	if spawn_time > 0:
		spawn_time -= delta_move
		
		if spawn_time > 0:
			# Rotation
			var ease_time = 1 - ease(spawn_time / spawn_time_start, 2)
			$Sprite.rotation_degrees = lerp(rotation_start, rotation_end, ease_time)
			
			# Collision
			var speed = lerp(spawn_speed, 0, ease_time)
			var collision = move_and_collide(spawn_direction * (speed * delta))
			if collision:
				spawn_direction = spawn_direction.bounce(collision.normal)
			
		else:
			$Sprite.rotation_degrees = rotation_end
			spawn_time = 0

func _input(event):
	if Input.is_key_pressed(KEY_F6):
		get_tree().reload_current_scene()
