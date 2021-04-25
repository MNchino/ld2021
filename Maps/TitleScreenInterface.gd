extends Control

func _ready():
	$Menu/HowToPlay.grab_focus()

func _on_Options_pressed():
	$Menu/Options.text = "Don't have time :c"

func _on_Exit_pressed():
	get_tree().quit()

func _on_HowToPlay_pressed():
	$Menu/HowToPlay.text = "Check LD48 Entry"

func _on_NewGame_pressed():
	assert(get_tree().change_scene("res://Maps/Playspace.tscn") == OK)

func _on_LudumDare_pressed():
	var _err = OS.shell_open("https://ldjam.com/events/ludum-dare/48/$245148")
