extends TileMap

signal exploded

func explode(position : Vector2):
	print("explod")
	emit_signal("exploded", position)
