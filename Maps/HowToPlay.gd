extends Node

var pages = []
var page_num = 0
var page_max = 0

func _ready():
	pages = [$Page1, $Page2, $Page3, $Page4, $Page5, $Page7, $Page6]
	page_max = pages.size() - 1
	update_pages()

func _on_PlayButton_pressed():
	assert(get_tree().change_scene("res://Maps/Playspace.tscn") == OK)

func _on_SkipButton_pressed():
	if $GUI/SkipButton.text != "Sure?":
		$GUI/SkipButton/Timer.start(2)
		$GUI/SkipButton.text = "Sure?"
	else:
		assert(get_tree().change_scene("res://Maps/Playspace.tscn") == OK)

func _on_PrevButton_pressed():
	page_num -= 1
	update_pages()

func _on_NextButton_pressed():
	page_num += 1
	update_pages()

func update_pages():
	for i in range(pages.size()):
		pages[i].visible = page_num == i
		
	if page_num <= 0:
		$GUI/PrevButton.disabled = true
	elif page_num >= page_max:
		$GUI/NextButton.disabled = true
		$GUI/SkipButton.visible = false
		$GUI/PlayButton.visible = true
	else:
		$GUI/PrevButton.disabled = false
		$GUI/NextButton.disabled = false
		$GUI/SkipButton.visible = true
		$GUI/PlayButton.visible = false

func _on_Timer_timeout():
	$GUI/SkipButton.text = "Skip"

func _on_HomeButton_pressed():
	assert(get_tree().change_scene("res://Maps/TitleScreen.tscn") == OK)
