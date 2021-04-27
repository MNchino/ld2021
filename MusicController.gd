extends Node

var cur_playing

func switch_music(type):
	if type == "lobby":
		$LobbyPlayer.play()
		$GamePlayer.stop()
	elif type == "game":
		$LobbyPlayer.stop()
		$GamePlayer.play()
	cur_playing = type
