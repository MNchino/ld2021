extends Control

var options_pressed = false

func _ready():
	$Menu/HowToPlay.grab_focus()
	$Menu/Options/OptionsPanel/VBoxContainer/PanelContainer2/HBoxContainer/HardMode.pressed = global.hard_mode
	if MusicController.cur_playing != "lobby":
		MusicController.switch_music("lobby")

func _on_Options_pressed():
	if !$AnimationPlayer.is_playing():
		if !options_pressed:
			$AnimationPlayer.play("DisplayOptions")
		else:
			$AnimationPlayer.play("DisplayOptionsReverse")
		options_pressed = !options_pressed

func _on_Exit_pressed():
	get_tree().quit()

func _on_HowToPlay_pressed():
	assert(get_tree().change_scene("res://Maps/HowToPlay.tscn") == OK)

func _on_NewGame_pressed():
	assert(get_tree().change_scene("res://Maps/Playspace.tscn") == OK)

func _on_LudumDare_pressed():
	var _err = OS.shell_open("https://ldjam.com/events/ludum-dare/48/$245148")

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))
	$TestAudio.play()

func _on_CheckBox_toggled(button_pressed):
	global.hard_mode = button_pressed
	print("hard is ", global.hard_mode)
