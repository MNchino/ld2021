extends KinematicBody2D

class_name Debris

signal debris_deleted
export(int) var sprite_frame = -1
export(bool) var active = true

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
	$Grabber.disable()
	if sprite_frame < 0:
		$Sprite.frame = randi() % (($Sprite.hframes * $Sprite.vframes))
	else:
		$Sprite.frame = sprite_frame
	
	if (active):
		start()
	

func activate():
	active = true
	call_deferred("enable_collision")
	start()
	
func enable_collision():
	$CollisionShape2D.disabled = false
	#$Grabber.monitorable = true
	
func start():
	modulate.a = .5
	
	spawn_time_start = rand_range(spawn_time_min, spawn_time_max)
	spawn_time = spawn_time_start
	
	spawn_speed_start = rand_range(spawn_speed_min, spawn_speed_max)
	spawn_speed = spawn_speed_start
	spawn_direction = Vector2(1,0).rotated(deg2rad(rand_range(-160, -20)))
	
	rotation_start = rand_range(-360, 360)
	rotation_end = rand_range(-360, 360)
	$Sprite.rotation_degrees = rotation_start
	
func set_sprite_frame (frame : int):
	$Sprite.frame = frame
	
func _physics_process(delta):
	var delta_move = EXPECTED_FPS * delta
	
	# Spawning movement
	# Kai I know you love to do this in GM
	# But Godot makes this so much easier with 
	# animation players >:(
	# But we keep it dw
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
			modulate.a = 1
			$Sprite.rotation_degrees = rotation_end
			$Grabber.enable()
			$Despawn.start()
			spawn_time = 0

#TODO: Add some nice UI to appear/Update a score
func _on_Grabber_collected():
	emit_signal("debris_deleted")
	queue_free()

func _on_Despawn_timeout():
	emit_signal("debris_deleted")
	queue_free()
