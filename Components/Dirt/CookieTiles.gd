extends TileMap

signal exploded

func explode(position : Vector2):
	emit_signal("exploded", position)
