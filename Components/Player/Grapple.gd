extends KinematicBody2D

const EXPECTED_FPS = 60
const GRAPPLE_SPEED = 20
var is_thrown = false
var is_retracting = false
var has_collided = false
var velocity = Vector2.ZERO

signal collided
signal obtained

func _ready():
	pass

func _process(delta):
	if visible:
		if not has_collided:
			var collision = move_and_collide(velocity * delta * EXPECTED_FPS)
			if collision:
				has_collided = true
				emit_signal("collided", collision.collider)

func throw(from : Vector2 , to : Vector2):
	is_thrown = true
	position = from
	var direction = position.direction_to(to)
	$Spoon.rotation = direction.angle() + deg2rad(45)
	velocity = direction * GRAPPLE_SPEED

func _on_PlayerDetector_body_entered(body):
	if has_collided:
		has_collided = false
		is_retracting = false
		is_thrown = false
		visible = false
		emit_signal("obtained")

func _on_Playspace_grapple_called(from):
	if not is_thrown:
		visible = true
		throw(from, get_global_mouse_position())