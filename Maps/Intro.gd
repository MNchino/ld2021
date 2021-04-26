extends Node

func _ready():
	$AnimationPlayer.play("meow")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		$AnimationPlayer.stop()
		assert(get_tree().change_scene("res://Maps/TitleScreen.tscn") == OK)
	
	var delta_move = 1 * delta
	$"Background/parallax-1".position.y += delta_move
	$"Background/parallax-2".position.y += delta_move
	delta_move = 2 * delta
	$"Background/parallax-3".position.y -= delta_move
	$"Background/parallax-4".position.y -= delta_move

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "meow":
		assert(get_tree().change_scene("res://Maps/TitleScreen.tscn") == OK)
